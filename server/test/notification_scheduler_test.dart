import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_server/src/modules/notifications/cairo_clock.dart';
import 'package:ejadah_server/src/modules/notifications/notification_scheduler.dart';
import 'package:test/test.dart';

import 'support/test_database.dart';

/// The notification scheduling proof.
///
/// Three promises are made to the user in writing, in both languages, on the
/// settings screen: the categories can be switched off separately, nothing
/// arrives between 22:00 and 08:00 Cairo time, and no more than two arrive in a
/// day. A promise that only the copy keeps is not kept, so each one is proven
/// here against the real database.
///
/// Idempotency is the fourth, unwritten promise: a sweep that runs hourly and
/// again after every restart must not re-announce the same deadline.
void main() {
  late TestDatabase db;
  late NotificationScheduler scheduler;

  late String userId;

  setUpAll(() async {
    db = await TestDatabase.open();
  });

  tearDownAll(() async {
    await db.close();
  });

  setUp(() async {
    await db.reset();
    await db.resetReferenceData();
    scheduler = NotificationScheduler(db.database);
    userId = await _createUser(db, 'sara@ejadah.test');
  });

  group('deadline alerts', () {
    test('a saved programme is announced once per window, never twice', () async {
      final now = _cairoMorning();
      // 30 days out from the sweep's "today".
      final programmeId = await _createProgramme(
        db,
        deadline: CairoClock.local(now).add(const Duration(days: 30)),
      );
      await _save(db, userId, programmeId);
      await _enableAll(db, userId);

      final first = await scheduler.sweep(now: now);
      expect(first, 1, reason: 'the 30-day window is due exactly once');

      // The sweep runs hourly. Every later run over the same window must be a
      // no-op — the dedupe key is enforced by the database, so the scheduler
      // does not have to remember what it did.
      final second = await scheduler.sweep(now: now);
      final third = await scheduler.sweep(
        now: now.add(const Duration(hours: 6)),
      );
      expect(second, 0);
      expect(third, 0);

      final queued = await db.execute(
        'SELECT dedupe_key FROM scheduled_notifications WHERE user_id = @u',
        {'u': userId},
      );
      expect(queued.length, 1);
      expect(queued.first[0], 'deadline:$programmeId:30');
    });

    test('a switched-off category is never queued at all', () async {
      final now = _cairoMorning();
      final programmeId = await _createProgramme(
        db,
        deadline: CairoClock.local(now).add(const Duration(days: 14)),
      );
      await _save(db, userId, programmeId);
      await scheduler.updatePreferences(
        userId,
        const NotificationPreferences(
          deadlineAlerts: false,
          sessionReminders: true,
          studyNudges: true,
        ),
      );

      expect(await scheduler.sweep(now: now), 0);

      // Not merely unsent — absent. The preference is checked when scheduling,
      // so switching the category off leaves no trace in the queue that a
      // later change of delivery logic could accidentally release.
      final queued = await db.execute(
        'SELECT count(*) FROM scheduled_notifications WHERE user_id = @u',
        {'u': userId},
      );
      expect(queued.first[0], 0);
    });

    test('an expired deadline is not announced', () async {
      final now = _cairoMorning();
      final programmeId = await _createProgramme(
        db,
        deadline: CairoClock.local(now).subtract(const Duration(days: 2)),
      );
      await _save(db, userId, programmeId);
      await _enableAll(db, userId);

      expect(await scheduler.sweep(now: now), 0);
    });

    test('a sweep that missed a day still catches the window', () async {
      final now = _cairoMorning();
      // The 7-day moment was yesterday; today the programme is 6 days out.
      final programmeId = await _createProgramme(
        db,
        deadline: CairoClock.local(now).add(const Duration(days: 6)),
      );
      await _save(db, userId, programmeId);
      await _enableAll(db, userId);

      expect(
        await scheduler.sweep(now: now),
        1,
        reason: 'an outage must not silently swallow a reminder window',
      );
    });
  });

  group('session reminders', () {
    setUp(() async {
      await _createProfessional(db);
      await _enableAll(db, userId);
    });

    test('T-24h and T-1h each fire once, in their own window', () async {
      // A session at 15:00 Cairo, three days out.
      final start = CairoClock.toUtc(DateTime.utc(2026, 9, 13, 15));
      await _createBooking(db, userId, start);

      // Four days out: neither window has opened.
      final tooEarly = CairoClock.toUtc(DateTime.utc(2026, 9, 12, 10));
      expect(await scheduler.sweep(now: tooEarly), 0);

      // The T-24h moment.
      final dayBefore = start.subtract(const Duration(hours: 24));
      expect(await scheduler.sweep(now: dayBefore), 1);
      expect(await scheduler.sweep(now: dayBefore), 0);

      // The T-1h moment, a separate reminder with its own key.
      final hourBefore = start.subtract(const Duration(hours: 1));
      expect(await scheduler.sweep(now: hourBefore), 1);
      expect(await scheduler.sweep(now: hourBefore), 0);

      final keys = await db.execute(
        'SELECT dedupe_key FROM scheduled_notifications '
        'WHERE user_id = @u ORDER BY dedupe_key',
        {'u': userId},
      );
      expect(keys.length, 2);
      expect((keys.first[0]! as String), endsWith(':1h'));
      expect((keys.last[0]! as String), endsWith(':24h'));
    });

    test('a booking made after T-24h is never told "tomorrow"', () async {
      // Booked two hours before it starts. The T-24h moment is long gone, and
      // a reminder that says "tomorrow" about a session two hours away is
      // worse than no reminder at all.
      final start = CairoClock.toUtc(DateTime.utc(2026, 9, 13, 15));
      await _createBooking(db, userId, start);

      final twoHoursBefore = start.subtract(const Duration(hours: 2));
      expect(await scheduler.sweep(now: twoHoursBefore), 0);

      // The T-1h reminder is still ahead, and still fires.
      expect(
        await scheduler.sweep(now: start.subtract(const Duration(hours: 1))),
        1,
      );
    });

    test('a cancelled booking is not reminded about', () async {
      final start = CairoClock.toUtc(DateTime.utc(2026, 9, 13, 15));
      final bookingId = await _createBooking(db, userId, start);
      await db.execute(
        "UPDATE bookings SET status = 'cancelled_by_student', "
        'cancelled_at = now() '
        'WHERE id = @id',
        {'id': bookingId},
      );

      expect(
        await scheduler.sweep(now: start.subtract(const Duration(hours: 24))),
        0,
      );
    });

    test('session reminders honour their own switch', () async {
      final start = CairoClock.toUtc(DateTime.utc(2026, 9, 13, 15));
      await _createBooking(db, userId, start);
      await scheduler.updatePreferences(
        userId,
        const NotificationPreferences(
          deadlineAlerts: true,
          sessionReminders: false,
          studyNudges: true,
        ),
      );

      expect(
        await scheduler.sweep(now: start.subtract(const Duration(hours: 24))),
        0,
      );
    });

    test('the reminder states the time in Cairo, in both languages', () async {
      final start = CairoClock.toUtc(DateTime.utc(2026, 9, 13, 15));
      await _createBooking(db, userId, start);

      final due = await scheduler.dueSessionReminders(
        now: start.subtract(const Duration(hours: 1)),
      );
      expect(due.length, 1);
      // 15:00 Cairo — the same rendering the booking screen shows, so the
      // reminder cannot contradict what it links to.
      expect(due.single.body.en, '15:00, Cairo time.');
      expect(due.single.body.ar, '15:00 بتوقيت القاهرة.');
      expect(due.single.title.en, contains('Dr. Mona Adel'));
      expect(due.single.title.ar, contains('د. منى عادل'));
    });
  });

  group('quiet hours', () {
    test('a reminder due at 02:00 Cairo is held to 08:00, not dropped', () async {
      // 02:00 Cairo on a fixed day.
      final quiet = CairoClock.toUtc(DateTime.utc(2026, 9, 10, 2));
      expect(CairoClock.isQuiet(quiet), isTrue);

      await scheduler.queue(
        PendingNotification(
          userId: userId,
          category: NotificationCategory.session,
          dedupeKey: 'test:quiet',
          sendAfter: quiet,
          title: const LocalizedText(en: 'Title', ar: 'عنوان'),
          body: const LocalizedText(en: 'Body', ar: 'نص'),
        ),
      );

      final rows = await db.execute(
        'SELECT send_after FROM scheduled_notifications WHERE user_id = @u',
        {'u': userId},
      );
      final sendAfter = (rows.first[0]! as DateTime).toUtc();

      // Held, not dropped: the row exists and its send time is the morning.
      expect(CairoClock.local(sendAfter).hour, CairoClock.quietEndHour);
      expect(CairoClock.local(sendAfter).day, 10);
    });

    test('a reminder due at 23:00 Cairo is held to the next morning', () async {
      final late = CairoClock.toUtc(DateTime.utc(2026, 9, 10, 23));
      await scheduler.queue(
        PendingNotification(
          userId: userId,
          category: NotificationCategory.deadline,
          dedupeKey: 'test:late',
          sendAfter: late,
          title: const LocalizedText(en: 'Title', ar: 'عنوان'),
          body: const LocalizedText(en: 'Body', ar: 'نص'),
        ),
      );

      final rows = await db.execute(
        'SELECT send_after FROM scheduled_notifications WHERE user_id = @u',
        {'u': userId},
      );
      final sendAfter = (rows.first[0]! as DateTime).toUtc();
      expect(CairoClock.local(sendAfter).day, 11);
      expect(CairoClock.local(sendAfter).hour, CairoClock.quietEndHour);
    });

    test('delivery does nothing during quiet hours', () async {
      final morning = CairoClock.toUtc(DateTime.utc(2026, 9, 10, 9));
      await _queueDirect(db, userId, 'ready', morning);

      final midnight = CairoClock.toUtc(DateTime.utc(2026, 9, 11, 0, 30));
      expect(
        await scheduler.deliverDue(now: midnight),
        0,
        reason: 'the Cairo day rolling over must not release held rows at 00:00',
      );
    });
  });

  group('the two-a-day cap', () {
    test('a third due notification waits for tomorrow', () async {
      final day = DateTime.utc(2026, 9, 10, 9);
      final now = CairoClock.toUtc(day);
      for (var i = 0; i < 3; i++) {
        await _queueDirect(
          db,
          userId,
          'cap:$i',
          now.subtract(Duration(minutes: 30 - i)),
        );
      }

      expect(await scheduler.deliverDue(now: now), CairoClock.dailyCap);
      expect(await scheduler.unreadCount(userId), CairoClock.dailyCap);

      // A second sweep the same day delivers nothing more: what has already
      // arrived today counts against the cap.
      expect(await scheduler.deliverDue(now: now.add(const Duration(hours: 2))), 0);

      // The third is held, not dropped — it still has its row.
      final held = await db.execute(
        'SELECT count(*) FROM scheduled_notifications '
        'WHERE user_id = @u AND sent_at IS NULL',
        {'u': userId},
      );
      expect(held.first[0], 1);

      final tomorrow = CairoClock.toUtc(DateTime.utc(2026, 9, 11, 9));
      expect(await scheduler.deliverDue(now: tomorrow), 1);
    });

    test('the cap is per user, not global', () async {
      final other = await _createUser(db, 'omar@ejadah.test');
      final now = CairoClock.toUtc(DateTime.utc(2026, 9, 10, 9));
      for (var i = 0; i < 2; i++) {
        await _queueDirect(db, userId, 'a:$i', now);
        await _queueDirect(db, other, 'b:$i', now);
      }

      expect(await scheduler.deliverDue(now: now), 4);
      expect(await scheduler.unreadCount(userId), 2);
      expect(await scheduler.unreadCount(other), 2);
    });
  });

  group('the notification centre', () {
    test('delivery writes both languages and the deep link', () async {
      final now = CairoClock.toUtc(DateTime.utc(2026, 9, 10, 9));
      await scheduler.queue(
        PendingNotification(
          userId: userId,
          category: NotificationCategory.deadline,
          dedupeKey: 'centre:1',
          sendAfter: now.subtract(const Duration(minutes: 1)),
          title: const LocalizedText(
            en: "King's College London closes in 30 days",
            ar: 'كينجز كوليدج لندن يُغلق بعد 30 يومًا',
          ),
          body: const LocalizedText(
            en: 'Your saved programme in the United Kingdom.',
            ar: 'برنامجك المحفوظ في المملكة المتحدة.',
          ),
          deepLink: '/programme/42',
        ),
      );

      expect(await scheduler.deliverDue(now: now), 1);

      final centre = await scheduler.centre(userId);
      expect(centre.length, 1);
      final item = centre.single;
      // The apostrophe survives the hand-rolled JSON payload encoding.
      expect(item.title.en, "King's College London closes in 30 days");
      expect(item.title.ar, contains('كينجز'));
      expect(item.body.ar, contains('المملكة المتحدة'));
      expect(item.deepLink, '/programme/42');
      expect(item.isRead, isFalse);
      expect(item.category, NotificationCategory.deadline);

      await scheduler.markAllRead(userId);
      expect(await scheduler.unreadCount(userId), 0);
      expect((await scheduler.centre(userId)).single.isRead, isTrue);
    });

    test('a row is delivered exactly once even across repeated sweeps', () async {
      final now = CairoClock.toUtc(DateTime.utc(2026, 9, 10, 9));
      await _queueDirect(db, userId, 'once', now);

      expect(await scheduler.deliverDue(now: now), 1);
      expect(await scheduler.deliverDue(now: now), 0);
      expect((await scheduler.centre(userId)).length, 1);
    });
  });

  group('preferences', () {
    test('default to all on, and round-trip', () async {
      expect(
        await scheduler.preferences(userId),
        const NotificationPreferences.allEnabled(),
      );

      const off = NotificationPreferences(
        deadlineAlerts: true,
        sessionReminders: false,
        studyNudges: false,
      );
      await scheduler.updatePreferences(userId, off);
      expect(await scheduler.preferences(userId), off);

      // Updating twice must not fail on the primary key.
      await scheduler.updatePreferences(
        userId,
        const NotificationPreferences.allEnabled(),
      );
      expect(
        await scheduler.preferences(userId),
        const NotificationPreferences.allEnabled(),
      );
    });
  });

  group('CairoClock', () {
    test('renders the 24-hour clock in Western digits', () {
      // 07:05 Cairo.
      final at = CairoClock.toUtc(DateTime.utc(2026, 9, 10, 7, 5));
      expect(CairoClock.formatTime(at), '07:05');
      // The rule from REGISTER.md: no Arabic-Indic digits anywhere.
      expect(RegExp(r'^[0-9:]+$').hasMatch(CairoClock.formatTime(at)), isTrue);
    });

    test('local and toUtc are inverses', () {
      final utc = DateTime.utc(2026, 9, 10, 14, 30);
      expect(CairoClock.toUtc(CairoClock.local(utc)), utc);
    });

    test('08:00 and 21:59 are not quiet; 22:00 and 07:59 are', () {
      bool quietAt(int hour, [int minute = 0]) => CairoClock.isQuiet(
        CairoClock.toUtc(DateTime.utc(2026, 9, 10, hour, minute)),
      );
      expect(quietAt(8), isFalse);
      expect(quietAt(21, 59), isFalse);
      expect(quietAt(22), isTrue);
      expect(quietAt(7, 59), isTrue);
    });
  });
}

