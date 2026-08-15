import 'dart:async';

import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../data/learn_models.dart';
import '../data/learn_repository.dart';

/// The catalogue, optionally narrowed to one department.
///
/// `null` asks for everything, which is what the hub needs in order to quote a
/// count on each department card.
final catalogueProvider = FutureProvider.family<Catalogue, Department?>(
  (ref, department) =>
      ref.watch(learnRepositoryProvider).catalogue(department: department),
);

/// One course with its lessons, handouts, decks and quizzes.
///
/// Invalidate it after a purchase or a completed lesson so the screen re-reads
/// ownership and progress from the server rather than patching them locally.
final courseDetailProvider = FutureProvider.family<CourseDetail, String>(
  (ref, slug) => ref.watch(learnRepositoryProvider).course(slug),
);

/// The course list's format filter.
///
/// Filters survive a relaunch, the same as the Career database's and each
/// People door's. Re-applying them by hand on every visit is friction the
/// design removes deliberately, and a filter that forgets overnight is the
/// version of that friction people notice most.
final courseFilterProvider =
    NotifierProvider<CourseFilterController, Set<String>>(
      CourseFilterController.new,
    );

class CourseFilterController extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    // Restored asynchronously, so the list paints immediately with nothing
    // filtered and narrows a frame later. The alternative — holding the list
    // back until storage answers — trades a correct first frame for a blank
    // one, which is the worse of the two.
    Future.microtask(_restore);
    return const {};
  }

  Future<void> _restore() async {
    final stored = await ref.read(localStoreProvider).courseFilters();
    if (stored != null && stored.isNotEmpty) state = stored;
  }

  /// Selections are toggles: with none selected the list shows everything,
  /// which is why there is no separate "All" chip to keep in sync.
  void toggle(String level) {
    state = state.contains(level)
        ? (state.toSet()..remove(level))
        : (state.toSet()..add(level));
    _persist();
  }

  void clear() {
    state = const {};
    _persist();
  }

  /// Best-effort: a filter that fails to save is not worth an error state on a
  /// course list.
  void _persist() {
    unawaited(ref.read(localStoreProvider).saveCourseFilters(state));
  }

  List<Course> apply(List<Course> courses) => state.isEmpty
      ? courses
      : courses.where((course) => state.contains(course.level.en)).toList();
}

// ---------------------------------------------------------------------------
// Playback
// ---------------------------------------------------------------------------

/// The rules that make playback resumable.
///
/// Two numbers matter and both live here rather than in the player widget, so
/// they can be reasoned about in one place:
///
/// * position is written about every five seconds, so a killed app loses at
///   most five seconds of progress;
/// * resuming lands within ten seconds of where the user stopped — a short
///   rewind for context, never a jump forward.
class PlaybackRecorder {
  PlaybackRecorder({
    required this.repository,
    required this.lessonId,
    this.saveInterval = const Duration(seconds: 5),
    this.contextRewind = const Duration(seconds: 5),
    this.resumeTolerance = const Duration(seconds: 10),
  }) : assert(
         contextRewind <= resumeTolerance,
         'a rewind longer than the tolerance would break the resume rule',
       );

  final LearnRepository repository;
  final int lessonId;
  final Duration saveInterval;
  final Duration contextRewind;
  final Duration resumeTolerance;

  int _lastSavedAt = -1;

  /// Where the player starts, given the stored position.
  ///
  /// A few seconds of run-up makes the resume comprehensible; more than ten
  /// would stop being a resume.
  int resumeFrom(int storedPosition) {
    if (storedPosition <= contextRewind.inSeconds) return 0;
    return storedPosition - contextRewind.inSeconds;
  }

  /// Whether [position] is far enough from the last write to justify another.
  bool isDueToSave(int position) =>
      _lastSavedAt < 0 ||
      (position - _lastSavedAt).abs() >= saveInterval.inSeconds;

  /// Writes the position, swallowing a network failure.
  ///
  /// Losing one five-second checkpoint is invisible; interrupting playback with
  /// an error toast for it is not. A failure that matters — completing the
  /// lesson — is surfaced by its own call.
  Future<void> save(int position) async {
    if (!isDueToSave(position)) return;
    _lastSavedAt = position;
    try {
      await repository.saveProgress(lessonId, position);
    } on Failure {
      // Allow the next tick to try again.
      _lastSavedAt = -1;
    }
  }

  /// Forces a write — used when the player is closed or backgrounded.
  Future<void> flush(int position) async {
    _lastSavedAt = -1;
    await save(position);
  }
}

