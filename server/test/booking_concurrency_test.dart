import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_server/src/http/api_error.dart';
import 'package:ejadah_server/src/modules/people/booking_service.dart';
import 'package:ejadah_server/src/modules/people/people_repository.dart';
import 'dart:io';

import 'package:ejadah_server/src/observability/logger.dart';
import 'package:ejadah_server/src/services/payments/payment_provider.dart';
import 'package:test/test.dart';

import 'support/test_database.dart';

/// The booking concurrency proof.
///
/// This is the test the brief calls mandatory, and it is the reason the
/// timeline lives in one table behind an exclusion constraint. It runs against
/// a real PostgreSQL instance because that is the component doing the work: a
/// mocked repository would prove only that the mock behaves.
void main() {
  late TestDatabase db;
  late BookingService service;
  late PeopleRepository repository;
  late DevPaymentProvider payments;

  const int professionalId = 1;
  late String studentA;
  late String studentB;
  late DateTime slotStart;

  setUpAll(() async {
    db = await TestDatabase.open();
  });

  tearDownAll(() async {
    await db.close();
  });

  setUp(() async {
    await db.reset();

    repository = PeopleRepository(db.database);
    payments = DevPaymentProvider(
      config: db.config,
      logger: AppLogger('test', sink: _silent),
    );
    service = BookingService(
      database: db.database,
      repository: repository,
      payments: payments,
      config: db.config,
      logger: AppLogger('test', sink: _silent),
    );

    studentA = await _createUser(db, 'a@ejadah.test');
    studentB = await _createUser(db, 'b@ejadah.test');
    await _createProfessional(db, professionalId);

    // Far enough ahead that the "not in the past" guard is not what is being
    // tested here.
    slotStart = DateTime.now().toUtc().add(const Duration(days: 3));
    slotStart = DateTime.utc(
      slotStart.year,
      slotStart.month,
      slotStart.day,
      10,
    );
  });

  test('two students racing for the same slot: exactly one wins', () async {
    // Both requests are in flight at once — the interleaving is genuinely
    // concurrent rather than sequential-with-a-delay.
    final results = await Future.wait([
      _attemptHold(service, studentA, slotStart),
      _attemptHold(service, studentB, slotStart),
    ]);

    final succeeded = results.where((r) => r.hold != null).toList();
    final failed = results.where((r) => r.error != null).toList();

    expect(
      succeeded.length,
      1,
      reason: 'exactly one caller may hold a given slot',
    );
    expect(failed.length, 1);

    // The loser gets the product's own words, not a database error.
    expect(failed.single.error!.code, ApiErrorCode.conflict);
    expect(failed.single.error!.message.en, ApiErrorCopy.slotTaken.en);
    expect(failed.single.error!.message.ar, ApiErrorCopy.slotTaken.ar);

    // And the database agrees: one active row on that professional's timeline.
    final active = await db.execute(
      "SELECT count(*) AS n FROM slot_reservations "
      "WHERE professional_id = @id AND status = 'active'",
      {'id': professionalId},
    );
    expect(active.first[0], 1);
  });

  test('ten simultaneous attempts still yield exactly one hold', () async {
    // The guarantee must not depend on there being only two racers.
    final students = <String>[
      for (var i = 0; i < 10; i++) await _createUser(db, 'racer$i@ejadah.test'),
    ];

    final results = await Future.wait(
      students.map((id) => _attemptHold(service, id, slotStart)),
    );

    expect(results.where((r) => r.hold != null).length, 1);
    expect(
      results.where((r) => r.error?.code == ApiErrorCode.conflict).length,
      9,
    );
  });

  test('a confirmed booking still blocks a later attempt', () async {
    final hold = await service.holdSlot(
      userId: studentA,
      professionalId: professionalId,
      startsAt: slotStart,
      durationMinutes: 60,
    );

    final booking = await service.confirmBooking(
      userId: studentA,
      holdId: hold.id,
      subject: 'Endodontics',
      goal: 'A molar retreatment I want a second opinion on.',
    );
    expect(booking.sessions, hasLength(1));

    // The hold became the session's reservation in place, so the slot was never
    // momentarily free.
    final second = await _attemptHold(service, studentB, slotStart);
    expect(second.error?.code, ApiErrorCode.conflict);
  });

  test('an expired hold releases the slot for someone else', () async {
    final hold = await service.holdSlot(
      userId: studentA,
      professionalId: professionalId,
      startsAt: slotStart,
      durationMinutes: 60,
    );

    // Age the hold past its expiry rather than waiting for the clock.
    await db.execute(
      'UPDATE slot_reservations SET expires_at = now() - interval \'1 minute\' '
      'WHERE id = @id',
      {'id': hold.id},
    );

    // The next attempt releases expired holds lazily, so correctness does not
    // depend on the background job having run.
    final second = await _attemptHold(service, studentB, slotStart);
    expect(second.hold, isNotNull);

    // And the original holder can no longer confirm against a dead hold.
    await expectLater(
      service.confirmBooking(
        userId: studentA,
        holdId: hold.id,
        subject: 'Endodontics',
        goal: 'A molar retreatment I want a second opinion on.',
      ),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message.en,
          'message',
          ApiErrorCopy.holdExpired.en,
        ),
      ),
    );
  });

  test('adjacent slots do not collide', () async {
    // The range is half-open, so an appointment ending at 11:00 and one
    // starting at 11:00 are neighbours, not an overlap.
    final first = await _attemptHold(service, studentA, slotStart);
    final second = await _attemptHold(
      service,
      studentB,
      slotStart.add(const Duration(hours: 1)),
    );

    expect(first.hold, isNotNull);
    expect(second.hold, isNotNull);
  });

  test('the price comes from the server, never from the caller', () async {
    final hold = await service.holdSlot(
      userId: studentA,
      professionalId: professionalId,
      startsAt: slotStart,
      durationMinutes: 60,
    );

    final booking = await service.confirmBooking(
      userId: studentA,
      holdId: hold.id,
      subject: 'Endodontics',
      goal: 'A molar retreatment I want a second opinion on.',
    );

    // 800 EGP/hour at the fixture rate, with the platform keeping 30%.
    expect(booking.totalEgp, 800);
    final row = await db.execute(
      'SELECT platform_fee_egp FROM bookings WHERE id = @id',
      {'id': booking.id},
    );
    expect(row.first[0], 240);
  });

  test('another user cannot confirm someone else\'s hold', () async {
    final hold = await service.holdSlot(
      userId: studentA,
      professionalId: professionalId,
      startsAt: slotStart,
      durationMinutes: 60,
    );

    await expectLater(
      service.confirmBooking(
        userId: studentB,
        holdId: hold.id,
        subject: 'Endodontics',
        goal: 'Trying to take a hold that is not mine.',
      ),
      throwsA(
        isA<ApiException>().having(
          (e) => e.code,
          'code',
          ApiErrorCode.authorization,
        ),
      ),
    );
  });

  test('cancelling releases the slot and refunds by the stated tier', () async {
    final hold = await service.holdSlot(
      userId: studentA,
      professionalId: professionalId,
      startsAt: slotStart,
      durationMinutes: 60,
    );
    final booking = await service.confirmBooking(
      userId: studentA,
      holdId: hold.id,
      subject: 'Endodontics',
      goal: 'A molar retreatment I want a second opinion on.',
    );

    final cancelled = await service.cancelBooking(
      userId: studentA,
      bookingId: booking.id,
      cancelledByProfessional: false,
    );

    // Three days out is well inside the full-refund tier.
    expect(cancelled.status, BookingStatus.cancelledByStudent);
    expect(cancelled.refundableEgp, 800);

    // The time goes back on the calendar.
    final second = await _attemptHold(service, studentB, slotStart);
    expect(second.hold, isNotNull);
  });
}

