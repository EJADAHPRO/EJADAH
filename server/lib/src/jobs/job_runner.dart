import 'dart:async';

import 'package:postgres/postgres.dart';

import '../config/config.dart';
import '../db/database.dart';
import '../modules/career/career_repository.dart';
import '../modules/notifications/notification_scheduler.dart';
import '../observability/logger.dart';

/// A unit of recurring server-side work.
abstract interface class Job {
  String get name;

  Duration get interval;

  /// Returns a short human-readable summary of what it did, for the job log.
  Future<String> run();
}

/// In-process scheduler for background work.
///
/// Deliberately not a broker or a worker fleet: this is a modular monolith, and
/// hold expiry plus a handful of reminder sweeps do not justify that
/// infrastructure. What matters is that none of it depends on the app being
/// open (brief §65).
class JobRunner {
  JobRunner({
    required Database database,
    required AppConfig config,
    required AppLogger logger,
    List<Job>? jobs,
  }) : _database = database,
       _logger = logger.child('jobs'),
       _jobs =
           jobs ??
           [
             ExpireHoldsJob(database),
             ScheduleRemindersJob(
               NotificationScheduler(
                 database,
                 career: CareerRepository(database),
               ),
             ),
             DeliverNotificationsJob(NotificationScheduler(database)),
             MatureEarningsJob(database),
           ];

  final Database _database;
  final AppLogger _logger;
  final List<Job> _jobs;
  final List<Timer> _timers = [];

  void start() {
    for (final job in _jobs) {
      // Run once at boot so a restart does not leave expired holds occupying
      // slots until the next tick.
      unawaited(_runOnce(job));
      _timers.add(Timer.periodic(job.interval, (_) => _runOnce(job)));
    }
    _logger.info('background jobs started', {'count': _jobs.length});
  }

  void stop() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
  }

  Future<void> _runOnce(Job job) async {
    final startedAt = DateTime.now().toUtc();
    try {
      final detail = await job.run();
      await _record(job.name, startedAt, true, detail);
    } catch (error, stackTrace) {
      _logger.error('job failed', {'job': job.name}, error, stackTrace);
      await _record(job.name, startedAt, false, error.toString());
    }
  }

  Future<void> _record(
    String name,
    DateTime startedAt,
    bool succeeded,
    String detail,
  ) async {
    try {
      await _database.run(
        (session) => session.execute(
          Sql.named(
            'INSERT INTO job_runs (job_name, started_at, finished_at, '
            'succeeded, detail) '
            'VALUES (@name, @started_at, now(), @succeeded, @detail)',
          ),
          parameters: {
            'name': name,
            'started_at': startedAt,
            'succeeded': succeeded,
            'detail': detail,
          },
        ),
      );
    } catch (_) {
      // Job bookkeeping must never be the reason the scheduler dies.
    }
  }
}

/// Releases expired booking holds so their slots become bookable again.
///
/// The booking service also releases expired holds lazily inside its own
/// transaction, so a slot is never wrongly occupied between ticks; this job
/// exists so the timeline stays clean without anyone having to ask.
class ExpireHoldsJob implements Job {
  const ExpireHoldsJob(this._database);

  final Database _database;

  @override
  String get name => 'expire_holds';

  @override
  Duration get interval => const Duration(minutes: 1);

  @override
  Future<String> run() async {
    final result = await _database.run(
      (session) => session.execute('''
        UPDATE slot_reservations
        SET status = 'released', released_at = now()
        WHERE kind = 'hold' AND status = 'active' AND expires_at <= now()
        '''),
    );
    return 'released ${result.affectedRows} expired holds';
  }
}

/// Queues deadline alerts (30/14/7 days) and session reminders (T-24h, T-1h).
///
/// Scheduling is server-side by requirement: none of this may depend on the
/// Flutter app being open. Running hourly rather than daily is safe because
/// every queued row carries a database-enforced dedupe key, so a second sweep
/// over the same window queues nothing.
class ScheduleRemindersJob implements Job {
  const ScheduleRemindersJob(this._scheduler);

  final NotificationScheduler _scheduler;

  @override
  String get name => 'schedule_reminders';

  @override
  Duration get interval => const Duration(hours: 1);

  @override
  Future<String> run() async {
    final queued = await _scheduler.sweep(now: DateTime.now().toUtc());
    return 'queued $queued reminders';
  }
}

/// Moves due queue rows into the notification centre.
///
/// The centre is the system of record rather than the OS tray, so a user who
/// declined push permission still finds every notification in the app.
class DeliverNotificationsJob implements Job {
  const DeliverNotificationsJob(this._scheduler);

  final NotificationScheduler _scheduler;

  @override
  String get name => 'deliver_notifications';

  @override
  Duration get interval => const Duration(minutes: 5);

  @override
  Future<String> run() async {
    final delivered = await _scheduler.deliverDue(now: DateTime.now().toUtc());
    return 'delivered $delivered notifications';
  }
}

/// Releases a tutor's earnings for work they never got round to marking.
///
/// Marking a session is what normally releases its money — that is what the
/// dashboard says and what `DashboardService.mark` does. This is the backstop
/// for the tutor who never marks: a week after the last session, the booking
/// completes itself and the money becomes available.
///
/// Without it, "marking releases your earnings" would quietly mean "and if you
/// forget, you are never paid", which is not a sentence this product could
/// stand behind. With it, marking is the fast path rather than the only one.
///
/// A cancelled booking is excluded, and its earning was reversed at
/// cancellation time.
///
/// Hourly is enough: nothing here is time-critical to the minute.
class MatureEarningsJob implements Job {
  const MatureEarningsJob(this._database);

  final Database _database;

  @override
  String get name => 'mature_earnings';

  @override
  Duration get interval => const Duration(hours: 1);

  @override
  Future<String> run() async {
    // Complete the bookings whose grace window has passed, then release their
    // money. Two statements rather than one so the booking's own status is
    // right as well — a `confirmed` booking whose sessions ended a month ago
    // is a row nobody could explain.
    final completed = await _database.run(
      (session) => session.execute("""
        UPDATE bookings b
        SET status = 'completed', updated_at = now()
        WHERE b.status = 'confirmed'
          AND NOT EXISTS (
            SELECT 1 FROM booking_sessions s
            WHERE s.booking_id = b.id
              AND s.ends_at > now() - INTERVAL '$_graceDays days'
          )
          -- A booking with no sessions at all is not a finished one.
          AND EXISTS (
            SELECT 1 FROM booking_sessions s WHERE s.booking_id = b.id
          )
        """),
    );

    final released = await _database.run(
      (session) => session.execute("""
        UPDATE earnings e
        SET status = 'available'
        WHERE e.status = 'pending'
          AND EXISTS (
            SELECT 1 FROM bookings b
            WHERE b.id = e.booking_id AND b.status = 'completed'
          )
        """),
    );

    return 'completed ${completed.affectedRows} bookings, '
        'released ${released.affectedRows} earnings';
  }

  /// Mirrors `DashboardService.autoCompleteAfterDays`.
  ///
  /// Interpolated rather than bound because PostgreSQL will not take a
  /// parameter inside an interval literal; the value is a compile-time
  /// constant in this file, never anything a request supplies.
  static const int _graceDays = 7;
}
