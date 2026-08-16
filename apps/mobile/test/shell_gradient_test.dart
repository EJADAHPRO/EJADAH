import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_mobile/app/router.dart';
import 'package:ejadah_mobile/features/shell/app_shell.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// The shell's gradient budget.
///
/// The active-tab indicator is a `BrandGradient` inside `bottomNavigationBar`,
/// which is a sibling of `body` rather than a descendant — so the per-route
/// budget installed inside `body` was never above it. `BrandGradient` asserts
/// when it cannot find a budget, and that assert fired on every tab route.
///
/// Asserted by pumping the real shell, because the bug survived a suite that
/// checked `maxPerScreen == 6`: the rule was right and the wiring was not.
void main() {
  testWidgets('the tab indicator is inside a gradient budget', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    // In debug an unbudgeted BrandGradient throws, and `takeException` is where
    // that lands. Null is the whole assertion.
    expect(tester.takeException(), isNull);
    expect(find.byType(EjadahBottomNav), findsOneWidget);
  });
}

Widget _app() {
  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          for (final tab in AppTab.values)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: tab.path,
                  builder: (context, state) => GradientBudget(
                    screenName: tab.name,
                    child: Scaffold(body: Center(child: Text(tab.name))),
                  ),
                ),
              ],
            ),
        ],
      ),
    ],
  );

  return ProviderScope(
    child: MaterialApp.router(
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: ejadahSupportedLocales,
      localizationsDelegates: EjadahStrings.localizationsDelegates,
      theme: buildEjadahTheme(
        language: AppLanguage.ar,
        windowClass: EjadahWindowClass.compact,
        reduceMotion: true,
      ),
      routerConfig: router,
    ),
  );
}
