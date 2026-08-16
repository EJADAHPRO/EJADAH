import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';

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
    required this.isMarked,
  });

  final String id;
  final String bookingId;
  final DateTime startsAt;
  final DateTime endsAt;
  final LocalizedText studentName;
  final String subject;

  /// What the student wrote they need. Shown to their own tutor and nobody
  /// else — never logged, never sent to analytics.
  final String goal;
  final int netEgp;
  final bool isMarked;

  static TutorSession fromJson(Map<String, dynamic> json) => TutorSession(
    id: json['id'] as String,
    bookingId: json['booking_id'] as String,
    startsAt: DateTime.parse(json['starts_at'] as String),
    endsAt: DateTime.parse(json['ends_at'] as String),
    studentName:
        LocalizedText.fromJson(json['student_name']) ??
        const LocalizedText.same(''),
    subject: json['subject'] as String? ?? '',
    goal: json['goal'] as String? ?? '',
    netEgp: (json['net_egp'] as num?)?.toInt() ?? 0,
    isMarked: json['is_marked'] as bool? ?? false,
  );
}

/// Everything the dashboard shows, in the order a tutor wants it.
class TutorDashboard {
  const TutorDashboard({
    required this.today,
    required this.unmarked,
    required this.week,
    required this.availableEgp,
    required this.pendingEgp,
    required this.requestedEgp,
    required this.isHidden,
    required this.autoCompleteAfterDays,
    this.meetingUrl,
  });

  final List<TutorSession> today;
  final List<TutorSession> unmarked;
  final List<TutorSession> week;

  /// Money as figures. Never a series: a tutor with six sessions a month has
  /// nothing to plot, and a sparkline over six points is decoration standing
  /// where a number should be.
  final int availableEgp;
  final int pendingEgp;
  final int requestedEgp;

  final bool isHidden;

  /// How long an unmarked session waits before releasing itself.
  final int autoCompleteAfterDays;

  /// Where the sessions happen. Null is a real state — the screen then offers
  /// to add one rather than showing a Join button that goes nowhere.
  final String? meetingUrl;

  bool get hasMeetingUrl => meetingUrl != null && meetingUrl!.isNotEmpty;

  static TutorDashboard fromJson(Map<String, dynamic> json) {
    List<TutorSession> sessions(String key) =>
        (json[key] as List<dynamic>? ?? const [])
            .map(
              (item) =>
                  TutorSession.fromJson(Map<String, dynamic>.from(item as Map)),
            )
            .toList();

    final earnings = Map<String, dynamic>.from(json['earnings'] as Map);
    return TutorDashboard(
      today: sessions('today'),
      unmarked: sessions('unmarked'),
      week: sessions('week'),
      availableEgp: (earnings['available_egp'] as num).toInt(),
      pendingEgp: (earnings['pending_egp'] as num).toInt(),
      requestedEgp: (earnings['requested_egp'] as num).toInt(),
      isHidden: json['is_hidden'] as bool? ?? false,
      autoCompleteAfterDays:
          (json['auto_complete_after_days'] as num?)?.toInt() ?? 7,
      meetingUrl: json['meeting_url'] as String?,
    );
  }
}

class DashboardRepository {
  const DashboardRepository(this._client);

  final ApiClient _client;

  Future<TutorDashboard> load() =>
      _client.get('/dashboard/', parse: TutorDashboard.fromJson);

  Future<void> mark(String sessionId) => _client.postVoid(
    '/dashboard/sessions/$sessionId/mark',
  );

  Future<void> setHidden(bool hidden) => _client.putVoid(
    '/dashboard/visibility',
    body: {'is_hidden': hidden},
  );

  Future<void> setMeetingUrl(String? url) => _client.putVoid(
    '/dashboard/meeting-url',
    body: {'meeting_url': url},
  );
}

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => DashboardRepository(ref.watch(apiClientProvider)),
);
