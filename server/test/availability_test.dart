import 'package:ejadah_server/src/http/api_error.dart';
import 'package:ejadah_server/src/modules/people/availability_service.dart';
import 'package:test/test.dart';

import 'support/test_database.dart';

/// The tutor's calendar (PE-14).
///
/// One rule carries this whole service: **a confirmed session is a promise, and
/// nothing here may break one silently.** A tutor who blocks a week for travel
/// must be told which students they would be standing up — because the only
/// other way those students find out is by turning up to an empty call.
void main() {
  late TestDatabase db;
  late AvailabilityService service;
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
    service = AvailabilityService(db.database);
    studentId = await _createUser(db, 'khaled@ejadah.test', 'Khaled Fathy');
    professionalId = await _createProfessional(db);
  });

  group('the weekly shape', () {
    test('saves and reads back in day order', () async {
      await service.saveRules(
        professionalId: professionalId,
        replacement: const [
          // Deliberately out of order going in.
          AvailabilityRule(id: 0, weekday: 3, startMinute: 1020, endMinute: 1200),
          AvailabilityRule(id: 0, weekday: 0, startMinute: 1020, endMinute: 1200),
        ],
      );

      final rules = await service.rules(professionalId);
      // 0 = Sunday, the first day of the booking week in both languages.
      expect(rules.map((rule) => rule.weekday), [0, 3]);
      expect(service.weeklyMinutes(rules), 360);
    });

    test('replaces rather than appending', () async {
      await service.saveRules(
        professionalId: professionalId,
        replacement: const [
          AvailabilityRule(id: 0, weekday: 0, startMinute: 600, endMinute: 720),
        ],
      );
      await service.saveRules(
        professionalId: professionalId,
        replacement: const [
          AvailabilityRule(id: 0, weekday: 1, startMinute: 600, endMinute: 720),
        ],
      );

      // The editor shows a week and saves a week. Appending would leave
      // yesterday's shape underneath today's.
      final rules = await service.rules(professionalId);
      expect(rules, hasLength(1));
      expect(rules.single.weekday, 1);
    });

    test('an impossible window is refused with the field named', () async {
      await expectLater(
        service.saveRules(
          professionalId: professionalId,
          replacement: const [
            AvailabilityRule(id: 0, weekday: 0, startMinute: 1200, endMinute: 600),
          ],
        ),
        throwsA(
          isA<ApiException>().having(
            (error) => error.fields.keys.single,
            'field',
            'hours',
          ),
        ),
      );
    });

    test('an eighth day is refused', () async {
      await expectLater(
        service.saveRules(
          professionalId: professionalId,
          replacement: const [
            AvailabilityRule(id: 0, weekday: 7, startMinute: 600, endMinute: 720),
          ],
        ),
        throwsA(isA<ApiException>()),
      );
    });

    test('an empty week is allowed — it strands nobody', () async {
      await service.saveRules(
        professionalId: professionalId,
        replacement: const [],
      );
      expect(await service.rules(professionalId), isEmpty);
    });
  });

  group('removing time somebody has booked', () {
    test('blocking a date with a confirmed session is refused, by name',
        () async {
      // 17:00–18:00 Cairo next Wednesday.
      final session = _cairo(days: 7, hour: 17);
      await _confirmedBooking(
        db,
        professionalId,
        studentId,
        startsAt: session,
        subject: 'Endodontics',
      );

      try {
        await service.block(
          professionalId: professionalId,
          startsAt: session.subtract(const Duration(hours: 6)),
          endsAt: session.add(const Duration(hours: 6)),
          reason: 'Travelling',
        );
        fail('blocking over a confirmed session must be refused');
      } on AvailabilityClash catch (clash) {
        // Named, not counted. "You have 1 conflict" tells a tutor nothing they
        // can act on.
        expect(clash.sessions, hasLength(1));
        expect(clash.sessions.single.studentName.en, 'Khaled Fathy');
        expect(clash.sessions.single.subject, 'Endodontics');
        expect(clash.sessions.single.startsAt, session);
      }

      // And nothing was written: a refusal that half-applies is worse than one
      // that does not apply at all.
      expect(
        await service.exceptions(professionalId, from: _now()),
        isEmpty,
      );
    });

    test('every clashing session is listed, not just the first', () async {
      final first = _cairo(days: 7, hour: 17);
      final second = _cairo(days: 8, hour: 18);
      await _confirmedBooking(db, professionalId, studentId, startsAt: first);
      await _confirmedBooking(db, professionalId, studentId, startsAt: second);

      try {
        await service.block(
          professionalId: professionalId,
          startsAt: first.subtract(const Duration(days: 1)),
          endsAt: second.add(const Duration(days: 1)),
        );
        fail('must be refused');
      } on AvailabilityClash catch (clash) {
        expect(clash.sessions, hasLength(2));
      }
    });

    test('an unpaid booking does not stand in the way', () async {
      final session = _cairo(days: 7, hour: 17);
      await _confirmedBooking(
        db,
        professionalId,
        studentId,
        startsAt: session,
        status: 'pending_payment',
      );

      // Nobody has paid and no promise has been made, so blocking over it costs
      // nothing.
      final blocked = await service.block(
        professionalId: professionalId,
        startsAt: session.subtract(const Duration(hours: 2)),
        endsAt: session.add(const Duration(hours: 2)),
      );
      expect(blocked.isAvailable, isFalse);
    });

    test('a cancelled booking does not stand in the way', () async {
      final session = _cairo(days: 7, hour: 17);
      await _confirmedBooking(
        db,
        professionalId,
        studentId,
        startsAt: session,
        status: 'cancelled_by_student',
      );

      await service.block(
        professionalId: professionalId,
        startsAt: session.subtract(const Duration(hours: 2)),
        endsAt: session.add(const Duration(hours: 2)),
      );
    });

    test('a free date blocks without complaint', () async {
      final free = _cairo(days: 30, hour: 9);
      final blocked = await service.block(
        professionalId: professionalId,
        startsAt: free,
        endsAt: free.add(const Duration(hours: 8)),
        reason: 'Conference',
      );

      expect(blocked.reason, 'Conference');
      expect(
        await service.exceptions(professionalId, from: _now()),
        hasLength(1),
      );
    });

    test('narrowing the weekly rules under a booked session is refused',
        () async {
      // A Wednesday 17:00 session, and a week that currently covers it.
      final session = _cairo(days: 7, hour: 17);
      await _confirmedBooking(db, professionalId, studentId, startsAt: session);

      final weekday = _cairoWeekday(session);
      await service.saveRules(
        professionalId: professionalId,
        replacement: [
          AvailabilityRule(
            id: 0,
            weekday: weekday,
            startMinute: 16 * 60,
            endMinute: 20 * 60,
          ),
        ],
      );

      // Now shrink the day to mornings. The session falls outside it.
      await expectLater(
        service.saveRules(
          professionalId: professionalId,
          replacement: [
            AvailabilityRule(
              id: 0,
              weekday: weekday,
              startMinute: 9 * 60,
              endMinute: 12 * 60,
            ),
          ],
        ),
        throwsA(isA<AvailabilityClash>()),
      );

      // The old shape survived the refusal.
      final rules = await service.rules(professionalId);
      expect(rules.single.startMinute, 16 * 60);
    });

    test('widening the week is always allowed', () async {
      final session = _cairo(days: 7, hour: 17);
      await _confirmedBooking(db, professionalId, studentId, startsAt: session);

      final weekday = _cairoWeekday(session);
      await service.saveRules(
        professionalId: professionalId,
        replacement: [
          AvailabilityRule(
            id: 0,
            weekday: weekday,
            startMinute: 9 * 60,
            endMinute: 22 * 60,
          ),
        ],
      );

      // Adding availability cannot strand anyone.
      expect(await service.rules(professionalId), hasLength(1));
    });

    test('a session beyond the horizon does not block a rules change',
        () async {
      // Six months out. Refusing a reasonable change today because of one
      // distant booking would make the editor unusable.
      final distant = _cairo(days: 180, hour: 17);
      await _confirmedBooking(db, professionalId, studentId, startsAt: distant);

      await service.saveRules(
        professionalId: professionalId,
        replacement: const [],
      );
      expect(await service.rules(professionalId), isEmpty);
    });
  });

  group('one-off openings', () {
    test('open extra hours and remove them again', () async {
      final saturday = _cairo(days: 10, hour: 10);
      final opening = await service.open(
        professionalId: professionalId,
        startsAt: saturday,
        endsAt: saturday.add(const Duration(hours: 3)),
      );
      expect(opening.isAvailable, isTrue);

      await service.removeException(
        professionalId: professionalId,
        exceptionId: opening.id,
      );
      expect(await service.exceptions(professionalId, from: _now()), isEmpty);
    });

    test("another professional's exception cannot be removed", () async {
      final other = await _createProfessional(db, email: 'other@ejadah.test');
      final saturday = _cairo(days: 10, hour: 10);
      final opening = await service.open(
        professionalId: professionalId,
        startsAt: saturday,
        endsAt: saturday.add(const Duration(hours: 3)),
      );

      await expectLater(
        service.removeException(
          professionalId: other,
          exceptionId: opening.id,
        ),
        throwsA(isA<ApiException>()),
      );
      expect(
        await service.exceptions(professionalId, from: _now()),
        hasLength(1),
      );
    });

    test('a period that ends before it starts is refused', () async {
      final day = _cairo(days: 10, hour: 10);
      await expectLater(
        service.open(
          professionalId: professionalId,
          startsAt: day,
          endsAt: day.subtract(const Duration(hours: 1)),
        ),
        throwsA(isA<ApiException>()),
      );
    });

    test('past exceptions are not listed', () async {
      final past = _now().subtract(const Duration(days: 10));
      await db.execute(
        "INSERT INTO availability_exceptions (professional_id, period, is_available) "
        "VALUES (@id, tstzrange(@from, @to, '[)'), false)",
        {
          'id': professionalId,
          'from': past,
          'to': past.add(const Duration(hours: 4)),
        },
      );

      // A day blocked last month is not something anyone can act on.
      expect(await service.exceptions(professionalId, from: _now()), isEmpty);
    });
  });
}

