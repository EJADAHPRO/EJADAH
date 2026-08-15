import 'dart:io';

import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_mobile/features/learn/presentation/widgets/course_card.dart';
import 'package:ejadah_mobile/features/learn/presentation/widgets/flashcard_view.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Visual regression cover for the two Learn surfaces a user looks at most.
///
/// Both languages are rendered, because Arabic is not English in a different
/// font: the family, line-heights, tracking and the whole layout direction
/// change. Two things these goldens exist to catch specifically:
///
/// * the course card must never show a price — courses are in-app purchase
///   only and the store is the pricing authority;
/// * the numbers on both cards ("6 lessons", "84 minutes") must stay in
///   Western digits, in the right order, inside an Arabic paragraph.
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadBundledFonts();
  });

  for (final language in AppLanguage.values) {
    final suffix = language.code;

    testWidgets('course card renders ($suffix)', (tester) async {
      await tester.pumpWidget(
        _Frame(
          language: language,
          child: CourseCard(course: _sampleCourse, onTap: () {}),
        ),
      );
      await expectLater(
        find.byType(_Frame),
        matchesGoldenFile('goldens/course_card_$suffix.png'),
      );
    });

    testWidgets('owned course card renders ($suffix)', (tester) async {
      await tester.pumpWidget(
        _Frame(
          language: language,
          child: CourseCard(course: _ownedCourse, onTap: () {}, progress: 0.4),
        ),
      );
      await expectLater(
        find.byType(_Frame),
        matchesGoldenFile('goldens/course_card_owned_$suffix.png'),
      );
    });

    testWidgets('flashcard front renders ($suffix)', (tester) async {
      await tester.pumpWidget(
        _Frame(
          language: language,
          child: FlashcardView(
            card: _sampleCard,
            isFlipped: false,
            onFlip: () {},
          ),
        ),
      );
      await expectLater(
        find.byType(_Frame),
        matchesGoldenFile('goldens/flashcard_$suffix.png'),
      );
    });

    testWidgets('flashcard back renders ($suffix)', (tester) async {
      await tester.pumpWidget(
        _Frame(
          language: language,
          child: FlashcardView(
            card: _sampleCard,
            isFlipped: true,
            onFlip: () {},
          ),
        ),
      );
      await expectLater(
        find.byType(_Frame),
        matchesGoldenFile('goldens/flashcard_back_$suffix.png'),
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
    supportedLocales: ejadahSupportedLocales,
    localizationsDelegates: EjadahStrings.localizationsDelegates,
    theme: buildEjadahTheme(
      language: language,
      windowClass: EjadahWindowClass.compact,
      // Reduce motion pins the skeleton shimmer and the card's press
      // animation, so a golden cannot capture a mid-animation frame.
      reduceMotion: true,
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

const Course _sampleCourse = Course(
  id: 1,
  slug: 'aligner-case-selection',
  title: LocalizedText(
    en: 'Clear aligner case selection and staging',
    ar: 'اختيار الحالات والتدريج في المصففات الشفافة',
  ),
  subtitle: LocalizedText(
    en: 'Which cases aligners finish well, and which belong in brackets.',
    ar: 'أي الحالات تنهيها المصففات جيدًا، وأيها يبقى للأجهزة الثابتة.',
  ),
  department: Department.orthodontics,
  lessonCount: 6,
  totalMinutes: 84,
  cpdPoints: 6,
  instructorName: LocalizedText(en: 'Dr. Yasmin Farouk', ar: 'د. ياسمين فاروق'),
  instructorBio: LocalizedText.same(''),
  iapProductId: 'international.ejadah.course.aligner_case_selection',
  isOwned: false,
  level: LocalizedText(en: 'Intermediate', ar: 'متوسط'),
);

const Course _ownedCourse = Course(
  id: 2,
  slug: 'intraoral-scanning',
  title: LocalizedText(
    en: 'Intraoral scanning the lab can actually use',
    ar: 'المسح داخل الفم بجودة يقبلها المعمل',
  ),
  subtitle: LocalizedText(
    en: 'Scan strategy, soft-tissue control and the errors that cost a remake.',
    ar: 'استراتيجية المسح والتحكم بالأنسجة والأخطاء التي تكلّف إعادة العمل.',
  ),
  department: Department.digital,
  lessonCount: 5,
  totalMinutes: 67,
  cpdPoints: 4,
  instructorName: LocalizedText(en: 'Dr. Karim Nabil', ar: 'د. كريم نبيل'),
  instructorBio: LocalizedText.same(''),
  iapProductId: 'international.ejadah.course.intraoral_scanning',
  isOwned: true,
  level: LocalizedText(en: 'Foundation', ar: 'تمهيدي'),
);

const Flashcard _sampleCard = Flashcard(
  id: 1,
  deckId: 1,
  front: LocalizedText(
    en: 'How much rotation of a lower premolar is realistic per stage?',
    ar: 'كم مقدار دوران الضاحك السفلي الواقعي في كل مرحلة؟',
  ),
  back: LocalizedText(
    en: 'About 2 degrees per aligner, with an optimised attachment.',
    ar: 'نحو درجتين لكل مصفف، مع ملحق محسّن.',
  ),
  intervalDays: 6,
  repetitions: 2,
  dueOn: null,
);

/// Registers the bundled families with the test font collection.
///
/// Without them Flutter renders its placeholder face and the goldens would
/// prove nothing about the typography, which is half of what they exist for.
Future<void> _loadBundledFonts() async {
  const families = {
    'Playfair Display':
        '../../packages/ejadah_ui/assets/fonts/PlayfairDisplay-Variable.ttf',
    'Inter': '../../packages/ejadah_ui/assets/fonts/Inter-Variable.ttf',
    'Amiri': '../../packages/ejadah_ui/assets/fonts/Amiri-Bold.ttf',
    'IBM Plex Sans Arabic':
        '../../packages/ejadah_ui/assets/fonts/IBMPlexSansArabic-Regular.ttf',
  };

  for (final entry in families.entries) {
    final file = File(entry.value);
    if (!file.existsSync()) continue;
    final loader = FontLoader(entry.key)
      ..addFont(Future.value(file.readAsBytesSync().buffer.asByteData()));
    await loader.load();
  }
}
