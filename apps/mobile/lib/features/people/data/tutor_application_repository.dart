import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';

/// The six steps, mirroring the server's enum.
///
/// The order is the flow's: the cheap questions come first, so someone who is
/// not going to finish discovers that before uploading a certificate.
enum ApplicationStep {
  basics(1, 'basics'),
  qualifications(2, 'qualifications'),
  subjects(3, 'subjects'),
  rate(4, 'rate'),
  availability(5, 'availability'),
  media(6, 'media');

  const ApplicationStep(this.position, this.wire);

  final int position;
  final String wire;

  static const int count = 6;

  bool get isLast => position == count;

  static ApplicationStep? fromPosition(int value) {
    for (final step in values) {
      if (step.position == value) return step;
    }
    return null;
  }
}

/// One thing the application still needs.
///
/// The server sends all of them at once — never the first one it found — and
/// the screen lists them all. A form that sends someone back one omission at a
/// time is a form nobody finishes.
class MissingItem {
  const MissingItem({
    required this.key,
    required this.step,
    required this.field,
    required this.label,
  });

  /// `qualifications.items` — unique across the whole application, because two
  /// steps both answer a field called `items`.
  final String key;
  final ApplicationStep step;
  final String field;
  final LocalizedText label;

  static MissingItem? fromJson(Map<String, dynamic> json) {
    final step = ApplicationStep.fromPosition((json['step'] as num).toInt());
    final label = LocalizedText.fromJson(json['label']);
    if (step == null || label == null) return null;
    return MissingItem(
      key: json['key'] as String,
      step: step,
      field: json['field'] as String,
      label: label,
    );
  }
}

/// One window of availability: a weekday and the hours inside it.
class AvailabilityWindow {
  const AvailabilityWindow({
    required this.weekday,
    required this.startsAt,
    required this.endsAt,
  });

  /// 0 = Sunday … 6 = Saturday — the schema's convention, matching
  /// `availability_rules` and the booking calendar, which starts on Sunday in
  /// both languages.
  final int weekday;

  /// `"17:00"`. A wall-clock time in Cairo, like every other time in the
  /// product — see `CairoClock` on the server.
  final String startsAt;
  final String endsAt;

  int get minutes {
    final start = _minutesOfDay(startsAt);
    final end = _minutesOfDay(endsAt);
    if (start == null || end == null || end <= start) return 0;
    return end - start;
  }

  Map<String, dynamic> toJson() => {
    'weekday': weekday,
    'starts_at': startsAt,
    'ends_at': endsAt,
  };

  static AvailabilityWindow? fromJson(Object? value) {
    if (value is! Map) return null;
    final weekday = (value['weekday'] as num?)?.toInt();
    final startsAt = value['starts_at'] as String?;
    final endsAt = value['ends_at'] as String?;
    if (weekday == null || startsAt == null || endsAt == null) return null;
    return AvailabilityWindow(
      weekday: weekday,
      startsAt: startsAt,
      endsAt: endsAt,
    );
  }

  AvailabilityWindow copyWith({int? weekday, String? startsAt, String? endsAt}) =>
      AvailabilityWindow(
        weekday: weekday ?? this.weekday,
        startsAt: startsAt ?? this.startsAt,
        endsAt: endsAt ?? this.endsAt,
      );

  static int? _minutesOfDay(String value) {
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final hours = int.tryParse(parts[0]);
    final minutes = int.tryParse(parts[1]);
    if (hours == null || minutes == null) return null;
    return hours * 60 + minutes;
  }
}

/// The saved application, at whatever stage it has reached.
class TutorApplication {
  const TutorApplication({
    required this.status,
    required this.lastStep,
    required this.payload,
    required this.isEditable,
    this.submittedAt,
    this.rejectionReason,
  });

  final ProfessionalStatus status;
  final int lastStep;
  final Map<String, dynamic> payload;
  final bool isEditable;
  final DateTime? submittedAt;
  final String? rejectionReason;

  /// The answers for one step, or an empty map when it has not been reached.
  Map<String, dynamic> answersFor(ApplicationStep step) {
    final section = payload[step.wire];
    return section is Map
        ? Map<String, dynamic>.from(section)
        : <String, dynamic>{};
  }

