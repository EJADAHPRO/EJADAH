import 'package:ejadah_models/ejadah_models.dart';
import 'package:postgres/postgres.dart';

import '../../db/database.dart';

/// A user row as the service layer needs it, including the password hash that
/// must never leave this layer.
class UserRecord {
  const UserRecord({
    required this.id,
    required this.email,
    required this.passwordHash,
    required this.user,
  });

  final String id;
  final String email;
  final String passwordHash;
  final AuthUser user;
}

/// All database access for identity. No SQL exists above this class.
class AuthRepository {
  const AuthRepository(this._database);

  final Database _database;

  static const String _userColumns = '''
    id, email, password_hash, full_name_en, full_name_ar, role, stage, language,
    email_verified_at, professional_status, is_premium, premium_renews_on,
    public_slug, avatar_url
  ''';

  Future<UserRecord?> findByEmail(String email, {Session? session}) async {
    final rows = await _query(
      'SELECT $_userColumns FROM users '
      'WHERE lower(email) = lower(@email) AND deleted_at IS NULL',
      {'email': email},
      session,
    );
    return rows.isEmpty ? null : _toRecord(rows.first);
  }

  Future<UserRecord?> findById(String id, {Session? session}) async {
    final rows = await _query(
      'SELECT $_userColumns FROM users WHERE id = @id AND deleted_at IS NULL',
      {'id': id},
      session,
    );
    return rows.isEmpty ? null : _toRecord(rows.first);
  }

  Future<UserRecord> createUser({
    required String email,
    required String passwordHash,
    required String fullNameEn,
    required String fullNameAr,
    required CareerStage stage,
    required AppLanguage language,
    String? referredByCode,
    Session? session,
  }) async {
    final rows = await _query(
      '''
      INSERT INTO users (
        email, password_hash, full_name_en, full_name_ar, stage, language,
        referred_by_code
      )
      VALUES (
        @email, @password_hash, @full_name_en, @full_name_ar, @stage::career_stage,
        @language, @referred_by_code
      )
      RETURNING $_userColumns
      ''',
      {
        'email': email.trim(),
        'password_hash': passwordHash,
        'full_name_en': fullNameEn,
        'full_name_ar': fullNameAr,
        'stage': stage.wire,
        'language': language.code,
        'referred_by_code': referredByCode,
      },
      session,
    );

    final record = _toRecord(rows.first);
    // Every account starts with all three notification categories on; the user
    // can switch each off separately in Settings.
    await _execute(
      'INSERT INTO notification_preferences (user_id) VALUES (@user_id) '
      'ON CONFLICT (user_id) DO NOTHING',
      {'user_id': record.id},
      session,
    );
    await _execute(
      'INSERT INTO profiles (user_id) VALUES (@user_id) '
      'ON CONFLICT (user_id) DO NOTHING',
      {'user_id': record.id},
      session,
    );
    return record;
  }

  Future<void> updatePassword(
    String userId,
    String passwordHash, {
    Session? session,
  }) => _execute(
    'UPDATE users SET password_hash = @hash, updated_at = now() WHERE id = @id',
    {'hash': passwordHash, 'id': userId},
    session,
  );

  Future<void> markEmailVerified(String userId, {Session? session}) => _execute(
    'UPDATE users SET email_verified_at = now(), updated_at = now() '
    'WHERE id = @id AND email_verified_at IS NULL',
    {'id': userId},
    session,
  );

  Future<void> updateLanguage(
    String userId,
    AppLanguage language, {
    Session? session,
  }) => _execute(
    'UPDATE users SET language = @language, updated_at = now() WHERE id = @id',
    {'language': language.code, 'id': userId},
    session,
  );

  /// Marks the account deleted, starting the stated 30-day undo window. Rows
  /// are retained until then, and tax-kept invoices are retained regardless.
  Future<void> softDelete(String userId, {Session? session}) async {
    await _execute(
      'UPDATE users SET deleted_at = now(), updated_at = now() WHERE id = @id',
      {'id': userId},
      session,
    );
    await revokeAllRefreshTokens(userId, session: session);
  }

