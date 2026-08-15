import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Local persistence for the state the design requires to survive a restart.
///
/// The acceptance criteria are explicit about what must come back: the active
/// tab, per-tab scroll, filter selections, form drafts and video position. This
/// is the client half of that; anything that must survive a *reinstall* lives
/// on the server instead.
class LocalStore {
  LocalStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  static const String _languageKey = 'ejadah.language';
  static const String _onboardedKey = 'ejadah.onboarding_complete';
  static const String _firstOpenKey = 'ejadah.first_open_at';
  static const String _programmeFiltersKey = 'ejadah.programme_filters';
  static const String _activeTabKey = 'ejadah.active_tab';

  Future<String?> language() => _preferences.getString(_languageKey);

  Future<void> setLanguage(String code) =>
      _preferences.setString(_languageKey, code);

  Future<bool> hasCompletedOnboarding() async =>
      await _preferences.getBool(_onboardedKey) ?? false;

  Future<void> setOnboardingComplete() =>
      _preferences.setBool(_onboardedKey, true);

  /// Stamped once, on the very first launch. The three-minute activation metric
  /// is measured from here, so it must never be overwritten.
  Future<DateTime> firstOpenAt() async {
    final existing = await _preferences.getString(_firstOpenKey);
    final parsed = existing == null ? null : DateTime.tryParse(existing);
    if (parsed != null) return parsed;

    final now = DateTime.now().toUtc();
    await _preferences.setString(_firstOpenKey, now.toIso8601String());
    return now;
  }

  /// Filters persist across sessions — re-applying them by hand every launch is
  /// the friction this removes.
  Future<Map<String, dynamic>?> programmeFilters() async {
    final raw = await _preferences.getString(_programmeFiltersKey);
    if (raw == null) return null;
    final decoded = jsonDecode(raw);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  Future<void> saveProgrammeFilters(Map<String, dynamic> filters) =>
      _preferences.setString(_programmeFiltersKey, jsonEncode(filters));

  Future<void> clearProgrammeFilters() =>
      _preferences.remove(_programmeFiltersKey);

  Future<int> activeTab() async => await _preferences.getInt(_activeTabKey) ?? 0;

  Future<void> setActiveTab(int index) =>
      _preferences.setInt(_activeTabKey, index);
}
