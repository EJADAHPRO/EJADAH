import 'package:ejadah_models/ejadah_models.dart';
import 'package:postgres/postgres.dart';

import '../../db/database.dart';

/// A professional as the service layer needs them, including fields the client
/// never sees.
class ProfessionalRecord {
  const ProfessionalRecord({
    required this.id,
    required this.slug,
    required this.kind,
    required this.hourlyRateEgp,
    required this.isApproved,
    required this.timezone,
  });

  final int id;
  final String slug;
  final ServiceKind kind;

  /// The pricing authority for a single session.
  final int hourlyRateEgp;
  final bool isApproved;
  final String timezone;
}

class PackageRecord {
  const PackageRecord({
    required this.id,
    required this.professionalId,
    required this.sessionCount,
    required this.sessionMinutes,
    required this.priceEgp,
  });

  final int id;
  final int professionalId;
  final int sessionCount;
  final int sessionMinutes;
  final int priceEgp;
}

/// A row on a professional's timeline: a hold or a confirmed session.
class ReservationRecord {
  const ReservationRecord({
    required this.id,
    required this.professionalId,
    required this.startsAt,
    required this.endsAt,
    required this.kind,
    required this.status,
    required this.expiresAt,
    required this.heldByUserId,
  });

  final String id;
  final int professionalId;
  final DateTime startsAt;
  final DateTime endsAt;
  final String kind;
  final String status;
  final DateTime? expiresAt;
  final String? heldByUserId;
}

/// Database access for professionals, availability and bookings.
class PeopleRepository {
  const PeopleRepository(this._database);

  final Database _database;

  // --- Professionals --------------------------------------------------------

