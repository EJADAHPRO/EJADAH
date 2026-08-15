import 'package:ejadah_models/ejadah_models.dart';
import 'package:postgres/postgres.dart';

import '../../db/database.dart';
import 'cairo_clock.dart';

/// A notification the scheduler wants to queue.
class PendingNotification {
  const PendingNotification({
    required this.userId,
    required this.category,
    required this.dedupeKey,
    required this.sendAfter,
    required this.title,
    required this.body,
    this.deepLink,
  });

  final String userId;
  final NotificationCategory category;

  /// The natural key of the thing being announced.
  ///
  /// Re-running the scheduler must not queue the same reminder twice, so this
  /// is unique per user and enforced by the database rather than by the sweep
  /// remembering what it did.
  final String dedupeKey;
  final DateTime sendAfter;
  final LocalizedText title;
  final LocalizedText body;
  final String? deepLink;
}

/// Queues and delivers the three notification categories.
///
/// There is deliberately no marketing category, and each of the three can be
/// switched off separately. A user who has turned a category off is never
/// queued for it — the preference is checked when scheduling, not merely when
/// sending, so a disabled category leaves no trace in the queue at all.
class NotificationScheduler {
  const NotificationScheduler(this._database);

  final Database _database;

  /// The deadline windows the product promises: 30, 14 and 7 days out.
  static const List<int> deadlineWindows = [30, 14, 7];

  /// Session reminders.
  static const Duration dayBefore = Duration(hours: 24);
  static const Duration hourBefore = Duration(hours: 1);

  /// Queues a notification, ignoring a duplicate.
  ///
  /// The `ON CONFLICT DO NOTHING` is the idempotency: the unique index on
  /// `(user_id, dedupe_key)` means a second sweep over the same deadline is a
  /// no-op rather than a second push.
  Future<bool> queue(PendingNotification notification, {Session? session}) async {
    // "Never between 22:00 and 08:00 Cairo time" is a promise the settings
    // screen makes in both languages. It is kept here, at the point of
    // queueing, so no caller can route around it.
    final sendAfter = CairoClock.afterQuietHours(notification.sendAfter.toUtc());

    final rows = await _query(
      '''
      INSERT INTO scheduled_notifications (
        user_id, category, dedupe_key, send_after, payload
      ) VALUES (
        @user_id, @category, @dedupe_key, @send_after, @payload::jsonb
      )
      ON CONFLICT (user_id, dedupe_key) DO NOTHING
      RETURNING id
      ''',
      {
        'user_id': notification.userId,
        'category': notification.category.wire,
        'dedupe_key': notification.dedupeKey,
        'send_after': sendAfter,
        'payload': _encodePayload(notification),
      },
      session,
    );
    return rows.isNotEmpty;
  }

  /// Queues everything due, and returns how many rows were new.
  ///
  /// Re-running this is a no-op by construction: every notification carries a
  /// dedupe key the database enforces, so the sweep does not need to remember
  /// what it did last time — which is what makes it safe to run on every tick
  /// and after every restart.
  Future<int> sweep({required DateTime now}) async {
    final due = [
      ...await dueDeadlineAlerts(now: now),
      ...await dueSessionReminders(now: now),
    ];

    var queued = 0;
    for (final notification in due) {
      if (await queue(notification)) queued++;
    }
    return queued;
  }

  /// Finds saved programmes whose deadline falls in one of the windows, for
  /// users who have deadline alerts on.
  ///
  /// The preference join is what keeps a switched-off category out of the queue
  /// entirely.
  Future<List<PendingNotification>> dueDeadlineAlerts({
    required DateTime now,
  }) async {
    final result = <PendingNotification>[];

    for (final daysOut in deadlineWindows) {
      final rows = await _query(
        '''
        SELECT s.user_id, p.id AS programme_id, p.university, p.country,
               p.deadline
        FROM saved_programmes s
        JOIN programmes p ON p.id = s.programme_id
        JOIN notification_preferences np ON np.user_id = s.user_id
        JOIN users u ON u.id = s.user_id
        WHERE np.deadline_alerts = true
          AND u.deleted_at IS NULL
          -- A one-day-wide match rather than an exact one, so a sweep that
          -- misses a day (deploy, outage) still catches the window. The dedupe
          -- key makes the overlap a no-op on the second day.
          AND p.deadline <= @today::date + @days_out::int
          AND p.deadline >= @today::date + (@days_out::int - 1)
        ''',
        {'today': now, 'days_out': daysOut},
        null,
      );

      for (final row in rows) {
        final university = row.str('university');
        result.add(
          PendingNotification(
            userId: row.str('user_id'),
            category: NotificationCategory.deadline,
            // One notification per programme per window.
            dedupeKey: 'deadline:${row.intAt('programme_id')}:$daysOut',
            sendAfter: now,
            // "King's College London closes in 14 days" — the institution is
            // named, and the number is Western in both languages.
            title: LocalizedText(
              en: '$university closes in $daysOut days',
              ar: '$university يُغلق بعد $daysOut يومًا',
            ),
            body: LocalizedText(
              en: 'Your saved programme in ${row.str('country')}.',
              ar: 'برنامجك المحفوظ في ${row.str('country')}.',
            ),
            deepLink: '/programme/${row.intAt('programme_id')}',
          ),
        );
      }
    }

    return result;
  }