final playbackRecorderProvider = Provider.family<PlaybackRecorder, int>(
  (ref, lessonId) => PlaybackRecorder(
    repository: ref.watch(learnRepositoryProvider),
    lessonId: lessonId,
  ),
);

// ---------------------------------------------------------------------------
// Flashcards
// ---------------------------------------------------------------------------

sealed class FlashcardSessionState {
  const FlashcardSessionState();
}

class FlashcardsLoading extends FlashcardSessionState {
  const FlashcardsLoading();
}

class FlashcardsFailed extends FlashcardSessionState {
  const FlashcardsFailed(this.failure);

  final Failure failure;
}

/// Cards are due and one is on screen.
class FlashcardsStudying extends FlashcardSessionState {
  const FlashcardsStudying({
    required this.deck,
    required this.cards,
    required this.index,
    required this.isFlipped,
    required this.againCount,
    required this.gotItCount,
    required this.remainingDue,
    this.isRecording = false,
  });

  final FlashcardDeck deck;
  final List<Flashcard> cards;
  final int index;

  /// The back is showing. Tapping flips; there is no separate reveal button.
  final bool isFlipped;
  final int againCount;
  final int gotItCount;

  /// Live from the server after each review, not counted down locally.
  final int remainingDue;
  final bool isRecording;

  Flashcard get card => cards[index];

  int get position => index + 1;

  FlashcardsStudying copyWith({
    int? index,
    bool? isFlipped,
    int? againCount,
    int? gotItCount,
    int? remainingDue,
    bool? isRecording,
  }) => FlashcardsStudying(
    deck: deck,
    cards: cards,
    index: index ?? this.index,
    isFlipped: isFlipped ?? this.isFlipped,
    againCount: againCount ?? this.againCount,
    gotItCount: gotItCount ?? this.gotItCount,
    remainingDue: remainingDue ?? this.remainingDue,
    isRecording: isRecording ?? this.isRecording,
  );
}

/// The session finished — either nothing was due, or every due card was seen.
class FlashcardsFinished extends FlashcardSessionState {
  const FlashcardsFinished({
    required this.deck,
    required this.againCount,
    required this.gotItCount,
    required this.remainingDue,
  });

  final FlashcardDeck deck;
  final int againCount;
  final int gotItCount;
  final int remainingDue;

  bool get reviewedNothing => againCount + gotItCount == 0;
}

final flashcardSessionProvider = NotifierProvider.autoDispose
    .family<FlashcardSessionController, FlashcardSessionState, int>(
      FlashcardSessionController.new,
    );

/// One study session over a deck's due queue.
///
/// "Again" and "Got it" are the only two outcomes, and each is recorded on the
/// server before the next card appears — the schedule is the product, so it is
/// never left on the device to be reconciled later.
class FlashcardSessionController
    extends AutoDisposeFamilyNotifier<FlashcardSessionState, int> {
  DateTime? _startedAt;

  @override
  FlashcardSessionState build(int deckId) {
    Future.microtask(load);
    return const FlashcardsLoading();
  }

  Future<void> load() async {
    state = const FlashcardsLoading();
    _startedAt = DateTime.now().toUtc();
    try {
      final queue = await ref.read(learnRepositoryProvider).dueCards(arg);
      state = queue.cards.isEmpty
          ? FlashcardsFinished(
              deck: queue.deck,
              againCount: 0,
              gotItCount: 0,
              remainingDue: queue.dueCount,
            )
          : FlashcardsStudying(
              deck: queue.deck,
              cards: queue.cards,
              index: 0,
              isFlipped: false,
              againCount: 0,
              gotItCount: 0,
              remainingDue: queue.dueCount,
            );
    } on Failure catch (failure) {
      state = FlashcardsFailed(failure);
    }
  }

  void flip() {
    final current = state;
    if (current is! FlashcardsStudying) return;
    state = current.copyWith(isFlipped: !current.isFlipped);
  }

  /// Records the outcome and moves on.
  ///
  /// The card is not removed from the local queue on "again": the server has
  /// scheduled it for today, and the session ends when the queue it was handed
  /// is exhausted.
  Future<void> answer(ReviewOutcome outcome) async {
    final current = state;
    if (current is! FlashcardsStudying || current.isRecording) return;

    state = current.copyWith(isRecording: true);
    try {
      final result = await ref
          .read(learnRepositoryProvider)
          .review(current.card.id, outcome, sessionStartedAt: _startedAt);

      final isLast = current.index + 1 >= current.cards.length;
      if (isLast) {
        state = FlashcardsFinished(
          deck: current.deck,
          againCount: result.againCount,
          gotItCount: result.gotItCount,
          remainingDue: result.remainingDue,
        );
      } else {
        state = current.copyWith(
          index: current.index + 1,
          isFlipped: false,
          againCount: result.againCount,
          gotItCount: result.gotItCount,
          remainingDue: result.remainingDue,
          isRecording: false,
        );
      }
    } on Failure catch (failure) {
      state = FlashcardsFailed(failure);
    }
  }
}