/// Attempts a hold and reports either the hold or the failure, so a race can be
/// awaited without one side's exception cancelling the other.
Future<({BookingHold? hold, ApiException? error})> _attemptHold(
  BookingService service,
  String userId,
  DateTime startsAt,
) async {
  try {
    final hold = await service.holdSlot(
      userId: userId,
      professionalId: 1,
      startsAt: startsAt,
      durationMinutes: 60,
    );
    return (hold: hold, error: null);
  } on ApiException catch (error) {
    return (hold: null, error: error);
  }
}

Future<String> _createUser(TestDatabase db, String email) async {
  final result = await db.execute(
    '''
    INSERT INTO users (email, password_hash, full_name_en, full_name_ar)
    VALUES (@email, 'x', 'Test Student', 'طالب تجريبي')
    RETURNING id
    ''',
    {'email': email},
  );
  return result.first[0]! as String;
}

Future<void> _createProfessional(TestDatabase db, int id) async {
  await db.execute(
    '''
    INSERT INTO professionals (
      id, slug, kind, display_name_en, display_name_ar, hourly_rate_egp,
      is_approved
    ) VALUES (
      @id, 'dr-mona-adel', 'tutoring', 'Dr. Mona Adel', 'د. منى عادل', 800, true
    )
    ''',
    {'id': id},
  );
}

/// Keeps the suite's output to test results rather than server log lines.
final IOSink _silent = _NullSink();

class _NullSink implements IOSink {
  @override
  void writeln([Object? object = '']) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
