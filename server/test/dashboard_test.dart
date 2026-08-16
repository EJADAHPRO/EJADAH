import 'package:ejadah_server/src/http/api_error.dart';
import 'package:ejadah_server/src/jobs/job_runner.dart';
import 'package:ejadah_server/src/modules/people/dashboard_service.dart';
import 'package:ejadah_server/src/modules/people/earnings_service.dart';
import 'package:test/test.dart';

import 'support/test_database.dart';

/// The tutor's working day (PE-13).
///
/// Two things here are load-bearing. Marking a session is what releases its
/// money — so the screen's promise, "marking releases your earnings", has to be
/// literally true. And hiding yourself must never touch a confirmed booking: a
/// switch that quietly cancelled on students would be the worst control in the
/// product.
void main() {
  late TestDatabase db;
  late DashboardService service;
  late EarningsService earnings;
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
    service = DashboardService(db.database);
    earnings = EarningsService(db.database, db.config);
    studentId = await _createUser(db, 'khaled@ejadah.test', 'Khaled Fathy');
    professionalId = await _createProfessional(db);
  });

  group('marking releases the money', () {
    test('a marked single-session booking completes and pays out', () async {
      final booking = await _booking(
        db,
        professionalId,
        studentId,
        startsAt: _hoursAgo(2),
      );

      expect((await earnings.summary(professionalId)).pendingEgp, 560);

      final marked = await service.mark(
        professionalId: professionalId,
        sessionId: booking.sessionIds.single,
      );

      expect(marked.isMarked, isTrue);
      // The screen's promise, literally: marking is what makes it askable-for.
      final summary = await earnings.summary(professionalId);
      expect(summary.pendingEgp, 0);
      expect(summary.availableEgp, 560);
    });

    test('a plan pays out only when its last session is marked', () async {
      final booking = await _booking(
        db,
        professionalId,
        studentId,
        startsAt: _hoursAgo(48),
        sessions: 3,
        totalEgp: 2400,
        feeEgp: 720,
      );

      await service.mark(
        professionalId: professionalId,
        sessionId: booking.sessionIds[0],
      );
      await service.mark(
        professionalId: professionalId,
        sessionId: booking.sessionIds[1],
      );

      // Two of three: the plan is not finished and neither is the payment.
      expect((await earnings.summary(professionalId)).availableEgp, 0);

      await service.mark(
        professionalId: professionalId,
        sessionId: booking.sessionIds[2],
      );
      expect((await earnings.summary(professionalId)).availableEgp, 1680);
    });

    test('a session that has not happened cannot be marked', () async {
      final booking = await _booking(
        db,
        professionalId,
        studentId,
        startsAt: _hoursAgo(-48),
      );

      // Marking work not yet done would be claiming money for it.
      await expectLater(
        service.mark(
          professionalId: professionalId,
          sessionId: booking.sessionIds.single,
        ),
        throwsA(isA<ApiException>()),
      );
    });

    test("another tutor's session cannot be marked", () async {
      final other = await _createProfessional(db, email: 'other@ejadah.test');
      final booking = await _booking(
        db,
        professionalId,
        studentId,
        startsAt: _hoursAgo(2),
      );

      await expectLater(
        service.mark(
          professionalId: other,
          sessionId: booking.sessionIds.single,
        ),
        throwsA(isA<ApiException>()),
      );
      expect((await earnings.summary(professionalId)).availableEgp, 0);
    });

    test('marking twice keeps the first time, and does not fail', () async {
      final booking = await _booking(
        db,
        professionalId,
        studentId,
        startsAt: _hoursAgo(2),
      );

      final first = await service.mark(
        professionalId: professionalId,
        sessionId: booking.sessionIds.single,
      );
      final second = await service.mark(
        professionalId: professionalId,
        sessionId: booking.sessionIds.single,
      );

      // A double-tap is not an error the tutor needs to hear about, and it
      // must not rewrite when the session was actually held.
      expect(second.attendedAt, first.attendedAt);
      expect((await earnings.summary(professionalId)).availableEgp, 560);
    });

    test('the unmarked list holds exactly what is waiting', () async {
      final past = await _booking(
        db,
        professionalId,
        studentId,
        startsAt: _hoursAgo(2),
      );
      await _booking(
        db,
        professionalId,
        studentId,
        startsAt: _hoursAgo(-48),
      );

      expect(await service.unmarked(professionalId: professionalId), hasLength(1));

      await service.mark(
        professionalId: professionalId,
        sessionId: past.sessionIds.single,
      );
      expect(await service.unmarked(professionalId: professionalId), isEmpty);
    });
  });

  group('forgetting to mark', () {
    test('a booking completes itself after the grace window', () async {
      await _booking(
        db,
        professionalId,
        studentId,
        startsAt: _daysAgo(DashboardService.autoCompleteAfterDays + 1),
      );

      await MatureEarningsJob(db.database).run();

      // "Marking releases your earnings" must not quietly mean "and if you
      // forget, you are never paid".
      expect((await earnings.summary(professionalId)).availableEgp, 560);
    });

    test('a booking inside the grace window is left alone', () async {
      await _booking(
        db,
        professionalId,
        studentId,
        startsAt: _hoursAgo(6),
      );

      await MatureEarningsJob(db.database).run();

      // Still the tutor's to mark. The nudge has not expired.
      expect((await earnings.summary(professionalId)).pendingEgp, 560);
      expect(await service.unmarked(professionalId: professionalId), hasLength(1));
    });
  });

  group('hide me for now', () {
    test('hiding never touches a confirmed booking', () async {
      final booking = await _booking(
        db,
        professionalId,
        studentId,
        startsAt: _hoursAgo(-48),
      );

      expect(
        await service.setHidden(professionalId: professionalId, hidden: true),
        isTrue,
      );

      // The session is exactly where it was. A switch that cancelled on
      // students would be the worst control in this product.
      final rows = await db.execute(
        // Cast: the enum comes back as raw bytes otherwise.
        'SELECT status::text FROM bookings WHERE id = @id',
        {'id': booking.id},
      );
      expect(rows.first[0], 'confirmed');
      expect(
        await service.sessions(
          professionalId: professionalId,
          from: _daysAgo(1),
          to: _hoursAgo(-96),
        ),
        hasLength(1),
      );
    });

    test('hiding takes the tutor out of the listings, un-hiding restores them',
        () async {
      Future<int> listed() async {
        final rows = await db.execute(
          'SELECT count(*) FROM professionals '
          'WHERE is_approved AND NOT is_hidden',
        );
        return rows.first[0]! as int;
      }

      expect(await listed(), 1);
      await service.setHidden(professionalId: professionalId, hidden: true);
      expect(await listed(), 0);
      await service.setHidden(professionalId: professionalId, hidden: false);
      expect(await listed(), 1);
    });
  });

  group('the meeting room', () {
    test('a plain-http link is refused', () async {
      await expectLater(
        service.setMeetingUrl(
          professionalId: professionalId,
          url: 'http://meet.example.com/mona',
        ),
        throwsA(isA<ApiException>()),
      );
    });

    test('an https link is kept, and clearing it is allowed', () async {
      expect(
        await service.setMeetingUrl(
          professionalId: professionalId,
          url: ' https://meet.example.com/mona ',
        ),
        'https://meet.example.com/mona',
      );
      expect(
        await service.setMeetingUrl(professionalId: professionalId, url: ''),
        isNull,
      );
    });
  });

  test('a session carries the student’s goal to their own tutor', () async {
    await _booking(
      db,
      professionalId,
      studentId,
      startsAt: _hoursAgo(-2),
      goal: 'A perforated furcation I could not seal',
    );

    final upcoming = await service.sessions(
      professionalId: professionalId,
      from: _hoursAgo(4),
      to: _hoursAgo(-24),
    );
    // The reason the session is worth preparing for. It reaches this tutor and
    // nobody else — never a third party, a log or analytics.
    expect(upcoming.single.goal, contains('perforated'));
  });
}

