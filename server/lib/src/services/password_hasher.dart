import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:hashlib/hashlib.dart';

/// Argon2id password hashing.
///
/// Argon2id is memory-hard, which is what makes an offline attack on a stolen
/// hash table expensive. MD5, SHA-1, unsalted SHA-256 and plaintext are all
/// disqualifying, and the encoded output carries its own parameters so a future
/// cost increase can be rolled out without invalidating existing hashes.
class PasswordHasher {
  PasswordHasher({Argon2Security? security, Random? random})
    : _security = security ?? Argon2Security.moderate,
      _random = random ?? Random.secure();

  /// Test suites pass [Argon2Security.test] so a suite that creates dozens of
  /// accounts does not spend a minute in key derivation. Never used at runtime.
  factory PasswordHasher.forTests() =>
      PasswordHasher(security: Argon2Security.test);

  final Argon2Security _security;
  final Random _random;

  static const int _saltBytes = 16;

  /// Returns a self-describing encoded hash
  /// (`$argon2id$v=19$m=...,t=...,p=...$salt$hash`).
  String hash(String password) {
    final salt = Uint8List.fromList(
      List<int>.generate(_saltBytes, (_) => _random.nextInt(256)),
    );
    return argon2id(utf8.encode(password), salt, security: _security).encoded();
  }

  /// Constant-time verification against a stored encoded hash.
  ///
  /// A malformed or legacy hash returns false rather than throwing, so one bad
  /// row cannot take down sign-in for everyone.
  bool verify({required String password, required String encodedHash}) {
    try {
      return argon2Verify(encodedHash, utf8.encode(password));
    } catch (_) {
      return false;
    }
  }

  /// A hash of a value nobody uses, carrying **this hasher's own parameters**.
  ///
  /// Built here rather than written as a constant because a hard-coded decoy
  /// drifts from the real cost the moment [Argon2Security] changes — and a
  /// cheap decoy is not a decoy. Verifying `m=8,t=2,p=1` against real hashes at
  /// `m=8192,t=2,p=4` is roughly a thousandth of the work, which a caller can
  /// measure: the unknown-address path answers in single-digit milliseconds
  /// while a real address takes tens. That difference enumerates every
  /// registered address, which is exactly what the identical error copy exists
  /// to prevent.
  late final String _decoyHash = hash('decoy-password-nobody-uses');

  /// Spends the same work as a real verification, and always fails.
  ///
  /// Call this on the unknown-address path so sign-in costs the same whether or
  /// not the address exists.
  bool verifyDecoy(String password) =>
      verify(password: password, encodedHash: _decoyHash);
}
