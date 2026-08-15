import 'dart:convert';
import 'dart:io';

import 'package:ejadah_models/ejadah_models.dart';

import '../../config/config.dart';
import '../../http/api_error.dart';
import 'flashcard_scheduler.dart';
import 'learn_repository.dart';

/// Everything the Learn tab needs about one course, in one read.
///
/// The course detail screen shows the curriculum, the handouts, the decks and
/// the quiz at once; assembling that here rather than making the client fan out
/// four requests is what keeps the screen's loading state a single skeleton.
class CourseDetail {
  const CourseDetail({
    required this.course,
    required this.lessons,
    required this.handouts,
    required this.decks,
    required this.quizzes,
    required this.progress,
  });

  final Course course;
  final List<Lesson> lessons;
  final List<Handout> handouts;
  final List<FlashcardDeck> decks;
  final List<QuizHeader> quizzes;

  /// Null for a guest: there is no progress without an account.
  final CourseProgress? progress;

  /// Where "Resume" goes: the first unfinished lesson the user may open.
  Lesson? get resumeLesson {
    for (final lesson in lessons) {
      if (!lesson.isComplete && lesson.isUnlocked) return lesson;
    }
    return lessons.where((lesson) => lesson.isUnlocked).firstOrNull;
  }

  Map<String, dynamic> toJson() => {
    'course': course.toJson(),
    'lessons': lessons.map((lesson) => lesson.toJson()).toList(),
    'handouts': handouts.map((handout) => handout.toJson()).toList(),
    'decks': decks.map((deck) => deck.toJson()).toList(),
    'quizzes': quizzes
        .map(
          (quiz) => {
            'id': quiz.id,
            'course_id': quiz.courseId,
            'title': quiz.title.toJson(),
            'pass_mark': quiz.passMark,
          },
        )
        .toList(),
    'progress': progress?.toJson(),
    'resume_lesson_id': resumeLesson?.id,
  };
}

/// The result of grading one attempt.
///
/// The answer key travels only in this direction: it is built *after* the
/// attempt is stored, never before it is submitted.
class GradedAttempt {
  const GradedAttempt({
    required this.attempt,
    required this.questions,
    required this.passMark,
  });

  final QuizAttempt attempt;
  final List<Map<String, dynamic>> questions;
  final int passMark;

  bool get passed => attempt.scorePercent >= passMark;

  Map<String, dynamic> toJson() => {
    'attempt': attempt.toJson(),
    'pass_mark': passMark,
    'passed': passed,
    // Below 60% the result offers ONE session on the topic. It never offers a
    // package, and it never blocks a retake.
    'offers_session':
        attempt.scorePercent < LearnService.sessionOfferThresholdPercent,
    'questions': questions,
  };
}

/// What a single flashcard review changed.
class ReviewResult {
  const ReviewResult({
    required this.schedule,
    required this.remainingDue,
    required this.againCount,
    required this.gotItCount,
  });

  final FlashcardSchedule schedule;

  /// Live count for the session header — read from the database, not counted
  /// down by the client.
  final int remainingDue;
  final int againCount;
  final int gotItCount;

  Map<String, dynamic> toJson() => {
    'interval_days': schedule.intervalDays,
    'repetitions': schedule.repetitions,
    'ease': schedule.ease,
    'due_on': schedule.dueOn.toIso8601String(),
    'remaining_due': remainingDue,
    'again_count': againCount,
    'got_it_count': gotItCount,
  };
}

/// Learn use-cases: the catalogue, playback position, spacing and grading.
class LearnService {
  LearnService({
    required LearnRepository repository,
    required AppConfig config,
    DateTime Function()? clock,
  }) : _repository = repository,
       _config = config,
       _now = clock ?? (() => DateTime.now().toUtc());

  final LearnRepository _repository;
  final AppConfig _config;
  final DateTime Function() _now;

  /// Below this, the quiz result offers one session on the topic.
  ///
  /// Fixed at 60 by the brief, independently of a quiz's own `pass_mark`: the
  /// offer is about the user needing help, not about a certificate threshold.
  static const int sessionOfferThresholdPercent = 60;

