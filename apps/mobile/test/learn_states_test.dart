import 'dart:async';

import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_mobile/features/learn/data/learn_models.dart';
import 'package:ejadah_mobile/features/learn/data/learn_repository.dart';
import 'package:ejadah_mobile/features/learn/presentation/learn_screen.dart';
import 'package:ejadah_mobile/features/learn/presentation/widgets/learn_skeletons.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The three states every Learn screen owes the user.
///
/// The screen state matrix flags LN-01 and LN-02 as missing a loading
/// treatment, so the skeleton is asserted here rather than trusted: a spinner
/// slipping back in would pass a visual review and fail this test.
void main() {
  testWidgets('the hub shows a skeleton while the catalogue loads', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(_FakeLearnRepository(pending: Completer<Catalogue>())),
    );
    await tester.pump();

    expect(find.byType(LearnHubSkeleton), findsOneWidget);
    // Skeletons, not spinners.
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('a failure states what happened and offers a retry', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(_FakeLearnRepository(failure: const NetworkFailure())),
    );
    await tester.pumpAndSettle();

    expect(find.byType(EjadahErrorState), findsOneWidget);
    expect(find.text(FailureCopy.offline.ar), findsOneWidget);
  });

  testWidgets('an empty catalogue routes somewhere rather than dead-ending', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        _FakeLearnRepository(
          result: const Catalogue(courses: [], counts: {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(EjadahEmptyState), findsOneWidget);
  });

  testWidgets('a loaded catalogue shows the three department doors', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        _FakeLearnRepository(
          result: Catalogue(
            courses: const [_course],
            counts: const {
              Department.orthodontics: 1,
              Department.digital: 0,
              Department.businessParadental: 0,
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('التقويم'), findsOneWidget);
    expect(find.text('الرقمي'), findsOneWidget);
    expect(find.text('الأعمال والمساندة'), findsOneWidget);
  });
}

Widget _harness(LearnRepository repository) => ProviderScope(
  overrides: [learnRepositoryProvider.overrideWithValue(repository)],
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    // Arabic is the default, so the default test runs in Arabic.
    locale: const Locale('ar'),
    supportedLocales: ejadahSupportedLocales,
    localizationsDelegates: EjadahStrings.localizationsDelegates,
    theme: buildEjadahTheme(
      language: AppLanguage.ar,
      windowClass: EjadahWindowClass.compact,
      reduceMotion: true,
    ),
    home: const Directionality(
      textDirection: TextDirection.rtl,
      child: LearnScreen(),
    ),
  ),
);

const Course _course = Course(
  id: 1,
  slug: 'aligner-case-selection',
  title: LocalizedText(en: 'Aligners', ar: 'المصففات'),
  subtitle: LocalizedText.same(''),
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

/// Only `catalogue` is exercised by the hub. The remaining members are
/// generated as throwing stubs by declaring `noSuchMethod`, so a future change
/// that starts calling one fails loudly instead of silently returning null.
class _FakeLearnRepository implements LearnRepository {
  _FakeLearnRepository({this.result, this.failure, this.pending});

  final Catalogue? result;
  final Failure? failure;

  /// Never completed: the screen stays in its loading state.
  final Completer<Catalogue>? pending;

  @override
  Future<Catalogue> catalogue({Department? department}) {
    if (pending != null) return pending!.future;
    if (failure != null) return Future<Catalogue>.error(failure!);
    return Future<Catalogue>.value(result);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
