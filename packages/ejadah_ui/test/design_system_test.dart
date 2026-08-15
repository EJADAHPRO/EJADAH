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
  });

  group('gradient discipline', () {
    test('the budget is six and the permitted uses are the six named ones', () {
      expect(EjadahGradient.maxPerScreen, 6);
      expect(GradientUse.values, hasLength(6));
      expect(RawTokens.gradientPermittedUses, hasLength(6));
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
        child: Scaffold(body: Center(child: child)),
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