  /// Session reminders at T-24h and T-1h for confirmed bookings.
  Future<List<PendingNotification>> dueSessionReminders({
    required DateTime now,
  }) async {
    final result = <PendingNotification>[];

    for (final (label, lead, grace) in [
      ('24h', dayBefore, const Duration(hours: 3)),
      ('1h', hourBefore, const Duration(minutes: 15)),
    ]) {
      // The window is on the *send* time, not the session time. A booking made
      // two hours before it starts must not be told "your session tomorrow" —
      // its T-24h moment has already gone, and a late reminder is worse than
      // none. The grace is the catch-up allowance for a sweep that was down,
      // sized so the reminder is still true when it lands.
      final sendTimeFloor = now.subtract(grace);

      final rows = await _query(
        '''
        SELECT b.user_id, bs.id AS session_id, bs.starts_at,
               p.display_name_en, p.display_name_ar, b.id AS booking_id
        FROM booking_sessions bs
        JOIN bookings b ON b.id = bs.booking_id
        JOIN professionals p ON p.id = b.professional_id
        JOIN notification_preferences np ON np.user_id = b.user_id
        JOIN users u ON u.id = b.user_id
        WHERE np.session_reminders = true
          AND u.deleted_at IS NULL
          AND b.status = 'confirmed'
          AND bs.attended_at IS NULL
          AND bs.starts_at > @now
          AND bs.starts_at - (@lead_seconds::int * INTERVAL '1 second') <= @now
          AND bs.starts_at - (@lead_seconds::int * INTERVAL '1 second') > @floor
        ''',
        {
          'now': now,
          'floor': sendTimeFloor,
          'lead_seconds': lead.inSeconds,
        },
        null,
      );

      for (final row in rows) {
        final startsAt = row.dateAt('starts_at');
        // 24-hour clock, Cairo, with the zone named — the same rendering the
        // booking screen uses, so the reminder cannot contradict what it links
        // to.
        final time = CairoClock.formatTime(startsAt);

        result.add(
          PendingNotification(
            userId: row.str('user_id'),
            category: NotificationCategory.session,
            dedupeKey: 'session:${row.str('session_id')}:$label',
            sendAfter: startsAt.subtract(lead),
            title: LocalizedText(
              en: 'Your session with ${row.str('display_name_en')}',
              ar: 'جلستك مع ${row.str('display_name_ar')}',
            ),
            body: LocalizedText(
              en: '$time, ${CairoClock.labelEn}.',
              ar: '$time ${CairoClock.labelAr}.',
            ),
            deepLink: '/booking/${row.str('booking_id')}',
          ),
        );
      }
    }

    return result;
  }

