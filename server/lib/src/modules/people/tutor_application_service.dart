import 'dart:convert';

import 'package:ejadah_models/ejadah_models.dart';
import 'package:postgres/postgres.dart';

import '../../config/config.dart';
import '../../db/database.dart';
import '../../http/api_error.dart';

/// The six steps of the tutor application.
///
/// Ordered as the flow states them: who you are, what you can prove, what you
/// teach, what you charge, when you are free, and how you appear. The order is
/// deliberate — the cheap questions come first so someone who is not going to
/// finish discovers that before uploading a certificate.
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

  /// The step at [value], or null.
  ///
  /// Null rather than a default: falling back to [basics] would let a bad step
  /// number quietly overwrite step 1's answers with step 9's, which is the
  /// draft losing work — the one thing this whole form is built not to do.
  static ApplicationStep? fromPosition(int value) {
    for (final step in values) {
      if (step.position == value) return step;
    }
    return null;
  }
}

/// One thing the application is still missing.
///
/// Carried as a list rather than a single message because the flow requires
/// submit to name **every** missing item at once: sending someone back six
/// times for six omissions is the failure this exists to prevent.
class MissingItem {
  const MissingItem({
    required this.step,
    required this.field,
    required this.label,
  });

  final ApplicationStep step;

  /// The field's name inside its own step's answers.
  ///
  /// Not unique on its own — qualifications and subjects both answer `items` —
  /// which is why anything keyed by a single string uses [key].
  final String field;

  final LocalizedText label;

  /// The application-wide identifier: `qualifications.items`, `subjects.items`.
  ///
  /// Submit reports the missing items as a map, and a map keyed by [field]
  /// would have silently collapsed those two into one — dropping a missing item
  /// from a list whose entire purpose is to be complete.
  String get key => '${step.wire}.$field';

  Map<String, dynamic> toJson() => {
    'step': step.position,
    'key': key,
    'field': field,
    'label': label.toJson(),
  };
}

/// A saved application, at whatever stage it has reached.
class TutorApplication {
  const TutorApplication({
    required this.status,
    required this.lastStep,
    required this.payload,
    this.submittedAt,
    this.rejectionReason,
  });

  final ProfessionalStatus status;
  final int lastStep;
  final Map<String, dynamic> payload;
  final DateTime? submittedAt;
  final String? rejectionReason;

  bool get isEditable =>
      status == ProfessionalStatus.draft ||
      status == ProfessionalStatus.rejected;

  Map<String, dynamic> toJson() => {
    'status': status.wire,
    'last_step': lastStep,
    'payload': payload,
    'submitted_at': submittedAt?.toIso8601String(),
    'rejection_reason': rejectionReason,
    'is_editable': isEditable,
  };
}

/// Applying to teach, and the first-student playbook that follows approval.
///
/// The supply side is the marketplace's survival risk: a demand-side product
/// with no tutors is a directory of empty rooms. This is the whole way in.
class TutorApplicationService {
  const TutorApplicationService(this._database, this._config);

  final Database _database;
  final AppConfig _config;

  /// The three actions a newly approved tutor is given.
  ///
  /// Three, and checkable, because "you're approved" on its own leaves someone
  /// with a profile and no idea what produces a first student.
  static const List<String> playbookItems = [
    'set_availability',
    'complete_profile',
    'share_card',
  ];

  /// What the pitch screen promises, computed rather than written into copy so
  /// the number on the public page and the number in the ledger cannot differ.
  int get professionalSharePercent => _config.professionalSharePercent;

  Future<TutorApplication?> find(String userId) async {
    final rows = await _query(
      'SELECT * FROM tutor_applications WHERE user_id = @user_id',
      {'user_id': userId},
    );
    if (rows.isEmpty) return null;
    return _toApplication(rows.first);
  }

