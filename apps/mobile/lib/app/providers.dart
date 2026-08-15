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

final analyticsProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsDispatcher(
    delegate: const DebugAnalyticsService(),
    appVersion: appVersion,
    language: () => ref.read(languageProvider),
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
final reduceMotionProvider = StateProvider<bool>((ref) => false);
