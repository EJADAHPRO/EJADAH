import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';

/// The page chrome every system state shares.
///
/// The ten screens differ only in their copy, icon and actions; putting the
/// scaffold here keeps each of them a genuinely thin composition over
/// [EjadahSystemState] rather than ten near-identical page bodies.
///
/// [blockExit] is set by the one state the user may not walk past — force
/// update — so the system back gesture cannot return to an app that can no
/// longer talk to the servers.
class SystemStateScaffold extends StatelessWidget {
  const SystemStateScaffold({
    required this.state,
    this.blockExit = false,
    super.key,
  });

  final EjadahSystemState state;
  final bool blockExit;

  @override
  Widget build(BuildContext context) => PopScope<void>(
    canPop: !blockExit,
    child: Scaffold(
      backgroundColor: EjadahColors.background,
      body: SafeArea(child: state),
    ),
  );
}
