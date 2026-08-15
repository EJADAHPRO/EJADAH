import 'dart:async';
import 'dart:math';

import 'package:ejadah_models/ejadah_models.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';

import '../observability/logger.dart';
import '../services/token_service.dart';
import 'api_error.dart';
import 'context.dart';
import 'responses.dart';

/// Attaches a correlation id, the caller's language and their identity.
///
/// Authentication is middleware rather than a per-route concern because guests
/// are legitimate callers on most routes — the route decides whether to demand
/// a user, using [RequestContext.requireUser].
Middleware contextMiddleware(TokenService tokens) => (innerHandler) {
  final random = Random();
  return (request) {
    final correlationId =
        request.headers['x-correlation-id'] ??
        '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}'
            '${random.nextInt(1 << 20).toRadixString(36)}';

    String? userId;
    UserRole? role;
    final authorization = request.headers['authorization'];
    if (authorization != null && authorization.startsWith('Bearer ')) {
      final claims = tokens.verifyAccessToken(authorization.substring(7));
      if (claims != null) {
        userId = claims.userId;
        role = claims.role;
      }
    }

    final context = RequestContext(
      correlationId: correlationId,
      // Arabic is the default when nothing says otherwise.
      language: AppLanguage.fromCode(
        request.url.queryParameters['lang'] ??
            request.headers['x-ejadah-language'],
      ),
      userId: userId,
      role: role,
      deviceToken: request.headers['x-device-token'],
    );

    return Future.sync(() => innerHandler(request.withContext(context))).then(
      (response) => response.change(
        headers: {'x-correlation-id': correlationId},
      ),
    );
  };
};

/// Turns every thrown failure into the approved error envelope.
///
/// An unexpected error is logged in full and returned as the approved server
/// copy — an internal message, SQL fragment or stack trace never reaches a user.
Middleware errorMiddleware(AppLogger logger) => (innerHandler) {
  return (request) async {
    try {
      return await innerHandler(request);
    } on ApiException catch (error) {
      final log = logger.withCorrelationId(request.ctx.correlationId);
      if (error.code == ApiErrorCode.unexpected) {
        log.error('request failed', {
          'path': request.url.path,
          'code': error.code.wire,
          'detail': error.details,
        });
      } else {
        log.info('request rejected', {
          'path': request.url.path,
          'code': error.code.wire,
          'detail': error.details,
        });
      }
      return Json.error(error);
    } on ServerException catch (error, stackTrace) {
      // Database-level failures that the repository layer did not translate.
      final translated = _translatePostgresError(error);
      logger.withCorrelationId(request.ctx.correlationId).error(
        'database error',
        {'path': request.url.path, 'sqlstate': error.code},
        error,
        stackTrace,
      );
      return Json.error(translated);
    } catch (error, stackTrace) {
      logger
          .withCorrelationId(request.ctx.correlationId)
          .error(
            'unhandled error',
            {'path': request.url.path},
            error,
            stackTrace,
          );
      return Json.error(
        ApiException(ApiErrorCode.unexpected, details: error.toString()),
      );
    }
  };
};

/// Maps the two PostgreSQL states the product depends on onto product states.
ApiException _translatePostgresError(ServerException error) => switch (error.code) {
  // 23P01 exclusion_violation — two callers raced for the same slot and the
  // database refused the second. This is the booking guarantee firing.
  '23P01' => ApiException.conflict(message: ApiErrorCopy.slotTaken),
  // 23505 unique_violation.
  '23505' => ApiException.conflict(),
  _ => ApiException(ApiErrorCode.unexpected, details: error.message),
};

/// One structured log line per request, with its duration.
Middleware loggingMiddleware(AppLogger logger) => (innerHandler) {
  return (request) async {
    final started = DateTime.now();
    final response = await innerHandler(request);
    logger.withCorrelationId(request.ctx.correlationId).info('request', {
      'method': request.method,
      'path': '/${request.url.path}',
      'status': response.statusCode,
      'ms': DateTime.now().difference(started).inMilliseconds,
      'user': request.ctx.userId,
    });
    return response;
  };
};

/// A fixed-window rate limiter held in memory.
///
/// Applied to the routes that are worth attacking: sign-in, registration,
/// password reset, e-mail verification and uploads. A single-process limiter is
/// the right size for a modular monolith; moving to a shared store is a
/// deployment concern, documented in `docs/security.md`.
class RateLimiter {
  RateLimiter({required this.limit, required this.window});

  final int limit;
  final Duration window;

  final Map<String, _Window> _windows = {};

  /// Returns null when the call is allowed, or the wait before retrying.
  Duration? consume(String key, {DateTime? now}) {
    final at = now ?? DateTime.now().toUtc();
    final existing = _windows[key];

    if (existing == null || at.isAfter(existing.resetsAt)) {
      _windows[key] = _Window(count: 1, resetsAt: at.add(window));
      _sweep(at);
      return null;
    }

    if (existing.count >= limit) return existing.resetsAt.difference(at);

    _windows[key] = _Window(count: existing.count + 1, resetsAt: existing.resetsAt);
    return null;
  }

  void reset() => _windows.clear();

  void _sweep(DateTime now) {
    if (_windows.length < 2048) return;
    _windows.removeWhere((_, window) => now.isAfter(window.resetsAt));
  }
}

class _Window {
  const _Window({required this.count, required this.resetsAt});

  final int count;
  final DateTime resetsAt;
}

/// Rejects a caller that exceeds [limiter] for the given [scope].
///
/// Keyed by the caller's identity where known and their address otherwise, so
/// one abusive client cannot lock out everyone behind the same proxy.
Middleware rateLimitMiddleware(
  RateLimiter limiter, {
  required String scope,
}) => (innerHandler) {
  return (request) async {
    final identity =
        request.ctx.userId ??
        request.headers['x-forwarded-for']?.split(',').first.trim() ??
        'anonymous';
    final wait = limiter.consume('$scope:$identity');
    if (wait != null) {
      throw ApiException(ApiErrorCode.rateLimit, retryAfter: wait);
    }
    return innerHandler(request);
  };
};

/// CORS for Flutter Web.
///
/// The allowed origin is explicit rather than `*` because authenticated
/// requests carry a bearer token.
Middleware corsMiddleware(List<String> allowedOrigins) => (innerHandler) {
  return (request) async {
    final origin = request.headers['origin'];
    final allowed =
        origin != null &&
        (allowedOrigins.contains('*') || allowedOrigins.contains(origin));

    final headers = <String, String>{
      if (allowed) 'access-control-allow-origin': origin,
      'vary': 'origin',
      'access-control-allow-methods': 'GET, POST, PATCH, PUT, DELETE, OPTIONS',
      'access-control-allow-headers':
          'authorization, content-type, x-device-token, x-ejadah-language, '
          'x-correlation-id, idempotency-key',
      'access-control-max-age': '86400',
    };

    if (request.method == 'OPTIONS') return Response(204, headers: headers);
    final response = await innerHandler(request);
    return response.change(headers: headers);
  };
};

/// Security headers appropriate to a JSON API.
Middleware securityHeadersMiddleware() => (innerHandler) {
  return (request) async {
    final response = await innerHandler(request);
    return response.change(
      headers: {
        'x-content-type-options': 'nosniff',
        'x-frame-options': 'DENY',
        'referrer-policy': 'no-referrer',
        'strict-transport-security': 'max-age=31536000; includeSubDomains',
      },
    );
  };
};