  /// Moves due queue rows into the notification centre.
  ///
  /// Delivery to the OS is a supporting concern handled by a push provider; the
  /// centre is the system of record, so a user who never granted permission
  /// still finds their notifications in the app.
  Future<int> deliverDue({required DateTime now}) async {
    final at = now.toUtc();

    // Quiet hours bind delivery as well as queueing. A row held back by the
    // daily cap has a send time in the past, so without this check it would be
    // released the instant the Cairo day rolls over — at midnight.
    if (CairoClock.isQuiet(at)) return 0;

    final rows = await _query(
      '''
      WITH candidate AS (
        SELECT id, user_id, category, payload, send_after
        FROM scheduled_notifications
        WHERE sent_at IS NULL AND send_after <= @now
        ORDER BY send_after
        LIMIT 500
        FOR UPDATE SKIP LOCKED
      ), already AS (
        -- What this user has already received today counts against the cap,
        -- so two sweeps in one day cannot deliver two each.
        SELECT n.user_id, count(*) AS sent_today
        FROM notifications n
        WHERE n.user_id IN (SELECT user_id FROM candidate)
          AND n.created_at >= @day_start
        GROUP BY n.user_id
      ), ranked AS (
        SELECT c.*,
               row_number() OVER (
                 PARTITION BY c.user_id ORDER BY c.send_after, c.id
               ) + coalesce(a.sent_today, 0) AS position
        FROM candidate c
        LEFT JOIN already a ON a.user_id = c.user_id
      ), due AS (
        -- "Two a day maximum" (pNotifyWhy), in both languages. Anything over
        -- the cap keeps its row and its send time and goes out tomorrow — it
        -- is held, not dropped, so no reminder is silently lost.
        SELECT * FROM ranked WHERE position <= @cap
      ), inserted AS (
        INSERT INTO notifications (
          user_id, category, title_en, title_ar, body_en, body_ar, deep_link,
          created_at
        )
        SELECT
          due.user_id,
          due.category,
          due.payload ->> 'title_en',
          due.payload ->> 'title_ar',
          coalesce(due.payload ->> 'body_en', ''),
          coalesce(due.payload ->> 'body_ar', ''),
          due.payload ->> 'deep_link',
          -- Stamped with the sweep's own clock rather than now(), so the daily
          -- cap counts against the same instant the sweep is reasoning about.
          @now
        FROM due
        RETURNING id
      )
      UPDATE scheduled_notifications
      SET sent_at = now()
      WHERE id IN (SELECT id FROM due)
      RETURNING id
      ''',
      {
        'now': at,
        'day_start': CairoClock.toUtc(
          DateTime.utc(
            CairoClock.local(at).year,
            CairoClock.local(at).month,
            CairoClock.local(at).day,
          ),
        ),
        'cap': CairoClock.dailyCap,
      },
      null,
    );
    return rows.length;
  }

  /// The notification centre, newest first.
  Future<List<AppNotification>> centre(String userId) async {
    final rows = await _query(
      'SELECT * FROM notifications WHERE user_id = @user_id '
      'ORDER BY created_at DESC LIMIT 100',
      {'user_id': userId},
      null,
    );

    return rows
        .map(
          (row) => AppNotification(
            id: row.str('id'),
            category: NotificationCategory.fromWire(row.str('category')),
            title: LocalizedText(
              en: row.str('title_en'),
              ar: row.str('title_ar'),
            ),
            body: LocalizedText(en: row.str('body_en'), ar: row.str('body_ar')),
            createdAt: row.dateAt('created_at'),
            isRead: row.dateOrNull('read_at') != null,
            deepLink: row.strOrNull('deep_link'),
          ),
        )
        .toList();
  }

  Future<int> unreadCount(String userId) async {
    final rows = await _query(
      'SELECT count(*) AS unread FROM notifications '
      'WHERE user_id = @user_id AND read_at IS NULL',
      {'user_id': userId},
      null,
    );
    return rows.first.intAt('unread');
  }

  Future<void> markAllRead(String userId) => _execute(
    'UPDATE notifications SET read_at = now() '
    'WHERE user_id = @user_id AND read_at IS NULL',
    {'user_id': userId},
    null,
  );

  Future<NotificationPreferences> preferences(String userId) async {
    final rows = await _query(
      'SELECT * FROM notification_preferences WHERE user_id = @user_id',
      {'user_id': userId},
      null,
    );
    if (rows.isEmpty) return const NotificationPreferences.allEnabled();

    final row = rows.first;
    return NotificationPreferences(
      deadlineAlerts: row.boolAt('deadline_alerts'),
      sessionReminders: row.boolAt('session_reminders'),
      studyNudges: row.boolAt('study_nudges'),
    );
  }

  Future<NotificationPreferences> updatePreferences(
    String userId,
    NotificationPreferences preferences,
  ) async {
    await _execute(
      '''
      INSERT INTO notification_preferences (
        user_id, deadline_alerts, session_reminders, study_nudges
      ) VALUES (@user_id, @deadline, @session, @study)
      ON CONFLICT (user_id) DO UPDATE SET
        deadline_alerts = EXCLUDED.deadline_alerts,
        session_reminders = EXCLUDED.session_reminders,
        study_nudges = EXCLUDED.study_nudges,
        updated_at = now()
      ''',
      {
        'user_id': userId,
        'deadline': preferences.deadlineAlerts,
        'session': preferences.sessionReminders,
        'study': preferences.studyNudges,
      },
      null,
    );
    return preferences;
  }

  static String _encodePayload(PendingNotification notification) =>
      '{"title_en":${_json(notification.title.en)},'
      '"title_ar":${_json(notification.title.ar)},'
      '"body_en":${_json(notification.body.en)},'
      '"body_ar":${_json(notification.body.ar)},'
      '"deep_link":${notification.deepLink == null ? 'null' : _json(notification.deepLink!)}}';

  static String _json(String value) =>
      '"${value.replaceAll(r'\', r'\\').replaceAll('"', r'\"')}"';

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