  Future<ProfessionalRecord?> findProfessional(
    int id, {
    Session? session,
  }) async {
    final rows = await _query(
      'SELECT id, slug, kind, hourly_rate_egp, is_approved, timezone '
      'FROM professionals WHERE id = @id',
      {'id': id},
      session,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return ProfessionalRecord(
      id: row.intAt('id'),
      slug: row.str('slug'),
      kind: ServiceKind.fromWire(row.str('kind')),
      hourlyRateEgp: row.intAt('hourly_rate_egp'),
      isApproved: row.boolAt('is_approved'),
      timezone: row.str('timezone'),
    );
  }

  Future<PackageRecord?> findPackage(int id, {Session? session}) async {
    final rows = await _query(
      'SELECT id, professional_id, session_count, session_minutes, price_egp '
      'FROM professional_packages WHERE id = @id AND is_active = true',
      {'id': id},
      session,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return PackageRecord(
      id: row.intAt('id'),
      professionalId: row.intAt('professional_id'),
      sessionCount: row.intAt('session_count'),
      sessionMinutes: row.intAt('session_minutes'),
      priceEgp: row.intAt('price_egp'),
    );
  }

  // --- The reservation timeline ---------------------------------------------

  /// Inserts a hold or a session.
  ///
  /// Relies on `slot_reservations_no_overlap` to reject an overlapping active
  /// row. There is deliberately no read-then-write check here: that pattern has
  /// a window between the read and the write, and the constraint does not.
  Future<String> insertReservation({
    required int professionalId,
    required DateTime startsAt,
    required DateTime endsAt,
    required String kind,
    String? heldByUserId,
    DateTime? expiresAt,
    String? bookingId,
    String? bookingSessionId,
    Session? session,
  }) async {
    final rows = await _query(
      '''
      INSERT INTO slot_reservations (
        professional_id, period, kind, expires_at, held_by_user_id,
        booking_id, booking_session_id
      ) VALUES (
        @professional_id, tstzrange(@starts_at, @ends_at, '[)'), @kind,
        @expires_at, @held_by_user_id, @booking_id, @booking_session_id
      )
      RETURNING id
      ''',
      {
        'professional_id': professionalId,
        'starts_at': startsAt,
        'ends_at': endsAt,
        'kind': kind,
        'expires_at': expiresAt,
        'held_by_user_id': heldByUserId,
        'booking_id': bookingId,
        'booking_session_id': bookingSessionId,
      },
      session,
    );
    return rows.first.str('id');
  }

  /// Reads a reservation and holds a row lock until the transaction ends.
  ///
  /// Two confirmations of the same hold serialise here instead of racing.
  Future<ReservationRecord?> lockReservation(
    String id, {
    required Session session,
  }) async {
    final rows = await _query(
      'SELECT id, professional_id, lower(period) AS starts_at, '
      'upper(period) AS ends_at, kind, status, expires_at, held_by_user_id '
      'FROM slot_reservations WHERE id = @id FOR UPDATE',
      {'id': id},
      session,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return ReservationRecord(
      id: row.str('id'),
      professionalId: row.intAt('professional_id'),
      startsAt: row.dateAt('starts_at'),
      endsAt: row.dateAt('ends_at'),
      kind: row.str('kind'),
      status: row.str('status'),
      expiresAt: row.dateOrNull('expires_at'),
      heldByUserId: row.strOrNull('held_by_user_id'),
    );
  }

  /// Turns a live hold into the confirmed session's reservation, in place.
  ///
  /// Doing it in place rather than delete-then-insert means the slot is never
  /// momentarily free for another caller to take.
  Future<void> convertHoldToSession({
    required String reservationId,
    required String bookingId,
    required String bookingSessionId,
    required Session session,
  }) => _execute(
    '''
    UPDATE slot_reservations
    SET kind = 'session', expires_at = NULL, booking_id = @booking_id,
        booking_session_id = @booking_session_id
    WHERE id = @id
    ''',
    {
      'id': reservationId,
      'booking_id': bookingId,
      'booking_session_id': bookingSessionId,
    },
    session,
  );

  Future<void> releaseReservation(String id, {Session? session}) => _execute(
    "UPDATE slot_reservations SET status = 'released', released_at = now() "
    'WHERE id = @id',
    {'id': id},
    session,
  );

  Future<void> releaseReservationsForBooking(
    String bookingId, {
    Session? session,
  }) => _execute(
    "UPDATE slot_reservations SET status = 'released', released_at = now() "
    'WHERE booking_id = @booking_id',
    {'booking_id': bookingId},
    session,
  );

  Future<int> releaseExpiredHolds({
    required int professionalId,
    required DateTime now,
    Session? session,
  }) async {
    final rows = await _query(
      '''
      UPDATE slot_reservations
      SET status = 'released', released_at = now()
      WHERE professional_id = @professional_id
        AND kind = 'hold' AND status = 'active' AND expires_at <= @now
      RETURNING id
      ''',
      {'professional_id': professionalId, 'now': now},
      session,
    );
    return rows.length;
  }

  // --- Availability ---------------------------------------------------------

  /// Slots for a window, marked available or not.
  ///
  /// Built from the professional's weekly rules, minus one-off blocks, minus
  /// anything the timeline already holds or has booked.
  Future<List<AvailabilitySlot>> availableSlots({
    required int professionalId,
    required DateTime from,
    required DateTime to,
    required int slotMinutes,
    required DateTime now,
  }) async {
    final rules = await _query(
      'SELECT weekday, start_minute, end_minute FROM availability_rules '
      'WHERE professional_id = @professional_id',
      {'professional_id': professionalId},
      null,
    );
    if (rules.isEmpty) return const [];

    final taken = await _query(
      '''
      SELECT lower(period) AS starts_at, upper(period) AS ends_at
      FROM slot_reservations
      WHERE professional_id = @professional_id
        AND status = 'active'
        AND (kind = 'session' OR expires_at > @now)
        AND period && tstzrange(@from, @to, '[)')
      ''',
      {'professional_id': professionalId, 'from': from, 'to': to, 'now': now},
      null,
    );

    final blocked = await _query(
      '''
      SELECT lower(period) AS starts_at, upper(period) AS ends_at
      FROM availability_exceptions
      WHERE professional_id = @professional_id AND is_available = false
        AND period && tstzrange(@from, @to, '[)')
      ''',
      {'professional_id': professionalId, 'from': from, 'to': to},
      null,
    );

    final occupied = [
      for (final row in [...taken, ...blocked])
        (start: row.dateAt('starts_at'), end: row.dateAt('ends_at')),
    ];

    final rulesByWeekday = <int, List<({int start, int end})>>{};
    for (final rule in rules) {
      rulesByWeekday
          .putIfAbsent(rule.intAt('weekday'), () => [])
          .add((start: rule.intAt('start_minute'), end: rule.intAt('end_minute')));
    }

    final slots = <AvailabilitySlot>[];
    var day = DateTime.utc(from.year, from.month, from.day);

    while (day.isBefore(to)) {
      // Sunday is 0, matching the booking calendar in both languages.
      final weekday = day.weekday % 7;
      final windows =
          rulesByWeekday[weekday] ?? const <({int start, int end})>[];
      for (final window in windows) {
        for (
          var minute = window.start;
          minute + slotMinutes <= window.end;
          minute += slotMinutes
        ) {
          final startsAt = day.add(Duration(minutes: minute));
          final endsAt = startsAt.add(Duration(minutes: slotMinutes));
          if (startsAt.isBefore(from) || !endsAt.isBefore(to)) continue;

          final isFree =
              startsAt.isAfter(now) &&
              !occupied.any(
                (busy) =>
                    startsAt.isBefore(busy.end) && endsAt.isAfter(busy.start),
              );

          slots.add(
            AvailabilitySlot(
              startsAt: startsAt,
              endsAt: endsAt,
              isAvailable: isFree,
            ),
          );
        }
      }
      day = day.add(const Duration(days: 1));
    }

    slots.sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return slots;
  }

  // --- Bookings -------------------------------------------------------------

  Future<String> insertBooking({
    required String userId,
    required int professionalId,
    required int? packageId,
    required ServiceKind kind,
    required int totalEgp,
    required int platformFeeEgp,
    required String subject,
    required String goal,
    required Session session,
  }) async {
    final rows = await _query(
      '''
      INSERT INTO bookings (
        user_id, professional_id, package_id, kind, total_egp,
        platform_fee_egp, subject, goal
      ) VALUES (
        @user_id, @professional_id, @package_id, @kind::service_kind,
        @total_egp, @platform_fee_egp, @subject, @goal
      )
      RETURNING id
      ''',
      {
        'user_id': userId,
        'professional_id': professionalId,
        'package_id': packageId,
        'kind': kind.wire,
        'total_egp': totalEgp,
        'platform_fee_egp': platformFeeEgp,
        'subject': subject,
        'goal': goal,
      },
      session,
    );
    return rows.first.str('id');
  }

  Future<String> insertBookingSession({
    required String bookingId,
    required int position,
    required DateTime startsAt,
    required DateTime endsAt,
    required Session session,
  }) async {
    final rows = await _query(
      'INSERT INTO booking_sessions (booking_id, position, starts_at, ends_at) '
      'VALUES (@booking_id, @position, @starts_at, @ends_at) RETURNING id',
      {
        'booking_id': bookingId,
        'position': position,
        'starts_at': startsAt,
        'ends_at': endsAt,
      },
      session,
    );
    return rows.first.str('id');
  }

  Future<void> insertPayment({
    required String userId,
    required String bookingId,
    required String provider,
    required int amountEgp,
    required Session session,
  }) => _execute(
    'INSERT INTO payments (user_id, booking_id, provider, amount_egp) '
    'VALUES (@user_id, @booking_id, @provider, @amount_egp)',
    {
      'user_id': userId,
      'booking_id': bookingId,
      'provider': provider,
      'amount_egp': amountEgp,
    },
    session,
  );

  Future<bool> ownsBooking({
    required String userId,
    required String bookingId,
    Session? session,
  }) async {
    final rows = await _query(
      'SELECT 1 AS owns FROM bookings WHERE id = @id AND user_id = @user_id',
      {'id': bookingId, 'user_id': userId},
      session,
    );
    return rows.isNotEmpty;
  }

  Future<void> cancelBooking({
    required String bookingId,
    required bool cancelledByProfessional,
    required int refundedEgp,
    required Session session,
  }) => _execute(
    '''
    UPDATE bookings
    SET status = @status::booking_status, cancelled_at = now(),
        refunded_egp = @refunded_egp, updated_at = now()
    WHERE id = @id
    ''',
    {
      'id': bookingId,
      'status': cancelledByProfessional
          ? BookingStatus.cancelledByProfessional.wire
          : BookingStatus.cancelledByStudent.wire,
      'refunded_egp': refundedEgp,
    },
    session,
  );

  Future<Booking?> findBooking(String id, {Session? session}) async {
    final rows = await _query(
      '''
      SELECT b.*, p.display_name_en, p.display_name_ar, p.avatar_url,
             (SELECT count(*) FROM reviews r WHERE r.booking_id = b.id) AS review_count
      FROM bookings b
      JOIN professionals p ON p.id = b.professional_id
      WHERE b.id = @id
      ''',
      {'id': id},
      session,
    );
    if (rows.isEmpty) return null;

    final sessions = await _query(
      'SELECT id, position, starts_at, ends_at, attended_at '
      'FROM booking_sessions WHERE booking_id = @id ORDER BY position',
      {'id': id},
      session,
    );
    return _toBooking(rows.first, sessions);
  }

  Future<List<Booking>> bookingsForUser(String userId) async {
    final rows = await _query(
      '''
      SELECT b.*, p.display_name_en, p.display_name_ar, p.avatar_url,
             (SELECT count(*) FROM reviews r WHERE r.booking_id = b.id) AS review_count
      FROM bookings b
      JOIN professionals p ON p.id = b.professional_id
      WHERE b.user_id = @user_id
      ORDER BY b.created_at DESC
      ''',
      {'user_id': userId},
      null,
    );
    if (rows.isEmpty) return const [];

    final sessions = await _query(
      '''
      SELECT s.* FROM booking_sessions s
      JOIN bookings b ON b.id = s.booking_id
      WHERE b.user_id = @user_id ORDER BY s.booking_id, s.position
      ''',
      {'user_id': userId},
      null,
    );

    final byBooking = <String, List<Map<String, dynamic>>>{};
    for (final row in sessions) {
      byBooking.putIfAbsent(row.str('booking_id'), () => []).add(row);
    }

    return rows
        .map((row) => _toBooking(row, byBooking[row.str('id')] ?? const []))
        .toList();
  }

  Booking _toBooking(
    Map<String, dynamic> row,
    List<Map<String, dynamic>> sessionRows,
  ) {
    final sessions = sessionRows
        .map(
          (s) => BookingSession(
            id: s.str('id'),
            position: s.intAt('position'),
            startsAt: s.dateAt('starts_at'),
            endsAt: s.dateAt('ends_at'),
            isAttended: s.dateOrNull('attended_at') != null,
          ),
        )
        .toList();

    final booking = Booking(
      id: row.str('id'),
      professionalId: row.intAt('professional_id'),
      professionalName: LocalizedText(
        en: row.str('display_name_en'),
        ar: row.str('display_name_ar'),
      ),
      kind: ServiceKind.fromWire(row.str('kind')),
      status: BookingStatus.fromWire(row.str('status')),
      sessions: sessions,
      totalEgp: row.intAt('total_egp'),
      // Filled by the service, which knows the current time.
      refundableEgp: row.intOrNull('refunded_egp') ?? 0,
      subject: row.str('subject'),
      createdAt: row.dateAt('created_at'),
      hasReview: (row.intOrNull('review_count') ?? 0) > 0,
      avatarUrl: row.strOrNull('avatar_url'),
    );
    return booking;
  }

  // --- Plumbing -------------------------------------------------------------

  Future<List<Map<String, dynamic>>> _query(
    String sql,
    Map<String, Object?> parameters,
    Session? session,
  ) async {
    Future<Result> run(Session s) =>
        s.execute(Sql.named(sql), parameters: parameters);
    final result = session != null ? await run(session) : await _database.run(run);
    return result.map((row) => row.toColumnMap()).toList();
  }

  Future<void> _execute(
    String sql,
    Map<String, Object?> parameters,
    Session? session,
  ) async {
    await _query(sql, parameters, session);
  }
}