DateTime _now() => DateTime.now().toUtc();

/// A UTC instant that is [hour] in Cairo, [days] from now.
DateTime _cairo({required int days, required int hour}) {
  final target = _now().add(Duration(days: days));
  return DateTime.utc(target.year, target.month, target.day, hour)
      .subtract(const Duration(hours: 2));
}

/// The Cairo weekday of an instant, 0 = Sunday.
int _cairoWeekday(DateTime utc) =>
    utc.add(const Duration(hours: 2)).weekday % 7;

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

Future<void> _confirmedBooking(
  TestDatabase db,
  int professionalId,
  String studentId, {
  required DateTime startsAt,
  String status = 'confirmed',
  String subject = 'Endodontics',
}) async {
  final booking = await db.execute(
    '''
    INSERT INTO bookings (
      user_id, professional_id, kind, status, total_egp, platform_fee_egp,
      subject
    ) VALUES (
      @user_id, @professional_id, 'tutoring', @status::booking_status,
      800, 240, @subject
    )
    RETURNING id
    ''',
    {
      'user_id': studentId,
      'professional_id': professionalId,
      'status': status,
      'subject': subject,
    },
  );

  await db.execute(
    'INSERT INTO booking_sessions (booking_id, position, starts_at, ends_at) '
    'VALUES (@booking_id, 1, @starts_at, @ends_at)',
    {
      'booking_id': booking.first[0]! as String,
      'starts_at': startsAt,
      'ends_at': startsAt.add(const Duration(hours: 1)),
    },
  );
}
