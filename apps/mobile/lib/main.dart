import 'package:ejadah_core/ejadah_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'features/auth/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
