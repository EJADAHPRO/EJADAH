import 'package:ejadah_models/ejadah_models.dart';
import 'package:postgres/postgres.dart';

import '../../db/database.dart';
import '../../http/api_error.dart';
import '../notifications/cairo_clock.dart';

/// One recurring window in the week.
class AvailabilityRule {
  const AvailabilityRule({
    required this.id,
    required this.weekday,
    required this.startMinute,
    required this.endMinute,
  });

  final int id;

  /// 0 = Sunday … 6 = Saturday. The schema's convention, and the booking
  /// calendar's — it starts on Sunday in both languages.
  final int weekday;

  /// Minutes from midnight, Cairo. Stored as minutes rather than a time so a
  /// half-hour block is expressible without a second column.
  final int startMinute;
  final int endMinute;

  int get minutes => endMinute - startMinute;

  Map<String, dynamic> toJson() => {
    'id': id,
    'weekday': weekday,
    'start_minute': startMinute,
    'end_minute': endMinute,
  };
}

/// A dated override: a day blocked off, or extra hours opened.
class AvailabilityException {
  const AvailabilityException({
    required this.id,
    required this.startsAt,
    required this.endsAt,
    required this.isAvailable,
    this.reason,
  });

  final int id;
  final DateTime startsAt;
  final DateTime endsAt;

  /// False blocks the period; true opens hours the weekly rules do not cover.
  final bool isAvailable;
  final String? reason;

  Map<String, dynamic> toJson() => {
    'id': id,
    'starts_at': startsAt.toIso8601String(),
    'ends_at': endsAt.toIso8601String(),
    'is_available': isAvailable,
    'reason': reason,
  };
}

/// A session that stands in the way of a block.
class ClashingSession {
  const ClashingSession({
    required this.bookingId,
    required this.startsAt,
    required this.endsAt,
    required this.studentName,
    required this.subject,
  });

  final String bookingId;
  final DateTime startsAt;
  final DateTime endsAt;
  final LocalizedText studentName;
  final String subject;

  Map<String, dynamic> toJson() => {
    'booking_id': bookingId,
    'starts_at': startsAt.toIso8601String(),
    'ends_at': endsAt.toIso8601String(),
    'student_name': studentName.toJson(),
    'subject': subject,
  };
}

/// Refused because the period already holds confirmed sessions.
///
/// Carries them, rather than only saying no. A tutor blocking a week for travel
/// has to be told *which* students they would be standing up, by name and by
/// time — otherwise the only way to find out is to strand them and wait for the
/// complaints.
class AvailabilityClash implements Exception {
  const AvailabilityClash(this.sessions);

  final List<ClashingSession> sessions;
}

/// The tutor's own calendar: the weekly shape, and the exceptions to it.
///
/// One rule decides the design of this whole service: **a confirmed session is
/// a promise, and nothing here may break one silently.** Removing availability
/// is always allowed for time nobody has booked; over time somebody has, it is
/// refused and the sessions are named. The tutor then cancels them
/// deliberately, through the flow that refunds the student and tells them —
/// which is the only path where the student finds out.
class AvailabilityService {
  const AvailabilityService(this._database);

  final Database _database;

  /// The floor the application asks for and the dashboard keeps nagging about.
  static const int minimumWeeklyHours = 5;

  Future<List<AvailabilityRule>> rules(int professionalId) async {
    final rows = await _query(
      'SELECT * FROM availability_rules WHERE professional_id = @id '
      'ORDER BY weekday, start_minute',
      {'id': professionalId},
    );
    return rows.map(_toRule).toList();
  }

  /// Exceptions from [from] forward.
  ///
  /// Past ones are not returned: a day blocked last month is not something
  /// anyone can act on, and a list that grows forever is a list nobody reads.
  Future<List<AvailabilityException>> exceptions(
    int professionalId, {
    required DateTime from,
  }) async {
    final rows = await _query(
      'SELECT id, lower(period) AS starts_at, upper(period) AS ends_at, '
      'is_available, reason FROM availability_exceptions '
      'WHERE professional_id = @id AND upper(period) > @from '
      'ORDER BY lower(period)',
      {'id': professionalId, 'from': from},
    );
    return rows.map(_toException).toList();
  }

  int weeklyMinutes(List<AvailabilityRule> rules) =>
      rules.fold(0, (total, rule) => total + rule.minutes);

