import 'package:ejadah_core/ejadah_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'app/providers.dart';
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

  final container = ProviderContainer();

  // The splash resolves fonts, language and auth before the first frame routes
  // anywhere. A cold-start deep link then navigates exactly once.
  await container.read(languageProvider.notifier).restore();
  await container.read(authControllerProvider.notifier).restore();

  final firstOpenAt = await container.read(localStoreProvider).firstOpenAt();
  container.read(reduceMotionProvider.notifier).state = SchedulerBinding
      .instance
      .platformDispatcher
      .accessibilityFeatures
      .disableAnimations;

  // A failed refresh sends the user to sign in — and brings them straight back.
  container.read(apiClientProvider).onSessionExpired = container
      .read(authControllerProvider.notifier)
      .sessionExpired;

  // Starts the three-minute activation clock.
  await container.read(analyticsProvider).track(AnalyticsEvents.appFirstOpen, {
    'ms_since_first_open': DateTime.now()
        .toUtc()
        .difference(firstOpenAt)
        .inMilliseconds,
  });

  runApp(
    UncontrolledProviderScope(container: container, child: const EjadahApp()),
  );
}
