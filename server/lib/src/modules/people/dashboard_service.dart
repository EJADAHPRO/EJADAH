import 'package:ejadah_models/ejadah_models.dart';
import 'package:postgres/postgres.dart';

import '../../db/database.dart';
import '../../http/api_error.dart';
import '../notifications/cairo_clock.dart';

/// One session on the tutor's own calendar.
class TutorSession {
  const TutorSession({
    required this.id,
    required this.bookingId,
    required this.startsAt,
    required this.endsAt,
    required this.studentName,
    required this.subject,
    required this.goal,
    required this.netEgp,
    this.attendedAt,
  });

  final String id;
  final String bookingId;
  final DateTime startsAt;
  final DateTime endsAt;
  final LocalizedText studentName;
  final String subject;

  /// What the student wrote they need. Shown to **their own tutor** and nobody
  /// else — it is why the session is worth preparing for, and it is also
  /// clinical free text, so it never reaches a third party, a log or analytics.
  final String goal;

  /// What this session is worth to the tutor, once it is marked.
  final int netEgp;

  /// When the tutor marked it as held. Null while it is still unmarked.
  final DateTime? attendedAt;

  bool get isMarked => attendedAt != null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'booking_id': bookingId,
    'starts_at': startsAt.toIso8601String(),
    'ends_at': endsAt.toIso8601String(),
    'student_name': studentName.toJson(),
    'subject': subject,
    'goal': goal,
    'net_egp': netEgp,
    'attended_at': attendedAt?.toIso8601String(),
    'is_marked': isMarked,
  };
}

/// The tutor's working day (PE-13).
///
/// Ordered by what a tutor opens the app to find out, in that order: what is
/// happening today, what they have earned, what is holding money up, and what
/// the rest of the week looks like. Deliberately not a chart — a tutor with six
/// sessions a month has nothing to plot, and a sparkline over six points is
/// decoration standing where a number should be.
class DashboardService {
  const DashboardService(this._database);

  final Database _database;

  /// How long after its last session a booking completes itself.
  ///
  /// Marking is what releases the money, and a tutor who never marks would
  /// otherwise never be paid. A week is long enough that the nudge does its job
  /// and short enough that forgetting is not punished.
  static const int autoCompleteAfterDays = 7;

  Future<Map<String, dynamic>> profile(int professionalId) async {
    final rows = await _query(
      'SELECT meeting_url, is_hidden FROM professionals WHERE id = @id',
      {'id': professionalId},
    );
    if (rows.isEmpty) throw ApiException.notFound();
    return {
      'meeting_url': rows.first.strOrNull('meeting_url'),
      'is_hidden': rows.first.boolAt('is_hidden'),
    };
  }

  /// Sessions between two instants.
  Future<List<TutorSession>> sessions({
    required int professionalId,
    required DateTime from,
    required DateTime to,
  }) async {
    final rows = await _query(
      '''
      SELECT s.id, s.booking_id, s.starts_at, s.ends_at, s.attended_at,
             b.subject, b.goal,
             b.total_egp - b.platform_fee_egp AS net_egp,
             (SELECT count(*) FROM booking_sessions x
              WHERE x.booking_id = b.id) AS session_count,
             u.full_name_en, u.full_name_ar
      FROM booking_sessions s
      JOIN bookings b ON b.id = s.booking_id
      JOIN users u ON u.id = b.user_id
      WHERE b.professional_id = @professional_id
        AND b.status IN ('confirmed', 'completed')
        AND s.starts_at >= @from AND s.starts_at < @to
      ORDER BY s.starts_at
      ''',
      {'professional_id': professionalId, 'from': from, 'to': to},
    );
    return rows.map(_toSession).toList();
  }

  /// Sessions that have ended and have not been marked.
  ///
  /// The dashboard's one piece of nagging, and it is honest about why: marking
  /// is what turns a held session into money the tutor can ask for.
  Future<List<TutorSession>> unmarked({
    required int professionalId,
    DateTime? now,
  }) async {
    final rows = await _query(
      '''
      SELECT s.id, s.booking_id, s.starts_at, s.ends_at, s.attended_at,
             b.subject, b.goal,
             b.total_egp - b.platform_fee_egp AS net_egp,
             (SELECT count(*) FROM booking_sessions x
              WHERE x.booking_id = b.id) AS session_count,
             u.full_name_en, u.full_name_ar
      FROM booking_sessions s
      JOIN bookings b ON b.id = s.booking_id
      JOIN users u ON u.id = b.user_id
      WHERE b.professional_id = @professional_id
        AND b.status = 'confirmed'
        AND s.ends_at <= @now
        AND s.attended_at IS NULL
      ORDER BY s.starts_at
      ''',
      {
        'professional_id': professionalId,
        'now': (now ?? DateTime.now()).toUtc(),
      },
    );
    return rows.map(_toSession).toList();
  }

