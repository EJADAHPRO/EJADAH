import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../home/data/home_repository.dart';

/// Who is using the app right now.
///
/// A guest is a first-class state, not an absence of one: browsing, the roadmap
/// funnel and public profiles all work signed out, and the five gates are the
/// only places this matters.
sealed class AuthState {
  const AuthState();

  AuthUser? get user => switch (this) {
    Authenticated(:final user) => user,
    _ => null,
  };

  bool get isAuthenticated => user != null;
}

/// Startup: tokens are being restored. Nothing has been decided yet.
class AuthResolving extends AuthState {
  const AuthResolving();
}

class Guest extends AuthState {
  const Guest();
}

class Authenticated extends AuthState {
  const Authenticated(this.user);

  @override
  final AuthUser user;
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(tokenStoreProvider),
  ),
);

/// Talks to `/auth`. No widget calls the client directly.
class AuthRepository {
  const AuthRepository(this._client, this._tokens);

  final ApiClient _client;
  final TokenStore _tokens;

  Future<AuthSession> register({
    required String email,
    required String password,
    required String fullNameEn,
    required String fullNameAr,
    required CareerStage stage,
  }) async {
    final session = await _client.post(
      '/auth/register',
      body: {
        'email': email,
        'password': password,
        'full_name_en': fullNameEn,
        'full_name_ar': fullNameAr,
        'stage': stage.wire,
      },
      parse: AuthSession.fromJson,
    );
    await _tokens.save(session.tokens);
    return session;
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final session = await _client.post(
      '/auth/login',
      body: {'email': email, 'password': password},
      parse: AuthSession.fromJson,
    );
    await _tokens.save(session.tokens);
    return session;
  }

  Future<AuthUser> currentUser() =>
      _client.get('/auth/me', parse: AuthUser.fromJson);

  Future<void> logout() async {
    final refreshToken = await _tokens.refreshToken();
    if (refreshToken != null) {
      try {
        await _client.postVoid(
          '/auth/logout',
          body: {'refresh_token': refreshToken},
        );
      } on Failure {
        // Signing out must succeed locally even when the network does not.
      }
    }
    await _tokens.clear();
  }

  Future<void> requestPasswordReset(String email) =>
      _client.postVoid('/auth/forgot-password', body: {'email': email});

  Future<void> verifyEmail(String code) =>
      _client.postVoid('/auth/verify-email', body: {'code': code});

  /// Asks for a new code. Returns the remaining cooldown in seconds, which is
  /// zero when one was actually sent.
  Future<int> resendVerification() => _client.post(
    '/auth/verify-email/resend',
    parse: (json) => jsonInt(json['cooldown_seconds']) ?? 0,
  );
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthResolving();

  /// Resolves the stored session at startup.
  ///
  /// Deep links wait for this so a cold start navigates exactly once — a link
  /// that lands on a guest screen and then jumps again once auth resolves is
  /// the double-navigation the handoff calls out.
  Future<void> restore() async {
    final hasSession = await ref.read(tokenStoreProvider).hasRefreshToken();
    if (!hasSession) {
      state = const Guest();
      return;
    }

    try {
      state = Authenticated(
        await ref.read(authRepositoryProvider).currentUser(),
      );
    } on Failure {
      state = const Guest();
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullNameEn,
    required String fullNameAr,
    required CareerStage stage,
    bool fromGate = false,
  }) async {
    final session = await ref
        .read(authRepositoryProvider)
        .register(
          email: email,
          password: password,
          fullNameEn: fullNameEn,
          fullNameAr: fullNameAr,
          stage: stage,
        );
    state = Authenticated(session.user);

    await ref
        .read(analyticsProvider)
        .setUser(userId: session.user.id, persona: session.user.stage.wire);
    // The guest-first conversion proof. `ms_since_first_open` is stamped by the
    // dispatcher because this event is meaningless without it.
    await ref.read(analyticsProvider).track(AnalyticsEvents.accountCreated, {
      'from_gate': fromGate,
    });
  }

  Future<void> login({required String email, required String password}) async {
    final session = await ref
        .read(authRepositoryProvider)
        .login(email: email, password: password);
    state = Authenticated(session.user);
    await ref
        .read(analyticsProvider)
        .setUser(userId: session.user.id, persona: session.user.stage.wire);
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();

    // The offline cache holds this account's feed. Leaving it behind would show
    // one person's shortlist and sessions to whoever signs in next on the same
    // device.
    await ref
        .read(localStoreProvider)
        .clearCachedResponses(const [HomeRepository.cacheKey]);

    state = const Guest();
    await ref.read(analyticsProvider).setUser(userId: null, persona: null);
  }

  /// Re-reads the user after their email is confirmed, so every screen that
  /// keys off `emailVerified` updates at once.
  Future<void> refreshUser() async {
    try {
      state = Authenticated(
        await ref.read(authRepositoryProvider).currentUser(),
      );
    } on Failure {
      // The confirmation itself succeeded; a failed re-read is not worth
      // signing the user out over.
    }
  }

  /// Called when a refresh finally fails.
  void sessionExpired() => state = const Guest();
}