  /// Saves one step's answers.
  ///
  /// Every step is saved on its own, so closing the app at step 4 loses
  /// nothing — the flow calls it "draft-saved each" and that is the point of a
  /// six-step form on a phone.
  ///
  /// The payload is merged rather than replaced: a client that only sends the
  /// step it is on must not blank the five it is not.
  Future<TutorApplication> saveStep({
    required String userId,
    required ApplicationStep step,
    required Map<String, dynamic> answers,
  }) async {
    final existing = await find(userId);
    if (existing != null && !existing.isEditable) {
      // An application under review is not a document to keep editing; a
      // rejected one is.
      throw ApiException.conflict();
    }

    final merged = {...?existing?.payload, step.wire: answers};

    await _execute(
      '''
      INSERT INTO tutor_applications (user_id, last_step, payload, status)
      VALUES (@user_id, @last_step, @payload::jsonb, 'draft')
      ON CONFLICT (user_id) DO UPDATE SET
        -- Never goes backwards: revisiting step 2 does not lose the fact
        -- that step 5 was already reached.
        last_step = GREATEST(tutor_applications.last_step, @last_step),
        payload = @payload::jsonb,
        status = 'draft',
        updated_at = now()
      ''',
      {
        'user_id': userId,
        'last_step': step.position,
        'payload': jsonEncode(merged),
      },
    );

    return (await find(userId))!;
  }

  /// Everything the application still needs, in step order.
  ///
  /// Public because the client shows it live on the review step rather than
  /// only after a rejected submit — the flow's "submit disabled WITH reason"
  /// needs the reason before the tap, not after it.
  List<MissingItem> missingItems(Map<String, dynamic> payload) {
    final missing = <MissingItem>[];

    void require(
      ApplicationStep step,
      String field,
      LocalizedText label, {
      bool Function(Object? value)? isPresent,
    }) {
      final section = payload[step.wire];
      final value = section is Map ? section[field] : null;
      final present = isPresent != null
          ? isPresent(value)
          : value != null && value.toString().trim().isNotEmpty;
      if (!present) {
        missing.add(MissingItem(step: step, field: field, label: label));
      }
    }

    bool isNonEmptyList(Object? value) => value is List && value.isNotEmpty;

    require(
      ApplicationStep.basics,
      'display_name_en',
      const LocalizedText(en: 'Your name in English', ar: 'اسمك بالإنجليزية'),
    );
    require(
      ApplicationStep.basics,
      'display_name_ar',
      const LocalizedText(en: 'Your name in Arabic', ar: 'اسمك بالعربية'),
    );
    require(
      ApplicationStep.basics,
      'headline',
      const LocalizedText(en: 'A one-line headline', ar: 'سطر تعريفي واحد'),
    );
    require(
      ApplicationStep.qualifications,
      'items',
      const LocalizedText(
        en: 'At least one qualification',
        ar: 'مؤهل واحد على الأقل',
      ),
      isPresent: isNonEmptyList,
    );
    require(
      ApplicationStep.qualifications,
      'document_key',
      const LocalizedText(
        en: 'A document proving one of them',
        ar: 'مستند يثبت أحدها',
      ),
    );
    require(
      ApplicationStep.subjects,
      'items',
      const LocalizedText(
        en: 'At least one subject you teach',
        ar: 'مادة واحدة على الأقل تدرّسها',
      ),
      isPresent: isNonEmptyList,
    );
    require(
      ApplicationStep.rate,
      'hourly_rate_egp',
      const LocalizedText(en: 'Your hourly rate', ar: 'سعر الساعة'),
      isPresent: (value) => value is num && value > 0,
    );
    require(
      ApplicationStep.availability,
      'rules',
      const LocalizedText(
        en: 'At least $minimumWeeklyHours hours a week',
        ar: 'ما لا يقل عن $minimumWeeklyHours ساعات أسبوعيًا',
      ),
      isPresent: (value) =>
          value is List && _weeklyHours(value) >= minimumWeeklyHours,
    );
    require(
      ApplicationStep.media,
      'avatar_key',
      const LocalizedText(en: 'A photograph', ar: 'صورة شخصية'),
    );

    return missing;
  }

