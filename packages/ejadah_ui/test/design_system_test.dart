import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Design-system rules that must not erode.
///
/// These are the constraints most likely to be broken by a well-meaning change:
/// contrast corrections, the gradient budget, Arabic type rules and RTL
/// mirroring. Each is asserted rather than left to review.
void main() {
  group('colour discipline', () {
    test('orange text uses the text-safe value, not the brand fill', () {
      // #FF6B1A measures 2.35:1 on the cream surface and fails AA as text.
      expect(EjadahColors.orangeText, isNot(EjadahColors.orange));
      expect(EjadahColors.orangeText, const Color(0xFFC2450F));
    });

    test('elevation resolves to tokens, not transcribed hex', () {
      // These were hand-written into Dart once. The generator emits them now,
      // so a change to DESIGN_TOKENS.json reaches the widgets instead of
      // silently leaving them on the old values.
      expect(EjadahElevation.card, RawTokens.elevationCard);
      expect(EjadahElevation.raised, RawTokens.elevationRaised);
      expect(EjadahElevation.overlay, RawTokens.elevationOverlay);
      expect(EjadahElevation.primaryGlow, RawTokens.elevationPrimaryGlow);
      expect(EjadahElevation.stickyTop, RawTokens.elevationStickyTop);
    });

    test('icon adornment sizes are named, not arithmetic', () {
      // `EjadahIconSize.inline - 4` at a call site is a raw value wearing a
      // token's clothes; the sizes it was reaching for have names now.
      expect(EjadahIconSize.badge, RawTokens.iconSizeBadge);
      expect(EjadahIconSize.adornment, RawTokens.iconSizeAdornment);
      expect(EjadahIconSize.badge, lessThan(EjadahIconSize.inline));
      expect(EjadahIconSize.adornment, lessThan(EjadahIconSize.inline));
    });

    test('the banned muted label is not a role anywhere', () {
      // #8E8A83 passed only in a mistaken legacy table.
      const banned = Color(0xFF8E8A83);
      expect(RawTokens.bannedMutedLabel, banned);
      expect(EjadahColors.labelMuted, isNot(banned));
      expect(EjadahColors.labelStrong, isNot(banned));
      expect(EjadahColors.textSecondary, isNot(banned));
    });

    test('AA contrast holds for the small-text roles on the app surface', () {
      // The two roles the handoff singles out for spot-checking.
      expect(
        _contrast(EjadahColors.labelMuted, EjadahColors.background),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(EjadahColors.textSecondary, EjadahColors.background),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(EjadahColors.orangeText, EjadahColors.background),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('every tinted surface carries text that passes AA on it', () {
      // The measurement that matters is against the *composited* surface, not
      // the token's own background. Each of these pairs was in the product;
      // `info` was reading its own base hue at 4.28:1 because the text member
      // of its family had never been added.
      final pairs = <String, (Color, Color, double)>{
        'warning': (EjadahColors.warningText, EjadahColors.amber, 0.10),
        'info': (EjadahColors.infoText, EjadahColors.info, 0.10),
        'success': (EjadahColors.successText, EjadahColors.success, 0.10),
        'danger': (EjadahColors.dangerText, EjadahColors.danger, 0.10),
      };

      pairs.forEach((name, pair) {
        final (text, base, opacity) = pair;
        expect(
          _contrast(text, EjadahColors.tint(base, opacity)),
          greaterThanOrEqualTo(4.5),
          reason: '$name alert text on its own tint',
        );
      });
    });

    test('the selected filter chip passes AA on its own tint', () {
      // `orangeText` sits at 4.83:1 on the plain surface, so the usual 8% tint
      // under it drops to 4.46. The chip uses the lighter tint instead of a
      // different text colour, because the text colour is canonical.
      expect(
        _contrast(
          EjadahColors.orangeText,
          EjadahColors.tint(
            EjadahColors.orange,
            EjadahColors.subtleTintOpacity,
          ),
        ),
        greaterThanOrEqualTo(4.5),
      );
    });
  });

  group('gradient discipline', () {
    test('the budget is six and the permitted uses are the six named ones', () {
      expect(EjadahGradient.maxPerScreen, 6);
      expect(GradientUse.values, hasLength(6));
      expect(RawTokens.gradientPermittedUses, hasLength(6));
    });

    test('a step list longer than the budget drops the gradient entirely', () {
      // Germany's guide has seven steps and a roadmap mirrors its destination's
      // guide one for one, so this is a real list, not a hypothetical. Marking
      // the first five and leaving the rest plain would read as a bug.
      expect(EjadahGradient.allowsStepMarkers(5), isTrue);
      expect(
        EjadahGradient.allowsStepMarkers(EjadahGradient.maxStepMarkers),
        isTrue,
      );
      expect(EjadahGradient.allowsStepMarkers(6), isFalse);
      expect(EjadahGradient.allowsStepMarkers(7), isFalse);

      // One under the screen budget: a stage list always shares its screen with
      // at least one other permitted use.
      expect(
        EjadahGradient.maxStepMarkers,
        lessThan(EjadahGradient.maxPerScreen),
      );
    });

    testWidgets('seven step markers stay inside the screen budget', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          language: AppLanguage.en,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              EjadahStepMarker(position: 1, total: 7),
              EjadahStepMarker(position: 2, total: 7),
              EjadahStepMarker(position: 3, total: 7),
              EjadahStepMarker(position: 4, total: 7),
              EjadahStepMarker(position: 5, total: 7),
              EjadahStepMarker(position: 6, total: 7),
              EjadahStepMarker(position: 7, total: 7),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // No gradient at all, and therefore no assertion: before this the seventh
      // marker tripped the budget and crashed the debug build on Germany.
      expect(find.byType(BrandGradient), findsNothing);
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('a short step list keeps the gradient', (tester) async {
      await tester.pumpWidget(
        _harness(
          language: AppLanguage.en,
          child: const EjadahStepMarker(position: 1, total: 4),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BrandGradient), findsOneWidget);
    });

    test('the angle mirrors with reading direction', () {
      final ltr = EjadahGradient.of(TextDirection.ltr);
      final rtl = EjadahGradient.of(TextDirection.rtl);

      // 135° in English, 225° in Arabic: the light comes from the leading edge
      // in both.
      expect(ltr.begin, Alignment.topLeft);
      expect(rtl.begin, Alignment.topRight);
      expect(rtl.colors, ltr.colors);
    });
  });

  group('Arabic typography', () {
    const arabic = EjadahTypography(AppLanguage.ar);
    const english = EjadahTypography(AppLanguage.en);

    test('Playfair is never used to render Arabic', () {
      // Playfair Display carries no Arabic glyphs; rendering it would produce
      // tofu, not a fallback.
      expect(english.displayFamily, 'Playfair Display');
      expect(arabic.displayFamily, 'Amiri');
      expect(arabic.bodyFamily, 'IBM Plex Sans Arabic');
    });

    test('Arabic line-heights are raised', () {
      for (final density in TextDensity.values) {
        expect(
          arabic.lineHeightFor(density),
          greaterThan(english.lineHeightFor(density)),
        );
      }
    });

    test('Arabic never carries letter spacing, including eyebrows', () {
      expect(arabic.letterSpacingFor(14), 0);
      expect(arabic.letterSpacingFor(12, isEyebrow: true), 0);
      // English eyebrows do.
      expect(english.letterSpacingFor(12, isEyebrow: true), greaterThan(0));
    });

    test('Arabic is never uppercased', () {
      const heading = 'دليل الدولة';
      expect(arabic.eyebrowText(heading), heading);
      expect(english.eyebrowText('country guide'), 'COUNTRY GUIDE');
    });

    test('Arabic headings shrink 12% above 28 characters', () {
      const short = 'دليل الدولة';
      final long = 'د' * 40;

      expect(arabic.headingSizeFor(28, short), 28);
      expect(arabic.headingSizeFor(28, long), closeTo(28 * 0.88, 0.001));
      // English is untouched at any length.
      expect(english.headingSizeFor(28, long), 28);
    });
  });

  group('icon mirroring', () {
    test('directional icons mirror and symbols do not', () {
      expect(EjadahIcons.mirrorsInRtl(EjadahIcons.chevronForward), isTrue);
      expect(EjadahIcons.mirrorsInRtl(EjadahIcons.back), isTrue);

      // A mirrored search glyph, clock or play triangle reads as broken.
      expect(EjadahIcons.mirrorsInRtl(EjadahIcons.search), isFalse);
      expect(EjadahIcons.mirrorsInRtl(EjadahIcons.clock), isFalse);
      expect(EjadahIcons.mirrorsInRtl(EjadahIcons.play), isFalse);
      expect(EjadahIcons.mirrorsInRtl(EjadahIcons.save), isFalse);
      expect(EjadahIcons.mirrorsInRtl(EjadahIcons.star), isFalse);
    });
  });

  group('spacing and sizing', () {
    test('the minimum tap target is 44', () {
      expect(EjadahSizes.tapTargetMin, 44);
    });

    test('the card radius is 20', () {
      expect(EjadahRadius.xl, 20);
    });

    test('every spacing constant is on the canonical scale', () {
      for (final value in [
        EjadahSpacing.xxs,
        EjadahSpacing.xs,
        EjadahSpacing.sm,
        EjadahSpacing.md,
        EjadahSpacing.gutter,
        EjadahSpacing.lg,
        EjadahSpacing.section,
        EjadahSpacing.xl,
        EjadahSpacing.xxl,
        EjadahSpacing.xxxl,
      ]) {
        expect(EjadahSpacing.scale, contains(value));
      }
    });
  });

  group('reduced motion', () {
    test('long durations are capped and short ones are left alone', () {
      expect(
        EjadahMotion.durationFor(EjadahMotion.slow, reduceMotion: true),
        EjadahMotion.fast,
      );
      expect(
        EjadahMotion.durationFor(EjadahMotion.slow, reduceMotion: false),
        EjadahMotion.slow,
      );
    });
  });

  group('bidi islands', () {
    testWidgets('currency reads LTR inside an Arabic page', (tester) async {
      await tester.pumpWidget(
        _harness(
          language: AppLanguage.ar,
          child: const CurrencyText(amount: 1400, currency: 'EGP'),
        ),
      );

      // The code leads the figure, and Western digits are grouped — the same
      // string an English page would show.
      expect(find.text('EGP 1,400'), findsOneWidget);

      final direction = Directionality.of(
        tester.element(find.text('EGP 1,400')),
      );
      expect(direction, TextDirection.ltr);
    });

    test('thousands are grouped with Western digits', () {
      expect(formatThousands(199), '199');
      expect(formatThousands(1400), '1,400');
      expect(formatThousands(105600), '105,600');
    });
  });

  group('states', () {
    testWidgets('an empty state always offers an action', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _harness(
          language: AppLanguage.ar,
          child: EjadahEmptyState(
            title: 'لا برامج محفوظة بعد',
            body: 'لا برامج محفوظة بعد — 17 برنامجًا مفتوح الآن.',
            actionLabel: 'تصفح البرامج',
            onAction: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('تصفح البرامج'));
      expect(tapped, isTrue, reason: 'an empty state must route to action');
    });

    testWidgets('the pending chip prints the exact words', (tester) async {
      await tester.pumpWidget(
        _harness(
          language: AppLanguage.ar,
          child: const SourcedValue(
            value: Sourced<String>.pending(),
            pendingLabel: 'بانتظار المصدر',
          ),
        ),
      );

      expect(find.text('بانتظار المصدر'), findsOneWidget);
      // Never a number, never a blank, never "N/A".
      expect(find.textContaining('0'), findsNothing);
    });
  });

  group('disabled controls explain themselves', () {
    testWidgets('a disabled primary button surfaces its reason', (
      tester,
    ) async {
      String? surfaced;
      await tester.pumpWidget(
        _harness(
          language: AppLanguage.en,
          child: EjadahPrimaryButton(
            label: 'Build my roadmap',
            onPressed: null,
            disabledReason: 'Answer the question to continue',
            onDisabledTap: (reason) => surfaced = reason,
          ),
        ),
      );

      await tester.tap(find.text('Build my roadmap'));
      expect(surfaced, 'Answer the question to continue');
    });
  });
}

/// Wraps a widget in the Ejadah theme for the given language.
Widget _harness({required AppLanguage language, required Widget child}) =>
    MaterialApp(
      theme: buildEjadahTheme(
        language: language,
        windowClass: EjadahWindowClass.compact,
      ),
      locale: Locale(language.code),
      home: Directionality(
        textDirection: language.isRtl ? TextDirection.rtl : TextDirection.ltr,
        // A component under test is on a screen, and screens carry a gradient
        // budget — so the harness carries one too, rather than the assertion
        // that enforces it being something tests have to work around.
        child: GradientBudget(
          screenName: 'test',
          child: Scaffold(body: Center(child: child)),
        ),
      ),
    );

/// WCAG relative-contrast ratio.
double _contrast(Color foreground, Color background) {
  final light = _luminance(foreground);
  final dark = _luminance(background);
  final brighter = light > dark ? light : dark;
  final darker = light > dark ? dark : light;
  return (brighter + 0.05) / (darker + 0.05);
}

double _luminance(Color color) {
  double channel(double value) {
    final normalized = value;
    return normalized <= 0.03928
        ? normalized / 12.92
        : _pow((normalized + 0.055) / 1.055, 2.4);
  }

  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}

double _pow(double base, double exponent) {
  var result = 1.0;
  var remaining = exponent;
  // A small integer/fractional power, adequate for the 2.4 exponent here.
  while (remaining >= 1) {
    result *= base;
    remaining -= 1;
  }
  // Fractional remainder by repeated square-root approximation.
  var fraction = remaining;
  var root = base;
  var step = 0.5;
  while (step > 0.001) {
    root = _sqrt(root);
    if (fraction >= step) {
      result *= root;
      fraction -= step;
    }
    step /= 2;
  }
  return result;
}

double _sqrt(double value) {
  var guess = value;
  for (var i = 0; i < 24; i++) {
    guess = (guess + value / guess) / 2;
  }
  return guess;
}