  /// How many cards one session hands out before it stops. A queue longer than
  /// this stops being a study session and becomes a chore.
  static const int maximumDueCards = 40;

  // --- Catalogue ------------------------------------------------------------

  Future<Map<String, dynamic>> catalogue({
    Department? department,
    String? userId,
  }) async {
    final courses = await _repository.listCourses(
      department: department,
      userId: userId,
    );
    final counts = await _repository.courseCountsByDepartment();

    return {
      'items': courses.map((course) => course.toJson()).toList(),
      'total': courses.length,
      'departments': [
        for (final value in Department.values)
          {'department': value.wire, 'course_count': counts[value] ?? 0},
      ],
    };
  }

  Future<CourseDetail> courseBySlug(String slug, {String? userId}) async {
    final course = await _repository.findCourseBySlug(slug, userId: userId);
    if (course == null) throw ApiException.notFound();
    return _detail(course, userId: userId);
  }

  Future<CourseDetail> courseById(int id, {String? userId}) async {
    final course = await _repository.findCourseById(id, userId: userId);
    if (course == null) throw ApiException.notFound();
    return _detail(course, userId: userId);
  }

  Future<CourseDetail> _detail(Course course, {String? userId}) async {
    final lessons = await _repository.lessonsForCourse(
      course.id,
      userId: userId,
      isOwned: course.isOwned,
    );
    return CourseDetail(
      course: course,
      lessons: lessons,
      handouts: await _repository.handoutsForCourse(course.id),
      decks: await _repository.decksForCourse(
        course.id,
        userId: userId,
        today: _now(),
      ),
      quizzes: await _repository.quizzesForCourse(course.id),
      progress: userId == null
          ? null
          : await _repository.courseProgress(
              userId: userId,
              courseId: course.id,
            ),
    );
  }

  /// The lesson list on its own — the player's sidebar and the curriculum tab.
  Future<List<Lesson>> lessons(int courseId, {String? userId}) async {
    final course = await _repository.findCourseById(courseId, userId: userId);
    if (course == null) throw ApiException.notFound();
    return _repository.lessonsForCourse(
      courseId,
      userId: userId,
      isOwned: course.isOwned,
    );
  }

  // --- Playback -------------------------------------------------------------

  /// Saves where the user stopped, roughly every five seconds of playback.
  ///
  /// The position is clamped to the lesson's own duration: a client whose clock
  /// or player misreports must not be able to store a position the video does
  /// not contain, or "Resume" would land past the end.
  Future<Lesson> saveProgress({
    required String userId,
    required int lessonId,
    required int positionSeconds,
  }) async {
    final found = await _repository.findLesson(lessonId, userId: userId);
    if (found == null) throw ApiException.notFound();
    if (!found.lesson.isUnlocked) throw ApiException.authorization();
    if (positionSeconds < 0) {
      throw ApiException(
        ApiErrorCode.validation,
        details: 'position_seconds must not be negative.',
      );
    }

    final duration = found.lesson.durationSeconds;
    final clamped = duration > 0 && positionSeconds > duration
        ? duration
        : positionSeconds;

    await _repository.saveProgress(
      userId: userId,
      lessonId: lessonId,
      positionSeconds: clamped,
    );
    // Watching a free preview enrols the user; the course then shows up under
    // "My learning" without a purchase, which is what the preview is for.
    await _repository.ensureEnrollment(
      userId: userId,
      courseId: found.courseId,
    );

    final refreshed = await _repository.findLesson(lessonId, userId: userId);
    return refreshed!.lesson;
  }