  /// The floor the availability step hints at.
  ///
  /// Not a rule invented here: a tutor offering two hours a week will be booked
  /// once and then look unavailable, which reads to a student as an inactive
  /// marketplace.
  static const int minimumWeeklyHours = 5;

  /// Submits for review.
  ///
  /// Refuses with every missing item named at once. A form that sends someone
  /// back one omission at a time is the thing this rule exists to prevent.
  Future<TutorApplication> submit(String userId) async {
    final application = await find(userId);
    if (application == null) throw ApiException.notFound();
    if (!application.isEditable) throw ApiException.conflict();

    final missing = missingItems(application.payload);
    if (missing.isNotEmpty) {
      throw ApiException(
        ApiErrorCode.validation,
        // Keyed step-qualified so two steps asking the same question cannot
        // collapse into one entry, and carrying the label so the client can
        // name each one without a second lookup.
        fields: {for (final item in missing) item.key: item.label},
        details: 'The application is missing ${missing.length} items.',
      );
    }

    await _execute(
      """
      UPDATE tutor_applications
      SET status = 'under_review', submitted_at = now(),
          rejection_reason = NULL, updated_at = now()
      WHERE user_id = @user_id
      """,
      {'user_id': userId},
    );
    return (await find(userId))!;
  }

  /// The playbook, with what has been done.
  Future<Map<String, bool>> playbook(String userId) async {
    final rows = await _query(
      'SELECT item FROM playbook_progress WHERE user_id = @user_id',
      {'user_id': userId},
    );
    final done = rows.map((row) => row.str('item')).toSet();
    return {for (final item in playbookItems) item: done.contains(item)};
  }

  Future<Map<String, bool>> completePlaybookItem({
    required String userId,
    required String item,
  }) async {
    if (!playbookItems.contains(item)) throw ApiException.notFound();
    await _execute(
      'INSERT INTO playbook_progress (user_id, item) VALUES (@user_id, @item) '
      'ON CONFLICT (user_id, item) DO NOTHING',
      {'user_id': userId, 'item': item},
    );
    return playbook(userId);
  }

  /// Total hours a week across the availability rules.
  static int _weeklyHours(List<dynamic> rules) {
    var minutes = 0;
    for (final rule in rules) {
      if (rule is! Map) continue;
      final start = _minutesOfDay(rule['starts_at']);
      final end = _minutesOfDay(rule['ends_at']);
      if (start == null || end == null || end <= start) continue;
      minutes += end - start;
    }
    return minutes ~/ 60;
  }

  /// `"18:00"` → 1080. Anything else is not a time and contributes nothing.
  static int? _minutesOfDay(Object? value) {
    final parts = value?.toString().split(':');
    if (parts == null || parts.length < 2) return null;
    final hours = int.tryParse(parts[0]);
    final minutes = int.tryParse(parts[1]);
    if (hours == null || minutes == null) return null;
    return hours * 60 + minutes;
  }

  TutorApplication _toApplication(Map<String, dynamic> row) => TutorApplication(
    status: ProfessionalStatus.fromWire(row.str('status')),
    lastStep: row.intAt('last_step'),
    payload: Map<String, dynamic>.from(row['payload'] as Map? ?? const {}),
    submittedAt: row.dateOrNull('submitted_at'),
    rejectionReason: row.strOrNull('rejection_reason'),
  );

  Future<List<Map<String, dynamic>>> _query(
    String sql,
    Map<String, Object?> parameters,
  ) async {
    final result = await _database.run(
      (session) => session.execute(Sql.named(sql), parameters: parameters),
    );
    return result.map((row) => row.toColumnMap()).toList();
  }

  Future<void> _execute(String sql, Map<String, Object?> parameters) async {
    await _query(sql, parameters);
  }
}
