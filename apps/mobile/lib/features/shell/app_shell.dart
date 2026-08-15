import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router.dart';

/// The five-tab shell.
///
/// Each tab keeps its own navigation stack and scroll position. Re-tapping the
/// active tab resets that tab to its root — the one place a tab tap does
/// something other than switch.
class AppShell extends ConsumerWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    body: navigationShell,
    bottomNavigationBar: EjadahBottomNav(
      destinations: navDestinations(context),
      currentIndex: navigationShell.currentIndex,
      onSelected: (index) {
        navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );
        // The active tab is restored on next launch.
        ref.read(localStoreProvider).setActiveTab(index);
      },
    ),
  );
}
