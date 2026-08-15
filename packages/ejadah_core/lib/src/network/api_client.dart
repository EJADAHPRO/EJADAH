import 'dart:async';
import 'dart:convert';

import 'package:ejadah_models/ejadah_models.dart';
import 'package:http/http.dart' as http;

import '../error/failures.dart';
import 'token_store.dart';

/// The single HTTP client.
///
/// Network calls are never made from a widget. Everything above this class
/// talks to a repository, which talks to this client — so authentication
/// headers, session refresh, timeouts, serialization and error translation are
/// each written once.
class ApiClient {
  ApiClient({
    required this.baseUrl,
    required TokenStore tokens,
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 20),
    AppLanguage Function()? language,
  }) : _tokens = tokens,
       _http = httpClient ?? http.Client(),
       _language = language ?? (() => AppLanguage.ar);

  final String baseUrl;
  final TokenStore _tokens;
  final http.Client _http;
  final Duration timeout;
  final AppLanguage Function() _language;

  /// Guards against a burst of 401s each starting its own refresh. The first
  /// caller refreshes; the rest await the same future.
  Future<AuthTokens?>? _inFlightRefresh;

  /// Called when a refresh finally fails, so the app can send the user to sign
  /// in — and bring them straight back afterwards.
  void Function()? onSessionExpired;

  Future<T> get<T>(
    String path, {
    Map<String, String>? query,
    required T Function(Map<String, dynamic>) parse,
  }) => _send(
    'GET',
    path,
    query: query,
    parse: parse,
  );

  Future<T> post<T>(
    String path, {
    Object? body,
    Map<String, String>? query,
    required T Function(Map<String, dynamic>) parse,
  }) => _send('POST', path, body: body, query: query, parse: parse);

  Future<T> put<T>(
    String path, {
    Object? body,
    required T Function(Map<String, dynamic>) parse,
  }) => _send('PUT', path, body: body, parse: parse);

  Future<T> patch<T>(
    String path, {
    Object? body,
    required T Function(Map<String, dynamic>) parse,
  }) => _send('PATCH', path, body: body, parse: parse);

  /// For endpoints that legitimately return no content.
  Future<void> delete(String path, {Object? body}) =>
      _send<void>('DELETE', path, body: body, parse: null);

  Future<void> putVoid(String path, {Object? body}) =>
      _send<void>('PUT', path, body: body, parse: null);

  Future<void> postVoid(String path, {Object? body}) =>
      _send<void>('POST', path, body: body, parse: null);

  Future<T> _send<T>(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
    T Function(Map<String, dynamic>)? parse,
    bool isRetryAfterRefresh = false,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: query?.isEmpty ?? true ? null : query,
    );

    late http.Response response;
    try {
      final request = http.Request(method, uri)
        ..headers.addAll(await _headers());
      if (body != null) request.body = jsonEncode(body);

      final streamed = await _http.send(request).timeout(timeout);
      response = await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw const NetworkFailure();
    } catch (_) {
      // A socket error, a DNS failure or a dropped connection are the same
      // thing to the user: they are offline and their saved content still works.
      throw const NetworkFailure();
    }

    // A 401 on a request that carried a token means the access token aged out.
    // Refresh once, then replay — the user never sees a sign-in screen for an
    // expiry the app can resolve itself.
    if (response.statusCode == 401 &&
        !isRetryAfterRefresh &&
        await _tokens.hasRefreshToken()) {
      final refreshed = await _refresh();
      if (refreshed != null) {
        return _send(
          method,
          path,
          body: body,
          query: query,
          parse: parse,
          isRetryAfterRefresh: true,
        );
      }
      onSessionExpired?.call();
      throw const AuthenticationFailure();
    }

    if (response.statusCode >= 400) throw _failureFrom(response);

    if (parse == null || response.statusCode == 204 || response.body.isEmpty) {
      return null as T;
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map<String, dynamic>) {
      throw const UnexpectedFailure();
    }
    return parse(decoded);
  }

  Future<Map<String, String>> _headers() async {
    final accessToken = await _tokens.accessToken();
    return {
      'content-type': 'application/json; charset=utf-8',
      // The server answers in the caller's language, so a failure surfaced by a
      // route the client does not know still reads as Ejadah.
      'x-ejadah-language': _language().code,
      // Identifies a guest across launches so funnel answers survive, and
      // migrate to the account on sign-up.
      'x-device-token': await _tokens.deviceToken(),
      if (accessToken != null) 'authorization': 'Bearer $accessToken',
    };
  }

  Future<AuthTokens?> _refresh() {
    return _inFlightRefresh ??= _performRefresh().whenComplete(() {
      _inFlightRefresh = null;
    });
  }

  Future<AuthTokens?> _performRefresh() async {
    final refreshToken = await _tokens.refreshToken();
    if (refreshToken == null) return null;

    try {
      final response = await _http
          .post(
            Uri.parse('$baseUrl/auth/refresh'),
            headers: {'content-type': 'application/json'},
            body: jsonEncode({'refresh_token': refreshToken}),
          )
          .timeout(timeout);

      if (response.statusCode >= 400) {
        await _tokens.clear();
        return null;
      }

      final session = AuthSession.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
      await _tokens.save(session.tokens);
      return session.tokens;
    } catch (_) {
      return null;
    }
  }

  Failure _failureFrom(http.Response response) {
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) {
        return Failure.fromEnvelope(decoded, response.statusCode);
      }
    } catch (_) {
      // Fall through: a non-JSON error body is a gateway or proxy failure, not
      // something the product has copy for.
    }
    return UnexpectedFailure(statusCode: response.statusCode);
  }

  void close() => _http.close();
}