  /// Marks a lesson complete and reports what comes next.
  ///
  /// The next lesson is chosen here, not by the client, so the five-second
  /// auto-advance cannot skip into something the user does not own.
  Future<Map<String, dynamic>> completeLesson({
    required String userId,
    required int lessonId,
    int? positionSeconds,
  }) async {
    final found = await _repository.findLesson(lessonId, userId: userId);
    if (found == null) throw ApiException.notFound();
    if (!found.lesson.isUnlocked) throw ApiException.authorization();

    await _repository.completeLesson(
      userId: userId,
      lessonId: lessonId,
      positionSeconds: positionSeconds ?? found.lesson.durationSeconds,
    );
    await _repository.ensureEnrollment(
      userId: userId,
      courseId: found.courseId,
    );

    final progress = await _repository.refreshCourseCompletion(
      userId: userId,
      courseId: found.courseId,
    );
    final lessons = await _repository.lessonsForCourse(
      found.courseId,
      userId: userId,
      isOwned: found.isOwned,
    );
    final next = lessons
        .where(
          (lesson) =>
              lesson.position > found.lesson.position && lesson.isUnlocked,
        )
        .firstOrNull;

    return {
      'lesson_id': lessonId,
      'course_id': found.courseId,
      'progress': progress.toJson(),
      'next_lesson': next?.toJson(),
      'course_complete': progress.isComplete,
    };
  }

  // --- Handouts -------------------------------------------------------------

  Future<List<Handout>> handouts({
    required String userId,
    required int courseId,
  }) async {
    await _requireOwnership(userId: userId, courseId: courseId);
    return _repository.handoutsForCourse(courseId);
  }

  /// One handout's bytes, base64 encoded.
  ///
  /// Entitlement is checked here as well as on the list, because a handout id
  /// is guessable and the list is not the only way to reach one. A missing file
  /// is a plain not-found rather than an empty document.
  Future<Map<String, dynamic>> handoutFile({
    required String userId,
    required int handoutId,
  }) async {
    final handout = await _repository.findHandout(handoutId);
    if (handout == null) throw ApiException.notFound();
    await _requireOwnership(userId: userId, courseId: handout.courseId);

    final file = File('${_config.storageRoot}/${handout.storageKey}');
    if (!file.existsSync()) throw ApiException.notFound();

    final bytes = await file.readAsBytes();
    return {
      ...handout.toJson(),
      'bytes': bytes.length,
      'content_base64': base64Encode(bytes),
    };
  }

  // --- Entitlements ---------------------------------------------------------

  /// Records ownership of a course.
  ///
  /// Courses are digital content and therefore in-app purchase only (Apple
  /// §3.1.1): there is no external checkout for a course anywhere in this
  /// product, and the server holds no course price — the store is the pricing
  /// authority.
  ///
  /// Two sources are accepted, and neither of them is "the client said so":
  ///
  /// * `dev` — the development payment simulator. Refused outside development
  ///   and test, exactly like the demo accounts.
  /// * `iap` — a store receipt, which must be verified with Apple or Google
  ///   before it grants anything. That verification is not wired up yet, so
  ///   this path deliberately fails rather than trusting the receipt.
  Future<Map<String, dynamic>> grantEntitlement({
    required String userId,
    required int courseId,
    required String source,
    String? receipt,
  }) async {
    final course = await _repository.findCourseById(courseId, userId: userId);
    if (course == null) throw ApiException.notFound();

    if (course.isOwned) {
      // Already owned: restoring or re-purchasing is a no-op, not a failure.
      return {'course': course.toJson(), 'granted': false};
    }

    switch (source) {
      case 'dev':
        if (!_config.environment.allowsDevelopmentAffordances) {
          throw ApiException(
            ApiErrorCode.authorization,
            details:
                'The development payment simulator cannot grant entitlements '
                'outside development or test.',
          );
        }
        await _repository.grantEntitlement(
          userId: userId,
          courseId: courseId,
          source: 'dev',
          // Scoped to the user so the simulator cannot collide across accounts,
          // and stable so re-running it is idempotent.
          externalRef: 'dev:$userId:$courseId',
        );

      case 'iap':
        final reference = receipt?.trim();
        if (reference == null || reference.isEmpty) {
          throw ApiException(
            ApiErrorCode.validation,
            details: 'An in-app purchase needs a store transaction reference.',
          );
        }
        final existingOwner = await _repository.receiptOwner(reference);
        if (existingOwner != null && existingOwner != userId) {
          throw ApiException.conflict(message: ApiErrorCopy.generic);
        }
        if (!_config.environment.allowsDevelopmentAffordances) {
          // Verification with the store is the only thing that may grant a
          // paid entitlement, and it is not implemented. Granting on the
          // client's word would hand every course away for free.
          throw ApiException(
            ApiErrorCode.payment,
            details:
                'Store receipt verification is not configured. No entitlement '
                'was granted.',
          );
        }
        await _repository.grantEntitlement(
          userId: userId,
          courseId: courseId,
          source: 'iap',
          externalRef: reference,
        );

      default:
        throw ApiException(
          ApiErrorCode.validation,
          details: 'Unknown entitlement source "$source".',
        );
    }

    final granted = await _repository.findCourseById(courseId, userId: userId);
    return {'course': granted!.toJson(), 'granted': true};
  }