  // --- Refresh tokens -------------------------------------------------------

  Future<void> storeRefreshToken({
    required String userId,
    required String tokenHash,
    required String familyId,
    required DateTime expiresAt,
    String? userAgent,
    Session? session,
  }) => _execute(
    '''
    INSERT INTO refresh_tokens (user_id, token_hash, family_id, expires_at, user_agent)
    VALUES (@user_id, @token_hash, @family_id, @expires_at, @user_agent)
    ''',
    {
      'user_id': userId,
      'token_hash': tokenHash,
      'family_id': familyId,
      'expires_at': expiresAt,
      'user_agent': userAgent,
    },
    session,
  );

  Future<RefreshTokenRecord?> findRefreshToken(
    String tokenHash, {
    Session? session,
  }) async {
    final rows = await _query(
      'SELECT id, user_id, family_id, expires_at, used_at, revoked_at '
      'FROM refresh_tokens WHERE token_hash = @hash',
      {'hash': tokenHash},
      session,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return RefreshTokenRecord(
      id: row.str('id'),
      userId: row.str('user_id'),
      familyId: row.str('family_id'),
      expiresAt: row.dateAt('expires_at'),
      usedAt: row.dateOrNull('used_at'),
      revokedAt: row.dateOrNull('revoked_at'),
    );
  }

  Future<void> markRefreshTokenUsed(String id, {Session? session}) => _execute(
    'UPDATE refresh_tokens SET used_at = now() WHERE id = @id',
    {'id': id},
    session,
  );

  /// Revokes an entire rotation family.
  ///
  /// Called when a token is presented twice: replay means the token leaked, and
  /// the safe response is to end every session descended from it.
  Future<void> revokeFamily(String familyId, {Session? session}) => _execute(
    'UPDATE refresh_tokens SET revoked_at = now() '
    'WHERE family_id = @family_id AND revoked_at IS NULL',
    {'family_id': familyId},
    session,
  );

  Future<void> revokeRefreshToken(String tokenHash, {Session? session}) =>
      _execute(
        'UPDATE refresh_tokens SET revoked_at = now() '
        'WHERE token_hash = @hash AND revoked_at IS NULL',
        {'hash': tokenHash},
        session,
      );

  Future<void> revokeAllRefreshTokens(String userId, {Session? session}) =>
      _execute(
        'UPDATE refresh_tokens SET revoked_at = now() '
        'WHERE user_id = @user_id AND revoked_at IS NULL',
        {'user_id': userId},
        session,
      );

  // --- Verification and reset ----------------------------------------------

  Future<void> storeEmailVerification({
    required String userId,
    required String codeHash,
    required DateTime expiresAt,
    Session? session,
  }) => _execute(
    'INSERT INTO email_verifications (user_id, code_hash, expires_at) '
    'VALUES (@user_id, @code_hash, @expires_at)',
    {'user_id': userId, 'code_hash': codeHash, 'expires_at': expiresAt},
    session,
  );

  Future<DateTime?> lastVerificationSentAt(
    String userId, {
    Session? session,
  }) async {
    final rows = await _query(
      'SELECT created_at FROM email_verifications WHERE user_id = @user_id '
      'ORDER BY created_at DESC LIMIT 1',
      {'user_id': userId},
      session,
    );
    return rows.isEmpty ? null : rows.first.dateAt('created_at');
  }

  /// Consumes a verification code, returning the user it belonged to.
  ///
  /// The update is the check: an expired or already-consumed row matches
  /// nothing, so there is no read-then-write window.
  Future<String?> consumeEmailVerification(
    String codeHash, {
    Session? session,
  }) async {
    final rows = await _query(
      '''
      UPDATE email_verifications SET consumed_at = now()
      WHERE code_hash = @hash AND consumed_at IS NULL AND expires_at > now()
      RETURNING user_id
      ''',
      {'hash': codeHash},
      session,
    );
    return rows.isEmpty ? null : rows.first.str('user_id');
  }

  Future<void> storePasswordReset({
    required String userId,
    required String tokenHash,
    required DateTime expiresAt,
    Session? session,
  }) => _execute(
    'INSERT INTO password_resets (user_id, token_hash, expires_at) '
    'VALUES (@user_id, @token_hash, @expires_at)',
    {'user_id': userId, 'token_hash': tokenHash, 'expires_at': expiresAt},
    session,
  );

  Future<String?> consumePasswordReset(
    String tokenHash, {
    Session? session,
  }) async {
    final rows = await _query(
      '''
      UPDATE password_resets SET consumed_at = now()
      WHERE token_hash = @hash AND consumed_at IS NULL AND expires_at > now()
      RETURNING user_id
      ''',
      {'hash': tokenHash},
      session,
    );
    return rows.isEmpty ? null : rows.first.str('user_id');
  }

  // --- Rate-limit bookkeeping ----------------------------------------------

  Future<void> recordAuthAttempt({
    required String scope,
    required String identifier,
    required bool succeeded,
    Session? session,
  }) => _execute(
    'INSERT INTO auth_attempts (scope, identifier, succeeded) '
    'VALUES (@scope, @identifier, @succeeded)',
    {
      'scope': scope,
      'identifier': identifier.toLowerCase(),
      'succeeded': succeeded,
    },
    session,
  );

  Future<int> failedAttemptsSince({
    required String scope,
    required String identifier,
    required DateTime since,
    Session? session,
  }) async {
    final rows = await _query(
      'SELECT count(*) AS failures FROM auth_attempts '
      'WHERE scope = @scope AND identifier = @identifier '
      'AND succeeded = false AND occurred_at > @since',
      {'scope': scope, 'identifier': identifier.toLowerCase(), 'since': since},
      session,
    );
    return rows.first.intAt('failures');
  }

  // --- Helpers --------------------------------------------------------------

  Future<List<Map<String, dynamic>>> _query(
    String sql,
    Map<String, Object?> parameters,
    Session? session,
  ) async {
    Future<Result> run(Session s) =>
        s.execute(Sql.named(sql), parameters: parameters);
    final result = session != null
        ? await run(session)
        : await _database.run(run);
    return result.map((row) => row.toColumnMap()).toList();
  }

  Future<void> _execute(
    String sql,
    Map<String, Object?> parameters,
    Session? session,
  ) async {
    await _query(sql, parameters, session);
  }

  UserRecord _toRecord(Map<String, dynamic> row) => UserRecord(
    id: row.str('id'),
    email: row.str('email'),
    passwordHash: row.str('password_hash'),
    user: AuthUser(
      id: row.str('id'),
      email: row.str('email'),
      fullName: LocalizedText(
        en: row.str('full_name_en'),
        ar: row.str('full_name_ar'),
      ),
      role: UserRole.fromWire(row.str('role')),
      stage: CareerStage.fromWire(row.str('stage')),
      language: AppLanguage.fromCode(row.str('language')),
      emailVerified: row.dateOrNull('email_verified_at') != null,
      professionalStatus: ProfessionalStatus.fromWire(
        row.str('professional_status'),
      ),
      isPremium: row.boolAt('is_premium'),
      premiumRenewsOn: row.dateOrNull('premium_renews_on'),
      publicSlug: row.strOrNull('public_slug'),
      avatarUrl: row.strOrNull('avatar_url'),
    ),
  );
}

class RefreshTokenRecord {
  const RefreshTokenRecord({
    required this.id,
    required this.userId,
    required this.familyId,
    required this.expiresAt,
    required this.usedAt,
    required this.revokedAt,
  });

  final String id;
  final String userId;
  final String familyId;
  final DateTime expiresAt;
  final DateTime? usedAt;
  final DateTime? revokedAt;

  bool get isExpired => DateTime.now().toUtc().isAfter(expiresAt);

  bool get isRevoked => revokedAt != null;

  /// A second presentation of the same token. Treated as theft.
  bool get isReplay => usedAt != null;
}
