import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The accessibility sweep, run over the whole interactive catalog.
///
/// The design system says every tap target clears 44×44, every one of them
/// announces itself in the language on screen, nothing clips at 200% text, and
/// reduce-motion is honoured. Those four rules are asserted per component here
/// rather than per screen, because a screen is assembled from these and a
/// component that fails fails everywhere it is used.
///
/// The catalog is deliberately built by hand rather than reflected: a component
/// added without a line here is a component nobody swept, and the missing line
/// is easier to notice than a silently-skipped type.
void main() {
  group('44×44 — the most-felt rule in the handoff', () {
    for (final language in AppLanguage.values) {
      testWidgets('every tap target clears it in ${language.name}', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(_catalog(language: language));
        await tester.pumpAndSettle();

        // 44 is the handoff's number and iOS's. Android's guideline asks for
        // 48; the components are built to 44, so this asserts what the design
        // system actually promises rather than a number it never claimed.
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        handle.dispose();
      });

      testWidgets('every tap target announces itself in ${language.name}', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(_catalog(language: language));
        await tester.pumpAndSettle();

        // An icon-only control with no label is a control a screen reader
        // reads out as "button" and nothing else.
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        handle.dispose();
      });
    }

    testWidgets('a chip is 36 tall and still 44 to hit', (tester) async {
      await tester.pumpWidget(
        _catalog(language: AppLanguage.en, only: _CatalogSlice.chip),
      );
      await tester.pumpAndSettle();

      // The two rules look like they conflict — the design asks for a 36-high
      // chip, accessibility asks for a 44 target. The visual stays 36 and the
      // box around it grows, which is the only resolution that does not make
      // components start opting out.
      final chip = tester.getSize(find.byType(EjadahFilterChip).first);
      expect(chip.height, greaterThanOrEqualTo(EjadahSizes.tapTargetMin));
      expect(
        tester.getSize(find.byType(AnimatedContainer).first).height,
        lessThan(EjadahSizes.tapTargetMin),
      );
    });
  });

  group('200% text', () {
    for (final language in AppLanguage.values) {
      testWidgets('nothing clips or overflows in ${language.name}', (
        tester,
      ) async {
        await tester.pumpWidget(_catalog(language: language, textScale: 2));
        await tester.pumpAndSettle();

        // A RenderFlex overflow paints Flutter's striped bar and is reported
        // as an exception; `takeException` is how the framework surfaces one
        // that happened during layout rather than during the pump.
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('the text actually doubles rather than being clamped', (
      tester,
    ) async {
      await tester.pumpWidget(_catalog(language: AppLanguage.ar, textScale: 2));
      await tester.pumpAndSettle();

      // A `MediaQuery` that swallows the user's setting passes the overflow
      // test above for the wrong reason.
      final scaler = MediaQuery.textScalerOf(
        tester.element(find.byType(EjadahPrimaryButton).first),
      );
      expect(scaler.scale(10), 20);
    });
  });

  group('reduce motion', () {
    testWidgets('a press applies no scale when it is on', (tester) async {
      await tester.pumpWidget(
        _catalog(language: AppLanguage.en, reduceMotion: true),
      );
      await tester.pumpAndSettle();

      final target = find.byType(EjadahPrimaryButton).first;
      final gesture = await tester.startGesture(tester.getCenter(target));
      await tester.pump(const Duration(milliseconds: 200));

      // The transform is not animated faster — it is not applied at all.
      // A vestibular trigger shortened is still a vestibular trigger.
      expect(
        tester
            .widget<AnimatedScale>(
              find.descendant(of: target, matching: find.byType(AnimatedScale)),
            )
            .scale,
        1,
      );

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('the same press does scale when it is off', (tester) async {
      await tester.pumpWidget(_catalog(language: AppLanguage.en));
      await tester.pumpAndSettle();

      final target = find.byType(EjadahPrimaryButton).first;
      final gesture = await tester.startGesture(tester.getCenter(target));
      await tester.pump(const Duration(milliseconds: 200));

      // Proves the test above is measuring reduce-motion and not a component
      // that never scaled in the first place.
      expect(
        tester
            .widget<AnimatedScale>(
              find.descendant(of: target, matching: find.byType(AnimatedScale)),
            )
            .scale,
        lessThan(1),
      );

      await gesture.up();
      await tester.pumpAndSettle();
    });
  });

  _rtlRendering();

  group('contrast', () {
    for (final language in AppLanguage.values) {
      testWidgets('text passes AA over the real catalog in ${language.name}', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(_catalog(language: language));
        await tester.pumpAndSettle();

        // The unit tests measure token pairs. This measures what is actually
        // painted, composited surfaces and all.
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });
    }
  });
}

/// Which part of the catalog to render. Whole thing unless a test needs one
/// component isolated.
enum _CatalogSlice { all, chip }

Widget _catalog({
  required AppLanguage language,
  _CatalogSlice only = _CatalogSlice.all,
  double textScale = 1,
  bool reduceMotion = false,
}) {
  final isArabic = language == AppLanguage.ar;
  final label = isArabic ? 'احجز جلسة' : 'Book a session';
  final short = isArabic ? 'حفظ' : 'Save';

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: buildEjadahTheme(
      language: language,
      windowClass: EjadahWindowClass.compact,
      reduceMotion: reduceMotion,
    ),
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: EjadahColors.background,
            body: SafeArea(
              child: GradientBudget(
                child: ListView(
                  padding: const EdgeInsets.all(EjadahSpacing.md),
                  children: only == _CatalogSlice.chip
                      ? _chips(label)
                      : _everything(label: label, short: short),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

List<Widget> _chips(String label) => [
  Wrap(
    spacing: EjadahSpacing.xs,
    children: [
      EjadahFilterChip(label: label, isSelected: false, onTap: () {}),
      EjadahFilterChip(label: label, isSelected: true, count: 12, onTap: () {}),
    ],
  ),
];

/// Every interactive component in the catalog, once each.
///
/// Non-interactive components are here too: the 200% and contrast sweeps apply
/// to them, and a badge that clips at 200% is as broken as a button that does.
List<Widget> _everything({required String label, required String short}) => [
  EjadahPrimaryButton(label: label, onPressed: () {}),
  const SizedBox(height: EjadahSpacing.xs),
  EjadahSecondaryButton(label: label, onPressed: () {}),
  const SizedBox(height: EjadahSpacing.xs),
  EjadahGhostButton(label: short, onPressed: () {}),
  const SizedBox(height: EjadahSpacing.xs),
  EjadahDestructiveButton(label: short, onPressed: () {}),
  const SizedBox(height: EjadahSpacing.xs),
  Row(
    children: [
      EjadahIconButton(
        icon: EjadahIcons.save,
        semanticLabel: short,
        onPressed: () {},
      ),
      EjadahIconButton(
        icon: EjadahIcons.share,
        semanticLabel: label,
        onPressed: () {},
      ),
    ],
  ),
  const SizedBox(height: EjadahSpacing.xs),
  ..._chips(label),
  const SizedBox(height: EjadahSpacing.xs),
  EjadahInput(label: label, hint: short, controller: TextEditingController()),
  const SizedBox(height: EjadahSpacing.xs),
  EjadahSearchField(
    hint: label,
    controller: TextEditingController(),
    onSubmitted: (_) {},
    clearLabel: short,
  ),
  const SizedBox(height: EjadahSpacing.xs),
  Wrap(
    spacing: EjadahSpacing.xs,
    children: [
      EjadahBadge(
        label: short,
        foreground: EjadahColors.successText,
        background: EjadahColors.tint(EjadahColors.success, 0.10),
      ),
      EjadahTag(label),
    ],
  ),
  const SizedBox(height: EjadahSpacing.xs),
  EjadahValueSlider(
    label: label,
    value: 3,
    min: 1,
    max: 10,
    divisions: 9,
    onChanged: (_) {},
    valueLabel: const Text('3'),
  ),
];

/// RTL rendering rules, asserted on what is painted rather than on the rule.
///
/// Both of the bugs these cover were invisible to a test that checked
/// `mirrorsInRtl(chevron) == true` — the list was right and the rendering was
/// not, which is the failure mode a rule-level assertion cannot see.
void _rtlRendering() {
  /// The net horizontal flip applied to the glyph, as a sign.
  ///
  /// Every mirroring mechanism in play — `Icon`'s own `matchTextDirection`
  /// handling and `Transform.flip` — lands as a `Transform` in the tree, so
  /// multiplying their x-scales is the whole answer. Negative means mirrored
  /// an odd number of times, which is what "mirrored" means on screen;
  /// positive means either untouched or flipped twice, which look identical
  /// and are the bug this measures.
  double netFlip(WidgetTester tester) => tester
      .widgetList<Transform>(find.byType(Transform))
      .map((widget) => widget.transform.entry(0, 0))
      .fold<double>(1, (product, scale) => product * scale)
      .sign;

  group('icon mirroring, measured', () {
    testWidgets('a chevron is mirrored exactly once in Arabic', (tester) async {
      Future<double> flipFor(TextDirection direction) async {
        await tester.pumpWidget(
          Directionality(
            textDirection: direction,
            child: const DirectionalIcon(EjadahIcons.chevronForward),
          ),
        );
        return netFlip(tester);
      }

      expect(await flipFor(TextDirection.ltr), 1);
      // Material's chevron carries `matchTextDirection: true`, so `Icon` has
      // already flipped it by the time anything else looks. A second flip on
      // top is the identity, and the arrow ends up pointing the way the
      // language does not read.
      expect(
        await flipFor(TextDirection.rtl),
        -1,
        reason: 'the chevron must be mirrored exactly once in Arabic',
      );
    });

    testWidgets('a clock is never mirrored', (tester) async {
      Future<double> flipFor(TextDirection direction) async {
        await tester.pumpWidget(
          Directionality(
            textDirection: direction,
            child: const DirectionalIcon(EjadahIcons.clock),
          ),
        );
        return netFlip(tester);
      }

      // Proves the test above measures mirroring rather than "RTL is
      // different": a clock face reads the same way in both languages.
      expect(await flipFor(TextDirection.ltr), 1);
      expect(await flipFor(TextDirection.rtl), 1);
    });
  });
}