  /// Marks a session as held.
  ///
  /// When it is the booking's last unmarked session the booking completes,
  /// which is what releases the earning. Everything happens in one transaction:
  /// a session marked without its money moving is the state a tutor would
  /// notice and nobody could explain.
  ///
  /// Scoped by professional in the WHERE clause — an ownership check in a
  /// separate statement is one that can be raced.
  Future<TutorSession> mark({
    required int professionalId,
    required String sessionId,
    DateTime? now,
  }) => _database.runTx((tx) async {
    final at = (now ?? DateTime.now()).toUtc();

    final marked = await tx.execute(
      Sql.named('''
        UPDATE booking_sessions s
        -- COALESCE, not assignment: a double-tap must not rewrite the time the
        -- session was actually marked. Idempotent rather than 404, because a
        -- second tap on a row that is already done is not an error the tutor
        -- needs to hear about.
        SET attended_at = COALESCE(s.attended_at, @now)
        FROM bookings b
        WHERE s.id = @id AND b.id = s.booking_id
          AND b.professional_id = @professional_id
          -- `completed` as well as `confirmed`: marking the last session of a
          -- booking completes it, so a double-tap would otherwise answer "no
          -- longer available" to a tutor who did nothing wrong. Cancelled
          -- bookings are still excluded — there is no work to claim there.
          AND b.status IN ('confirmed', 'completed')
          -- Marking a session that has not happened yet would be claiming
          -- money for work not done.
          AND s.ends_at <= @now
        RETURNING s.booking_id
      '''),
      parameters: {
        'id': sessionId,
        'professional_id': professionalId,
        'now': at,
      },
    );
    if (marked.isEmpty) throw ApiException.notFound();
    final bookingId = marked.first.toColumnMap().str('booking_id');

    // The booking is done when nothing is left unmarked.
    final remaining = await tx.execute(
      Sql.named(
        'SELECT count(*) AS n FROM booking_sessions '
        'WHERE booking_id = @id AND attended_at IS NULL',
      ),
      parameters: {'id': bookingId},
    );
    if (remaining.first.toColumnMap().intAt('n') == 0) {
      await tx.execute(
        Sql.named(
          "UPDATE bookings SET status = 'completed', updated_at = now() "
          'WHERE id = @id',
        ),
        parameters: {'id': bookingId},
      );
      await tx.execute(
        Sql.named(
          "UPDATE earnings SET status = 'available' "
          "WHERE booking_id = @id AND status = 'pending'",
        ),
        parameters: {'id': bookingId},
      );
    }

    final rows = await tx.execute(
      Sql.named('''
        SELECT s.id, s.booking_id, s.starts_at, s.ends_at, s.attended_at,
               b.subject, b.goal,
               b.total_egp - b.platform_fee_egp AS net_egp,
               (SELECT count(*) FROM booking_sessions x
                WHERE x.booking_id = b.id) AS session_count,
               u.full_name_en, u.full_name_ar
        FROM booking_sessions s
        JOIN bookings b ON b.id = s.booking_id
        JOIN users u ON u.id = b.user_id
        WHERE s.id = @id
      '''),
      parameters: {'id': sessionId},
    );
    return _toSession(rows.first.toColumnMap());
  });

  /// "Hide me for now."
  ///
  /// Removes the tutor from every listing and search. Confirmed bookings are
  /// untouched — a promise already made is honoured either way, and a switch
  /// that quietly cancelled them would be the worst control in the product.
  Future<bool> setHidden({
    required int professionalId,
    required bool hidden,
  }) async {
    final rows = await _query(
      'UPDATE professionals SET is_hidden = @hidden, updated_at = now() '
      'WHERE id = @id RETURNING is_hidden',
      {'id': professionalId, 'hidden': hidden},
    );
    if (rows.isEmpty) throw ApiException.notFound();
    return rows.first.boolAt('is_hidden');
  }

  /// The room a tutor's sessions happen in.
  Future<String?> setMeetingUrl({
    required int professionalId,
    required String? url,
  }) async {
    final trimmed = url?.trim();
    if (trimmed != null && trimmed.isNotEmpty && !trimmed.startsWith('https://')) {
      // Same rule as the NFC card's links: a student taps this from a phone,
      // and a plain-http meeting room is a downgrade they did not choose.
      throw ApiException.validation({'meeting_url': _notHttps});
    }
    final rows = await _query(
      'UPDATE professionals SET meeting_url = @url, updated_at = now() '
      'WHERE id = @id RETURNING meeting_url',
      {
        'id': professionalId,
        'url': trimmed == null || trimmed.isEmpty ? null : trimmed,
      },
    );
    if (rows.isEmpty) throw ApiException.notFound();
    return rows.first.strOrNull('meeting_url');
  }

  TutorSession _toSession(Map<String, dynamic> row) {
    // A multi-session plan's money belongs to the plan, not to any one hour of
    // it. Dividing it is the only honest thing to show against a single row.
    final count = row.intAt('session_count');
    return TutorSession(
      id: row.str('id'),
      bookingId: row.str('booking_id'),
      startsAt: row.dateAt('starts_at'),
      endsAt: row.dateAt('ends_at'),
      studentName: LocalizedText(
        en: row.str('full_name_en'),
        ar: row.str('full_name_ar'),
      ),
      subject: row.strOrNull('subject') ?? '',
      goal: row.strOrNull('goal') ?? '',
      netEgp: count > 0 ? row.intAt('net_egp') ~/ count : row.intAt('net_egp'),
      attendedAt: row.dateOrNull('attended_at'),
    );
  }

  /// The Cairo day [at] falls in, as a UTC half-open range.
  static (DateTime, DateTime) cairoDay(DateTime at) {
    final local = CairoClock.local(at);
    final start = CairoClock.toUtc(
      DateTime.utc(local.year, local.month, local.day),
    );
    return (start, start.add(const Duration(days: 1)));
  }

  Future<List<Map<String, dynamic>>> _query(
    String sql,
    Map<String, Object?> parameters,
  ) async {
    final result = await _database.run(
      (session) => session.execute(Sql.named(sql), parameters: parameters),
    );
    return result.map((row) => row.toColumnMap()).toList();
  }

  static const LocalizedText _notHttps = LocalizedText(
    en: 'The link has to start with https://',
    ar: 'يجب أن يبدأ الرابط بـ https://',
  );
}
