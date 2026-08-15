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
