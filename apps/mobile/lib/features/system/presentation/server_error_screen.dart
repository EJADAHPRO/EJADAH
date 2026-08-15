import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'system_state_scaffold.dart';

/// SY-02 · The request reached us and we failed it.
///
/// The fault is named as ours and the sentence ends with what survived —
/// "Nothing you saved is affected." No status code ever reaches this screen:
/// the failure taxonomy carries approved copy, not codes to be formatted.
class ServerErrorScreen extends StatelessWidget {
  const ServerErrorScreen({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return SystemStateScaffold(
      state: EjadahSystemState(
        icon: EjadahIcons.warning,
        tone: SystemStateTone.warning,
        // "We couldn't load that" — `errTitle` is the Home feed's wording and
        // would be wrong on the other four tabs.
        title: strings.sysServerErrorTitle,
        body: strings.errServer,
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
