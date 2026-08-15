import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';

import 'system_state_scaffold.dart';

/// SY-04 · The one state with no way past.
///
/// Every other system screen offers a second route. This one cannot: the build
/// can no longer talk to the servers, so "carry on anyway" would only fail
/// again a screen later. Rather than leave that unexplained, the body states
/// the reason — "This version can no longer talk to our servers." — and the
/// back gesture is blocked so the dead end is honest instead of accidental.
class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({required this.onUpdate, super.key});

  /// Opens the store listing. Injected because the URL is platform-specific.
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return SystemStateScaffold(
      blockExit: true,
      state: EjadahSystemState(
        icon: EjadahIcons.download,
        tone: SystemStateTone.blocking,
        title: strings.sysForceUpdateTitle,
        body: strings.sysForceUpdateBody,
        primaryAction: EjadahSystemAction(
          label: strings.sysUpdateAction,
          onPressed: onUpdate,
        ),
        // Deliberately no secondary action. See the class docs.
      ),
    );
  }
}
