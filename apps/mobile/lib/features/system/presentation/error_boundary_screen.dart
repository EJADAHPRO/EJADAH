import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'system_state_scaffold.dart';

/// SY-08 · A widget-level crash, caught before the user sees a red screen.
///
/// The failure is local to one screen, so the whole app is not lost and the
/// copy does not imply it was: "Nothing you entered is lost." Home is the
/// primary route because it is guaranteed to build; retry rebuilds the subtree
/// for the case where the cause was transient data.
///
/// Rendered by [SystemErrorBoundary], never routed to directly.
class ErrorBoundaryScreen extends StatelessWidget {
  const ErrorBoundaryScreen({required this.onRetry, super.key});

  /// Clears the caught error and rebuilds the guarded subtree.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return SystemStateScaffold(
      state: EjadahSystemState(
        icon: EjadahIcons.warning,
        tone: SystemStateTone.warning,
        title: strings.sysErrorBoundaryTitle,
        // "We couldn't do that just now. Nothing you entered is lost."
        body: strings.sysErrorBoundaryBody,
        primaryAction: EjadahSystemAction(
          label: strings.backHome,
          onPressed: () => context.go('/home'),
        ),
        secondaryAction: EjadahSystemAction(
          label: strings.retry,
          onPressed: onRetry,
        ),
      ),
    );
  }
}