DateTime _cairoMorning() => CairoClock.toUtc(DateTime.utc(2026, 9, 10, 9));

Future<String> _createUser(TestDatabase db, String email) async {
  final result = await db.execute(
    '''
    INSERT INTO users (email, password_hash, full_name_en, full_name_ar)
    VALUES (@email, 'x', 'Sara Hassan', 'سارة حسن')
    RETURNING id
    ''',
    {'email': email},
  );
  return result.first[0]! as String;
}

Future<void> _enableAll(TestDatabase db, String userId) => db.execute(
  '''
  INSERT INTO notification_preferences (user_id) VALUES (@u)
  ON CONFLICT (user_id) DO NOTHING
  ''',
  {'u': userId},
);

Future<void> _createProfessional(TestDatabase db) => db.execute(
  '''
  INSERT INTO professionals (
    id, slug, kind, display_name_en, display_name_ar, hourly_rate_egp,
    is_approved
  ) VALUES (
    1, 'dr-mona-adel', 'tutoring', 'Dr. Mona Adel', 'د. منى عادل', 800, true
  )
  ''',
);

Future<String> _createBooking(
  TestDatabase db,
  String userId,
  DateTime startsAt,
) async {
  final booking = await db.execute(
    '''
    INSERT INTO bookings (user_id, professional_id, kind, status, total_egp)
    VALUES (@u, 1, 'tutoring', 'confirmed', 800)
    RETURNING id
    ''',
    {'u': userId},
  );
  final bookingId = booking.first[0]! as String;
  await db.execute(
    '''
    INSERT INTO booking_sessions (booking_id, position, starts_at, ends_at)
    VALUES (@b, 1, @start, @end)
    ''',
    {
      'b': bookingId,
      'start': startsAt,
      'end': startsAt.add(const Duration(hours: 1)),
    },
  );
  return bookingId;
}