// ---------------------------------------------------------------------------
// Quiz
// ---------------------------------------------------------------------------

sealed class QuizState {
  const QuizState();
}

class QuizLoading extends QuizState {
  const QuizLoading();
}

class QuizFailed extends QuizState {
  const QuizFailed(this.failure);

  final Failure failure;
}

/// The user is answering. No option carries a correctness flag at this point,
/// because the server has not sent one.
class QuizAnswering extends QuizState {
  const QuizAnswering({
    required this.paper,
    required this.index,
    required this.answers,
    this.isSubmitting = false,
  });

  final QuizPaper paper;
  final int index;

  /// Question id → chosen option id. A question may be left out.
  final Map<int, int?> answers;
  final bool isSubmitting;

  QuizQuestion get question => paper.questions[index];

  int get position => index + 1;

  int get total => paper.questions.length;

  bool get isLast => index + 1 >= total;

  int? get selected => answers[question.id];

  QuizAnswering copyWith({
    int? index,
    Map<int, int?>? answers,
    bool? isSubmitting,
  }) => QuizAnswering(
    paper: paper,
    index: index ?? this.index,
    answers: answers ?? this.answers,
    isSubmitting: isSubmitting ?? this.isSubmitting,
  );
}

/// Graded. The per-question feedback is walked first, then the score — the
/// explanation is the reason the quiz exists, so it is not skippable scenery
/// behind a percentage.
class QuizReviewing extends QuizState {
  const QuizReviewing({
    required this.paper,
    required this.graded,
    required this.index,
  });

  final QuizPaper paper;
  final GradedAttempt graded;
  final int index;

  GradedQuestion get question => graded.questions[index];

  int get position => index + 1;

  int get total => graded.questions.length;

  bool get isLast => index + 1 >= total;
}

class QuizScored extends QuizState {
  const QuizScored({required this.paper, required this.graded});

  final QuizPaper paper;
  final GradedAttempt graded;
}

final quizControllerProvider = NotifierProvider.autoDispose
    .family<QuizController, QuizState, int>(QuizController.new);

/// One pass through a quiz.
///
/// Grading is a server call, always. Nothing here compares an answer to a key,
/// because the client never has one.
class QuizController extends AutoDisposeFamilyNotifier<QuizState, int> {
  @override
  QuizState build(int quizId) {
    Future.microtask(load);
    return const QuizLoading();
  }

  Future<void> load() async {
    state = const QuizLoading();
    try {
      final paper = await ref.read(learnRepositoryProvider).quiz(arg);
      state = QuizAnswering(paper: paper, index: 0, answers: const {});
    } on Failure catch (failure) {
      state = QuizFailed(failure);
    }
  }

  void choose(int optionId) {
    final current = state;
    if (current is! QuizAnswering || current.isSubmitting) return;
    state = current.copyWith(
      answers: {...current.answers, current.question.id: optionId},
    );
  }

  void next() {
    final current = state;
    if (current is! QuizAnswering || current.isLast) return;
    state = current.copyWith(index: current.index + 1);
  }

  void previous() {
    final current = state;
    if (current is! QuizAnswering || current.index == 0) return;
    state = current.copyWith(index: current.index - 1);
  }

  Future<void> submit() async {
    final current = state;
    if (current is! QuizAnswering || current.isSubmitting) return;

    state = current.copyWith(isSubmitting: true);
    try {
      final graded = await ref.read(learnRepositoryProvider).submitAttempt(
        current.paper.id,
        {
          // Every question is sent, skipped ones included, so the stored
          // attempt is a complete record.
          for (final question in current.paper.questions)
            question.id: current.answers[question.id],
        },
      );
      state = QuizReviewing(paper: current.paper, graded: graded, index: 0);
    } on Failure catch (failure) {
      state = QuizFailed(failure);
    }
  }

  void nextFeedback() {
    final current = state;
    if (current is! QuizReviewing) return;
    state = current.isLast
        ? QuizScored(paper: current.paper, graded: current.graded)
        : QuizReviewing(
            paper: current.paper,
            graded: current.graded,
            index: current.index + 1,
          );
  }

  /// A retake is never blocked, whatever the score.
  Future<void> retake() => load();
}
