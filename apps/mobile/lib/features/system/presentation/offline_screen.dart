import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'system_state_scaffold.dart';

/// SY-01 · The connection dropped.
///
/// Being offline is a condition, not a fault, and the copy says what is still
/// true: downloaded lessons, saved programmes and drafts are all still on the
/// device. Retry is the primary route; Home is the second, because the saved
/// content is readable there without a connection.
class OfflineScreen extends StatelessWidget {
  const OfflineScreen({required this.onRetry, super.key});

  /// Re-runs whatever failed. Injected, because only the caller knows what that
  /// was.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return SystemStateScaffold(
      state: EjadahSystemState(
        icon: EjadahIcons.offline,
        title: strings.sysOfflineTitle,
        // "Your saved work is safe on this device. Try again in a moment."
        body: strings.sysOfflineBody,
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
