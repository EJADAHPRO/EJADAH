import 'dart:math';

import 'package:ejadah_models/ejadah_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the session and the guest device identifier.
///
/// The device token is the mechanism behind one of the product's load-bearing
/// promises: a guest completes the whole roadmap funnel without an account, and
/// their answers and result migrate to that account on sign-up. It is created
/// once and kept until the app is uninstalled.
class TokenStore {
  TokenStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  static const String _accessKey = 'ejadah.access_token';
  static const String _refreshKey = 'ejadah.refresh_token';
  static const String _expiryKey = 'ejadah.access_expires_at';
  static const String _deviceKey = 'ejadah.device_token';

  String? _cachedDeviceToken;

  Future<String?> accessToken() => _preferences.getString(_accessKey);

  Future<String?> refreshToken() => _preferences.getString(_refreshKey);

  Future<bool> hasRefreshToken() async => await refreshToken() != null;

  Future<DateTime?> accessExpiry() async {
    final raw = await _preferences.getString(_expiryKey);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<void> save(AuthTokens tokens) async {
    await _preferences.setString(_accessKey, tokens.accessToken);
    await _preferences.setString(_refreshKey, tokens.refreshToken);
    await _preferences.setString(
      _expiryKey,
      tokens.expiresAt.toIso8601String(),
    );
  }

  /// Clears the session but deliberately keeps the device token: signing out is
  /// not the same as becoming a different person, and the guest work that
  /// device produced still belongs to it.
  Future<void> clear() async {
    await _preferences.remove(_accessKey);
    await _preferences.remove(_refreshKey);
    await _preferences.remove(_expiryKey);
  }

  /// A stable anonymous identifier, created on first launch.
  Future<String> deviceToken() async {
    final cached = _cachedDeviceToken;
    if (cached != null) return cached;

    final existing = await _preferences.getString(_deviceKey);
    if (existing != null) {
      _cachedDeviceToken = existing;
      return existing;
    }

    final random = Random.secure();
    final token = List<int>.generate(
      16,
      (_) => random.nextInt(256),
    ).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();

    await _preferences.setString(_deviceKey, token);
    _cachedDeviceToken = token;
    return token;
  }
}