  /// "Restore purchases": the entitlements are server-side, so restoring on a
  /// new device is a read rather than a re-purchase.
  Future<Map<String, dynamic>> restore(String userId) async {
    final ids = await _repository.entitledCourseIds(userId);
    final courses = <Course>[];
    for (final id in ids) {
      final course = await _repository.findCourseById(id, userId: userId);
      if (course != null) courses.add(course);
    }
    return {
      'items': courses.map((course) => course.toJson()).toList(),
      'total': courses.length,
    };
  }

  // --- Flashcards -----------------------------------------------------------

  /// The cards due today in one deck.
  Future<Map<String, dynamic>> dueQueue({
    required String userId,
    required int deckId,
  }) async {
    final today = _now();
    final deck = await _repository.findDeck(
      deckId,
      userId: userId,
      today: today,
    );
    if (deck == null) throw ApiException.notFound();
    if (deck.courseId != null) {
      await _requireOwnership(userId: userId, courseId: deck.courseId!);
    }

    final cards = await _repository.dueCards(
      deckId: deckId,
      userId: userId,
      today: today,
      limit: maximumDueCards,
    );
    return {
      'deck': deck.toJson(),
      'items': cards.map((card) => card.toJson()).toList(),
      'due_count': deck.dueCount,
    };
  }

  /// Records one review and returns the card's new schedule.
  Future<ReviewResult> review({
    required String userId,
    required int flashcardId,
    required ReviewOutcome outcome,
    DateTime? sessionStartedAt,
  }) async {
    final today = _now();
    final state = await _repository.flashcardState(
      flashcardId: flashcardId,
      userId: userId,
      today: today,
    );
    if (state == null) throw ApiException.notFound();
    if (state.courseId != null) {
      await _requireOwnership(userId: userId, courseId: state.courseId!);
    }

    final next = FlashcardScheduler.next(
      current: state.schedule,
      outcome: outcome,
      today: today,
    );
    await _repository.recordReview(
      userId: userId,
      flashcardId: flashcardId,
      outcome: outcome,
      schedule: next,
    );

    final totals = await _repository.reviewTotalsSince(
      userId: userId,
      deckId: state.deckId,
      since: sessionStartedAt ?? today.subtract(const Duration(hours: 6)),
    );

    return ReviewResult(
      schedule: next,
      remainingDue: await _repository.dueCount(
        deckId: state.deckId,
        userId: userId,
        today: today,
      ),
      againCount: totals.again,
      gotItCount: totals.gotIt,
    );
  }

  // --- Quizzes --------------------------------------------------------------

  /// The quiz as the client is allowed to see it: prompts and options, with
  /// **no** `is_correct` and **no** explanation.
  ///
  /// Both are withheld, not just the flag: an explanation that reads "because
  /// the working length stops 1mm short" gives the answer away as surely as the
  /// key does.
  Future<Map<String, dynamic>> quizForClient({
    required String userId,
    required int quizId,
  }) async {
    final quiz = await _repository.findQuiz(quizId);
    if (quiz == null) throw ApiException.notFound();
    await _requireOwnership(userId: userId, courseId: quiz.courseId);

    final questions = await _repository.questionsWithKey(quizId);
    final best = await _repository.bestAttempt(userId: userId, quizId: quizId);

    return {
      'id': quiz.id,
      'course_id': quiz.courseId,
      'title': quiz.title.toJson(),
      'pass_mark': quiz.passMark,
      'question_count': questions.length,
      'questions': [
        for (final question in questions)
          {
            'id': question.id,
            'position': question.position,
            'prompt': question.prompt.toJson(),
            'options': [
              for (final option in question.options)
                {
                  'id': option.id,
                  'position': option.position,
                  'label': option.label.toJson(),
                },
            ],
          },
      ],
      'best_attempt': best?.toJson(),
    };
  }

