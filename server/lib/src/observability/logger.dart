import 'dart:convert';
import 'dart:io';

/// Structured logger.
///
/// Output is one JSON object per line so logs stay greppable in development and
/// ingestible in production. Correlation ids are attached by the request
/// middleware and travel with every line a request produces.
class AppLogger {
  AppLogger(this.scope, {this.correlationId, IOSink? sink})
    : _sink = sink ?? stdout;

  final String scope;
  final String? correlationId;
  final IOSink _sink;

  /// Keys whose values are never written to a log line, at any level.
  ///
  /// The list is deliberately broad: passwords, tokens, payment credentials and
  /// uploaded evidence must not appear in logs even by accident (brief §79).
  static const Set<String> _redactedKeys = {
    'password',
    'password_hash',
    'new_password',
    'current_password',
    'token',
    'access_token',
    'refresh_token',
    'authorization',
    'code',
    'verification_code',
    'secret',
    'jwt_secret',
    'card',
    'card_number',
    'cvv',
    'goal',
    'notes',
    'body',
  };

  AppLogger withCorrelationId(String id) =>
      AppLogger(scope, correlationId: id, sink: _sink);

  AppLogger child(String childScope) => AppLogger(
    '$scope.$childScope',
    correlationId: correlationId,
    sink: _sink,
  );

  void debug(String message, [Map<String, Object?> fields = const {}]) =>
      _write('debug', message, fields);

  void info(String message, [Map<String, Object?> fields = const {}]) =>
      _write('info', message, fields);

  void warn(String message, [Map<String, Object?> fields = const {}]) =>
      _write('warn', message, fields);

  void error(
    String message, [
    Map<String, Object?> fields = const {},
    Object? error,
    StackTrace? stackTrace,
  ]) => _write('error', message, {
    ...fields,
    if (error != null) 'error': error.toString(),
    if (stackTrace != null) 'stack': stackTrace.toString(),
  });

  void _write(String level, String message, Map<String, Object?> fields) {
    final entry = <String, Object?>{
      'ts': DateTime.now().toUtc().toIso8601String(),
      'level': level,
      'scope': scope,
      'msg': message,
      if (correlationId != null) 'correlation_id': correlationId,
      ..._redact(fields),
    };
    _sink.writeln(jsonEncode(entry));
  }

  static Map<String, Object?> _redact(Map<String, Object?> fields) =>
      fields.map(
        (key, value) => MapEntry(
          key,
          _redactedKeys.contains(key.toLowerCase())
              ? '[redacted]'
              : value is Map<String, Object?>
              ? _redact(value)
              : value,
        ),
      );
}