  /// Replaces the weekly shape.
  ///
  /// Whole-list rather than per-rule edits: the editor shows a week and saves a
  /// week, and a diffing protocol between two representations of the same seven
  /// days is a source of drift with nothing to show for it.
  ///
  /// Refused, with the sessions named, if the new shape would remove hours that
  /// a confirmed session already occupies within the next [_horizonDays].
  Future<List<AvailabilityRule>> saveRules({
    required int professionalId,
    required List<AvailabilityRule> replacement,
    DateTime? now,
  }) async {
    for (final rule in replacement) {
      if (rule.weekday < 0 || rule.weekday > 6) {
        throw ApiException.validation({'weekday': _badWeekday});
      }
      if (rule.startMinute < 0 ||
          rule.endMinute > 1440 ||
          rule.endMinute <= rule.startMinute) {
        throw ApiException.validation({'hours': _badHours});
      }
    }

    return _database.runTx((tx) async {
      final at = (now ?? DateTime.now()).toUtc();

      // Every confirmed session ahead of us, checked against the *new* shape.
      // Doing this inside the transaction that rewrites the rules is what stops
      // a booking landing between the check and the write.
      final upcoming = await _confirmedSessions(
        professionalId: professionalId,
        from: at,
        to: at.add(const Duration(days: _horizonDays)),
        session: tx,
      );

      final orphaned = upcoming
          .where((session) => !_covered(session, replacement))
          .toList();
      if (orphaned.isNotEmpty) throw AvailabilityClash(orphaned);

      await tx.execute(
        Sql.named('DELETE FROM availability_rules WHERE professional_id = @id'),
        parameters: {'id': professionalId},
      );
      for (final rule in replacement) {
        await tx.execute(
          Sql.named(
            'INSERT INTO availability_rules '
            '(professional_id, weekday, start_minute, end_minute) '
            'VALUES (@id, @weekday, @start, @end)',
          ),
          parameters: {
            'id': professionalId,
            'weekday': rule.weekday,
            'start': rule.startMinute,
            'end': rule.endMinute,
          },
        );
      }

      final rows = await tx.execute(
        Sql.named(
          'SELECT * FROM availability_rules WHERE professional_id = @id '
          'ORDER BY weekday, start_minute',
        ),
        parameters: {'id': professionalId},
      );
      return rows.map((row) => _toRule(row.toColumnMap())).toList();
    });
  }

  /// Blocks a period.
  ///
  /// **The load-bearing method.** A tutor blocking a date they have already
  /// been booked on is the single way this product can silently strand a
  /// student: the slot vanishes, the booking stays, and nobody is told. So the
  /// block is refused and every confirmed session inside it is named. Cancelling
  /// is still available — through the cancellation flow, which refunds and
  /// notifies.
  Future<AvailabilityException> block({
    required int professionalId,
    required DateTime startsAt,
    required DateTime endsAt,
    String? reason,
  }) async {
    if (!endsAt.isAfter(startsAt)) {
      throw ApiException.validation({'period': _badPeriod});
    }

    return _database.runTx((tx) async {
      final clashes = await _confirmedSessions(
        professionalId: professionalId,
        from: startsAt,
        to: endsAt,
        session: tx,
      );
      if (clashes.isNotEmpty) throw AvailabilityClash(clashes);

      final rows = await tx.execute(
        Sql.named(
          'INSERT INTO availability_exceptions '
          '(professional_id, period, is_available, reason) '
          'VALUES (@id, tstzrange(@from, @to, \'[)\'), false, @reason) '
          'RETURNING id, lower(period) AS starts_at, upper(period) AS ends_at, '
          'is_available, reason',
        ),
        parameters: {
          'id': professionalId,
          'from': startsAt,
          'to': endsAt,
          'reason': reason,
        },
      );
      return _toException(rows.first.toColumnMap());
    });
  }

  /// Opens hours the weekly rules do not cover — a one-off Saturday.
  ///
  /// No clash check: adding availability cannot strand anyone.
  Future<AvailabilityException> open({
    required int professionalId,
    required DateTime startsAt,
    required DateTime endsAt,
  }) async {
    if (!endsAt.isAfter(startsAt)) {
      throw ApiException.validation({'period': _badPeriod});
    }
    final rows = await _query(
      'INSERT INTO availability_exceptions '
      '(professional_id, period, is_available) '
      "VALUES (@id, tstzrange(@from, @to, '[)'), true) "
      'RETURNING id, lower(period) AS starts_at, upper(period) AS ends_at, '
      'is_available, reason',
      {'id': professionalId, 'from': startsAt, 'to': endsAt},
    );
    return _toException(rows.first);
  }

