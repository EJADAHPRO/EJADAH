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
  // The shell's own gradient budget, for the shell's own chrome.
  //
  // The active-tab indicator is a `BrandGradient`, and it lives in
  // `bottomNavigationBar` — a *sibling* of `body`, not a descendant. Inherited
  // lookup walks up, so the per-route budget inside `body` was never above it:
  // the indicator was unbudgeted, and the debug assert that says so fired on
  // every tab route.
  //
  // Budgeted here rather than by widening a screen's scope, because the
  // indicator belongs to the chrome and is on screen on all five tabs at once.
  // Note what that means and does not mean: the six-per-screen rule still holds
  // inside each route, and the indicator is the one gradient outside it.
  Widget build(BuildContext context, WidgetRef ref) => GradientBudget(
    screenName: 'shell',
    child: Scaffold(
      body: navigationShell,
      bottomNavigationBar: EjadahBottomNav(
        destinations: navDestinations(context),
        currentIndex: navigationShell.currentIndex,
        onSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
          // Read back by `main` on the next launch, which resolves it into the
          // router's initial location.
          ref.read(localStoreProvider).setActiveTab(index);
        },
      ),
    ),
  );
}
