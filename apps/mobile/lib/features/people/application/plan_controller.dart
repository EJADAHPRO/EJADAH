import 'dart:async';

import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/people_repository.dart';

/// One week of a plan, and what has been placed in it.
class PlanWeek {
  const PlanWeek({
    required this.index,
    required this.startsAt,
    this.slots = const [],
    this.chosen = const [],
    this.isLoading = false,
    this.failure,
    this.unfillable = false,
  });

  /// Zero-based.
  final int index;

  /// Midnight UTC on the Sunday this week begins.
  final DateTime startsAt;

  /// Everything on the calendar that week, available or not.
  final List<AvailabilitySlot> slots;

  /// The times the student placed in this week.
  final List<AvailabilitySlot> chosen;
  final bool isLoading;
  final Failure? failure;

  /// "Same time every week" could not place the requested time here, because
  /// the professional was not free. Reported rather than silently skipped.
  final bool unfillable;

  bool isComplete(int sessionsPerWeek) => chosen.length >= sessionsPerWeek;

  PlanWeek copyWith({
    List<AvailabilitySlot>? slots,
    List<AvailabilitySlot>? chosen,
    bool? isLoading,
    Failure? failure,
    bool clearFailure = false,
    bool? unfillable,
  }) => PlanWeek(
    index: index,
    startsAt: startsAt,
    slots: slots ?? this.slots,
    chosen: chosen ?? this.chosen,
    isLoading: isLoading ?? this.isLoading,
    failure: clearFailure ? null : (failure ?? this.failure),
    unfillable: unfillable ?? this.unfillable,
  );
}

/// The custom plan being built.
class PlanState {
  const PlanState({
    required this.professional,
    required this.sessionsPerWeek,
    required this.sessionMinutes,
    required this.weekCount,
    required this.weeks,
    this.currentWeek = 0,
  });

  final Professional professional;

  /// The cadence dials. Never an aggregate-hours question: "how many hours in
  /// total" makes the student do the scheduling arithmetic the product exists
  /// to do for them, and asking it is a defect.
  final int sessionsPerWeek;
  final int sessionMinutes;
  final int weekCount;
  final List<PlanWeek> weeks;
  final int currentWeek;

  int get totalSessions => sessionsPerWeek * weekCount;

  /// The live quote, from the professional's own rate.
  ///
  /// Displayed only. The server prices the booking itself and never reads a
  /// figure from the client.
  int get quotedEgp =>
      (professional.hourlyRateEgp * sessionMinutes / 60).round() *
      totalSessions;

  int get filledWeeks =>
      weeks.where((week) => week.isComplete(sessionsPerWeek)).length;

  bool get isComplete => filledWeeks == weekCount && weekCount > 0;

  /// The weeks "same time every week" could not fill, one-based for display.
  List<int> get unfillableWeeks => [
    for (final week in weeks)
      if (week.unfillable) week.index + 1,
  ];

  PlanState copyWith({
    int? sessionsPerWeek,
    int? sessionMinutes,
    int? weekCount,
    List<PlanWeek>? weeks,
    int? currentWeek,
  }) => PlanState(
    professional: professional,
    sessionsPerWeek: sessionsPerWeek ?? this.sessionsPerWeek,
    sessionMinutes: sessionMinutes ?? this.sessionMinutes,
    weekCount: weekCount ?? this.weekCount,
    weeks: weeks ?? this.weeks,
    currentWeek: currentWeek ?? this.currentWeek,
  );
}

final planControllerProvider =
    NotifierProvider.family<PlanController, PlanState, Professional>(
      PlanController.new,
    );

/// Builds a multi-session plan, one week at a time.
///
/// The week stepper is the whole interaction: fill week 1, tick, advance. A
/// week already filled stays reachable, so changing week 2 after reaching week
/// 6 does not mean starting again.
class PlanController extends FamilyNotifier<PlanState, Professional> {
  @override
  PlanState build(Professional arg) {
    final start = _startOfWeek(DateTime.now().toUtc());
    const weekCount = 8;

    Future.microtask(() => loadWeek(0));
    return PlanState(
      professional: arg,
      sessionsPerWeek: 1,
      sessionMinutes: 60,
      weekCount: weekCount,
      weeks: [
        for (var index = 0; index < weekCount; index++)
          PlanWeek(
            index: index,
            startsAt: start.add(Duration(days: 7 * index)),
            isLoading: index == 0,
          ),
      ],
    );
  }