  /// Grades an attempt on the server and stores it.
  ///
  /// Scoring never happens on the client. [answers] maps question id → chosen
  /// option id; a question the user skipped may be omitted and is marked wrong.
  Future<GradedAttempt> submitAttempt({
    required String userId,
    required int quizId,
    required Map<int, int?> answers,
  }) async {
    final quiz = await _repository.findQuiz(quizId);
    if (quiz == null) throw ApiException.notFound();
    await _requireOwnership(userId: userId, courseId: quiz.courseId);

    final questions = await _repository.questionsWithKey(quizId);
    if (questions.isEmpty) {
      throw ApiException(
        ApiErrorCode.validation,
        details: 'This quiz has no questions.',
      );
    }

    final questionIds = questions.map((question) => question.id).toSet();
    for (final id in answers.keys) {
      if (!questionIds.contains(id)) {
        throw ApiException(
          ApiErrorCode.validation,
          details: 'Question $id does not belong to quiz $quizId.',
        );
      }
    }

    final stored = <int, ({int? optionId, bool isCorrect})>{};
    final feedback = <Map<String, dynamic>>[];
    var correctCount = 0;

    for (final question in questions) {
      final chosen = answers[question.id];
      final optionIds = question.options.map((option) => option.id).toSet();
      if (chosen != null && !optionIds.contains(chosen)) {
        throw ApiException(
          ApiErrorCode.validation,
          details: 'Option $chosen does not belong to question ${question.id}.',
        );
      }

      final isCorrect =
          chosen != null &&
          question.options.any(
            (option) => option.id == chosen && option.isCorrect,
          );
      if (isCorrect) correctCount++;

      stored[question.id] = (optionId: chosen, isCorrect: isCorrect);
      feedback.add({
        'id': question.id,
        'position': question.position,
        'prompt': question.prompt.toJson(),
        // The explanation is the point of the quiz, and it is shown whether the
        // answer was right or wrong.
        'explanation': question.explanation.toJson(),
        'selected_option_id': chosen,
        'correct_option_id': question.correctOptionId,
        'is_correct': isCorrect,
        'options': [
          for (final option in question.options)
            {
              'id': option.id,
              'position': option.position,
              'label': option.label.toJson(),
              'is_correct': option.isCorrect,
            },
        ],
      });
    }

    // Integer percent, rounded — the screen quotes "{score}% — {correct} of
    // {total}", and the two halves must agree.
    final scorePercent = ((correctCount / questions.length) * 100).round();

    final attemptId = await _repository.recordAttempt(
      userId: userId,
      quizId: quizId,
      scorePercent: scorePercent,
      correctCount: correctCount,
      questionCount: questions.length,
      answers: stored,
    );

    return GradedAttempt(
      attempt: QuizAttempt(
        id: attemptId,
        quizId: quizId,
        scorePercent: scorePercent,
        correctCount: correctCount,
        questionCount: questions.length,
        submittedAt: _now(),
        results: {
          for (final entry in stored.entries) entry.key: entry.value.isCorrect,
        },
      ),
      questions: feedback,
      passMark: quiz.passMark,
    );
  }

  // --- Guards ---------------------------------------------------------------

  /// Handouts, decks and quizzes belong to people who own the course.
  ///
  /// Frontend visibility is never authorization, so the check lives here and
  /// every one of those routes goes through it.
  Future<void> _requireOwnership({
    required String userId,
    required int courseId,
  }) async {
    final owns = await _repository.hasEntitlement(
      userId: userId,
      courseId: courseId,
    );
    if (!owns) throw ApiException.authorization();
  }
}
