import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:ejadah_models/ejadah_models.dart';

import '../config/config.dart';

/// The claims carried by a verified access token.
class AccessClaims {
  const AccessClaims({
    required this.userId,
    required this.role,
    required this.expiresAt,
  });

  final String userId;
  final UserRole role;
  final DateTime expiresAt;
}

/// A newly minted refresh token: the secret handed to the client, and the hash
/// stored in the database.
class RefreshTokenPair {
  const RefreshTokenPair({
    required this.secret,
    required this.hash,
    required this.expiresAt,
  });

  final String secret;
  final String hash;
  final DateTime expiresAt;
}

/// Issues and verifies session tokens.
///
/// Access tokens are short-lived JWTs so the common path needs no database
/// read. Refresh tokens are long-lived and therefore opaque, single-use and
/// stored only as a SHA-256 hash — a database leak must not yield usable
/// sessions.
class TokenService {
  TokenService(this._config, {Random? random})
    : _random = random ?? Random.secure();

  final AppConfig _config;
  final Random _random;

  String issueAccessToken({required String userId, required UserRole role}) {
    final jwt = JWT(
      {'role': role.wire},
      subject: userId,
      issuer: 'ejadah',
    );
    return jwt.sign(
      SecretKey(_config.jwtSecret),
      expiresIn: _config.accessTokenTtl,
    );
  }

  DateTime accessTokenExpiry() =>
      DateTime.now().toUtc().add(_config.accessTokenTtl);

  /// Returns null for any token that is absent, malformed, expired or signed
  /// with the wrong key — callers treat all of those identically.
  AccessClaims? verifyAccessToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(_config.jwtSecret), issuer: 'ejadah');
      final subject = jwt.subject;
      if (subject == null) return null;
      final payload = jwt.payload;
      final role = payload is Map ? payload['role'] as String? : null;
      return AccessClaims(
        userId: subject,
        role: UserRole.fromWire(role),
        // `JWT.verify` has already rejected an expired token; this value is for
        // the client's refresh scheduling only.
        expiresAt: accessTokenExpiry(),
      );
    } on JWTException {
      return null;
    }
  }

  RefreshTokenPair issueRefreshToken() {
    final bytes = List<int>.generate(32, (_) => _random.nextInt(256));
    final secret = base64Url.encode(bytes).replaceAll('=', '');
    return RefreshTokenPair(
      secret: secret,
      hash: hashOpaqueToken(secret),
      expiresAt: DateTime.now().toUtc().add(_config.refreshTokenTtl),
    );
  }

  /// Also used for e-mail verification codes and password-reset tokens: those
  /// are secrets too, and are likewise stored only as hashes.
  static String hashOpaqueToken(String secret) =>
      sha256.convert(utf8.encode(secret)).toString();

  /// A short numeric code for e-mail verification. Six digits, rendered LTR.
  String issueNumericCode({int digits = 6}) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits; i++) {
      buffer.write(_random.nextInt(10));
    }
    return buffer.toString();
  }

  /// A URL-safe opaque token for password reset links.
  String issueOpaqueToken() {
    final bytes = List<int>.generate(32, (_) => _random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  /// A random UUID v4.
  ///
  /// Refresh-token families are keyed by a `uuid` column, so this produces the
  /// canonical textual form rather than an arbitrary random string.
  String issueUuid() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    // Version 4, variant 1, per RFC 4122.
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    String hex(int start, int end) => bytes
        .sublist(start, end)
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();

    return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
  }
}
