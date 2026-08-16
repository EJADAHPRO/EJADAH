import 'package:ejadah_server/src/http/api_error.dart';
import 'package:ejadah_server/src/jobs/job_runner.dart';
import 'package:ejadah_server/src/modules/people/earnings_service.dart';
import 'package:test/test.dart';

import 'support/test_database.dart';

/// The tutor's ledger.
///
/// Money is the thing a marketplace cannot be approximately right about. A
/// tutor who cannot reconstruct their own balance from the rows in front of
/// them stops trusting the platform, and a tutor who is paid twice for one
/// session is a hole in the business. Both are pinned here.
void main() {
  late TestDatabase db;
  late EarningsService service;
  late int professionalId;
  late String studentId;

  setUpAll(() async {
    db = await TestDatabase.open();
  });

  tearDownAll(() async {
    await db.close();
  });

  setUp(() async {
    await db.reset();
    service = EarningsService(db.database, db.config);
    studentId = await _createUser(db, 'student@ejadah.test', 'Khaled Fathy');
    professionalId = await _createProfessional(db);
  });

  group('a row states the whole subtraction', () {
    test('gross minus fee equals net, and all three are sent', () async {
      await _earning(db, professionalId, studentId, gross: 1000, fee: 300);

      final row = (await service.rows(professionalId)).single;
      expect(row.grossEgp, 1000);
      expect(row.platformFeeEgp, 300);
      // Sent, not left for the client to compute: a screen that subtracts for
      // itself is a screen that can disagree with the database.
      expect(row.netEgp, 700);
      expect(row.toJson()['net_egp'], 700);
    });

    test('the row names the student but never their goal', () async {
      await _earning(
        db,
        professionalId,
        studentId,
        gross: 800,
        fee: 240,
        goal: 'Retreatment on a patient with a perforated furcation',
      );

      final row = (await service.rows(professionalId)).single;
      expect(row.description.en, 'Khaled Fathy');
      // The goal is clinical free text the student wrote in confidence. It
      // belongs to the booking and does not travel to a third party's screen.
      expect(row.toJson().toString(), isNot(contains('perforated')));
    });

    test('only this professional appears in this professional’s ledger',
        () async {
      final other = await _createProfessional(db, email: 'other@ejadah.test');
      await _earning(db, professionalId, studentId, gross: 1000, fee: 300);
      await _earning(db, other, studentId, gross: 5000, fee: 1500);

      expect(await service.rows(professionalId), hasLength(1));
      expect((await service.summary(professionalId)).availableEgp, 0);
      expect((await service.summary(professionalId)).pendingEgp, 700);
    });
  });

  group('the summary', () {
    test('counts each state in its own bucket', () async {
      await _earning(db, professionalId, studentId, gross: 1000, fee: 300);
      await _earning(
        db,
        professionalId,
        studentId,
        gross: 2000,
        fee: 600,
        status: 'available',
      );
      await _earning(
        db,
        professionalId,
        studentId,
        gross: 500,
        fee: 150,
        status: 'paid',
      );
      // A cancelled booking. It stays as a row and counts towards nothing.
      await _earning(
        db,
        professionalId,
        studentId,
        gross: 9000,
        fee: 2700,
        status: 'reversed',
      );

      final summary = await service.summary(professionalId);
      expect(summary.pendingEgp, 700);
      expect(summary.availableEgp, 1400);
      expect(summary.paidEgp, 350);
      // A reversed row is in neither the lifetime gross nor the fee: no money
      // moved, so counting it would overstate both sides at once.
      expect(summary.lifetimeGrossEgp, 3500);
      expect(summary.lifetimeFeeEgp, 1050);
    });

    test('an empty ledger is zeroes, not an error', () async {
      final summary = await service.summary(professionalId);
      expect(summary.availableEgp, 0);
      expect(summary.lifetimeGrossEgp, 0);
    });
  });

  group('asking to be paid', () {
    test('below the floor, the reason states the shortfall', () async {
      await _earning(
        db,
        professionalId,
        studentId,
        gross: 400,
        fee: 120,
        status: 'available',
      );

      final reason = service.blockedReason(
        summary: await service.summary(professionalId),
        payouts: await service.payouts(professionalId),
      );
      // 280 available against a 500 floor: the tutor is told they need 220
      // more, rather than being shown a grey button.
      expect(reason, isNotNull);
      expect(reason!.en, contains('220'));
      expect(reason.ar, contains('220'));

      await expectLater(
        service.requestPayout(professionalId),
        throwsA(isA<ApiException>()),
      );
    });

    test('with nothing available the reason says why, not "no"', () async {
      await _earning(db, professionalId, studentId, gross: 5000, fee: 1500);

      final reason = service.blockedReason(
        summary: await service.summary(professionalId),
        payouts: await service.payouts(professionalId),
      );
      // 3,500 pending is not 3,500 available, and the difference is explained.
      expect(reason!.en, contains('over'));
    });

    test('above the floor it opens a request for the whole balance', () async {
      await _earning(
        db,
        professionalId,
        studentId,
        gross: 2000,
        fee: 600,
        status: 'available',
      );

      final payout = await service.requestPayout(professionalId);
      expect(payout.amountEgp, 1400);
      expect(payout.status, 'requested');

      // The rows left `available` so nothing can claim them twice — and did
      // not become `paid`, because nothing has been transferred.
      final summary = await service.summary(professionalId);
      expect(summary.availableEgp, 0);
      expect(summary.requestedEgp, 1400);
      expect(summary.paidEgp, 0);
    });

    test('a second request while one is open is refused with a reason',
        () async {
      await _earning(
        db,
        professionalId,
        studentId,
        gross: 2000,
        fee: 600,
        status: 'available',
      );
      await service.requestPayout(professionalId);
      await _earning(
        db,
        professionalId,
        studentId,
        gross: 3000,
        fee: 900,
        status: 'available',
      );

      await expectLater(
        service.requestPayout(professionalId),
        throwsA(isA<ApiException>()),
      );
    });

    test('two simultaneous requests produce one payout, not two', () async {
      await _earning(
        db,
        professionalId,
        studentId,
        gross: 4000,
        fee: 1200,
        status: 'available',
      );

      // The double-tap, and the two-devices case. Without the row lock and the
      // partial unique index both would see 2,800 available and each open a
      // request against the same money.
      final results = await Future.wait(
        [
          service.requestPayout(professionalId),
          service.requestPayout(professionalId),
        ].map((future) => future.then<Object?>((v) => v).catchError((e) => e)),
      );

      final succeeded = results.whereType<PayoutRequest>().toList();
      expect(succeeded, hasLength(1));
      expect(succeeded.single.amountEgp, 2800);
      expect(await service.payouts(professionalId), hasLength(1));
    });
  });

  group('maturing', () {
    test('a long-finished session releases itself; a recent one waits',
        () async {
      // Marking is what normally releases the money — see `dashboard_test`.
      // This job is the backstop for the tutor who never marks.
      final old = await _earning(
        db,
        professionalId,
        studentId,
        gross: 1000,
        fee: 300,
        sessionEndsAt: DateTime.now().toUtc().subtract(
          const Duration(days: 8),
        ),
      );
      final recent = await _earning(
        db,
        professionalId,
        studentId,
        gross: 2000,
        fee: 600,
        sessionEndsAt: DateTime.now().toUtc().subtract(
          const Duration(hours: 2),
        ),
      );
      final future = await _earning(
        db,
        professionalId,
        studentId,
        gross: 500,
        fee: 150,
        sessionEndsAt: DateTime.now().toUtc().add(const Duration(days: 3)),
      );

      await MatureEarningsJob(db.database).run();

      expect(await _statusOf(db, old), 'available');
      // Still the tutor's to mark: the nudge on the dashboard has not expired.
      expect(await _statusOf(db, recent), 'pending');
      // And paying before the session would mean clawing money back from
      // someone who has already spent it.
      expect(await _statusOf(db, future), 'pending');
    });

    test('a cancelled booking never matures', () async {
      final id = await _earning(
        db,
        professionalId,
        studentId,
        gross: 1000,
        fee: 300,
        sessionEndsAt: DateTime.now().toUtc().subtract(
          const Duration(days: 8),
        ),
        bookingStatus: 'cancelled_by_student',
      );

      await MatureEarningsJob(db.database).run();

      expect(await _statusOf(db, id), 'pending');
    });
  });

  test('a student has no ledger at all', () async {
    expect(await service.professionalIdFor(studentId), isNull);
  });
}

