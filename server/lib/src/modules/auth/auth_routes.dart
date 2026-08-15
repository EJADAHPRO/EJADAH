import 'package:ejadah_models/ejadah_models.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../http/api_error.dart';
import '../../http/context.dart';
import '../../http/middleware.dart';
import '../../http/responses.dart';
import 'auth_service.dart';

/// `/api/v1/auth` — registration, sign-in, session lifecycle.
///
/// Routes parse input and shape output. Every decision lives in [AuthService].
Router authRoutes(AuthService service, {int trustedProxyCount = 0}) {
  final router = Router();

  // Credential endpoints are the ones worth attacking, so each carries its own
  // limiter rather than sharing a global budget.
  final signInLimiter = RateLimiter(
    limit: 8,
    window: const Duration(minutes: 5),
  );
  final signUpLimiter = RateLimiter(
    limit: 5,
    window: const Duration(minutes: 15),
  );
  final resetLimiter = RateLimiter(
    limit: 4,
    window: const Duration(minutes: 15),
  );

  Handler limited(RateLimiter limiter, String scope, Handler handler) =>
      rateLimitMiddleware(
        limiter,
        scope: scope,
        trustedProxyCount: trustedProxyCount,
      )(handler);

  router.post(
    '/register',
    limited(signUpLimiter, 'register', (Request request) async {
      final body = await readJsonBody(request);
      final session = await service.register(
        email: _requireString(body, 'email'),
        password: _requireString(body, 'password'),
        fullNameEn: (body['full_name_en'] ?? body['full_name'] ?? '') as String,
        fullNameAr: (body['full_name_ar'] ?? body['full_name'] ?? '') as String,
        stage: CareerStage.fromWire(body['stage'] as String?),
        language: request.ctx.language,
        // Carries the guest's roadmap draft and results into the new account.
        deviceToken: request.ctx.deviceToken,
        referralCode: body['referral_code'] as String?,
        userAgent: request.headers['user-agent'],
      );
      return Json.created(session.toJson());
    }),
  );

  router.post(
    '/login',
    limited(signInLimiter, 'login', (Request request) async {
      final body = await readJsonBody(request);
      final session = await service.login(
        email: _requireString(body, 'email'),
        password: _requireString(body, 'password'),
        deviceToken: request.ctx.deviceToken,
        userAgent: request.headers['user-agent'],
      );
      return Json.ok(session.toJson());
    }),
  );

  router.post('/refresh', (Request request) async {
    final body = await readJsonBody(request);
    final session = await service.refresh(
      refreshToken: _requireString(body, 'refresh_token'),
      userAgent: request.headers['user-agent'],
    );
    return Json.ok(session.toJson());
  });

  router.post('/logout', (Request request) async {
    final body = await readJsonBody(request);
    final token = body['refresh_token'] as String?;
    if (token != null && token.isNotEmpty) await service.logout(token);
    return Json.noContent();
  });

  router.post('/logout-all', (Request request) async {
    await service.logoutEverywhere(request.ctx.requireUser());
    return Json.noContent();
  });

  router.get('/me', (Request request) async {
    final user = await service.currentUser(request.ctx.requireUser());
    return Json.ok(user.toJson());
  });

  router.patch('/me/language', (Request request) async {
    final body = await readJsonBody(request);
    final user = await service.setLanguage(
      request.ctx.requireUser(),
      AppLanguage.fromCode(body['language'] as String?),
    );
    return Json.ok(user.toJson());
  });

  router.post('/verify-email', (Request request) async {
    final body = await readJsonBody(request);
    await service.verifyEmail(_requireString(body, 'code'));
    return Json.noContent();
  });

  router.post('/verify-email/resend', (Request request) async {
    final wait = await service.resendVerification(request.ctx.requireUser());
    // The cooldown is reported as a number the UI renders as text — never a
    // disabled button with no explanation.
    return Json.ok({'cooldown_seconds': wait?.inSeconds ?? 0});
  });

  router.post(
    '/forgot-password',
    limited(resetLimiter, 'forgot', (Request request) async {
      final body = await readJsonBody(request);
      await service.requestPasswordReset(
        _requireString(body, 'email'),
        request.ctx.language,
      );
      // Always 204: whether an address has an account is not public knowledge.
      return Json.noContent();
    }),
  );

  router.post(
    '/reset-password',
    limited(resetLimiter, 'reset', (Request request) async {
      final body = await readJsonBody(request);
      await service.resetPassword(
        token: _requireString(body, 'token'),
        newPassword: _requireString(body, 'password'),
      );
      return Json.noContent();
    }),
  );

  router.delete('/me', (Request request) async {
    await service.deleteAccount(request.ctx.requireUser());
    return Json.noContent();
  });

  return router;
}

String _requireString(Map<String, dynamic> body, String key) {
  final value = body[key];
  if (value is! String || value.isEmpty) {
    throw ApiException(
      ApiErrorCode.validation,
      details: 'Missing required field "$key".',
    );
  }
  return value;
}
