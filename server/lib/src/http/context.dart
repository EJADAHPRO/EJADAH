import 'package:ejadah_models/ejadah_models.dart';
import 'package:shelf/shelf.dart';

import 'api_error.dart';

/// Who is making a request.
///
/// A guest is a first-class caller: browsing everything, completing the roadmap
/// funnel and reading public profiles all happen without an account. Only the
/// five gates — the roadmap result, saving, booking, purchasing and Profile —
/// require [requireUser].
class RequestContext {
  const RequestContext({
    required this.correlationId,
    required this.language,
    this.userId,
    this.role,
    this.deviceToken,
  });

  final String correlationId;
  final AppLanguage language;
  final String? userId;
  final UserRole? role;

  /// Anonymous identifier that lets a guest keep a roadmap draft across app
  /// launches, and lets that work migrate to the account on sign-up.
  final String? deviceToken;

  bool get isAuthenticated => userId != null;

  bool get isAdmin => role == UserRole.admin;

  /// The signed-in user's id, or a 401 carrying the approved copy.
  String requireUser() {
    final id = userId;
    if (id == null) {
      throw ApiException.authentication(message: ApiErrorCopy.signInRequired);
    }
    return id;
  }

  /// Enforces a role on the server. Frontend visibility is never authorization.
  String requireRole(UserRole required) {
    final id = requireUser();
    if (role != required && role != UserRole.admin) {
      throw ApiException.authorization();
    }
    return id;
  }

  String requireAdmin() {
    final id = requireUser();
    if (role != UserRole.admin) throw ApiException.authorization();
    return id;
  }
}

const _contextKey = 'ejadah.context';

extension RequestContextAccess on Request {
  /// The context attached by [contextMiddleware].
  RequestContext get ctx => context[_contextKey] as RequestContext;

  Request withContext(RequestContext value) =>
      change(context: {_contextKey: value});
}
