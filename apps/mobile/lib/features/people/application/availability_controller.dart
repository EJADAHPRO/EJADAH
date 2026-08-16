import 'package:ejadah_core/ejadah_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/availability_repository.dart';

/// The preset blocks the day rows offer.
///
/// Three, in the shape of a dentist's day: a morning before clinic, an
/// afternoon, and the evening when most tutoring actually happens. A tutor who
/// wants something else uses custom hours — the chips are a shortcut, not the
/// only way in.
enum TimeBlock {
  morning(9 * 60, 12 * 60),
  afternoon(13 * 60, 17 * 60),
  evening(17 * 60, 21 * 60);

  const TimeBlock(this.startMinute, this.endMinute);

  final int startMinute;
  final int endMinute;

  int get minutes => endMinute - startMinute;
}

/// The editor's working copy.
class AvailabilityDraft {
  const AvailabilityDraft({
    required this.saved,
    required this.rules,
    this.isSaving = false,
  });

  /// What the server last returned. Kept so the screen can tell a changed week
  /// from an unchanged one without guessing.
  final Availability saved;

  /// The week as edited.
  final List<AvailabilityRule> rules;
  final bool isSaving;

  int get weeklyMinutes => rules.fold(0, (total, rule) => total + rule.minutes);

  int get weeklyHours => weeklyMinutes ~/ 60;

  bool get meetsFloor => weeklyHours >= saved.minimumWeeklyHours;

  /// Whether there is anything to save.
  ///
  /// Compared by content, not by identity: a chip tapped on and off again
  /// leaves the week exactly as it was, and offering to save that is a button
  /// that does nothing.
  bool get isDirty {
    final before = _signature(saved.rules);
    final after = _signature(rules);
    return before.length != after.length || !before.every(after.contains);
  }

  List<AvailabilityRule> forDay(int weekday) =>
      rules.where((rule) => rule.weekday == weekday).toList()
        ..sort((a, b) => a.startMinute.compareTo(b.startMinute));

  bool hasBlock(int weekday, TimeBlock block) => rules.any(
    (rule) =>
        rule.weekday == weekday &&
        rule.matches(block.startMinute, block.endMinute),
  );

  AvailabilityDraft copyWith({
    Availability? saved,
    List<AvailabilityRule>? rules,
    bool? isSaving,
  }) => AvailabilityDraft(
    saved: saved ?? this.saved,
    rules: rules ?? this.rules,
    isSaving: isSaving ?? this.isSaving,
  );

  static Set<String> _signature(List<AvailabilityRule> rules) => rules
      .map((rule) => '${rule.weekday}:${rule.startMinute}:${rule.endMinute}')
      .toSet();
}

final availabilityControllerProvider =
    AsyncNotifierProvider<AvailabilityController, AvailabilityDraft>(
      AvailabilityController.new,
    );

/// PE-14's state.
class AvailabilityController extends AsyncNotifier<AvailabilityDraft> {
  @override
  Future<AvailabilityDraft> build() async {
    final saved = await ref.read(availabilityRepositoryProvider).load();
    return AvailabilityDraft(saved: saved, rules: List.of(saved.rules));
  }

  AvailabilityRepository get _repository =>
      ref.read(availabilityRepositoryProvider);

  Future<void> refresh() async {
    state = await AsyncValue.guard(() async {
      final saved = await _repository.load();
      return AvailabilityDraft(saved: saved, rules: List.of(saved.rules));
    });
  }

  /// Adds or removes a preset block on one day.
  void toggleBlock(int weekday, TimeBlock block) {
    final draft = state.valueOrNull;
    if (draft == null) return;

    final has = draft.hasBlock(weekday, block);
    state = AsyncData(
      draft.copyWith(
        rules: [
          for (final rule in draft.rules)
            if (!(rule.weekday == weekday &&
                rule.matches(block.startMinute, block.endMinute)))
              rule,
          if (!has)
            AvailabilityRule(
              weekday: weekday,
              startMinute: block.startMinute,
              endMinute: block.endMinute,
            ),
        ],
      ),
    );
  }

  void addCustom(int weekday, int startMinute, int endMinute) {
    final draft = state.valueOrNull;
    if (draft == null || endMinute <= startMinute) return;
    state = AsyncData(
      draft.copyWith(
        rules: [
          ...draft.rules,
          AvailabilityRule(
            weekday: weekday,
            startMinute: startMinute,
            endMinute: endMinute,
          ),
        ],
      ),
    );
  }

  void removeRule(AvailabilityRule target) {
    final draft = state.valueOrNull;
    if (draft == null) return;
    state = AsyncData(
      draft.copyWith(
        rules: [
          for (final rule in draft.rules)
            if (!(rule.weekday == target.weekday &&
                rule.matches(target.startMinute, target.endMinute)))
              rule,
        ],
      ),
    );
  }

  /// Saves the week.
  ///
  /// Returns the clash when the server refuses because confirmed sessions
  /// stand in hours the new shape drops — the screen lists them. The draft is
  /// **left as edited** on refusal: throwing away what someone just typed
  /// because the server said no is how an editor loses trust.
  Future<AvailabilityClash?> save() async {
    final draft = state.valueOrNull;
    if (draft == null) return null;

    state = AsyncData(draft.copyWith(isSaving: true));
    try {
      await _repository.saveRules(draft.rules);
      final saved = await _repository.load();
      state = AsyncData(
        AvailabilityDraft(saved: saved, rules: List.of(saved.rules)),
      );
      return null;
    } on AvailabilityClash catch (clash) {
      state = AsyncData(draft.copyWith(isSaving: false));
      return clash;
    } on Failure {
      state = AsyncData(draft.copyWith(isSaving: false));
      rethrow;
    }
  }

  /// Blocks a period. Returns the clash when confirmed sessions stand in it.
  Future<AvailabilityClash?> block({
    required DateTime startsAt,
    required DateTime endsAt,
    String? reason,
  }) async {
    try {
      await _repository.block(
        startsAt: startsAt,
        endsAt: endsAt,
        reason: reason,
      );
      await refresh();
      return null;
    } on AvailabilityClash catch (clash) {
      return clash;
    }
  }

  Future<void> open({
    required DateTime startsAt,
    required DateTime endsAt,
  }) async {
    await _repository.open(startsAt: startsAt, endsAt: endsAt);
    await refresh();
  }

  Future<void> removeException(int id) async {
    await _repository.removeException(id);
    await refresh();
  }
}
