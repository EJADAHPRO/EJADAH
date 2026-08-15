import 'dart:ui';

import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The API base URL.
///
/// Supplied at build time so a release build cannot accidentally point at a
/// development server: `flutter build web --dart-define=EJADAH_API_URL=...`.
const String apiBaseUrl = String.fromEnvironment(
  'EJADAH_API_URL',
  defaultValue: 'http://localhost:8080/api/v1',
);

const String appVersion = String.fromEnvironment(
  'EJADAH_APP_VERSION',
  defaultValue: '1.0.0',
);

final localStoreProvider = Provider<LocalStore>((ref) => LocalStore());

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());

/// The active language.
///
/// Arabic until the user or their stored preference says otherwise. Switching
/// rebuilds the app in place — no reload, and no lost form state, because only
/// the locale changes and the widget state above it is preserved.
final languageProvider = NotifierProvider<LanguageController, AppLanguage>(
  LanguageController.new,
);

class LanguageController extends Notifier<AppLanguage> {
  @override
  AppLanguage build() => AppLanguage.ar;

  /// Restores the stored preference at startup.
  Future<void> restore() async {
    final stored = await ref.read(localStoreProvider).language();
    if (stored != null) state = AppLanguage.fromCode(stored);
  }

  Future<void> set(AppLanguage language) async {
    if (state == language) return;
    state = language;
    await ref.read(localStoreProvider).setLanguage(language.code);
    await ref.read(analyticsProvider).track(AnalyticsEvents.languageSelected, {
      'lang': language.code,
    });
  }
}

/// The real first-open instant, read from disk in `main` before the first
/// frame. Overridden there; the fallback only applies to tests that build the
/// container directly.
final firstOpenAtProvider = Provider<DateTime>(
  (ref) => DateTime.now().toUtc(),
);

final analyticsProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsDispatcher(
    delegate: const DebugAnalyticsService(),
    appVersion: appVersion,
    language: () => ref.read(languageProvider),
    // Every event carries `ms_since_first_open` measured from the real first
    // open, not from this launch — the activation funnel is the whole point of
    // the field, and session age would have been a different number under the
    // same name.
    firstOpenAt: () => ref.read(firstOpenAtProvider),
  );
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient(
    baseUrl: apiBaseUrl,
    tokens: ref.watch(tokenStoreProvider),
    language: () => ref.read(languageProvider),
  );
  ref.onDispose(client.close);
  return client;
});

/// Whether reduce-motion is on. Read from the platform at startup and honoured
/// by every Ejadah animation through `EjadahMotion.durationFor`.
/// Whether the OS has asked for reduced motion.
///
/// Followed rather than sampled: reading `accessibilityFeatures` once at
/// startup meant a user who turned the setting on mid-session kept every
/// animation until they restarted the app — and someone turning it on
/// mid-session is very often turning it on *because* of what they just saw.
final reduceMotionProvider =
    NotifierProvider<ReduceMotionController, bool>(ReduceMotionController.new);

class ReduceMotionController extends Notifier<bool> {
  PlatformDispatcher? _dispatcher;

  @override
  bool build() => false;

  /// Adopts the current value and keeps following it.
  void follow(PlatformDispatcher dispatcher) {
    _dispatcher = dispatcher;
    state = dispatcher.accessibilityFeatures.disableAnimations;

    final previous = dispatcher.onAccessibilityFeaturesChanged;
    dispatcher.onAccessibilityFeaturesChanged = () {
      // Chained rather than replaced: whatever the framework or another
      // listener had registered keeps running.
      previous?.call();
      state = dispatcher.accessibilityFeatures.disableAnimations;
    };

    ref.onDispose(() {
      _dispatcher?.onAccessibilityFeaturesChanged = previous;
    });
  }
}

/// Where the app opens, decided once at startup.
///
/// Two things feed it and both were being written but never read: the
/// onboarding flag, which sends a first-time user to the language pick, and the
/// last active tab, which the shell has been saving since it was written under
/// a comment claiming it was restored.
///
/// Overridden in `main` before the first frame, so the router is built knowing
/// the answer and a cold start navigates exactly once.
final startupLocationProvider = Provider<String>(
  (ref) => throw StateError('startupLocationProvider must be overridden'),
);
