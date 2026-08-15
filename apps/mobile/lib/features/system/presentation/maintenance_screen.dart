import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'system_state_scaffold.dart';

/// SY-05 · Planned downtime.
///
/// Short and unfrightening: we are back shortly, and nothing saved is affected.
/// No window is promised, because a missed estimate costs more trust than no
/// estimate at all.
class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return SystemStateScaffold(
      state: EjadahSystemState(
        icon: EjadahIcons.clock,
        title: strings.sysMaintenanceTitle,
        body: strings.sysMaintenanceBody,
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
