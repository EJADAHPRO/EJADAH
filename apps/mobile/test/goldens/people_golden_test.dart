import 'dart:io';

import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ejadah_mobile/features/people/presentation/widgets/professional_card.dart';
import 'package:ejadah_mobile/features/people/presentation/widgets/slot_grid.dart';

/// Visual regression cover for the two People surfaces that carry the most
/// product meaning.
///
/// Both are rendered in **both** languages, because Arabic is not English in a
/// different font: the family, line-heights, tracking and the entire layout
/// direction change, and a card that reads correctly in English can be broken
/// in Arabic.
///
/// What these goldens are actually protecting:
///
/// * the **professional card** — initials rather than a photograph, the mentor
///   journey as an LTR island inside an Arabic card, the rate as a currency
///   island, and the "New this month" badge standing in for an empty star row;
/// * the **slot grid** — a taken hour rendered as an inert tile rather than a
///   button, and clock times reading left-to-right inside a right-to-left page.
///
/// Fonts are loaded first. Without them Flutter draws the test placeholder face
/// and the goldens would prove nothing about typography at all.
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadBundledFonts();
  });

  for (final language in AppLanguage.values) {
    final suffix = language.code;

    testWidgets('professional card renders ($suffix)', (tester) async {
      await tester.pumpWidget(
        _Frame(language: language, child: _ProfessionalCardSample()),
      );
      await tester.pump();
      await expectLater(
        find.byType(_Frame),
        matchesGoldenFile('professional_card_$suffix.png'),
      );
    });

    testWidgets('slot grid renders ($suffix)', (tester) async {
      await tester.pumpWidget(
        _Frame(language: language, child: const _SlotGridSample()),
      );
      await tester.pump();
      await expectLater(
        find.byType(_Frame),
        matchesGoldenFile('slot_grid_$suffix.png'),
      );
    });
  }
}

/// A fixed-size frame so a golden captures layout rather than window size.
class _Frame extends StatelessWidget {
  const _Frame({required this.language, required this.child});

  final AppLanguage language;
  final Widget child;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: Locale(language.code),
    supportedLocales: ejadahSupportedLocales,
    localizationsDelegates: EjadahStrings.localizationsDelegates,
    theme: buildEjadahTheme(
      language: language,
      windowClass: EjadahWindowClass.compact,
      // Goldens must not race a shimmer: with motion suppressed the skeleton
      // and press states settle to a single deterministic frame.
      reduceMotion: true,
    ),
    home: Directionality(
      textDirection: language.isRtl ? TextDirection.rtl : TextDirection.ltr,
      // Every screen installs one; the components under test count their
      // gradients against it.
      child: GradientBudget(
        screenName: 'golden',
        child: Scaffold(
          backgroundColor: EjadahColors.background,
          body: Center(
            child: SizedBox(
              width: 360,
              child: Padding(
                padding: const EdgeInsets.all(EjadahSpacing.gutter),
                child: child,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// A mentor: the card leads with the journey, not with a rating.
class _ProfessionalCardSample extends StatelessWidget {
  _ProfessionalCardSample();

  final Professional _mentor = Professional(
    id: 1,
    slug: 'dr-mona-adel',
    kind: ServiceKind.mentoring,
    displayName: const LocalizedText(en: 'Dr. Mona Adel', ar: 'د. منى عادل'),
    headline: const LocalizedText(
      en: 'Cairo to London, 2021. ORE Part 1 and 2 first attempt.',
      ar: 'من القاهرة إلى لندن 2021. اجتزت ORE من المحاولة الأولى.',
    ),
    bio: const LocalizedText.same(''),
    specialties: const ['Endodontics'],
    languages: const ['ar', 'en'],
    hourlyRateEgp: 800,
    rating: null,
    // No reviews yet: the "New this month" badge stands in for an empty star
    // row, which reads as a bad score rather than as no score.
    reviewCount: 0,
    qualifications: const [],
    packages: const [],
    offersFreeIntroCall: true,
    isNewThisMonth: true,
    cancellationPolicy: const LocalizedText.same(''),
    // Null everywhere: no licensed photography exists, so the card falls back
    // to initials on the inset surface — never a broken image, never a stock
    // portrait of a stranger.
    journeyFrom: 'Cairo',
    journeyTo: 'London',
    journeyYear: 2021,
  );

  @override
  Widget build(BuildContext context) =>
      ProfessionalCard(professional: _mentor, onTap: () {}, onBook: () {});
}

/// A day of slots with one already taken.
class _SlotGridSample extends StatelessWidget {
  const _SlotGridSample();

  @override
  Widget build(BuildContext context) {
    // A fixed date so the golden does not move with the calendar.
    final day = DateTime.utc(2026, 9, 6, 8);
    final slots = [
      for (var hour = 0; hour < 5; hour++)
        AvailabilitySlot(
          startsAt: day.add(Duration(hours: hour)),
          endsAt: day.add(Duration(hours: hour + 1)),
          // The third hour is taken. It must render as an inert tile, not as a
          // button that rejects the tap.
          isAvailable: hour != 2,
        ),
    ];

    return SlotGrid(slots: slots, selected: slots.first, onSelect: (_) {});
  }
}

/// Registers the four bundled families with the test font collection.
Future<void> _loadBundledFonts() async {
  const root = '../../packages/ejadah_ui/assets/fonts';
  const families = {
    'Playfair Display': '$root/PlayfairDisplay-Variable.ttf',
    'Inter': '$root/Inter-Variable.ttf',
    'Amiri': '$root/Amiri-Bold.ttf',
    'IBM Plex Sans Arabic': '$root/IBMPlexSansArabic-Regular.ttf',
  };

  for (final entry in families.entries) {
    final file = File(entry.value);
    if (!file.existsSync()) continue;
    final loader = FontLoader(entry.key)
      ..addFont(Future.value(file.readAsBytesSync().buffer.asByteData()));
    await loader.load();
  }
}
