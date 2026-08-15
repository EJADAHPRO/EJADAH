import 'dart:io';

import 'package:ejadah_server/src/config/config.dart';
import 'package:ejadah_server/src/db/database.dart';
import 'package:ejadah_server/src/db/migrator.dart';
import 'package:ejadah_server/src/observability/logger.dart';
import 'package:postgres/postgres.dart';

/// A real PostgreSQL database for tests.
///
/// The suites that matter here — concurrency, constraints, transactional
/// rollback — cannot be proven against a fake. An in-memory double would happily
/// let two callers book the same slot, which is exactly the bug the schema
/// exists to prevent, so these tests run against the real engine.
class TestDatabase {
  TestDatabase._(this.database, this.config);

  final Database database;
  final AppConfig config;

  static const String _defaultUrl =
      'postgres://ejadah:ejadah_dev@localhost:5432/ejadah_test?sslmode=disable';

  /// Connects and brings the schema up to date.
  static Future<TestDatabase> open() async {
    final url = Platform.environment['TEST_DATABASE_URL'] ?? _defaultUrl;
    final config = AppConfig.fromEnvironment({
      'EJADAH_ENV': 'test',
      'DATABASE_URL': url,
      'JWT_SECRET': 'test-secret-that-is-long-enough-for-tests',
      'BOOKING_HOLD_MINUTES': '15',
      'PLATFORM_FEE_PERCENT': '30',
    });

    final database = await Database.connect(url, maxConnections: 8);
    await Migrator(
      database,
      directory: Directory('migrations'),
      logger: AppLogger('test', sink: _NullSink()),
    ).migrate();

    return TestDatabase._(database, config);
  }

  /// Empties every table between tests, leaving the schema in place.
  ///
  /// Truncating rather than re-migrating keeps the suite fast while still
  /// giving each test a clean slate.
  Future<void> reset() async {
    await database.run(
      (session) => session.execute('''
        TRUNCATE TABLE
          slot_reservations, booking_sessions, bookings, payments,
          payment_events, earnings, payout_requests, reviews,
          professional_packages, professional_qualifications,
          availability_rules, availability_exceptions, professionals,
          tutor_applications, playbook_progress,
          roadmap_stages, roadmaps, roadmap_drafts,
          saved_programmes, saved_filters, recently_viewed,
          quiz_answers, quiz_attempts, quiz_options, quiz_questions, quizzes,
          flashcard_reviews, flashcard_states, flashcards, flashcard_decks,
          lesson_progress, enrollments, entitlements, course_downloads,
          handouts, lessons, courses,
          certificates, cpd_entries, cv_sections, stored_files,
          public_profile_views, profiles,
          notifications, scheduled_notifications, analytics_events, job_runs,
          notification_preferences, refresh_tokens, email_verifications,
          password_resets, auth_attempts, audit_log, users
        RESTART IDENTITY CASCADE
      '''),
    );
  }

  /// Clears the imported reference data too. Only for tests that import it.
  Future<void> resetReferenceData() async {
    await database.run(
      (session) => session.execute('''
        TRUNCATE TABLE
          country_steps, country_exams, country_costs, country_documents,
          country_tips, programmes, countries
        RESTART IDENTITY CASCADE
      '''),
    );
  }

  Future<void> close() => database.close();

  /// Convenience for arranging fixtures.
  Future<Result> execute(
    String sql, [
    Map<String, Object?> parameters = const {},
  ]) => database.run(
    (session) => session.execute(Sql.named(sql), parameters: parameters),
  );
}

class _NullSink implements IOSink {
  @override
  void writeln([Object? object = '']) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