  List<AvailabilityWindow> get availability {
    final rules = answersFor(ApplicationStep.availability)['rules'];
    if (rules is! List) return const [];
    return rules
        .map(AvailabilityWindow.fromJson)
        .whereType<AvailabilityWindow>()
        .toList();
  }

  int get weeklyMinutes =>
      availability.fold(0, (total, window) => total + window.minutes);

  static TutorApplication fromJson(Map<String, dynamic> json) =>
      TutorApplication(
        status: ProfessionalStatus.fromWire(json['status'] as String?),
        lastStep: (json['last_step'] as num?)?.toInt() ?? 1,
        payload: Map<String, dynamic>.from(
          json['payload'] as Map? ?? const {},
        ),
        isEditable: json['is_editable'] as bool? ?? false,
        submittedAt: DateTime.tryParse(json['submitted_at'] as String? ?? ''),
        rejectionReason: json['rejection_reason'] as String?,
      );
}

/// What `GET /people/apply` answers.
///
/// The split and the weekly floor arrive from the server rather than being
/// written into the app's copy, so the number on the public pitch and the
/// number the ledger uses cannot drift apart.
class TutorApplicationSnapshot {
  const TutorApplicationSnapshot({
    required this.professionalSharePercent,
    required this.minimumWeeklyHours,
    required this.missing,
    this.application,
  });

  final int professionalSharePercent;
  final int minimumWeeklyHours;

  /// Live, so the review step can say why submit is disabled *before* the tap.
  final List<MissingItem> missing;
  final TutorApplication? application;

  int get platformFeePercent => 100 - professionalSharePercent;

  bool get hasStarted => application != null;

  static TutorApplicationSnapshot fromJson(Map<String, dynamic> json) =>
      TutorApplicationSnapshot(
        professionalSharePercent:
            (json['professional_share_percent'] as num).toInt(),
        minimumWeeklyHours: (json['minimum_weekly_hours'] as num).toInt(),
        missing: (json['missing'] as List<dynamic>? ?? const [])
            .map(
              (item) => MissingItem.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .whereType<MissingItem>()
            .toList(),
        application: json['application'] == null
            ? null
            : TutorApplication.fromJson(
                Map<String, dynamic>.from(json['application'] as Map),
              ),
      );
}

/// The three actions a newly approved tutor is given, and what is done.
class Playbook {
  const Playbook(this.items);

  final Map<String, bool> items;

  int get done => items.values.where((value) => value).length;

  int get total => items.length;

  bool isDone(String item) => items[item] ?? false;

  static Playbook fromJson(Map<String, dynamic> json) => Playbook({
    for (final entry in (json['items'] as Map? ?? const {}).entries)
      entry.key.toString(): entry.value == true,
  });
}

/// Applying to teach.
class TutorApplicationRepository {
  const TutorApplicationRepository(this._client);

  final ApiClient _client;

  /// Readable without an account: the pitch states the split before anyone
  /// signs in.
  Future<TutorApplicationSnapshot> snapshot() => _client.get(
    '/people/apply',
    parse: TutorApplicationSnapshot.fromJson,
  );

  Future<TutorApplication> saveStep({
    required ApplicationStep step,
    required Map<String, dynamic> answers,
  }) => _client.put(
    '/people/apply/${step.position}',
    body: {'answers': answers},
    parse: TutorApplication.fromJson,
  );

  /// Throws [ValidationFailure] carrying **every** missing item, keyed
  /// `step.field`.
  Future<TutorApplication> submit() => _client.post(
    '/people/apply/submit',
    parse: TutorApplication.fromJson,
  );

  Future<Playbook> playbook() =>
      _client.get('/people/playbook', parse: Playbook.fromJson);

  Future<Playbook> completePlaybookItem(String item) =>
      _client.post('/people/playbook/$item', parse: Playbook.fromJson);
}

final tutorApplicationRepositoryProvider = Provider<TutorApplicationRepository>(
  (ref) => TutorApplicationRepository(ref.watch(apiClientProvider)),
);
