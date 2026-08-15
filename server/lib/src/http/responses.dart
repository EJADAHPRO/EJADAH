import 'dart:convert';

import 'package:shelf/shelf.dart';

import 'api_error.dart';

/// JSON response helpers.
///
/// Every route returns through these so the content type, encoding and error
/// envelope are identical everywhere.
abstract final class Json {
  static Response ok(Object? body) => _json(200, body);

  static Response created(Object? body) => _json(201, body);

  static Response noContent() => Response(204);

  static Response error(ApiException exception) => _json(
    exception.code.statusCode,
    exception.toJson(),
    headers: {
      if (exception.retryAfter != null)
        'retry-after': '${exception.retryAfter!.inSeconds}',
    },
  );

  static Response _json(
    int status,
    Object? body, {
    Map<String, String> headers = const {},
  }) => Response(
    status,
    body: body == null ? null : jsonEncode(body),
    headers: {
      'content-type': 'application/json; charset=utf-8',
      // Public endpoints are cached by intermediaries; private ones must not be.
      'cache-control': 'no-store',
      ...headers,
    },
  );
}

/// Reads and validates a JSON object request body.
Future<Map<String, dynamic>> readJsonBody(Request request) async {
  final raw = await request.readAsString();
  if (raw.trim().isEmpty) return <String, dynamic>{};
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw ApiException(
        ApiErrorCode.validation,
        details: 'Request body must be a JSON object.',
      );
    }
    return Map<String, dynamic>.from(decoded);
  } on FormatException catch (error) {
    throw ApiException(
      ApiErrorCode.validation,
      details: 'Malformed JSON body: $error',
    );
  }
}

/// Reads an integer path segment.
///
/// A path segment is user input like any other. `int.parse` on it turns a
/// typo'd link into a 500, which reads to the caller — and to our own
/// monitoring — as a server fault rather than a bad request.
int parsePathInt(String raw, String field) {
  final value = int.tryParse(raw);
  if (value == null) {
    throw ApiException(
      ApiErrorCode.validation,
      details: '$field must be an integer.',
    );
  }
  return value;
}

/// UUID v4 canonical form, the shape every id in the schema takes.
final RegExp _uuidPattern = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-'
  r'[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
);

/// Reads a UUID path segment.
///
/// Handing an arbitrary string to a `uuid`-typed query raises `22P02` deep in
/// the driver, which surfaces as a 500. The shape is checked here so a
/// malformed id is a plain not-found — the same answer as an id that does not
/// exist, which is also the answer that reveals least.
String parsePathUuid(String raw) {
  if (!_uuidPattern.hasMatch(raw)) throw ApiException.notFound();
  return raw;
}
