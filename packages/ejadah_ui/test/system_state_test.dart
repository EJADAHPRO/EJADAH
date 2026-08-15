import 'dart:io';

import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// The system-state template — the one widget behind all ten states.
///
/// The template is where the accessibility promises are kept, so this is where
/// they are asserted: a mandatory action, a title that announces itself, 44px
/// targets, and — the rule most likely to be quietly broken — no clipping at
/// 200% text scale.
///
/// The bundled fonts are loaded before the goldens so they prove typography
/// rather than the test placeholder face.
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadBundledFonts();
  });

  group('anatomy', () {
    testWidgets('renders icon, title, body and both actions', (tester) async {
      await tester.pumpWidget(
        const _Frame(
          language: AppLanguage.en,
          child: EjadahSystemState(
            icon: EjadahIcons.offline,
            title: _Copy.offlineTitleEn,
            body: _Copy.offlineBodyEn,
            primaryAction: _Copy.retryEn,
            secondaryAction: _Copy.homeEn,
          ),
        ),
      );

      expect(find.byIcon(EjadahIcons.offline), findsOneWidget);
      expect(find.text(_Copy.offlineTitleEn), findsOneWidget);
      expect(find.text(_Copy.offlineBodyEn), findsOneWidget);
      expect(find.text(_Copy.retryEn.label), findsOneWidget);
      expect(find.text(_Copy.homeEn.label), findsOneWidget);
    });

    testWidgets('the secondary action is the only optional part', (
      tester,
    ) async {
      await tester.pumpWidget(
        const _Frame(
          language: AppLanguage.en,
          child: EjadahSystemState(
            icon: EjadahIcons.warning,
            title: 'Update to continue',
            body: 'This version can no longer talk to our servers.',
            primaryAction: _Copy.retryEn,
          ),
        ),
      );

      // Force update is the one state with no way past; nothing else renders.
      expect(find.text(_Copy.retryEn.label), findsOneWidget);
      expect(find.byType(EjadahGhostButton), findsNothing);
    });

    testWidgets('both actions fire', (tester) async {
      var primary = 0;
      var secondary = 0;

      await tester.pumpWidget(
        _Frame(
          language: AppLanguage.en,
          child: EjadahSystemState(
            icon: EjadahIcons.offline,
            title: _Copy.offlineTitleEn,
            body: _Copy.offlineBodyEn,
            primaryAction: EjadahSystemAction(
              label: 'Try again',
              onPressed: () => primary++,
            ),
            secondaryAction: EjadahSystemAction(
              label: 'Back to Home',
              onPressed: () => secondary++,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Try again'));
      await tester.tap(find.text('Back to Home'));
      await tester.pump();

      expect(primary, 1);
      expect(secondary, 1);
    });
  });

  group('accessibility', () {
    testWidgets('the title announces itself as a live region', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        const _Frame(
          language: AppLanguage.en,
          child: EjadahSystemState(
            icon: EjadahIcons.offline,
            title: _Copy.offlineTitleEn,
            body: _Copy.offlineBodyEn,
            primaryAction: _Copy.retryEn,
          ),
        ),
      );

      expect(
        tester.getSemantics(find.text(_Copy.offlineTitleEn)),
        matchesSemantics(
          label: _Copy.offlineTitleEn,
          isLiveRegion: true,
          isHeader: true,
          textDirection: TextDirection.ltr,
        ),
      );

      handle.dispose();
    });

    testWidgets('every tap target clears 44 logical pixels', (tester) async {
      await tester.pumpWidget(
        const _Frame(
          language: AppLanguage.en,
          child: EjadahSystemState(
            icon: EjadahIcons.offline,
            title: _Copy.offlineTitleEn,
            body: _Copy.offlineBodyEn,
            primaryAction: _Copy.retryEn,
            secondaryAction: _Copy.homeEn,
          ),
        ),
      );

      for (final entry in {
        'primary action': find.byType(EjadahPrimaryButton),
        'secondary action': find.byType(EjadahGhostButton),
      }.entries) {
        final size = tester.getSize(entry.value);
        expect(
          size.height,
          greaterThanOrEqualTo(EjadahSizes.tapTargetMin),
          reason: 'the ${entry.key} is under the minimum target',
        );
      }
    });

    testWidgets('focus is visible and the keyboard can activate an action', (
      tester,
    ) async {
      var fired = 0;
      await tester.pumpWidget(
        _Frame(
          language: AppLanguage.en,
          child: EjadahSystemState(
            icon: EjadahIcons.offline,
            title: _Copy.offlineTitleEn,
            body: _Copy.offlineBodyEn,
            primaryAction: EjadahSystemAction(
              label: 'Try again',
              onPressed: () => fired++,
            ),
          ),
        ),
      );

      final ring = tester.widget<Focus>(
        find.descendant(
          of: find.byType(SystemStateFocusRing),
          matching: find.byType(Focus),
        ),
      );
      ring.focusNode?.requestFocus();
      // A ring the user cannot see is not a focus indicator.
      final node = Focus.of(
        tester.element(find.byType(EjadahPrimaryButton)),
        scopeOk: true,
      );
      node.requestFocus();
      await tester.pump();

      final decorated = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(SystemStateFocusRing),
              matching: find.byType(Container),
            )
            .first,
      );
      final border = (decorated.decoration! as BoxDecoration).border!;
      expect(border.top.color, EjadahColors.orange);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(fired, 1);
    });
  });

  group('200% text scale', () {
    // The acceptance criterion: dynamic type to 200% without clipping, tested
    // on the Arabic long-copy case on the smallest phone the product supports.
    for (final language in AppLanguage.values) {
      for (final size in _phoneSizes) {
        testWidgets('nothing overflows at 2.0 in ${language.code} on '
            '${size.width.toInt()}x${size.height.toInt()}', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(
            _Frame(
              language: language,
              textScale: 2,
              size: null,
              child: EjadahSystemState(
                icon: EjadahIcons.warning,
                tone: SystemStateTone.warning,
                // The longest state in the product, in both languages.
                title: _Copy.sessionTitle(language),
                body: _Copy.sessionBody(language),
                primaryAction: _Copy.signIn(language),
                secondaryAction: _Copy.home(language),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('the actions stay reachable by scrolling at 2.0', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      var fired = 0;
      await tester.pumpWidget(
        _Frame(
          language: AppLanguage.ar,
          textScale: 2,
          size: null,
          child: EjadahSystemState(
            icon: EjadahIcons.warning,
            title: _Copy.sessionTitle(AppLanguage.ar),
            body: _Copy.sessionBody(AppLanguage.ar),
            primaryAction: EjadahSystemAction(
              label: _Copy.signIn(AppLanguage.ar).label,
              onPressed: () => fired++,
            ),
            secondaryAction: _Copy.home(AppLanguage.ar),
          ),
        ),
      );

      // Proves this test is not vacuous: at 200% the Arabic copy genuinely
      // runs past a 568pt phone, so the scroll below is load-bearing.
      final position = tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position;
      expect(
        position.maxScrollExtent,
        greaterThan(0),
        reason: 'the 200% case no longer exceeds the viewport',
      );

      // A state that overflows its viewport must scroll, not clip: the action
      // is what makes the screen a route rather than a dead end.
      await tester.scrollUntilVisible(
        find.byType(EjadahPrimaryButton),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byType(EjadahPrimaryButton));
      await tester.pump();

      expect(fired, 1);
      expect(tester.takeException(), isNull);
    });
  });

  group('goldens', () {
    // Offline, server error and session expired in both languages: the three
    // states a user is most likely to meet, and Arabic is not English with a
    // different font — direction, family and line-height all change.
    final states = <String, EjadahSystemState Function(AppLanguage)>{
      'system_offline': (language) => EjadahSystemState(
        icon: EjadahIcons.offline,
        title: _Copy.offlineTitle(language),
        body: _Copy.offlineBody(language),
        primaryAction: _Copy.retry(language),
        secondaryAction: _Copy.home(language),
      ),
      'system_server_error': (language) => EjadahSystemState(
        icon: EjadahIcons.warning,
        tone: SystemStateTone.warning,
        title: _Copy.serverTitle(language),
        body: _Copy.serverBody(language),
        primaryAction: _Copy.retry(language),
        secondaryAction: _Copy.home(language),
      ),
      'system_session_expired': (language) => EjadahSystemState(
        icon: EjadahIcons.locked,
        title: _Copy.sessionTitle(language),
        body: _Copy.sessionBody(language),
        primaryAction: _Copy.signIn(language),
        secondaryAction: _Copy.home(language),
      ),
    };

    for (final entry in states.entries) {
      for (final language in AppLanguage.values) {
        testWidgets('${entry.key} (${language.code})', (tester) async {
          await tester.pumpWidget(
            _Frame(language: language, child: entry.value(language)),
          );
          await expectLater(
            find.byType(_Frame),
            matchesGoldenFile('goldens/${entry.key}_${language.code}.png'),
          );
        });
      }
    }
  });
}

const List<Size> _phoneSizes = [
  // The smallest phone in the support matrix, and a modern one.
  Size(320, 568),
  Size(390, 844),
];

/// A fixed frame so a golden captures layout, not window size.
class _Frame extends StatelessWidget {
  const _Frame({
    required this.language,
    required this.child,
    this.textScale = 1,
    this.size = const Size(360, 640),
  });

  final AppLanguage language;
  final Widget child;
  final double textScale;

  /// Null fills the test window, so a text-scale test measures against the real
  /// viewport rather than a box that happens to be big enough.
  final Size? size;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: Locale(language.code),
    theme: buildEjadahTheme(
      language: language,
      windowClass: EjadahWindowClass.compact,
    ),
    home: Directionality(
      textDirection: language.isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: GradientBudget(
            screenName: 'system-state',
            child: Scaffold(
              backgroundColor: EjadahColors.background,
              body: size == null
                  ? child
                  : SizedBox(
                      width: size!.width,
                      height: size!.height,
                      child: child,
                    ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// The approved copy, verbatim from `06-content/CONTENT.md`, used as fixtures.
///
/// The design system package carries no string table — the app supplies the
/// copy — so the words live here so that a golden proves the real sentence
/// renders, not a placeholder.
abstract final class _Copy {
  static const String offlineTitleEn = 'You are offline';
  static const String offlineBodyEn =
      'Your saved work is safe on this device. Try again in a moment.';

  static const EjadahSystemAction retryEn = EjadahSystemAction(
    label: 'Try again',
    onPressed: _noop,
  );
  static const EjadahSystemAction homeEn = EjadahSystemAction(
    label: 'Back to Home',
    onPressed: _noop,
  );

  static void _noop() {}

  static String offlineTitle(AppLanguage language) =>
      language.isRtl ? 'لا يوجد اتصال' : offlineTitleEn;

  static String offlineBody(AppLanguage language) => language.isRtl
      ? 'عملك المحفوظ آمن على هذا الجهاز. حاول مرة أخرى بعد قليل.'
      : offlineBodyEn;

  static String serverTitle(AppLanguage language) =>
      language.isRtl ? 'تعذّر التحميل' : "We couldn't load that";

  static String serverBody(AppLanguage language) => language.isRtl
      ? 'حدث خطأ من جانبنا. لم يتأثر ما حفظته.'
      : 'Something went wrong on our side. Nothing you saved is affected.';

  static String sessionTitle(AppLanguage language) =>
      language.isRtl ? 'سجّل الدخول مجددًا' : 'Please sign in again';

  static String sessionBody(AppLanguage language) => language.isRtl
      ? 'سجّل الدخول مجددًا. ستعود لمكانك — لم يُفقد شيء.'
      : "Please sign in again. You'll come straight back — nothing is lost.";

  static EjadahSystemAction retry(AppLanguage language) => EjadahSystemAction(
    label: language.isRtl ? 'حاول مرة أخرى' : 'Try again',
    onPressed: _noop,
  );

  static EjadahSystemAction home(AppLanguage language) => EjadahSystemAction(
    label: language.isRtl ? 'العودة للرئيسية' : 'Back to Home',
    onPressed: _noop,
  );

  static EjadahSystemAction signIn(AppLanguage language) => EjadahSystemAction(
    label: language.isRtl ? 'تسجيل الدخول' : 'Sign in',
    onPressed: _noop,
  );
}

/// Registers the four bundled families with the test font collection.
Future<void> _loadBundledFonts() async {
  const families = {
    'Playfair Display': 'assets/fonts/PlayfairDisplay-Variable.ttf',
    'Inter': 'assets/fonts/Inter-Variable.ttf',
    'Amiri': 'assets/fonts/Amiri-Bold.ttf',
    'IBM Plex Sans Arabic': 'assets/fonts/IBMPlexSansArabic-Regular.ttf',
  };

  for (final entry in families.entries) {
    final file = File(entry.value);
    if (!file.existsSync()) continue;
    final loader = FontLoader(entry.key)
      ..addFont(Future.value(file.readAsBytesSync().buffer.asByteData()));
    await loader.load();
  }
}
