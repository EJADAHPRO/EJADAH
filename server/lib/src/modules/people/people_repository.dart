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
      rulesByWeekday.putIfAbsent(rule.intAt('weekday'), () => []).add((
        start: rule.intAt('start_minute'),
        end: rule.intAt('end_minute'),
      ));
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

  /// Moves a booking to another status, without touching cancellation or
  /// refund fields — those belong to [cancelBooking] and mean money moved.
  Future<void> setBookingStatus({
    required String bookingId,
    required BookingStatus status,
    Session? session,
  }) => _execute(
    'UPDATE bookings SET status = @status::booking_status, updated_at = now() '
    'WHERE id = @id',
    {'id': bookingId, 'status': status.wire},
    session,
  );

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

  // --- Discovery ------------------------------------------------------------
  //
  // The three doors share one roster, one profile shape and one booking
  // architecture. Building three unrelated marketplaces is the failure mode
  // `ServiceKind` exists to prevent, so every query below is parameterised by
  // kind rather than duplicated per door.

  /// How many approved professionals stand behind each door.
  ///
  /// The hub states its own supply: a door that leads to an empty list is worse
  /// than a door that says how many people are behind it.
  Future<Map<ServiceKind, int>> countsByKind() async {
    final rows = await _query(
      'SELECT kind, count(*) AS n FROM professionals '
      'WHERE is_approved GROUP BY kind',
      const {},
      null,
    );
    return {
      for (final kind in ServiceKind.values)
        kind: rows
            .where((row) => row.str('kind') == kind.wire)
            .map((row) => row.intAt('n'))
            .firstOrNull ??
            0,
    };
  }

  /// A filtered, paged marketplace list.
  ///
  /// Filtering and paging happen in SQL. The client never downloads the roster
  /// to filter it locally, which is what keeps the list honest about its own
  /// count.
  Future<Paginated<Professional>> searchProfessionals(
    ProfessionalQuery query,
  ) async {
    final where = _professionalWhere(query);

    final countRows = await _query(
      'SELECT count(*) AS total FROM professionals p ${where.sql}',
      where.parameters,
      null,
    );
    final total = countRows.first.intAt('total');

    final rows = await _query(
      '''
      SELECT $_professionalColumns
      FROM professionals p
      $_ratingJoin
      ${where.sql}
      ORDER BY ${_professionalOrderBy(query.sort)}
      LIMIT @limit OFFSET @offset
      ''',
      {
        ...where.parameters,
        'limit': query.pageSize,
        'offset': (query.page - 1) * query.pageSize,
      },
      null,
    );

    return Paginated(
      items: rows.map((row) => _toProfessional(row)).toList(),
      total: total,
      page: query.page,
      pageSize: query.pageSize,
    );
  }

  /// The "New this month" rail.
  ///
  /// Cold-start supply survival: a professional with no reviews yet would sink
  /// to the bottom of every sort, so the rail gives them a first booking.
  Future<List<Professional>> newThisMonth(
    ServiceKind kind, {
    int limit = 8,
  }) async {
    final rows = await _query(
      '''
      SELECT $_professionalColumns
      FROM professionals p
      $_ratingJoin
      WHERE p.is_approved AND p.kind = @kind::service_kind
        AND p.created_at >= date_trunc('month', now())
      ORDER BY p.created_at DESC, p.id
      LIMIT @limit
      ''',
      {'kind': kind.wire, 'limit': limit},
      null,
    );
    return rows.map((row) => _toProfessional(row)).toList();
  }

  /// A full profile: qualifications and packages included.
  ///
  /// Looked up by slug because that is what the deep link carries — a numeric
  /// id in a shared URL tells a reader nothing and cannot be checked by eye.
  Future<Professional?> findProfessionalBySlug(String slug) async {
    final rows = await _query(
      '''
      SELECT $_professionalColumns
      FROM professionals p
      $_ratingJoin
      WHERE p.slug = @slug AND p.is_approved
      ''',
      {'slug': slug},
      null,
    );
    if (rows.isEmpty) return null;

    final id = rows.first.intAt('id');
    return _toProfessional(
      rows.first,
      qualifications: await qualificationsFor(id),
      packages: await packagesFor(id),
    );
  }

  /// Qualifications in the order the professional arranged them.
  ///
  /// `evidence` travels with every row: verified and stated are different
  /// facts, and the client must never have to guess which it is holding.
  Future<List<Qualification>> qualificationsFor(int professionalId) async {
    final rows = await _query(
      'SELECT id, title_en, title_ar, issuer_en, issuer_ar, evidence, year '
      'FROM professional_qualifications WHERE professional_id = @id '
      'ORDER BY position',
      {'id': professionalId},
      null,
    );
    return rows
        .map(
          (row) => Qualification(
            id: row.intAt('id'),
            title: LocalizedText(
              en: row.str('title_en'),
              ar: row.str('title_ar'),
            ),
            issuer: LocalizedText(
              en: row.str('issuer_en'),
              ar: row.str('issuer_ar'),
            ),
            evidence: CredentialEvidence.fromWire(row.str('evidence')),
            year: row.intOrNull('year'),
          ),
        )
        .toList();
  }

  /// Active packages, each carrying its own cadence sentence.
  ///
  /// The sentence is stored rather than composed, so the booking flow never
  /// re-asks what the plan already answered.
  Future<List<ServicePackage>> packagesFor(int professionalId) async {
    final rows = await _query(
      '''
      SELECT id, title_en, title_ar, session_count, session_minutes, price_egp,
             cadence_sentence_en, cadence_sentence_ar
      FROM professional_packages
      WHERE professional_id = @id AND is_active = true
      ORDER BY session_count, id
      ''',
      {'id': professionalId},
      null,
    );
    return rows
        .map(
          (row) => ServicePackage(
            id: row.intAt('id'),
            title: LocalizedText(
              en: row.str('title_en'),
              ar: row.str('title_ar'),
            ),
            sessionCount: row.intAt('session_count'),
            sessionMinutes: row.intAt('session_minutes'),
            priceEgp: row.intAt('price_egp'),
            cadenceSentence: LocalizedText(
              en: row.str('cadence_sentence_en'),
              ar: row.str('cadence_sentence_ar'),
            ),
          ),
        )
        .toList();
  }

  /// Reviews, newest first.
  ///
  /// A review is written by a real student against a real attended booking, so
  /// the author's name is theirs rather than an invented handle.
  Future<List<ProfessionalReview>> reviewsFor(
    int professionalId, {
    int limit = 10,
  }) async {
    final rows = await _query(
      '''
      SELECT r.id, r.rating, r.body, r.created_at,
             u.full_name_en, u.full_name_ar
      FROM reviews r
      JOIN users u ON u.id = r.user_id
      WHERE r.professional_id = @id
      ORDER BY r.created_at DESC
      LIMIT @limit
      ''',
      {'id': professionalId, 'limit': limit},
      null,
    );
    return rows
        .map(
          (row) => ProfessionalReview(
            id: row.str('id'),
            rating: row.intAt('rating'),
            body: row.str('body'),
            authorName: LocalizedText(
              en: row.str('full_name_en'),
              ar: row.str('full_name_ar'),
            ),
            createdAt: row.dateAt('created_at'),
          ),
        )
        .toList();
  }

  /// The filter values this door actually contains.
  ///
  /// Offering a filter that matches nothing is the same defect as a dead-end
  /// empty state, so the sheet is built from the roster rather than a constant.
  Future<Map<String, List<String>>> professionalFacets(ServiceKind kind) async {
    // The expression is projected in a subquery rather than filtered in place:
    // `unnest` is set-returning and PostgreSQL rejects it in a WHERE clause.
    Future<List<String>> distinctFrom(String expression) async {
      final rows = await _query(
        '''
        SELECT DISTINCT value FROM (
          SELECT $expression AS value FROM professionals p
          WHERE p.is_approved AND p.kind = @kind::service_kind
        ) AS values
        WHERE value IS NOT NULL AND value <> ''
        ORDER BY value
        ''',
        {'kind': kind.wire},
        null,
      );
      return rows.map((row) => row.str('value')).toList();
    }

    return {
      'specialties': await distinctFrom('unnest(p.specialties)'),
      'languages': await distinctFrom('unnest(p.languages)'),
      // Only mentors have a journey; for the other doors this is empty and the
      // filter simply does not render.
      'destinations': await distinctFrom('p.journey_to'),
    };
  }

  static const String _ratingJoin = '''
    LEFT JOIN (
      SELECT professional_id, avg(rating) AS rating, count(*) AS review_count
      FROM reviews GROUP BY professional_id
    ) rv ON rv.professional_id = p.id
  ''';

  static const String _professionalColumns = '''
    p.id, p.slug, p.kind, p.display_name_en, p.display_name_ar,
    p.headline_en, p.headline_ar, p.bio_en, p.bio_ar,
    p.specialties, p.languages, p.hourly_rate_egp, p.offers_free_intro_call,
    p.journey_from, p.journey_to, p.journey_year,
    p.cancellation_policy_en, p.cancellation_policy_ar, p.avatar_url,
    (p.created_at >= date_trunc('month', now())) AS is_new_this_month,
    rv.rating AS rating, COALESCE(rv.review_count, 0) AS review_count
  ''';

  Professional _toProfessional(
    Map<String, dynamic> row, {
    List<Qualification> qualifications = const [],
    List<ServicePackage> packages = const [],
  }) => Professional(
    id: row.intAt('id'),
    slug: row.str('slug'),
    kind: ServiceKind.fromWire(row.str('kind')),
    displayName: LocalizedText(
      en: row.str('display_name_en'),
      ar: row.str('display_name_ar'),
    ),
    headline: LocalizedText(
      en: row.str('headline_en'),
      ar: row.str('headline_ar'),
    ),
    bio: LocalizedText(en: row.str('bio_en'), ar: row.str('bio_ar')),
    specialties: row.stringList('specialties'),
    languages: row.stringList('languages'),
    hourlyRateEgp: row.intAt('hourly_rate_egp'),
    rating: row.doubleOrNull('rating'),
    reviewCount: row.intOrNull('review_count') ?? 0,
    qualifications: qualifications,
    packages: packages,
    offersFreeIntroCall: row.boolAt('offers_free_intro_call'),
    isNewThisMonth: row.boolAt('is_new_this_month'),
    cancellationPolicy: LocalizedText(
      en: row.str('cancellation_policy_en'),
      ar: row.str('cancellation_policy_ar'),
    ),
    // Never a placeholder portrait: the client falls back to initials, because
    // no licensed photograph exists for any professional in this release.
    avatarUrl: row.strOrNull('avatar_url'),
    journeyFrom: row.strOrNull('journey_from'),
    journeyTo: row.strOrNull('journey_to'),
    journeyYear: row.intOrNull('journey_year'),
  );

  _ProfessionalWhere _professionalWhere(ProfessionalQuery query) {
    final conditions = <String>[
      'p.is_approved',
      'p.kind = @kind::service_kind',
    ];
    final parameters = <String, Object?>{'kind': query.kind.wire};

    // Array overlap expressed through `= ANY(...)` so the driver can infer the
    // parameter type from the Dart list rather than needing a cast.
    void overlaps(String column, List<String> values, String key) {
      if (values.isEmpty) return;
      conditions.add(
        'EXISTS (SELECT 1 FROM unnest(p.$column) AS v WHERE v = ANY(@$key))',
      );
      parameters[key] = values;
    }

    overlaps('specialties', query.specialties, 'specialties');
    overlaps('languages', query.languages, 'languages');

    if (query.destinations.isNotEmpty) {
      // Mentors are matched on the move they actually made — that is the whole
      // reason the mentoring door exists.
      conditions.add('p.journey_to = ANY(@destinations)');
      parameters['destinations'] = query.destinations;
    }
    if (query.maxRateEgp != null) {
      conditions.add('p.hourly_rate_egp <= @max_rate');
      parameters['max_rate'] = query.maxRateEgp;
    }
    if (query.freeIntroCallOnly) {
      conditions.add('p.offers_free_intro_call = true');
    }
    if (query.newThisMonthOnly) {
      conditions.add("p.created_at >= date_trunc('month', now())");
    }

    return _ProfessionalWhere(
      sql: 'WHERE ${conditions.join(' AND ')}',
      parameters: parameters,
    );
  }

  /// Ordering is fully specified in every branch, and every branch ends on
  /// `p.id`: without a unique final key two equal rows can swap between pages
  /// and a reader sees one of them twice.
  static String _professionalOrderBy(ProfessionalSort sort) => switch (sort) {
    // Someone with no reviews yet is not buried: the rail and this tie-break
    // are what give a new professional a first booking.
    ProfessionalSort.recommended =>
      'rv.rating DESC NULLS LAST, rv.review_count DESC NULLS LAST, p.id',
    ProfessionalSort.priceAsc => 'p.hourly_rate_egp ASC, p.id',
    ProfessionalSort.priceDesc => 'p.hourly_rate_egp DESC, p.id',
    ProfessionalSort.ratingDesc => 'rv.rating DESC NULLS LAST, p.id',
    ProfessionalSort.newest => 'p.created_at DESC, p.id',
  };

  // --- Plumbing -------------------------------------------------------------

  Future<List<Map<String, dynamic>>> _query(
    String sql,
    Map<String, Object?> parameters,
    Session? session,
  ) async {
    Future<Result> run(Session s) =>
        s.execute(Sql.named(sql), parameters: parameters);
    final result = session != null
        ? await run(session)
        : await _database.run(run);
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

/// How a marketplace list is ordered.
enum ProfessionalSort {
  recommended('recommended'),
  priceAsc('price_asc'),
  priceDesc('price_desc'),
  ratingDesc('rating_desc'),
  newest('newest');

  const ProfessionalSort(this.wire);

  final String wire;

  static ProfessionalSort fromWire(String? value) =>
      ProfessionalSort.values.firstWhere(
        (sort) => sort.wire == value,
        orElse: () => ProfessionalSort.recommended,
      );
}

/// The filters one marketplace door offers.
///
/// The set differs by door in what is *populated*, not in what exists:
/// `destinations` is only ever non-empty for mentoring, because only a mentor
/// has a move to match on. One query type across three doors is deliberate.
class ProfessionalQuery {
  const ProfessionalQuery({
    required this.kind,
    this.specialties = const [],
    this.languages = const [],
    this.destinations = const [],
    this.maxRateEgp,
    this.freeIntroCallOnly = false,
    this.newThisMonthOnly = false,
    this.sort = ProfessionalSort.recommended,
    this.page = 1,
    this.pageSize = 12,
  });

  final ServiceKind kind;
  final List<String> specialties;
  final List<String> languages;

  /// Where the mentor moved to. Empty for tutoring and consulting.
  final List<String> destinations;
  final int? maxRateEgp;
  final bool freeIntroCallOnly;
  final bool newThisMonthOnly;
  final ProfessionalSort sort;
  final int page;
  final int pageSize;

  bool get hasActiveFilters =>
      specialties.isNotEmpty ||
      languages.isNotEmpty ||
      destinations.isNotEmpty ||
      maxRateEgp != null ||
      freeIntroCallOnly ||
      newThisMonthOnly;
}

/// A review left against an attended booking.
///
/// Not a model in `ejadah_models` because nothing outside the People module
/// reads one; it travels as part of the profile payload.
class ProfessionalReview {
  const ProfessionalReview({
    required this.id,
    required this.rating,
    required this.body,
    required this.authorName,
    required this.createdAt,
  });

  final String id;

  /// One to five, enforced by the schema.
  final int rating;
  final String body;
  final LocalizedText authorName;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'rating': rating,
    'body': body,
    'author_name': authorName.toJson(),
    'created_at': createdAt.toIso8601String(),
  };
}

class _ProfessionalWhere {
  const _ProfessionalWhere({required this.sql, required this.parameters});

  final String sql;
  final Map<String, Object?> parameters;
}
