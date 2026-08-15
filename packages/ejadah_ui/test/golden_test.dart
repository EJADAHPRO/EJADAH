import 'dart:io';

import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Visual regression cover for the components that carry the Ejadah identity.
///
/// Both languages are rendered, because Arabic is not English with a different
/// font: the type family, line-heights, tracking and the whole layout direction
/// change, and a card that looks right in English can be broken in Arabic.
///
/// The bundled fonts are loaded first — without them Flutter renders the test
/// placeholder face and the goldens would prove nothing about typography.
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadBundledFonts();
  });

  for (final language in AppLanguage.values) {
    final suffix = language.code;

    testWidgets('programme card renders ($suffix)', (tester) async {
      await tester.pumpWidget(
        _Frame(
          language: language,
          child: _ProgrammeCardSample(language: language),
        ),
      );
      await expectLater(
        find.byType(_Frame),
        matchesGoldenFile('goldens/programme_card_$suffix.png'),
      );
    });

    testWidgets('sourced facts and badges render ($suffix)', (tester) async {
      await tester.pumpWidget(
        _Frame(
          language: language,
          child: _BadgeSample(language: language),
        ),
      );
      await expectLater(
        find.byType(_Frame),
        matchesGoldenFile('goldens/badges_$suffix.png'),
      );
    });

    testWidgets('buttons render ($suffix)', (tester) async {
      await tester.pumpWidget(
        _Frame(
          language: language,
          child: _ButtonSample(language: language),
        ),
      );
      await expectLater(
        find.byType(_Frame),
        matchesGoldenFile('goldens/buttons_$suffix.png'),
      );
    });
  }
}

/// A fixed-size frame so a golden captures layout, not window size.
class _Frame extends StatelessWidget {
  const _Frame({required this.language, required this.child});

  final AppLanguage language;
  final Widget child;

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
  );
}

class _ProgrammeCardSample extends StatelessWidget {
  const _ProgrammeCardSample({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) => EjadahCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // A Latin university name inside an Arabic card — the bidi island case.
        const CodeText("King's College London"),
        const SizedBox(height: EjadahSpacing.xxs),
        Text(
          language.isRtl ? 'ماجستير علاج الجذور' : 'MSc in Endodontology',
          style: context.type.h6(),
        ),
        const SizedBox(height: EjadahSpacing.xs),
        Text(
          language.isRtl ? 'لندن · المملكة المتحدة' : 'London · United Kingdom',
          style: context.type.small(color: EjadahColors.textSecondary),
        ),
        const SizedBox(height: EjadahSpacing.sm),
        Wrap(
          spacing: EjadahSpacing.xs,
          runSpacing: EjadahSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DeadlineBadge(
              status: DeadlineStatus.closingSoon,
              daysRemaining: 14,
              closingSoonLabel: language.isRtl ? '14 يومًا' : '14 days left',
              openLabel: language.isRtl ? 'مفتوح الآن' : 'Open now',
              closedLabel: language.isRtl ? 'انتهى' : 'Past deadline',
            ),
            const EjadahTag('MSc'),
            const CurrencyText(amount: 48800, currency: 'USD'),
          ],
        ),
      ],
    ),
  );
}

class _BadgeSample extends StatelessWidget {
  const _BadgeSample({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      // Verified and stated must be distinguishable at a glance.
      VerificationBadge(
        evidence: CredentialEvidence.verifiedByEjadah,
        verifiedLabel: language.isRtl ? 'موثّق من إجادة' : 'Verified by Ejadah',
        statedLabel: language.isRtl
            ? 'مُقدَّم من المدرّس'
            : 'Stated by the tutor',
      ),
      const SizedBox(height: EjadahSpacing.xs),
      VerificationBadge(
        evidence: CredentialEvidence.statedByProfessional,
        verifiedLabel: language.isRtl ? 'موثّق من إجادة' : 'Verified by Ejadah',
        statedLabel: language.isRtl
            ? 'مُقدَّم من المدرّس'
            : 'Stated by the tutor',
      ),
      const SizedBox(height: EjadahSpacing.md),
      // The exact words for an unsourced fact.
      SourcedValue(
        value: const Sourced<String>.pending(),
        pendingLabel: language.isRtl ? 'بانتظار المصدر' : 'Pending source',
      ),
      const SizedBox(height: EjadahSpacing.xs),
      const SourcedValue(
        value: Sourced<String>(value: r'$975', status: SourceStatus.verified),
        pendingLabel: 'Pending source',
      ),
      const SizedBox(height: EjadahSpacing.md),
      InlineAlert(
        title: language.isRtl ? 'احترس' : 'Watch out',
        message: language.isRtl
            ? 'التكلفة المعتادة تتجاوز ميزانيتك المعلنة بنحو 3,000 دولار.'
            : 'The typical cost runs about USD 3,000 above your stated budget.',
      ),
    ],
  );
}

class _ButtonSample extends StatelessWidget {
  const _ButtonSample({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      EjadahPrimaryButton(
        label: language.isRtl ? 'أنشئ خارطة مساري' : 'Build my roadmap',
        onPressed: () {},
      ),
      const SizedBox(height: EjadahSpacing.sm),
      EjadahSecondaryButton(
        label: language.isRtl ? 'افتح الدليل' : 'Open the guide',
        onPressed: () {},
      ),
      const SizedBox(height: EjadahSpacing.sm),
      EjadahPrimaryButton(
        label: language.isRtl ? 'جارٍ الحفظ' : 'Saving',
        isLoading: true,
        onPressed: () {},
      ),
    ],
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
