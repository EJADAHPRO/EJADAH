import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'system_state_scaffold.dart';

/// SY-09 · The thing behind the link is gone.
///
/// Almost always a closed intake, so the copy names that likely reason rather
/// than leaving the user to wonder whether the link was wrong. The route out is
/// the programme database, where the 17 that are still open live.
class ContentUnavailableScreen extends StatelessWidget {
  const ContentUnavailableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return SystemStateScaffold(
      state: EjadahSystemState(
        icon: EjadahIcons.empty,
        title: strings.sysContentUnavailableTitle,
        // "This is no longer available — often the intake closed."
        body: strings.contentUnavailableBody,
        primaryAction: EjadahSystemAction(
          label: strings.browseProgrammes,
          onPressed: () => context.go('/programmes'),
        ),
        secondaryAction: EjadahSystemAction(
          label: strings.backHome,
          onPressed: () => context.go('/home'),
        ),
      ),
    );
  }
}