/// Programme ids come from the canonical dataset rather than a sequence, so
/// fixtures supply their own.
var _nextProgrammeId = 9000;

Future<int> _createProgramme(
  TestDatabase db, {
  required DateTime deadline,
}) async {
  final id = _nextProgrammeId++;
  await db.execute(
    '''
    INSERT INTO programmes (
      id, region, country, university, programme_name, deadline
    ) VALUES (
      @id, 'Europe', 'United Kingdom', 'King''s College London',
      'MSc Endodontics', @deadline::date
    )
    ''',
    {
      'id': id,
      'deadline': DateTime.utc(deadline.year, deadline.month, deadline.day),
    },
  );
  return id;
}

Future<void> _save(TestDatabase db, String userId, int programmeId) =>
    db.execute(
      'INSERT INTO saved_programmes (user_id, programme_id) '
      'VALUES (@u, @p)',
      {'u': userId, 'p': programmeId},
    );

/// Puts a row straight on the queue, bypassing the quiet-hours shift, so the
/// delivery tests can control the send time exactly.
Future<void> _queueDirect(
  TestDatabase db,
  String userId,
  String key,
  DateTime sendAfter,
) => db.execute(
  '''
  INSERT INTO scheduled_notifications (
    user_id, category, dedupe_key, send_after, payload
  ) VALUES (
    @u, 'deadline', @k, @s,
    '{"title_en":"Title","title_ar":"عنوان","body_en":"Body","body_ar":"نص"}'::jsonb
  )
  ''',
  {'u': userId, 'k': key, 's': sendAfter},
);
