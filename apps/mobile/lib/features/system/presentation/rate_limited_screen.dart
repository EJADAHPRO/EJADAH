import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'system_state_scaffold.dart';

/// SY-10 · Too many requests, too quickly.
///
/// Framed as a pause rather than a punishment, and the wait is stated in plain
/// words — "try in 2 minutes" — instead of a retry-after header the user would
/// have to decode. Retry stays enabled: a disabled button that never explains
/// itself is the worse failure.
class RateLimitedScreen extends StatelessWidget {
  const RateLimitedScreen({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return SystemStateScaffold(
      state: EjadahSystemState(
        icon: EjadahIcons.clock,
        title: strings.sysRateLimitedTitle,
        // "Take a short break — try in 2 minutes."
        body: strings.sysRateLimitedBody,
        primaryAction: EjadahSystemAction(
          label: strings.retry,
          onPressed: onRetry,
        ),
        secondaryAction: EjadahSystemAction(
          label: strings.backHome,
          onPressed: () => context.go('/home'),
        ),
      ),
    );
  }
}
