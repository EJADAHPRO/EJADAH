import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';

import 'system_state_scaffold.dart';

/// SY-06 · Notifications were declined at the OS prompt.
///
/// The app cannot re-ask, so the only honest route is Settings — and the copy
/// says what the permission actually buys: deadline warnings. "Maybe later"
/// leaves without cost, because a permission screen that traps the user is a
/// worse outcome than a user who never enables notifications.
class NotificationPermissionDeniedScreen extends StatelessWidget {
  const NotificationPermissionDeniedScreen({
    required this.onOpenSettings,
    this.onMaybeLater,
    super.key,
  });

  /// Opens the OS settings page for this app. Injected: it is a platform call,
  /// not a route.
  final VoidCallback onOpenSettings;

  /// Defaults to leaving the screen.
  final VoidCallback? onMaybeLater;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return SystemStateScaffold(
      state: EjadahSystemState(
        icon: EjadahIcons.bell,
        title: strings.sysNotifDeniedTitle,
        body: strings.sysNotifDeniedBody,
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
