import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';

import 'system_state_scaffold.dart';

/// SY-07 · The camera was declined at the OS prompt.
///
/// Reached from the NFC card scan. The body names the one feature that needs
/// it, so the ask is proportionate, and "maybe later" returns to whatever the
/// user was doing — nothing else in the app depends on the camera.
class CameraPermissionDeniedScreen extends StatelessWidget {
  const CameraPermissionDeniedScreen({
    required this.onOpenSettings,
    this.onMaybeLater,
    super.key,
  });

  final VoidCallback onOpenSettings;
  final VoidCallback? onMaybeLater;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return SystemStateScaffold(
      state: EjadahSystemState(
        icon: EjadahIcons.locked,
        title: strings.sysCameraDeniedTitle,
        body: strings.sysCameraDeniedBody,
        primaryAction: EjadahSystemAction(
          label: strings.sysOpenSettings,
          onPressed: onOpenSettings,
        ),
        secondaryAction: EjadahSystemAction(
          label: strings.maybeLater,
          onPressed: onMaybeLater ?? () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }
}