  /// The booking calendar starts on Sunday in both languages.
  static DateTime _startOfWeek(DateTime day) {
    final midnight = DateTime.utc(day.year, day.month, day.day);
    return midnight.subtract(Duration(days: midnight.weekday % 7));
  }

  void setSessionsPerWeek(int value) =>
      state = state.copyWith(sessionsPerWeek: value);

  void setSessionMinutes(int value) =>
      state = state.copyWith(sessionMinutes: value);

  void setWeekCount(int value) {
    final start = _startOfWeek(DateTime.now().toUtc());
    state = state.copyWith(
      weekCount: value,
      weeks: [
        for (var index = 0; index < value; index++)
          index < state.weeks.length
              ? state.weeks[index]
              : PlanWeek(
                  index: index,
                  startsAt: start.add(Duration(days: 7 * index)),
                ),
      ],
      currentWeek: state.currentWeek.clamp(0, value - 1),
    );
  }

  Future<void> selectWeek(int index) async {
    state = state.copyWith(currentWeek: index);
    if (state.weeks[index].slots.isEmpty) await loadWeek(index);
  }

  Future<void> loadWeek(int index) async {
    _updateWeek(index, (week) => week.copyWith(
      isLoading: true,
      clearFailure: true,
    ));

    final week = state.weeks[index];
    try {
      final slots = await ref
          .read(peopleRepositoryProvider)
          .availability(
            professionalId: state.professional.id,
            from: week.startsAt,
            to: week.startsAt.add(const Duration(days: 7)),
          );
      _updateWeek(
        index,
        (current) => current.copyWith(slots: slots, isLoading: false),
      );
    } on Failure catch (failure) {
      _updateWeek(
        index,
        (current) => current.copyWith(isLoading: false, failure: failure),
      );
    }
  }

  /// Places or removes a time in the current week.
  void toggleSlot(AvailabilitySlot slot) {
    if (!slot.isAvailable) return;
    final index = state.currentWeek;
    final week = state.weeks[index];

    final chosen = week.chosen.toList();
    final existing = chosen.indexWhere((s) => s.startsAt == slot.startsAt);
    if (existing >= 0) {
      chosen.removeAt(existing);
    } else {
      if (chosen.length >= state.sessionsPerWeek) chosen.removeAt(0);
      chosen.add(slot);
    }

    _updateWeek(
      index,
      (current) => current.copyWith(chosen: chosen, unfillable: false),
    );

    // Ticking a week advances to the next unfilled one, which is what the
    // stepper's rhythm is: fill, tick, advance.
    if (chosen.length >= state.sessionsPerWeek) _advance();
  }

  void _advance() {
    final next = state.weeks.indexWhere(
      (week) =>
          week.index > state.currentWeek &&
          !week.isComplete(state.sessionsPerWeek),
    );
    if (next >= 0) unawaited(selectWeek(next));
  }

  /// "Same time every week" — copies week one forward.
  ///
  /// Weeks where the professional is not free at that time are **reported**,
  /// not silently skipped: a plan that quietly lost three of its eight sessions
  /// is worse than one that says which three need a different time.
  Future<void> copyFirstWeekForward() async {
    final template = state.weeks.first.chosen;
    if (template.isEmpty) return;

    for (var index = 1; index < state.weekCount; index++) {
      if (state.weeks[index].slots.isEmpty) await loadWeek(index);
      final week = state.weeks[index];

      final matched = <AvailabilitySlot>[];
      for (final wanted in template) {
        final match = week.slots
            .where(
              (slot) =>
                  slot.isAvailable &&
                  _sameWeekdayAndTime(slot.startsAt, wanted.startsAt),
            )
            .firstOrNull;
        if (match != null) matched.add(match);
      }

      _updateWeek(
        index,
        (current) => current.copyWith(
          chosen: matched,
          unfillable: matched.length < template.length,
        ),
      );
    }
  }

  static bool _sameWeekdayAndTime(DateTime a, DateTime b) =>
      a.weekday == b.weekday && a.hour == b.hour && a.minute == b.minute;

  void _updateWeek(int index, PlanWeek Function(PlanWeek) update) {
    state = state.copyWith(
      weeks: [
        for (final week in state.weeks)
          week.index == index ? update(week) : week,
      ],
    );
  }
}
