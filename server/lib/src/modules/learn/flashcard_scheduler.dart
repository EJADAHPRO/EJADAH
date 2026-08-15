import 'package:ejadah_models/ejadah_models.dart';

/// One card's spacing state.
///
/// These are exactly the four columns `flashcard_states` carries, so a schedule
/// round-trips to the database without translation.
class FlashcardSchedule {
  const FlashcardSchedule({
    required this.intervalDays,
    required this.repetitions,
    required this.ease,
    required this.dueOn,
  });

  /// The state of a card that has never been reviewed: due immediately.
  factory FlashcardSchedule.fresh(DateTime today) => FlashcardSchedule(
    intervalDays: 0,
    repetitions: 0,
    ease: FlashcardScheduler.startingEase,
    dueOn: FlashcardScheduler.dateOnly(today),
  );

  /// Days until the card is due again. Zero means "still in this session".
  final int intervalDays;

  /// Consecutive successful recalls. Reset to zero by an "again".
  final int repetitions;

  /// The easiness factor. Bounded to [FlashcardScheduler.minimumEase] …
  /// [FlashcardScheduler.startingEase].
  final double ease;

  /// Midnight UTC on the day the card next comes up.
  final DateTime dueOn;

  bool isDueOn(DateTime day) =>
      !dueOn.isAfter(FlashcardScheduler.dateOnly(day));

  @override
  String toString() =>
      'FlashcardSchedule(interval: $intervalDays, repetitions: $repetitions, '
      'ease: ${ease.toStringAsFixed(2)}, due: ${dueOn.toIso8601String()})';
}

/// Deterministic spaced repetition.
///
/// SM-2 in shape — first success in a day, second in six, then multiply by the
/// card's own easiness — with two deliberate departures:
///
/// * **The outcome is binary.** The UI offers "Again" and "Got it", not a
///   five-point self-grade, because a dentist revising between patients will
///   not calibrate a 0–5 scale honestly. Ease therefore moves by a fixed step
///   rather than by SM-2's quality polynomial.
/// * **Ease is capped at its starting value.** Unbounded ease compounds into
///   multi-year intervals that quietly stop being revision at all. A card can
///   lose ease by being forgotten and earn it back, and no further.
///
/// The whole thing is a pure function of its inputs: no clock, no database, no
/// randomness. That is what makes a "mastery percentage" impossible to sneak in
/// and what lets `learn_scheduler_test.dart` pin the behaviour exactly.
abstract final class FlashcardScheduler {
  /// The ease a new card starts at, and the ceiling it can return to.
  static const double startingEase = 2.50;

  /// The floor. A card that keeps being forgotten stops getting harder to
  /// schedule and simply comes back often.
  static const double minimumEase = 1.30;

  /// Taken off ease by an "again", added back by a "got it".
  static const double easeStep = 0.20;
  static const double easeRecovery = 0.10;

  /// The first two successes are fixed, as in SM-2.
  static const int firstIntervalDays = 1;
  static const int secondIntervalDays = 6;

  /// No card waits longer than a year. Beyond that the schedule has stopped
  /// being revision and become storage.
  static const int maximumIntervalDays = 365;

  /// The next state of [current] after [outcome] was recorded on [today].
  ///
  /// [today] is passed in rather than read from the clock so the caller owns
  /// the notion of "now" and the function stays testable.
  static FlashcardSchedule next({
    required FlashcardSchedule current,
    required ReviewOutcome outcome,
    required DateTime today,
  }) {
    final day = dateOnly(today);

    if (outcome == ReviewOutcome.again) {
      // A forgotten card returns to the front of the queue: same session, not
      // tomorrow. Repetitions reset, because the streak genuinely ended.
      return FlashcardSchedule(
        intervalDays: 0,
        repetitions: 0,
        ease: _clampEase(current.ease - easeStep),
        dueOn: day,
      );
    }

    final repetitions = current.repetitions + 1;
    final ease = _clampEase(current.ease + easeRecovery);
    final interval = switch (repetitions) {
      1 => firstIntervalDays,
      2 => secondIntervalDays,
      // Growth is driven by the ease the card earned, not by a constant.
      _ => _grow(current.intervalDays, ease),
    };

    return FlashcardSchedule(
      intervalDays: interval,
      repetitions: repetitions,
      ease: ease,
      dueOn: day.add(Duration(days: interval)),
    );
  }

  /// Midnight UTC of [value]'s day. `due_on` is a `date`, so the time part
  /// would otherwise make an equality comparison depend on when a review
  /// happened to be submitted.
  static DateTime dateOnly(DateTime value) {
    final utc = value.toUtc();
    return DateTime.utc(utc.year, utc.month, utc.day);
  }

  static int _grow(int previousInterval, double ease) {
    // A card that lapsed has interval 0; the next success restarts the ladder
    // rather than multiplying zero forever.
    final base = previousInterval < firstIntervalDays
        ? secondIntervalDays
        : previousInterval;
    final grown = (base * ease).round();
    return grown > maximumIntervalDays ? maximumIntervalDays : grown;
  }

  /// Rounded to two decimals because the column is `numeric(4,2)`: keeping the
  /// in-memory value at the stored precision is what makes a round-trip
  /// through the database produce the same next interval.
  static double _clampEase(double value) {
    final bounded = value < minimumEase
        ? minimumEase
        : (value > startingEase ? startingEase : value);
    return (bounded * 100).roundToDouble() / 100;
  }
}
