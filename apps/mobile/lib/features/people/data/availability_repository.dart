import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';

/// One recurring window in the week.
class AvailabilityRule {
  const AvailabilityRule({
    required this.weekday,
    required this.startMinute,
    required this.endMinute,
    this.id = 0,
  });

  final int id;

  /// 0 = Sunday … 6 = Saturday, matching the schema and the booking calendar.
  final int weekday;
  final int startMinute;
  final int endMinute;

  int get minutes => endMinute - startMinute;

  /// Whether this rule is exactly the block [start]–[end].
  ///
  /// Exact rather than overlapping: the chips are a shorthand for one specific
  /// window, and a chip that lights up for a window it does not describe is a
  /// chip that lies about what tapping it will do.
  bool matches(int start, int end) => startMinute == start && endMinute == end;

  Map<String, dynamic> toJson() => {
    'weekday': weekday,
    'start_minute': startMinute,
    'end_minute': endMinute,
  };

  static AvailabilityRule fromJson(Map<String, dynamic> json) =>
      AvailabilityRule(
        id: (json['id'] as num?)?.toInt() ?? 0,
        weekday: (json['weekday'] as num).toInt(),
        startMinute: (json['start_minute'] as num).toInt(),
        endMinute: (json['end_minute'] as num).toInt(),
      );
}

/// A dated override: time blocked off, or extra hours opened.
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
  final bool isAvailable;
  final String? reason;

  static AvailabilityException fromJson(Map<String, dynamic> json) =>
      AvailabilityException(
        id: (json['id'] as num).toInt(),
        startsAt: DateTime.parse(json['starts_at'] as String),
        endsAt: DateTime.parse(json['ends_at'] as String),
        isAvailable: json['is_available'] as bool? ?? false,
        reason: json['reason'] as String?,
      );
}

/// The whole calendar.
class Availability {
  const Availability({
    required this.rules,
    required this.exceptions,
    required this.weeklyMinutes,
    required this.minimumWeeklyHours,
  });

  final List<AvailabilityRule> rules;
  final List<AvailabilityException> exceptions;

  /// From the server, so the hint under the grid and the check the application
  /// ran are the same number.
  final int weeklyMinutes;
  final int minimumWeeklyHours;

  List<AvailabilityRule> forDay(int weekday) =>
      rules.where((rule) => rule.weekday == weekday).toList();

  static Availability fromJson(Map<String, dynamic> json) => Availability(
    rules: (json['rules'] as List<dynamic>)
        .map(
          (item) =>
              AvailabilityRule.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(),
    exceptions: (json['exceptions'] as List<dynamic>)
        .map(
          (item) => AvailabilityException.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList(),
    weeklyMinutes: (json['weekly_minutes'] as num).toInt(),
    minimumWeeklyHours: (json['minimum_weekly_hours'] as num).toInt(),
  );
}

/// Refused because confirmed sessions stand in the period.
///
/// Carries them so the screen can name the students rather than saying "no".
class AvailabilityClash implements Exception {
  const AvailabilityClash(this.message, this.sessions);

  final LocalizedText message;

  /// Each entry describes one session the block would have stranded.
  final List<LocalizedText> sessions;
}

class AvailabilityRepository {
  const AvailabilityRepository(this._client);

  final ApiClient _client;

  Future<Availability> load() =>
      _client.get('/availability/', parse: Availability.fromJson);

  /// Replaces the weekly shape.
  ///
  /// Throws [AvailabilityClash] when the new shape would drop hours a
  /// confirmed session already occupies.
  Future<void> saveRules(List<AvailabilityRule> rules) => _guardClash(
    () => _client.put<void>(
      '/availability/rules',
      body: {'rules': rules.map((rule) => rule.toJson()).toList()},
      parse: (_) {},
    ),
  );

  Future<void> block({
    required DateTime startsAt,
    required DateTime endsAt,
    String? reason,
  }) => _guardClash(
    () => _client.post<void>(
      '/availability/blocks',
      body: {
        'starts_at': startsAt.toUtc().toIso8601String(),
        'ends_at': endsAt.toUtc().toIso8601String(),
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
      parse: (_) {},
    ),
  );

  Future<void> open({required DateTime startsAt, required DateTime endsAt}) =>
      _client.post<void>(
        '/availability/openings',
        body: {
          'starts_at': startsAt.toUtc().toIso8601String(),
          'ends_at': endsAt.toUtc().toIso8601String(),
        },
        parse: (_) {},
      );

  Future<void> removeException(int id) =>
      _client.delete('/availability/exceptions/$id');

  /// Turns the server's 409 into something the screen can list.
  ///
  /// The conflict arrives with one field per clashing session; a bare
  /// `ConflictFailure` would carry the message and lose the names, which are
  /// the only part a tutor can act on.
  Future<void> _guardClash(Future<void> Function() action) async {
    try {
      await action();
    } on ConflictFailure catch (failure) {
      if (failure.fields.isEmpty) rethrow;
      throw AvailabilityClash(failure.message, failure.fields.values.toList());
    }
  }
}

final availabilityRepositoryProvider = Provider<AvailabilityRepository>(
  (ref) => AvailabilityRepository(ref.watch(apiClientProvider)),
);
