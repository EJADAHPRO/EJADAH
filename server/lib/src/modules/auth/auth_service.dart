import 'package:ejadah_models/ejadah_models.dart';
import 'package:postgres/postgres.dart';

import '../../config/config.dart';
import '../../db/database.dart';
import '../../http/api_error.dart';
import '../../observability/logger.dart';
import '../../services/mailer.dart';
import '../../services/password_hasher.dart';
import '../../services/token_service.dart';
import '../roadmap/roadmap_repository.dart';
import 'auth_repository.dart';
import 'validators.dart';

/// Identity use-cases.
///
/// Everything a route needs to do with an account happens here; routes only
/// parse input and shape the response.
class AuthService {
  AuthService({
    required Database database,
    required AuthRepository repository,
    required RoadmapRepository roadmaps,
    required PasswordHasher hasher,
    required TokenService tokens,
    required Mailer mailer,
    required AppConfig config,
    required AppLogger logger,
  }) : _database = database,
       _repository = repository,
       _roadmaps = roadmaps,
       _hasher = hasher,
       _tokens = tokens,
       _mailer = mailer,
       _config = config,
       _logger = logger;

  final Database _database;
  final AuthRepository _repository;
  final RoadmapRepository _roadmaps;
  final PasswordHasher _hasher;
  final TokenService _tokens;
  final Mailer _mailer;
  final AppConfig _config;
  final AppLogger _logger;

  static const Duration _verificationTtl = Duration(hours: 24);
  static const Duration _resetTtl = Duration(hours: 2);

  /// The 60-second resend cooldown, shown to the user as text.
  static const Duration resendCooldown = Duration(seconds: 60);

  /// Registers an account and adopts any guest work.
  ///
  /// [deviceToken] carries the guest's roadmap draft and generated roadmaps; a
  /// user who signs up at the gate must land on the same roadmap, full. Losing
  /// that work is a critical defect, so adoption happens in the same
  /// transaction as account creation.
  Future<AuthSession> register({
    required String email,
    required String password,
    required String fullNameEn,
    required String fullNameAr,
    required CareerStage stage,
    required AppLanguage language,
    String? deviceToken,
    String? referralCode,
    String? userAgent,
  }) async {
    final fieldErrors = <String, LocalizedText>{
      ...validateEmail(email),
      ...validatePassword(password),
      ...validateName(fullNameEn, fullNameAr, language),
    };
    if (fieldErrors.isNotEmpty) throw ApiException.validation(fieldErrors);

    final existing = await _repository.findByEmail(email);
    if (existing != null) {
      // Deliberately the same field-level message the client already shows for
      // a taken address: this route is authenticated-adjacent and enumeration
      // here is unavoidable, so it is rate-limited instead of obscured.
      throw ApiException.validation({'email': ValidationCopy.emailTaken});
    }

    final session = await _database.runTx((tx) async {
      final record = await _repository.createUser(
        email: email,
        passwordHash: _hasher.hash(password),
        fullNameEn: fullNameEn,
        fullNameAr: fullNameAr,
        stage: stage,
        language: language,
        referredByCode: referralCode,
        session: tx,
      );

      if (deviceToken != null && deviceToken.isNotEmpty) {
        await _roadmaps.adoptGuestWork(
          deviceToken: deviceToken,
          userId: record.id,
          session: tx,
        );
      }

      return _issueSession(record, userAgent: userAgent, session: tx);
    });

    await _sendVerificationCode(session.user, language);
    _logger.info('account created', {
      'user': session.user.id,
      'from_guest': deviceToken != null,
    });
    return session;
  }

  /// Signs in.
  ///
  /// A wrong password and an unknown address produce the identical failure, so
  /// the response cannot be used to discover which addresses have accounts.
  Future<AuthSession> login({
    required String email,
    required String password,
    String? deviceToken,
    String? userAgent,
  }) async {
    final record = await _repository.findByEmail(email);
    final verified =
        record != null &&
        _hasher.verify(password: password, encodedHash: record.passwordHash);

    await _repository.recordAuthAttempt(
      scope: 'login',
      identifier: email,
      succeeded: verified,
    );

    if (!verified) {
      // Spend comparable time on the unknown-address path so response timing
      // does not become the enumeration oracle the message avoids being.
      if (record == null) {
        _hasher.verify(password: password, encodedHash: _dummyHash);
      }
      throw ApiException.authentication(message: ValidationCopy.signInFailed);
    }

    return _database.runTx((tx) async {
      if (deviceToken != null && deviceToken.isNotEmpty) {
        await _roadmaps.adoptGuestWork(
          deviceToken: deviceToken,
          userId: record.id,
          session: tx,
        );
      }
      return _issueSession(record, userAgent: userAgent, session: tx);
    });
  }

