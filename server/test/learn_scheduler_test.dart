import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_server/src/modules/learn/flashcard_scheduler.dart';
import 'package:test/test.dart';

/// The flashcard scheduler.
///
/// This is the one piece of Learn that must be provably deterministic: the
/// brief forbids a random "mastery" percentage, and a user who reviews the same
/// card the same way twice must get the same next date both times. The
/// scheduler takes no clock and touches no database precisely so that claim can
/// be tested rather than asserted.
void main() {
  final monday = DateTime.utc(2026, 8, 17);

  FlashcardSchedule review(
    FlashcardSchedule from,
    ReviewOutcome outcome, {
    DateTime? on,
  }) => FlashcardScheduler.next(
    current: from,
    outcome: outcome,
    today: on ?? monday,
  );

  group('determinism', () {
    test('the same inputs always produce the same schedule', () {
      final start = FlashcardSchedule.fresh(monday);

      // Two hundred independent runs, not two: a stray random source shows up
      // as a single divergence somewhere in the middle, not on the second call.
      final first = review(start, ReviewOutcome.gotIt);
      for (var i = 0; i < 200; i++) {
        final again = review(start, ReviewOutcome.gotIt);
        expect(again.intervalDays, first.intervalDays);
        expect(again.repetitions, first.repetitions);
        expect(again.ease, first.ease);
        expect(again.dueOn, first.dueOn);
      }
    });

    test('two identical histories end in the same state', () {
      const outcomes = [
        ReviewOutcome.gotIt,
        ReviewOutcome.gotIt,
        ReviewOutcome.again,
        ReviewOutcome.gotIt,
        ReviewOutcome.gotIt,
        ReviewOutcome.gotIt,
      ];

      FlashcardSchedule replay() {
        var state = FlashcardSchedule.fresh(monday);
        var day = monday;
        for (final outcome in outcomes) {
          state = review(state, outcome, on: day);
          day = state.dueOn;
        }
        return state;
      }

      final a = replay();
      final b = replay();
      expect(a.intervalDays, b.intervalDays);
      expect(a.repetitions, b.repetitions);
      expect(a.ease, b.ease);
      expect(a.dueOn, b.dueOn);
    });

    test(
      'the time of day a review is submitted does not change the result',
      () {
        final start = FlashcardSchedule.fresh(monday);
        final morning = review(
          start,
          ReviewOutcome.gotIt,
          on: DateTime.utc(2026, 8, 17, 6, 15),
        );
        final midnight = review(
          start,
          ReviewOutcome.gotIt,
          on: DateTime.utc(2026, 8, 17, 23, 59, 59),
        );
        expect(morning.dueOn, midnight.dueOn);
        expect(morning.intervalDays, midnight.intervalDays);
      },
    );
  });

  group('interval growth', () {
    test('the first two successes are one day and six days', () {
      final first = review(
        FlashcardSchedule.fresh(monday),
        ReviewOutcome.gotIt,
      );
      expect(first.repetitions, 1);
      expect(first.intervalDays, 1);
      expect(first.dueOn, monday.add(const Duration(days: 1)));

      final second = review(first, ReviewOutcome.gotIt, on: first.dueOn);
      expect(second.repetitions, 2);
      expect(second.intervalDays, 6);
      expect(second.dueOn, first.dueOn.add(const Duration(days: 6)));
    });

    test('later intervals multiply by the card\'s own ease', () {
      var state = FlashcardSchedule.fresh(monday);
      var day = monday;
      for (var i = 0; i < 2; i++) {
        state = review(state, ReviewOutcome.gotIt, on: day);
        day = state.dueOn;
      }

      // interval 6, ease 2.50 → 15 days.
      final third = review(state, ReviewOutcome.gotIt, on: day);
      expect(third.intervalDays, 15);
      expect(third.repetitions, 3);

      // 15 × 2.50 → 38 (rounded).
      final fourth = review(third, ReviewOutcome.gotIt, on: third.dueOn);
      expect(fourth.intervalDays, 38);
    });

    test('intervals only ever grow while the card is recalled', () {
      var state = FlashcardSchedule.fresh(monday);
      var day = monday;
      var previous = 0;

      for (var i = 0; i < 12; i++) {
        state = review(state, ReviewOutcome.gotIt, on: day);
        expect(
          state.intervalDays,
          greaterThanOrEqualTo(previous),
          reason: 'a recalled card must never come back sooner than before',
        );
        previous = state.intervalDays;
        day = state.dueOn;
      }
    });

    test('no card is ever scheduled more than a year out', () {
      var state = FlashcardSchedule.fresh(monday);
      var day = monday;
      for (var i = 0; i < 40; i++) {
        state = review(state, ReviewOutcome.gotIt, on: day);
        day = state.dueOn;
      }
      expect(state.intervalDays, FlashcardScheduler.maximumIntervalDays);
    });

    test('ease never rises above its starting value', () {
      var state = FlashcardSchedule.fresh(monday);
      var day = monday;
      for (var i = 0; i < 20; i++) {
        state = review(state, ReviewOutcome.gotIt, on: day);
        day = state.dueOn;
        expect(state.ease, lessThanOrEqualTo(FlashcardScheduler.startingEase));
      }
    });
  });

  group('"again" resets', () {
    test('a forgotten card returns to the same session', () {
      var state = FlashcardSchedule.fresh(monday);
      var day = monday;
      for (var i = 0; i < 4; i++) {
        state = review(state, ReviewOutcome.gotIt, on: day);
        day = state.dueOn;
      }
      expect(state.intervalDays, greaterThan(10));

      final lapsed = review(state, ReviewOutcome.again, on: day);
      expect(lapsed.intervalDays, 0);
      expect(lapsed.repetitions, 0);
      // Due today, not tomorrow: "Again" means show it to me again now.
      expect(lapsed.dueOn, FlashcardScheduler.dateOnly(day));
      expect(lapsed.isDueOn(day), isTrue);
    });

    test('a lapse costs ease, and recall earns it back slowly', () {
      final start = FlashcardSchedule.fresh(monday);
      expect(start.ease, FlashcardScheduler.startingEase);

      final lapsed = review(start, ReviewOutcome.again);
      expect(lapsed.ease, closeTo(2.30, 0.001));

      final recovering = review(lapsed, ReviewOutcome.gotIt);
      expect(recovering.ease, closeTo(2.40, 0.001));
    });

    test('ease has a floor, however often the card is forgotten', () {
      var state = FlashcardSchedule.fresh(monday);
      for (var i = 0; i < 50; i++) {
        state = review(state, ReviewOutcome.again);
      }
      expect(state.ease, FlashcardScheduler.minimumEase);
    });

    test('the ladder restarts after a lapse rather than multiplying zero', () {
      var state = FlashcardSchedule.fresh(monday);
      var day = monday;
      for (var i = 0; i < 3; i++) {
        state = review(state, ReviewOutcome.gotIt, on: day);
        day = state.dueOn;
      }

      final lapsed = review(state, ReviewOutcome.again, on: day);
      final first = review(lapsed, ReviewOutcome.gotIt, on: day);
      expect(first.intervalDays, 1);

      final second = review(first, ReviewOutcome.gotIt, on: first.dueOn);
      expect(second.intervalDays, 6);

      // The third success multiplies from six, never from the zero the lapse
      // left behind.
      final third = review(second, ReviewOutcome.gotIt, on: second.dueOn);
      expect(third.intervalDays, greaterThan(6));
    });

    test('a card is never scheduled into the past', () {
      var state = FlashcardSchedule.fresh(monday);
      var day = monday;
      for (final outcome in [
        ReviewOutcome.gotIt,
        ReviewOutcome.again,
        ReviewOutcome.gotIt,
        ReviewOutcome.again,
        ReviewOutcome.gotIt,
      ]) {
        state = review(state, outcome, on: day);
        expect(state.dueOn.isBefore(FlashcardScheduler.dateOnly(day)), isFalse);
        day = state.dueOn;
      }
    });
  });

  test('a fresh card is due immediately', () {
    final fresh = FlashcardSchedule.fresh(DateTime.utc(2026, 8, 17, 13, 45));
    expect(fresh.dueOn, monday);
    expect(fresh.isDueOn(monday), isTrue);
    expect(fresh.repetitions, 0);
    expect(fresh.intervalDays, 0);
  });
}