  /// Removes an exception.
  ///
  /// Scoped by professional in the WHERE clause rather than checked first: an
  /// ownership check in a separate statement is one that can be raced.
  Future<void> removeException({
    required int professionalId,
    required int exceptionId,
  }) async {
    final rows = await _query(
      'DELETE FROM availability_exceptions '
      'WHERE id = @id AND professional_id = @professional_id RETURNING id',
      {'id': exceptionId, 'professional_id': professionalId},
    );
    if (rows.isEmpty) throw ApiException.notFound();
  }

  /// Confirmed sessions overlapping a period.
  ///
  /// `pending_payment` is excluded on purpose: nobody has paid and no promise
  /// has been made, so blocking over one costs nothing. Cancelled ones are
  /// excluded for the obvious reason.
  Future<List<ClashingSession>> _confirmedSessions({
    required int professionalId,
    required DateTime from,
    required DateTime to,
    Session? session,
  }) async {
    final rows = await _query(
      '''
      SELECT s.booking_id, s.starts_at, s.ends_at, b.subject,
             u.full_name_en, u.full_name_ar
      FROM booking_sessions s
      JOIN bookings b ON b.id = s.booking_id
      JOIN users u ON u.id = b.user_id
      WHERE b.professional_id = @professional_id
        AND b.status IN ('confirmed', 'completed')
        AND s.starts_at < @to
        AND s.ends_at > @from
      ORDER BY s.starts_at
      ''',
      {'professional_id': professionalId, 'from': from, 'to': to},
      session,
    );

    return rows
        .map(
          (row) => ClashingSession(
            bookingId: row.str('booking_id'),
            startsAt: row.dateAt('starts_at'),
            endsAt: row.dateAt('ends_at'),
            studentName: LocalizedText(
              en: row.str('full_name_en'),
              ar: row.str('full_name_ar'),
            ),
            subject: row.strOrNull('subject') ?? '',
          ),
        )
        .toList();
  }

  /// How far ahead a rules change is checked.
  ///
  /// Sessions are booked weeks out, not months; checking a year forward would
  /// refuse a reasonable change because of one distant booking, and checking
  /// only a week would miss the ones people actually hold.
  static const int _horizonDays = 90;

  /// Whether a session still falls inside the proposed weekly shape.
  static bool _covered(ClashingSession session, List<AvailabilityRule> rules) {
    // Compared in Cairo, because that is the clock the rules are written in and
    // the one the tutor was looking at.
    final start = CairoClock.local(session.startsAt);
    final end = CairoClock.local(session.endsAt);

    // A session crossing midnight cannot be covered by a single weekday rule;
    // treating it as covered would be the silent-stranding this exists to stop.
    if (start.day != end.day) return false;

    final weekday = start.weekday % 7; // Dart: Mon=1..Sun=7 → Sun=0..Sat=6.
    final startMinute = start.hour * 60 + start.minute;
    final endMinute = end.hour * 60 + end.minute;

    return rules.any(
      (rule) =>
          rule.weekday == weekday &&
          rule.startMinute <= startMinute &&
          rule.endMinute >= endMinute,
    );
  }

  AvailabilityRule _toRule(Map<String, dynamic> row) => AvailabilityRule(
    id: row.intAt('id'),
    weekday: row.intAt('weekday'),
    startMinute: row.intAt('start_minute'),
    endMinute: row.intAt('end_minute'),
  );

  AvailabilityException _toException(Map<String, dynamic> row) =>
      AvailabilityException(
        id: row.intAt('id'),
        startsAt: row.dateAt('starts_at'),
        endsAt: row.dateAt('ends_at'),
        isAvailable: row['is_available'] as bool? ?? false,
        reason: row.strOrNull('reason'),
      );

  Future<List<Map<String, dynamic>>> _query(
    String sql,
    Map<String, Object?> parameters, [
    Session? session,
  ]) async {
    final result = session != null
        ? await session.execute(Sql.named(sql), parameters: parameters)
        : await _database.run(
            (owned) => owned.execute(Sql.named(sql), parameters: parameters),
          );
    return result.map((row) => row.toColumnMap()).toList();
  }

  static const LocalizedText _badWeekday = LocalizedText(
    en: 'That is not a day of the week.',
    ar: 'هذا ليس يومًا من أيام الأسبوع.',
  );

  static const LocalizedText _badHours = LocalizedText(
    en: 'The end time has to come after the start time.',
    ar: 'يجب أن يأتي وقت الانتهاء بعد وقت البدء.',
  );

  static const LocalizedText _badPeriod = LocalizedText(
    en: 'That period ends before it starts.',
    ar: 'هذه الفترة تنتهي قبل أن تبدأ.',
  );
}