DateTime _hoursAgo(int hours) =>
    DateTime.now().toUtc().subtract(Duration(hours: hours));

DateTime _daysAgo(int days) =>
    DateTime.now().toUtc().subtract(Duration(days: days));

class _Booking {
  const _Booking(this.id, this.sessionIds);

  final String id;
  final List<String> sessionIds;
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
  String email = 'mona@ejadah.test',
}) async {
  final userId = await _createUser(db, email, 'Mona Adel');
  final result = await db.execute(
    '''
    INSERT INTO professionals (
      user_id, slug, kind, display_name_en, display_name_ar,
      hourly_rate_egp, is_approved
    ) VALUES (
      @user_id, @slug, 'tutoring', 'Dr. Mona Adel', 'د. منى عادل', 800, true
    )
    RETURNING id
    ''',
    {'user_id': userId, 'slug': 'mona-${email.hashCode.abs()}'},
  );
  return result.first[0]! as int;
}

/// A confirmed booking, its sessions, and the pending earning that came with it.
Future<_Booking> _booking(
  TestDatabase db,
  int professionalId,
  String studentId, {
  required DateTime startsAt,
  int sessions = 1,
  int totalEgp = 800,
  int feeEgp = 240,
  String goal = '',
}) async {
  final booking = await db.execute(
    '''
    INSERT INTO bookings (
      user_id, professional_id, kind, status, total_egp, platform_fee_egp,
      subject, goal
    ) VALUES (
      @user_id, @professional_id, 'tutoring', 'confirmed', @total, @fee,
      'Endodontics', @goal
    )
    RETURNING id
    ''',
    {
      'user_id': studentId,
      'professional_id': professionalId,
      'total': totalEgp,
      'fee': feeEgp,
      'goal': goal,
    },
  );
  final bookingId = booking.first[0]! as String;

  final sessionIds = <String>[];
  for (var i = 0; i < sessions; i++) {
    // Spaced weekly and ending at [startsAt], so a multi-session fixture built
    // "two days ago" has every session in the past rather than one.
    final at = startsAt.subtract(Duration(days: (sessions - 1 - i) * 7));
    final row = await db.execute(
      'INSERT INTO booking_sessions (booking_id, position, starts_at, ends_at) '
      'VALUES (@booking_id, @position, @starts_at, @ends_at) RETURNING id',
      {
        'booking_id': bookingId,
        'position': i + 1,
        'starts_at': at,
        'ends_at': at.add(const Duration(hours: 1)),
      },
    );
    sessionIds.add(row.first[0]! as String);
  }

  await db.execute(
    'INSERT INTO earnings (professional_id, booking_id, gross_egp, '
    "platform_fee_egp, status) VALUES (@p, @b, @gross, @fee, 'pending')",
    {
      'p': professionalId,
      'b': bookingId,
      'gross': totalEgp,
      'fee': feeEgp,
    },
  );

  return _Booking(bookingId, sessionIds);
}
