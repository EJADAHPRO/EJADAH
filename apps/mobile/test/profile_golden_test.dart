import 'dart:io';

import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_mobile/features/profile/data/profile_repository.dart';
import 'package:ejadah_mobile/features/profile/presentation/certificates_screen.dart';
import 'package:ejadah_mobile/features/profile/presentation/public_profile_screen.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Visual cover for the two screens the product's credibility rests on.
///
/// Both are rendered in **both** languages, because Arabic is not English with
/// a different font: the family, line-heights and the whole layout direction
/// change, and a card that reads correctly in English can be broken in Arabic.
///
/// The certificate golden deliberately puts a verified and a stated
/// certificate side by side. Conflating those two is the single failure this
/// product cannot survive, so it is pinned as a picture, not only as a unit
/// test: the icon, the colour and the words must all differ, and a change that
/// quietly makes the stated one look verified fails here.
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadBundledFonts();
  });

  for (final language in AppLanguage.values) {
    final suffix = language.code;

    testWidgets('certificate list, verified beside stated ($suffix)', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 1700));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _Harness(
          language: language,
          repository: _FakeProfileRepository(),
          child: const CertificatesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(CertificatesScreen),
        matchesGoldenFile('goldens/certificates_$suffix.png'),
      );
    });

    testWidgets('public profile ($suffix)', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _Harness(
          language: language,
          repository: _FakeProfileRepository(),
          child: const PublicProfileScreen(slug: 'nour-hassan'),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(PublicProfileScreen),
        matchesGoldenFile('goldens/public_profile_$suffix.png'),
      );
    });
  }

  testWidgets('the public card carries only the verified certificate', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _Harness(
        language: AppLanguage.en,
        repository: _FakeProfileRepository(),
        child: const PublicProfileScreen(slug: 'nour-hassan'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Rotary & reciprocating endodontics'), findsOneWidget);
    // The stated one the same person holds never reaches a public page.
    expect(find.text('Clear aligner therapy weekend'), findsNothing);
  });

  testWidgets('verified and stated read differently in the owner list', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 1700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _Harness(
        language: AppLanguage.en,
        repository: _FakeProfileRepository(),
        child: const CertificatesScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Different words, not merely a different colour. Read from the string
    // table rather than pinned as literals, so approved copy can be revised
    // without the assertion quietly becoming a test of stale wording.
    final strings = EjadahStrings.of(
      tester.element(find.byType(CertificatesScreen)),
    );
    expect(strings.verifiedByEjadah, isNot(strings.statedByTutor));
    expect(find.text(strings.verifiedByEjadah), findsOneWidget);
    expect(find.text(strings.statedByTutor), findsOneWidget);
    expect(find.text(strings.notVerified), findsOneWidget);
    // Only the verified one carries a code to check.
    expect(find.text('EJ-DEMO-0001'), findsOneWidget);
  });
}

/// A MaterialApp configured exactly as the real app configures itself:
/// locale, direction, Ejadah theme and the string tables.
class _Harness extends StatelessWidget {
  const _Harness({
    required this.language,
    required this.repository,
    required this.child,
  });

  final AppLanguage language;
  final ProfileRepository repository;
  final Widget child;

  @override
  Widget build(BuildContext context) => ProviderScope(
    overrides: [profileRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Locale(language.code),
      supportedLocales: ejadahSupportedLocales,
      localizationsDelegates: EjadahStrings.localizationsDelegates,
      theme: buildEjadahTheme(
        language: language,
        windowClass: EjadahWindowClass.compact,
        // Goldens capture layout, not animation.
        reduceMotion: true,
      ),
      builder: (context, child) => Directionality(
        textDirection: language.isRtl ? TextDirection.rtl : TextDirection.ltr,
        // Routes get a budget automatically; this harness installs one so the
        // screens render exactly as they do under the router.
        child: GradientBudget(
          screenName: 'golden',
          child: child ?? const SizedBox.shrink(),
        ),
      ),
      home: child,
    ),
  );
}

/// Fixed data, so a golden captures the design rather than the day's records.
class _FakeProfileRepository implements ProfileRepository {
  static final _verified = Certificate(
    id: 'c1',
    title: const LocalizedText(
      en: 'Rotary & reciprocating endodontics',
      ar: 'المعالجة اللبية بالمبارد الدوّارة',
    ),
    issuer: const LocalizedText(
      en: 'Ejadah International Academy',
      ar: 'أكاديمية إجادة الدولية',
    ),
    issuedOn: DateTime.utc(2026, 5, 12),
    evidence: CredentialEvidence.verifiedByEjadah,
    cpdPoints: 8,
    verificationCode: 'EJ-DEMO-0001',
    courseId: 1,
  );

  static final _stated = Certificate(
    id: 'c2',
    title: const LocalizedText(
      en: 'Clear aligner therapy weekend',
      ar: 'ورشة التقويم الشفاف',
    ),
    issuer: const LocalizedText(
      en: 'Cairo Dental Congress',
      ar: 'مؤتمر القاهرة لطب الأسنان',
    ),
    issuedOn: DateTime.utc(2025, 11, 2),
    evidence: CredentialEvidence.statedByProfessional,
    cpdPoints: 3,
  );

  @override
  Future<List<Certificate>> certificates() async => [_verified, _stated];

  @override
  Future<PublicProfileView> publicProfile(String slug) async =>
      PublicProfileView(
        profile: PublicProfile(
          slug: slug,
          displayName: const LocalizedText(
            en: 'Dr. Nour Hassan',
            ar: 'د. نور حسن',
          ),
          title: const LocalizedText(
            en: 'General dentist · Endodontics',
            ar: 'طبيبة أسنان عامة · علاج الجذور',
          ),
          clinic: const LocalizedText(
            en: 'Nile Dental Studio, Zamalek, Cairo',
            ar: 'نايل دنتال ستوديو، الزمالك، القاهرة',
          ),
          bio: const LocalizedText(
            en:
                'Root canal treatment and digital workflows. '
                'Cairo University, 2023.',
            ar: 'علاج الجذور وسير العمل الرقمي. جامعة القاهرة، 2023.',
          ),
          // Only verified certificates ever reach a public card.
          certificates: [_verified],
          links: const {'website': 'https://ejadah.international'},
        ),
        shareUrl: 'https://ejadah.international/dr/$slug',
      );

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not used here');
}

/// Registers the bundled families with the test font collection.
///
/// Without them Flutter renders the test placeholder face and the goldens
/// would prove nothing about typography — which is most of what an Arabic
/// layout is.
Future<void> _loadBundledFonts() async {
  const families = {
    'Playfair Display': 'PlayfairDisplay-Variable.ttf',
    'Inter': 'Inter-Variable.ttf',
    'Amiri': 'Amiri-Bold.ttf',
    'IBM Plex Sans Arabic': 'IBMPlexSansArabic-Regular.ttf',
  };

  for (final entry in families.entries) {
    final file = File('../../packages/ejadah_ui/assets/fonts/${entry.value}');
    if (!file.existsSync()) continue;
    final loader = FontLoader(entry.key)
      ..addFont(Future.value(file.readAsBytesSync().buffer.asByteData()));
    await loader.load();
  }
}
