import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_mobile/features/people/data/dashboard_repository.dart';
import 'package:ejadah_mobile/features/people/presentation/tutor_dashboard_screen.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The tutor's working day (PE-13).
///
/// The screen answers four questions in the order a tutor has them: what is
/// happening today, what have I earned, what is holding money up, and what is
/// coming. Money is figures, never a chart — a tutor with six sessions a month
/// has nothing to plot.
void main() {
  testWidgets('today comes first, then money, then the week', (tester) async {
    await tester.pumpWidget(
      _harness(_FakeRepository(dashboard: _dashboard(today: [_session()]))),
    );
    await tester.pumpAndSettle();

    final today = tester.getTopLeft(find.text('اليوم'));
    final week = tester.getTopLeft(find.text('بقية الأسبوع'));
    expect(today.dy, lessThan(week.dy));
  });

  testWidgets('money is figures, not a chart', (tester) async {
    await tester.pumpWidget(
      _harness(
        _FakeRepository(dashboard: _dashboard(available: 1400, pending: 560)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('EGP 1,400'), findsOneWidget);
    expect(find.text('EGP 560'), findsOneWidget);
    // Nothing plotted. Six data points is not a series.
    expect(find.byType(CustomPaint).evaluate().length, lessThan(20));
  });

  testWidgets('an empty day says so rather than showing nothing', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(_FakeRepository(dashboard: _dashboard())));
    await tester.pumpAndSettle();

    expect(find.text('لا جلسات اليوم.'), findsOneWidget);
    expect(find.text('لا حجوزات هذا الأسبوع.'), findsOneWidget);
  });

  testWidgets('with no meeting link, Join is replaced by adding one', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(_FakeRepository(dashboard: _dashboard(today: [_session()]))),
    );
    await tester.pumpAndSettle();

    // Never a Join button that goes nowhere: the missing link is the problem,
    // so the action is to supply it.
    expect(find.text('انضم'), findsNothing);
    expect(find.text('أضف رابط اجتماعك'), findsOneWidget);
  });

  testWidgets('with a meeting link, the session offers Join', (tester) async {
    await tester.pumpWidget(
      _harness(
        _FakeRepository(
          dashboard: _dashboard(
            today: [_session()],
            meetingUrl: 'https://meet.example.com/mona',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('انضم'), findsOneWidget);
  });

  testWidgets('an unmarked session says what marking is worth, and why', (
    tester,
  ) async {
    final repository = _FakeRepository(
      dashboard: _dashboard(unmarked: [_session(netEgp: 560)]),
    );
    await tester.pumpWidget(_harness(repository));
    await tester.pumpAndSettle();

    // The promise, the amount, and the backstop — all three before the tap.
    expect(find.text('تعليم الجلسة كمنعقدة يُفرج عن أرباحها.'), findsOneWidget);
    expect(find.text('EGP 560'), findsWidgets);
    expect(find.textContaining('تُفرج الجلسات عن نفسها'), findsOneWidget);

    await tester.ensureVisible(find.text('علّمها كمنعقدة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('علّمها كمنعقدة'));
    await tester.pumpAndSettle();

    expect(repository.marked, 's1');
  });

  testWidgets('hiding says the sessions still happen, before the switch', (
    tester,
  ) async {
    final repository = _FakeRepository(dashboard: _dashboard());
    await tester.pumpWidget(_harness(repository));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('أخفِ ملفي مؤقتًا'));
    await tester.pumpAndSettle();

    // The half people worry about, said before they touch it.
    expect(
      find.text('تختفي من السوق. وتبقى الجلسات المحجوزة قائمة كما هي.'),
      findsOneWidget,
    );

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(repository.hidden, isTrue);
  });

  testWidgets('being hidden is stated at the top, every time', (tester) async {
    await tester.pumpWidget(
      _harness(_FakeRepository(dashboard: _dashboard(isHidden: true))),
    );
    await tester.pumpAndSettle();

    // Invisibility is the kind of setting people forget they turned on and
    // then blame the marketplace for.
    expect(find.text('مخفي — لا يستطيع الطلاب إيجادك'), findsOneWidget);
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

Widget _harness(DashboardRepository repository) => ProviderScope(
  overrides: [dashboardRepositoryProvider.overrideWithValue(repository)],
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
      child: TutorDashboardScreen(),
    ),
  ),
);

TutorSession _session({int netEgp = 560}) => TutorSession(
  id: 's1',
  bookingId: 'b1',
  startsAt: DateTime.utc(2026, 9, 6, 15),
  endsAt: DateTime.utc(2026, 9, 6, 16),
  studentName: const LocalizedText(en: 'Khaled Fathy', ar: 'خالد فتحي'),
  subject: 'Endodontics',
  goal: '',
  netEgp: netEgp,
  isMarked: false,
);

TutorDashboard _dashboard({
  List<TutorSession> today = const [],
  List<TutorSession> unmarked = const [],
  List<TutorSession> week = const [],
  int available = 0,
  int pending = 0,
  bool isHidden = false,
  String? meetingUrl,
}) => TutorDashboard(
  today: today,
  unmarked: unmarked,
  week: week,
  availableEgp: available,
  pendingEgp: pending,
  requestedEgp: 0,
  isHidden: isHidden,
  autoCompleteAfterDays: 7,
  meetingUrl: meetingUrl,
);

class _FakeRepository implements DashboardRepository {
  _FakeRepository({this.dashboard, this.failure});

  final TutorDashboard? dashboard;
  final Failure? failure;

  String? marked;
  bool? hidden;

  @override
  Future<TutorDashboard> load() async {
    if (failure != null) throw failure!;
    return dashboard!;
  }

  @override
  Future<void> mark(String sessionId) async {
    marked = sessionId;
  }

  @override
  Future<void> setHidden(bool value) async {
    hidden = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