  /// Rotates a refresh token.
  ///
  /// A token is single-use. Presenting one twice proves it leaked, so the whole
  /// rotation family is revoked and the caller must sign in again.
  Future<AuthSession> refresh({
    required String refreshToken,
    String? userAgent,
  }) async {
    final hash = TokenService.hashOpaqueToken(refreshToken);
    final record = await _repository.findRefreshToken(hash);

    if (record == null || record.isRevoked || record.isExpired) {
      throw ApiException.authentication();
    }

    if (record.isReplay) {
      await _repository.revokeFamily(record.familyId);
      _logger.warn('refresh token replay — family revoked', {
        'user': record.userId,
        'family': record.familyId,
      });
      throw ApiException.authentication();
    }

    final user = await _repository.findById(record.userId);
    if (user == null) throw ApiException.authentication();

    return _database.runTx((tx) async {
      await _repository.markRefreshTokenUsed(record.id, session: tx);
      return _issueSession(
        user,
        familyId: record.familyId,
        userAgent: userAgent,
        session: tx,
      );
    });
  }

  Future<void> logout(String refreshToken) =>
      _repository.revokeRefreshToken(TokenService.hashOpaqueToken(refreshToken));

  Future<void> logoutEverywhere(String userId) =>
      _repository.revokeAllRefreshTokens(userId);

  Future<AuthUser> currentUser(String userId) async {
    final record = await _repository.findById(userId);
    if (record == null) throw ApiException.authentication();
    return record.user;
  }

  /// Re-sends the verification code, honouring the 60-second cooldown.
  Future<Duration?> resendVerification(String userId) async {
    final record = await _repository.findById(userId);
    if (record == null) throw ApiException.authentication();
    if (record.user.emailVerified) return null;

    final lastSent = await _repository.lastVerificationSentAt(userId);
    if (lastSent != null) {
      final elapsed = DateTime.now().toUtc().difference(lastSent);
      if (elapsed < resendCooldown) return resendCooldown - elapsed;
    }

    await _sendVerificationCode(record.user, record.user.language);
    return null;
  }

  Future<void> verifyEmail(String code) async {
    final userId = await _repository.consumeEmailVerification(
      TokenService.hashOpaqueToken(code),
    );
    if (userId == null) {
      throw ApiException.validation({'code': ValidationCopy.codeDidNotMatch});
    }
    await _repository.markEmailVerified(userId);
  }

  /// Starts a password reset.
  ///
  /// Always reports success. Whether an address has an account is not something
  /// an unauthenticated caller gets to learn.
  Future<void> requestPasswordReset(String email, AppLanguage language) async {
    final record = await _repository.findByEmail(email);
    if (record == null) return;

    final token = _tokens.issueOpaqueToken();
    await _repository.storePasswordReset(
      userId: record.id,
      tokenHash: TokenService.hashOpaqueToken(token),
      expiresAt: DateTime.now().toUtc().add(_resetTtl),
    );

    await _mailer.sendPasswordReset(
      to: record.email,
      language: language,
      resetUrl: '${_config.publicBaseUrl}/reset-password?token=$token',
    );
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final errors = validatePassword(newPassword);
    if (errors.isNotEmpty) throw ApiException.validation(errors);

    final userId = await _repository.consumePasswordReset(
      TokenService.hashOpaqueToken(token),
    );
    if (userId == null) {
      throw ApiException.validation({'token': ValidationCopy.resetLinkExpired});
    }

    await _database.runTx((tx) async {
      await _repository.updatePassword(
        userId,
        _hasher.hash(newPassword),
        session: tx,
      );
      // A password change ends every other session — that is the point of it.
      await _repository.revokeAllRefreshTokens(userId, session: tx);
    });
  }

  Future<void> deleteAccount(String userId) async {
    await _repository.softDelete(userId);
    _logger.info('account deletion started', {'user': userId});
  }

  Future<AuthUser> setLanguage(String userId, AppLanguage language) async {
    await _repository.updateLanguage(userId, language);
    return currentUser(userId);
  }

  Future<AuthSession> _issueSession(
    UserRecord record, {
    String? familyId,
    String? userAgent,
    required Session session,
  }) async {
    final refresh = _tokens.issueRefreshToken();
    await _repository.storeRefreshToken(
      userId: record.id,
      tokenHash: refresh.hash,
      // A fresh sign-in starts a new family; a rotation stays in its own.
      familyId: familyId ?? _newFamilyId(),
      expiresAt: refresh.expiresAt,
      userAgent: userAgent,
      session: session,
    );

    return AuthSession(
      user: record.user,
      tokens: AuthTokens(
        accessToken: _tokens.issueAccessToken(
          userId: record.id,
          role: record.user.role,
        ),
        refreshToken: refresh.secret,
        expiresAt: _tokens.accessTokenExpiry(),
      ),
    );
  }

  Future<void> _sendVerificationCode(AuthUser user, AppLanguage language) async {
    final code = _tokens.issueNumericCode();
    await _repository.storeEmailVerification(
      userId: user.id,
      codeHash: TokenService.hashOpaqueToken(code),
      expiresAt: DateTime.now().toUtc().add(_verificationTtl),
    );
    await _mailer.sendVerificationCode(
      to: user.email,
      language: language,
      code: code,
    );
  }

  String _newFamilyId() => _tokens.issueOpaqueToken().substring(0, 22);

  /// A real Argon2id hash of a value no one uses, so the unknown-address path
  /// performs the same work as a wrong-password path.
  static const String _dummyHash =
      r'$argon2id$v=19$m=8,t=2,p=1$c29tZXNhbHRoZXJlMTI$4W5wZ3RlbXBoYXNoZHVtbXk';
}
