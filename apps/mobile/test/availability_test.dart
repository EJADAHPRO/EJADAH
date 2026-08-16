import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_mobile/features/people/data/availability_repository.dart';
import 'package:ejadah_mobile/features/people/presentation/availability_screen.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The availability editor (PE-14).
///
/// The rule everything else serves: **a confirmed session is a promise.** A
/// tutor who removes hours somebody has booked is shown which students they
/// would be standing up — because the only other way those students find out is
/// by turning up to an empty call.
void main() {
  testWidgets('the week is seven days, each with three blocks', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(_FakeRepository(availability: _empty())));
    await tester.pumpAndSettle();

    // Sunday first, in both languages — the schema's convention and the
    // booking calendar's.
    expect(find.byType(EjadahCard), findsNWidgets(7));
    expect(find.text('صباحًا'), findsNWidgets(7));
    expect(find.text('مساءً'), findsNWidgets(7));
  });

  testWidgets('tapping a block adds hours and the total follows', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(_FakeRepository(availability: _empty())));
    await tester.pumpAndSettle();

    // Evening is 17:00–21:00 — four hours.
    await tester.tap(find.text('مساءً').first);
    await tester.pump();

    expect(find.text('4 ساعة أسبوعيًا'), findsOneWidget);
  });

  testWidgets('below the floor the hint warns, above it does not', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(_FakeRepository(availability: _empty())));
    await tester.pumpAndSettle();

    // One evening is four hours against a five-hour floor.
    await tester.tap(find.text('مساءً').first);
    await tester.pump();
    expect(_hintColour(tester), EjadahColors.warningText);

    // A second day clears it. Below the fold on a short viewport, so scroll
    // the way a tutor would.
    await tester.ensureVisible(find.text('مساءً').at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('مساءً').at(1));
    await tester.pump();
    expect(_hintColour(tester), EjadahColors.textSecondary);
  });

  testWidgets('save is disabled until something changes', (tester) async {
    final repository = _FakeRepository(
      availability: _empty(
        rules: const [
          AvailabilityRule(weekday: 0, startMinute: 1020, endMinute: 1260),
        ],
      ),
    );
    await tester.pumpWidget(_harness(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('احفظ الساعات'));
    await tester.pumpAndSettle();
    expect(repository.savedRules, isNull);

    // Toggling the same block off is a change.
    await tester.tap(find.text('مساءً').first);
    await tester.pump();
    await tester.tap(find.text('احفظ الساعات'));
    await tester.pumpAndSettle();
    expect(repository.savedRules, isEmpty);
  });

  testWidgets('a chip tapped on and off again leaves nothing to save', (
    tester,
  ) async {
    final repository = _FakeRepository(availability: _empty());
    await tester.pumpWidget(_harness(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('صباحًا').first);
    await tester.pump();
    await tester.tap(find.text('صباحًا').first);
    await tester.pump();

    // The week is exactly as it was. Offering to save it is a button that
    // does nothing.
    await tester.tap(find.text('احفظ الساعات'));
    await tester.pumpAndSettle();
    expect(repository.savedRules, isNull);
  });

  testWidgets('a refused save names the students, and keeps the edit', (
    tester,
  ) async {
    final repository = _FakeRepository(
      availability: _empty(),
      clashOnSave: const AvailabilityClash(
        LocalizedText(
          en: 'You have confirmed sessions in that time.',
          ar: 'لديك جلسات مؤكدة في هذا الوقت.',
        ),
        [
          LocalizedText(en: 'Khaled Fathy — Endodontics', ar: 'خالد فتحي — علاج الجذور'),
          LocalizedText(en: 'Sara Nabil — Prosthodontics', ar: 'سارة نبيل — التركيبات'),
        ],
      ),
    );
    await tester.pumpWidget(_harness(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('مساءً').first);
    await tester.pump();
    await tester.tap(find.text('احفظ الساعات'));
    await tester.pumpAndSettle();

    // Every student, by name. "You have 2 conflicts" is not something a tutor
    // can act on.
    expect(find.text('جلسات في هذا الوقت'), findsOneWidget);
    expect(find.text('خالد فتحي — علاج الجذور'), findsOneWidget);
    expect(find.text('سارة نبيل — التركيبات'), findsOneWidget);

    await tester.tap(find.text('رجوع'));
    await tester.pumpAndSettle();

    // And the edit survived the refusal. Throwing away what someone just did
    // because the server said no is how an editor loses trust.
    expect(find.text('4 ساعة أسبوعيًا'), findsOneWidget);
  });

  testWidgets('with nothing blocked, time off says so', (tester) async {
    await tester.pumpWidget(_harness(_FakeRepository(availability: _empty())));
    await tester.pumpAndSettle();

    expect(find.text('لا يوجد شيء محجوب.'), findsOneWidget);
  });

  testWidgets('a blocked period is listed with its reason', (tester) async {
    await tester.pumpWidget(
      _harness(
        _FakeRepository(
          availability: _empty(
            exceptions: [
              AvailabilityException(
                id: 1,
                startsAt: DateTime.utc(2026, 9, 6, 8),
                endsAt: DateTime.utc(2026, 9, 9, 8),
                isAvailable: false,
                reason: 'Conference',
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The tutor's own words, not "blocked" — they wrote the reason so they
    // would recognise it later.
    await tester.scrollUntilVisible(find.text('Conference'), 200);
    expect(find.text('Conference'), findsOneWidget);
  });

  testWidgets('a failure states what happened and offers a retry', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(_FakeRepository(failure: const NetworkFailure())),
    );
    await tester.pumpAndSettle();

    expect(find.byType(EjadahErrorState), findsOneWidget);
  });
}

/// The colour of the weekly-hours hint under the grid, which is how it warns.
///
/// `.first` because the sticky bar carries the same sentence as its disabled
/// reason — deliberately, since the two say the same thing in two places a
/// tutor might be looking.
Color? _hintColour(WidgetTester tester) => tester
    .widget<Text>(find.textContaining('ما لا يقل عن').first)
    .style
    ?.color;

Widget _harness(AvailabilityRepository repository) => ProviderScope(
  overrides: [availabilityRepositoryProvider.overrideWithValue(repository)],
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
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
      child: AvailabilityScreen(),
    ),
  ),
);

Availability _empty({
  List<AvailabilityRule> rules = const [],
  List<AvailabilityException> exceptions = const [],
}) => Availability(
  rules: rules,
  exceptions: exceptions,
  weeklyMinutes: rules.fold(0, (total, rule) => total + rule.minutes),
  minimumWeeklyHours: 5,
);

class _FakeRepository implements AvailabilityRepository {
  _FakeRepository({this.availability, this.failure, this.clashOnSave});

  final Availability? availability;
  final Failure? failure;
  final AvailabilityClash? clashOnSave;

  List<AvailabilityRule>? savedRules;

  @override
  Future<Availability> load() async {
    if (failure != null) throw failure!;
    return availability!;
  }

  @override
  Future<void> saveRules(List<AvailabilityRule> rules) async {
    if (clashOnSave != null) throw clashOnSave!;
    savedRules = rules;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
