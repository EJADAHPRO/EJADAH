import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'system_state_scaffold.dart';

/// SY-03 · The session is gone.
///
/// The fear this screen has to answer is "have I lost my work", so the copy
/// answers it first: "You'll come straight back — nothing is lost." [next]
/// carries where the user was, and sign-in returns them there rather than to a
/// generic Home.
class SessionExpiredScreen extends StatelessWidget {
  const SessionExpiredScreen({this.next, super.key});

  /// The location to return to after signing in.
  final String? next;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final destination = next == null
        ? '/sign-in'
        : '/sign-in?next=${Uri.encodeComponent(next!)}';

    return SystemStateScaffold(
      state: EjadahSystemState(
        icon: EjadahIcons.locked,
        title: strings.sysSessionExpiredTitle,
        // "Please sign in again. You'll come straight back — nothing is lost."
        body: strings.sysSessionExpiredBody,
        primaryAction: EjadahSystemAction(
          label: strings.signIn,
          onPressed: () => context.go(destination),
        ),
        // Browsing is open signed out, so there is a real second route.
        secondaryAction: EjadahSystemAction(
          label: strings.backHome,
          onPressed: () => context.go('/home'),
        ),
      ),
    );
  }
}
