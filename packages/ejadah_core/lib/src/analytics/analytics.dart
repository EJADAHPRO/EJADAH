import 'dart:developer' as developer;

import 'package:ejadah_models/ejadah_models.dart';

/// The canonical analytics event names.
///
/// Taken from `handoff/analytics-events.md`. Names are constants rather than
/// inline strings because the taxonomy is a contract with the dashboards: a
/// typo produces a silently empty funnel, not an error.
abstract final class AnalyticsEvents {
  // Activation funnel — the three-minute metric.
  static const String appFirstOpen = 'app_first_open';
  static const String languageSelected = 'language_selected';
  static const String welcomeSlideViewed = 'welcome_slide_viewed';
  static const String welcomeSkipped = 'welcome_skipped';
  static const String roadmapStarted = 'roadmap_started';
  static const String roadmapStepCompleted = 'roadmap_step_completed';
  static const String roadmapAbandoned = 'roadmap_abandoned';

  /// The headline metric. Requires `ms_since_first_open`.
  static const String roadmapGenerated = 'roadmap_generated';
  static const String guestGateShown = 'guest_gate_shown';

  /// Also requires `ms_since_first_open`.
  static const String accountCreated = 'account_created';
  static const String roadmapSaved = 'roadmap_saved';

  // Career.
  static const String programmeViewed = 'programme_viewed';
  static const String programmeSaved = 'programme_saved';

  // Retention.
  static const String deadlineAlertEnabled = 'deadline_alert_enabled';
  static const String deadlineNotificationSent = 'deadline_notification_sent';
  static const String deadlineNotificationOpened =
      'deadline_notification_opened';
  static const String roadmapNudgeOpened = 'roadmap_nudge_opened';
  static const String checklistItemCompleted = 'checklist_item_completed';
  static const String courseViewed = 'course_viewed';
  static const String lessonCompleted = 'lesson_completed';
  static const String flashcardSessionCompleted = 'flashcard_session_completed';
  static const String courseCompleted = 'course_completed';

  // Marketplace.
  static const String tutorViewed = 'tutor_viewed';
  static const String bookingStepCompleted = 'booking_step_completed';
  static const String bookingAbandoned = 'booking_abandoned';
  static const String paymentRedirectOpened = 'payment_redirect_opened';
  static const String paymentReturned = 'payment_returned';
  static const String tutorApplicationStep = 'tutor_application_step';

  // Distribution.
  static const String shareOpened = 'share_opened';
  static const String shareCompleted = 'share_completed';
  static const String referralLinkCreated = 'referral_link_created';
  static const String referralSignupAttributed = 'referral_signup_attributed';
  static const String nfcCardScanned = 'nfc_card_scanned';

  /// Events that are meaningless without `ms_since_first_open`: the product's
  /// headline claim is "a dentist reaches a personalised roadmap in three
  /// minutes", and these two are how it is measured.
  static const Set<String> requireMsSinceFirstOpen = {
    roadmapGenerated,
    accountCreated,
  };
}

/// Where analytics go.
///
/// An interface rather than a vendor SDK so the UI never couples to one
/// provider, and so tests can assert on events without a network.
abstract interface class AnalyticsService {
  Future<void> track(String event, [Map<String, Object?> properties]);

  Future<void> setUser({required String? userId, required String? persona});
}

/// Adds the properties every event must carry, and enforces the privacy rules.
///
/// Wrapping rather than trusting each call site means `lang`, `persona`,
/// `app_version` and `ms_since_first_open` cannot be forgotten, and the
/// forbidden keys cannot be sent by accident.
class AnalyticsDispatcher implements AnalyticsService {
  AnalyticsDispatcher({
    required AnalyticsService delegate,
    required String appVersion,
    required AppLanguage Function() language,
    DateTime? firstOpenAt,
  }) : _delegate = delegate,
       _appVersion = appVersion,
       _language = language,
       _firstOpenAt = firstOpenAt ?? DateTime.now().toUtc();

  final AnalyticsService _delegate;
  final String _appVersion;
  final AppLanguage Function() _language;
  final DateTime _firstOpenAt;

  String? _persona;

  /// Never sent, at any level.
  ///
  /// Private notes, uploaded evidence, authentication secrets, payment details
  /// and free-text clinical content stay out of analytics entirely — including
  /// the booking goal, which is exactly the field most likely to contain
  /// patient detail.
  static const Set<String> forbiddenKeys = {
    'goal',
    'notes',
    'note',
    'subject_detail',
    'password',
    'token',
    'access_token',
    'refresh_token',
    'email',
    'phone',
    'card',
    'card_number',
    'document',
    'document_url',
    'patient',
    'patient_name',
    'cv',
    'free_text',
  };

  @override
  Future<void> track(
    String event, [
    Map<String, Object?> properties = const {},
  ]) async {
    final sanitized = <String, Object?>{
      for (final entry in properties.entries)
        if (!forbiddenKeys.contains(entry.key.toLowerCase()))
          entry.key: entry.value,
    };

    assert(
      sanitized.length == properties.length,
      'Analytics event "$event" carried a forbidden property. '
      'Private notes, documents, credentials and free text never reach '
      'analytics.',
    );

    final msSinceFirstOpen = DateTime.now()
        .toUtc()
        .difference(_firstOpenAt)
        .inMilliseconds;

    await _delegate.track(event, {
      ...sanitized,
      'lang': _language().code,
      if (_persona != null) 'persona': _persona,
      'app_version': _appVersion,
      if (AnalyticsEvents.requireMsSinceFirstOpen.contains(event) ||
          sanitized.containsKey('ms_since_first_open'))
        'ms_since_first_open': msSinceFirstOpen,
    });
  }

  @override
  Future<void> setUser({
    required String? userId,
    required String? persona,
  }) async {
    _persona = persona;
    await _delegate.setUser(userId: userId, persona: persona);
  }
}

/// Writes events to the debug log. The development default.
class DebugAnalyticsService implements AnalyticsService {
  const DebugAnalyticsService();

  @override
  Future<void> track(
    String event, [
    Map<String, Object?> properties = const {},
  ]) async {
    developer.log('$event $properties', name: 'analytics');
  }

  @override
  Future<void> setUser({
    required String? userId,
    required String? persona,
  }) async {
    developer.log('identify $userId ($persona)', name: 'analytics');
  }
}

/// Records events in memory, for tests.
class RecordingAnalyticsService implements AnalyticsService {
  final List<({String event, Map<String, Object?> properties})> events = [];

  @override
  Future<void> track(
    String event, [
    Map<String, Object?> properties = const {},
  ]) async {
    events.add((event: event, properties: properties));
  }

  @override
  Future<void> setUser({
    required String? userId,
    required String? persona,
  }) async {}

  bool contains(String event) => events.any((e) => e.event == event);
}
