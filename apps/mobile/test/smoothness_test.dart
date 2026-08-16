import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The things that decide whether the app feels finished.
///
/// None of these is a feature. All of them are the difference between an app
/// people tolerate and one they keep open, and every one is the kind that
/// silently stops holding the next time a screen is rewritten.
void main() {
  group('swipe-back', () {
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      testWidgets('a pushed screen can be dragged away on ${platform.name}', (
        tester,
      ) async {
        debugDefaultTargetPlatformOverride = platform;
        try {
          await tester.pumpWidget(_app(AppLanguage.en));
          await tester.tap(find.text('open'));
          await tester.pumpAndSettle();
          expect(find.text('interior'), findsOneWidget);

          // From the leading edge, the way a thumb reaches it.
          await tester.dragFrom(const Offset(2, 300), const Offset(400, 0));
          await tester.pumpAndSettle();

          // Android's default builder has no drag-to-dismiss at all, which on
          // the phones most of this product's users hold left the app-bar
          // arrow as the only way out of an interior screen.
          expect(find.text('interior'), findsNothing);
          expect(find.text('open'), findsOneWidget);
        } finally {
          // Reset inside the body: the framework checks this invariant before
          // `addTearDown` callbacks run.
          debugDefaultTargetPlatformOverride = null;
        }
      });
    }

    testWidgets('in Arabic the gesture starts at the right edge', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
        await tester.pumpWidget(_app(AppLanguage.ar));
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        final width =
            tester.view.physicalSize.width / tester.view.devicePixelRatio;
        await tester.dragFrom(Offset(width - 2, 300), const Offset(-400, 0));
        await tester.pumpAndSettle();

        // Right-to-left: back is the direction the language reads back
        // towards, so the gesture has to start at the other edge.
        expect(find.text('interior'), findsNothing);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  });

  group('the stagger plays once', () {
    testWidgets('items animate in on first appearance', (tester) async {
      await tester.pumpWidget(_staggered(itemCount: 3));
      // Each pump before the measurement is load-bearing: the localization
      // delegates resolve on the first (which is when the list actually
      // builds), the post-frame callback registers on the second, its
      // zero-delay timer fires and starts the controller on the third, and
      // only the fourth lets the ticker advance it.
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));

      // Mid-flight: the first item is ahead of the third. That difference is
      // what a stagger *is*.
      await tester.pump(const Duration(milliseconds: 80));
      expect(_opacityOf(tester, 0), greaterThan(_opacityOf(tester, 2)));

      await tester.pumpAndSettle();
      expect(_opacityOf(tester, 2), 1);
    });

    testWidgets('a later item appears with the last staggered one', (
      tester,
    ) async {
      await tester.pumpWidget(_staggered(itemCount: 10));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump(EjadahMotion.base + const Duration(milliseconds: 50));

      // Past the cap the delay would grow without bound — item 40 would wait
      // 1.6 seconds and item 200 eight, at which point the entrance animation
      // has become a loading screen.
      expect(_opacityOf(tester, StaggeredIn.maxStaggered + 1), 1);
    });

    testWidgets('outside a group it is a plain pass-through', (tester) async {
      await tester.pumpWidget(
        _frame(const StaggeredIn(index: 3, child: Text('bare'))),
      );
      await tester.pumpAndSettle();

      expect(find.text('bare'), findsOneWidget);
    });
  });

  testWidgets('reduced motion keeps the fade and drops the lift', (
    tester,
  ) async {
    await tester.pumpWidget(_staggered(itemCount: 3, reduceMotion: true));
    await tester.pumpAndSettle();

    // The transform is what causes vestibular trouble; the opacity is not.
    final transform = tester.widget<Transform>(
      find.descendant(of: _itemAt(0), matching: find.byType(Transform)).first,
    );
    expect(transform.transform.getTranslation().y, 0);
  });
}

/// The [StaggeredIn] at [index], regardless of what wraps it.
Finder _itemAt(int index) => find.byWidgetPredicate(
  (widget) => widget is StaggeredIn && widget.index == index,
);

double _opacityOf(WidgetTester tester, int index) => tester
    .widget<Opacity>(
      find.descendant(of: _itemAt(index), matching: find.byType(Opacity)).first,
    )
    .opacity;

Widget _frame(Widget child, {bool reduceMotion = false}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  locale: const Locale('en'),
  supportedLocales: ejadahSupportedLocales,
  localizationsDelegates: EjadahStrings.localizationsDelegates,
  theme: buildEjadahTheme(
    language: AppLanguage.en,
    windowClass: EjadahWindowClass.compact,
    reduceMotion: reduceMotion,
  ),
  home: Scaffold(body: child),
);

Widget _staggered({required int itemCount, bool reduceMotion = false}) =>
    _frame(
      StaggerGroup(
        child: ListView.builder(
          itemCount: itemCount,
          itemBuilder: (context, index) =>
              StaggeredIn(index: index, child: Text('item $index')),
        ),
      ),
      reduceMotion: reduceMotion,
    );

/// A two-screen app: a launcher and one interior screen to swipe away.
Widget _app(AppLanguage language) => MaterialApp(
  debugShowCheckedModeBanner: false,
  locale: Locale(language.code),
  supportedLocales: ejadahSupportedLocales,
  localizationsDelegates: EjadahStrings.localizationsDelegates,
  theme: buildEjadahTheme(
    language: language,
    windowClass: EjadahWindowClass.compact,
    reduceMotion: false,
  ),
  home: Builder(
    builder: (context) => Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  const Scaffold(body: Center(child: Text('interior'))),
            ),
          ),
          child: const Text('open'),
        ),
      ),
    ),
  ),
);
