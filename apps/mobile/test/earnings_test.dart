import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_mobile/features/people/data/earnings_repository.dart';
import 'package:ejadah_mobile/features/people/presentation/earnings_screen.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The tutor's ledger, on screen.
///
/// One rule decides this screen: never show a share without showing what was
/// taken to arrive at it. A single "your share" figure is the number a tutor
/// cannot check, and a marketplace whose supply side suspects the arithmetic
/// loses the supply side.
void main() {
  testWidgets('every row shows the whole subtraction', (tester) async {
    await tester.pumpWidget(
      _harness(
        _FakeRepository(
          earnings: _earnings(
            rows: [
              _row(gross: 1000, fee: 300, net: 700, subject: 'Endodontics'),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Gross, fee and net all present. The fee carries its sign — "300" beside
    // "1,000" would read as an amount received.
    expect(find.text('Endodontics'), findsOneWidget);
    expect(find.text('−300'), findsOneWidget);
    expect(find.text('700'), findsOneWidget);
  });

  testWidgets('the net comes from the server, not from subtracting here', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        _FakeRepository(
          earnings: _earnings(
            // Deliberately not gross − fee. If the screen ever starts doing
            // its own arithmetic this test is what notices.
            rows: [_row(gross: 1000, fee: 300, net: 111)],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('111'), findsOneWidget);
  });

  testWidgets('a cancelled session stays on the ledger, struck through', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        _FakeRepository(
          earnings: _earnings(
            rows: [
              _row(
                gross: 900,
                fee: 270,
                net: 630,
                status: EarningStatus.reversed,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Shown, not dropped: a ledger that quietly loses a line is one a tutor
    // cannot reconcile against their own memory of the month.
    expect(find.text('630'), findsOneWidget);
    final net = tester.widget<Text>(find.text('630'));
    expect(net.style?.decoration, TextDecoration.lineThrough);
  });

  testWidgets('below the floor, the shortfall is on the screen', (
    tester,
  ) async {
    final repository = _FakeRepository(
      earnings: _earnings(
        available: 280,
        blockedReason: const LocalizedText(
          en: 'Payouts start at EGP 500. You need EGP 220 more.',
          ar: 'يبدأ الصرف من 500 جنيهًا. تحتاج إلى 220 جنيهًا إضافيًا.',
        ),
      ),
    );
    await tester.pumpWidget(_harness(repository));
    await tester.pumpAndSettle();

    // The reason is visible above the button, not hidden behind a tap on a
    // control that merely looks broken.
    expect(find.textContaining('220'), findsOneWidget);

    await tester.tap(find.text('اطلب الصرف'));
    await tester.pumpAndSettle();
    expect(repository.requested, isFalse);
  });

  testWidgets('with a balance over the floor the request goes through', (
    tester,
  ) async {
    final repository = _FakeRepository(earnings: _earnings(available: 1400));
    await tester.pumpWidget(_harness(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('اطلب الصرف'));
    await tester.pumpAndSettle();

    expect(repository.requested, isTrue);
  });

  testWidgets('pending money is shown apart from the balance, with why', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        _FakeRepository(earnings: _earnings(available: 0, pending: 2100)),
      ),
    );
    await tester.pumpAndSettle();

    // Not folded into the headline figure, and the reason it is not payable
    // yet is stated rather than left as a number that will not move.
    expect(find.text('بعد انعقاد الجلسات'), findsOneWidget);
    expect(
      find.text('تصبح الجلسة قابلة للصرف بعد انتهائها.'),
      findsOneWidget,
    );
  });

  testWidgets('an empty ledger routes somewhere rather than dead-ending', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(_FakeRepository(earnings: _earnings(rows: []))),
    );
    await tester.pumpAndSettle();

    expect(find.byType(EjadahEmptyState), findsOneWidget);
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

Widget _harness(EarningsRepository repository) => ProviderScope(
  overrides: [earningsRepositoryProvider.overrideWithValue(repository)],
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
      child: EarningsScreen(),
    ),
  ),
);

EarningRow _row({
  required int gross,
  required int fee,
  required int net,
  String subject = 'Endodontics',
  EarningStatus status = EarningStatus.available,
}) => EarningRow(
  id: 'e-$gross-$net',
  bookingId: 'b-$gross',
  grossEgp: gross,
  platformFeeEgp: fee,
  netEgp: net,
  status: status,
  occurredAt: DateTime.utc(2026, 8, 1),
  description: const LocalizedText(en: 'Khaled Fathy', ar: 'خالد فتحي'),
  subject: subject,
);

Earnings _earnings({
  int available = 1400,
  int pending = 0,
  List<EarningRow>? rows,
  LocalizedText? blockedReason,
}) => Earnings(
  summary: EarningsSummary(
    availableEgp: available,
    pendingEgp: pending,
    requestedEgp: 0,
    paidEgp: 0,
    lifetimeGrossEgp: 2000,
    lifetimeFeeEgp: 600,
    lifetimeNetEgp: 1400,
  ),
  rows: rows ?? [_row(gross: 2000, fee: 600, net: 1400)],
  payouts: const [],
  minimumPayoutEgp: 500,
  platformFeePercent: 30,
  payoutBlockedReason: blockedReason,
);

class _FakeRepository implements EarningsRepository {
  _FakeRepository({this.earnings, this.failure});

  final Earnings? earnings;
  final Failure? failure;
  bool requested = false;

  @override
  Future<Earnings> load() async {
    if (failure != null) throw failure!;
    return earnings!;
  }

  @override
  Future<PayoutRequest> requestPayout() async {
    requested = true;
    return PayoutRequest(
      id: 'p1',
      amountEgp: earnings!.summary.availableEgp,
      status: 'requested',
      requestedAt: DateTime.utc(2026, 8, 15),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