Future<String> _createUser(TestDatabase db, String email, String name) async {
  final result = await db.execute(
    "INSERT INTO users (email, password_hash, full_name_en, full_name_ar) "
    "VALUES (@email, 'x', @name, @name) RETURNING id",
    {'email': email, 'name': name},
  );
  return result.first[0]! as String;
}

Future<int> _createProfessional(
  TestDatabase db, {
  String email = 'tutor@ejadah.test',
}) async {
  final userId = await _createUser(db, email, 'Mona Adel');
  final result = await db.execute(
    '''
    INSERT INTO professionals (
      user_id, slug, kind, display_name_en, display_name_ar,
      headline_en, headline_ar, hourly_rate_egp, is_approved
    ) VALUES (
      @user_id, @slug, 'tutoring', 'Dr. Mona Adel', 'د. منى عادل',
      'Endodontist', 'أخصائية علاج جذور', 800, true
    )
    RETURNING id
    ''',
    {'user_id': userId, 'slug': 'mona-${email.hashCode.abs()}'},
  );
  return result.first[0]! as int;
}

/// A booking, its single session, and the ledger row that came with it.
Future<String> _earning(
  TestDatabase db,
  int professionalId,
  String studentId, {
  required int gross,
  required int fee,
  String status = 'pending',
  String bookingStatus = 'confirmed',
  String goal = '',
  DateTime? sessionEndsAt,
}) async {
  final booking = await db.execute(
    '''
    INSERT INTO bookings (
      user_id, professional_id, kind, status, total_egp, platform_fee_egp,
      subject, goal
    ) VALUES (
      @user_id, @professional_id, 'tutoring', @status::booking_status,
      @total, @fee, 'Endodontics', @goal
    )
    RETURNING id
    ''',
    {
      'user_id': studentId,
      'professional_id': professionalId,
      'status': bookingStatus,
      'total': gross,
      'fee': fee,
      'goal': goal,
    },
  );
  final bookingId = booking.first[0]! as String;

  final ends = sessionEndsAt ?? DateTime.now().toUtc().add(const Duration(days: 7));
  await db.execute(
    'INSERT INTO booking_sessions (booking_id, position, starts_at, ends_at) '
    'VALUES (@booking_id, 1, @starts_at, @ends_at)',
    {
      'booking_id': bookingId,
      'starts_at': ends.subtract(const Duration(hours: 1)),
      'ends_at': ends,
    },
  );

  final earning = await db.execute(
    'INSERT INTO earnings (professional_id, booking_id, gross_egp, '
    'platform_fee_egp, status) '
    'VALUES (@professional_id, @booking_id, @gross, @fee, @status) '
    'RETURNING id',
    {
      'professional_id': professionalId,
      'booking_id': bookingId,
      'gross': gross,
      'fee': fee,
      'status': status,
    },
  );
  return earning.first[0]! as String;
}

Future<String> _statusOf(TestDatabase db, String earningId) async {
  final rows = await db.execute(
    'SELECT status FROM earnings WHERE id = @id',
    {'id': earningId},
  );
  return rows.first[0]! as String;
}
