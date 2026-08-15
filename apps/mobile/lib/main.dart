import 'package:ejadah_core/ejadah_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'app/router.dart';
import 'features/auth/auth_controller.dart';
import 'features/system/system.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Release builds swap Flutter's red error box for a silent widget that
  // reports to the nearest boundary. Debug builds keep the red box: hiding a
  // crash from the engineer who caused it trades a visible bug for an
  // invisible one.
  SystemErrorBoundary.install();

  // Month and weekday names for both languages. GlobalMaterialLocalizations
  // loads these too, but only once its locale resolves — a date formatted
  // before that would fall back to English inside an Arabic screen.
  await initializeDateFormatting();

  // Read straight off the device, before the container exists, because the
  // container is built with these values already decided. Everything the first
  // frame depends on is resolved here so the cold start navigates exactly once.
  final store = LocalStore();
  final firstOpenAt = await store.firstOpenAt();
  final startupLocation = await _startupLocation(store);

  final container = ProviderContainer(
    overrides: [
      startupLocationProvider.overrideWithValue(startupLocation),
      // Every analytics event is stamped from the real first open rather than
      // from this launch.
      firstOpenAtProvider.overrideWithValue(firstOpenAt),
      localStoreProvider.overrideWithValue(store),
    ],
  );

  // The splash resolves language and auth before the first frame routes
  // anywhere, for the same reason.
  await container.read(languageProvider.notifier).restore();
  await container.read(authControllerProvider.notifier).restore();

  container.read(reduceMotionProvider.notifier).follow(
    SchedulerBinding.instance.platformDispatcher,
  );

  // A failed refresh sends the user to sign in — and brings them straight back.
  container.read(apiClientProvider).onSessionExpired = container
      .read(authControllerProvider.notifier)
      .sessionExpired;

  // Starts the three-minute activation clock.
  await container.read(analyticsProvider).track(AnalyticsEvents.appFirstOpen);

  runApp(
    UncontrolledProviderScope(container: container, child: const EjadahApp()),
  );
}

/// Where the app opens.
///
/// First run goes to the language pick — story E1-01, and the one screen that
/// was written and never reachable. Every run after it reopens the tab the user
/// left on.
Future<String> _startupLocation(LocalStore store) async {
  if (!await store.hasCompletedOnboarding()) return '/language';
  final index = (await store.activeTab()).clamp(0, AppTab.values.length - 1);
  return AppTab.values[index].path;
}
