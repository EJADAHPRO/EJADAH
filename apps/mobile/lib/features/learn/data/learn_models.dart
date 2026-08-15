import 'package:ejadah_models/ejadah_models.dart';

/// Client-side shapes for the Learn payloads that have no model in
/// `ejadah_models` yet.
///
/// Course, Lesson, Flashcard, FlashcardDeck, QuizQuestion, QuizOption and
/// QuizAttempt all live in the shared package and are reused verbatim. What is
/// added here is only the envelopes around them — a course detail screen's
/// single read, a graded attempt's per-question feedback, a due queue — so
/// nothing is duplicated and no field is re-typed.

/// The catalogue plus the per-department counts the hub cards quote.
class Catalogue {
  const Catalogue({required this.courses, required this.counts});

  final List<Course> courses;
  final Map<Department, int> counts;

  int countFor(Department department) => counts[department] ?? 0;

  /// The distinct levels present, in catalogue order.
  ///
  /// The course list's filter is built from what the catalogue actually holds,
  /// so it can never offer a filter that matches nothing.
  List<LocalizedText> get levels {
    final seen = <String>{};
    final levels = <LocalizedText>[];
    for (final course in courses) {
      if (course.level.isNotEmpty && seen.add(course.level.en)) {
        levels.add(course.level);
      }
    }
    return levels;
  }

  static Catalogue fromJson(Map<String, dynamic> json) => Catalogue(
    courses: (json['items'] as List<dynamic>? ?? const [])
        .map((item) => Course.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList(),
    counts: {
      for (final entry in (json['departments'] as List<dynamic>? ?? const []))
        Department.fromWire((entry as Map)['department'] as String?):
            ((entry)['course_count'] as num?)?.toInt() ?? 0,
    },
  );
}

/// A downloadable handout.
class Handout {
  const Handout({
    required this.id,
    required this.courseId,
    required this.title,
    required this.bytes,
    required this.mimeType,
  });

  final int id;
  final int courseId;
  final LocalizedText title;
  final int bytes;
  final String mimeType;

  /// "1.2 MB" — always Western digits, rendered inside an LTR island.
  String get sizeLabel {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static Handout fromJson(Map<String, dynamic> json) => Handout(
    id: (json['id'] as num).toInt(),
    courseId: (json['course_id'] as num?)?.toInt() ?? 0,
    title: LocalizedText.fromJson(json['title'])!,
    bytes: (json['bytes'] as num?)?.toInt() ?? 0,
    mimeType: (json['mime_type'] as String?) ?? 'application/pdf',
  );
}

/// A quiz as it appears on the course detail screen: a title and a pass mark,
/// with none of its questions.
class QuizSummary {
  const QuizSummary({
    required this.id,
    required this.title,
    required this.passMark,
  });

  final int id;
  final LocalizedText title;
  final int passMark;

  static QuizSummary fromJson(Map<String, dynamic> json) => QuizSummary(
    id: (json['id'] as num).toInt(),
    title: LocalizedText.fromJson(json['title'])!,
    passMark: (json['pass_mark'] as num?)?.toInt() ?? 60,
  );
}

/// How far through a course this user is.
class CourseProgress {
  const CourseProgress({
    required this.lessonCount,
    required this.completedCount,
    required this.isComplete,
    this.completedAt,
  });

  final int lessonCount;
  final int completedCount;
  final bool isComplete;
  final DateTime? completedAt;

  double get fraction =>
      lessonCount == 0 ? 0 : (completedCount / lessonCount).clamp(0.0, 1.0);

  bool get hasStarted => completedCount > 0;

  static CourseProgress fromJson(Map<String, dynamic> json) => CourseProgress(
    lessonCount: (json['lesson_count'] as num?)?.toInt() ?? 0,
    completedCount: (json['completed_count'] as num?)?.toInt() ?? 0,
    isComplete: json['is_complete'] == true,
    completedAt: json['completed_at'] == null
        ? null
        : DateTime.tryParse(json['completed_at'] as String),
  );
}

/// Everything the course detail screen renders, from one request.
class CourseDetail {
  const CourseDetail({
    required this.course,
    required this.lessons,
    required this.handouts,
    required this.decks,
    required this.quizzes,
    this.progress,
    this.resumeLessonId,
  });

  final Course course;
  final List<Lesson> lessons;
  final List<Handout> handouts;
  final List<FlashcardDeck> decks;
  final List<QuizSummary> quizzes;

  /// Null for a guest — there is no progress without an account.
  final CourseProgress? progress;

  /// Where "Resume" goes. Chosen by the server so it can never point at a
  /// lesson the user does not own.
  final int? resumeLessonId;

  Lesson? get resumeLesson {
    final id = resumeLessonId;
    if (id == null) return null;
    for (final lesson in lessons) {
      if (lesson.id == id) return lesson;
    }
    return null;
  }

  Lesson? lessonAt(int id) {
    for (final lesson in lessons) {
      if (lesson.id == id) return lesson;
    }
    return null;
  }

  int get totalDueCards =>
      decks.fold(0, (total, deck) => total + deck.dueCount);

  static CourseDetail fromJson(Map<String, dynamic> json) => CourseDetail(
    course: Course.fromJson(Map<String, dynamic>.from(json['course'] as Map)),
    lessons: (json['lessons'] as List<dynamic>? ?? const [])
        .map((item) => Lesson.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList(),
    handouts: (json['handouts'] as List<dynamic>? ?? const [])
        .map((item) => Handout.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList(),
    decks: (json['decks'] as List<dynamic>? ?? const [])
        .map(
          (item) =>
              FlashcardDeck.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(),
    quizzes: (json['quizzes'] as List<dynamic>? ?? const [])
        .map(
          (item) =>
              QuizSummary.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(),
    progress: json['progress'] == null
        ? null
        : CourseProgress.fromJson(
            Map<String, dynamic>.from(json['progress'] as Map),
          ),
    resumeLessonId: (json['resume_lesson_id'] as num?)?.toInt(),
  );
}

/// What the server reports after a lesson is marked complete.
class LessonCompletion {
  const LessonCompletion({
    required this.progress,
    required this.courseComplete,
    this.nextLesson,
  });

  final CourseProgress progress;
  final bool courseComplete;

  /// The auto-advance target, chosen server-side.
  final Lesson? nextLesson;

  static LessonCompletion fromJson(Map<String, dynamic> json) =>
      LessonCompletion(
        progress: CourseProgress.fromJson(
          Map<String, dynamic>.from(json['progress'] as Map),
        ),
        courseComplete: json['course_complete'] == true,
        nextLesson: json['next_lesson'] == null
            ? null
            : Lesson.fromJson(
                Map<String, dynamic>.from(json['next_lesson'] as Map),
              ),
      );
}

/// A deck's due queue for today.
class DueQueue {
  const DueQueue({
    required this.deck,
    required this.cards,
    required this.dueCount,
  });

  final FlashcardDeck deck;
  final List<Flashcard> cards;
  final int dueCount;

  static DueQueue fromJson(Map<String, dynamic> json) => DueQueue(
    deck: FlashcardDeck.fromJson(
      Map<String, dynamic>.from(json['deck'] as Map),
    ),
    cards: (json['items'] as List<dynamic>? ?? const [])
        .map(
          (item) => Flashcard.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(),
    dueCount: (json['due_count'] as num?)?.toInt() ?? 0,
  );
}

/// What one review changed. The counts come from the server rather than being
/// tallied on the device, so the session summary reports what happened.
class ReviewResult {
  const ReviewResult({
    required this.intervalDays,
    required this.repetitions,
    required this.remainingDue,
    required this.againCount,
    required this.gotItCount,
  });

  final int intervalDays;
  final int repetitions;
  final int remainingDue;
  final int againCount;
  final int gotItCount;

  static ReviewResult fromJson(Map<String, dynamic> json) => ReviewResult(
    intervalDays: (json['interval_days'] as num?)?.toInt() ?? 0,
    repetitions: (json['repetitions'] as num?)?.toInt() ?? 0,
    remainingDue: (json['remaining_due'] as num?)?.toInt() ?? 0,
    againCount: (json['again_count'] as num?)?.toInt() ?? 0,
    gotItCount: (json['got_it_count'] as num?)?.toInt() ?? 0,
  );
}

/// The quiz as the client is allowed to hold it.
///
/// Its options carry no `is_correct`, because the server does not send one
/// until an attempt has been graded. Nothing in the app can therefore mark an
/// answer right or wrong before submission, by construction rather than by
/// discipline.
class QuizPaper {
  const QuizPaper({
    required this.id,
    required this.title,
    required this.passMark,
    required this.questions,
    this.bestAttempt,
  });

  final int id;
  final LocalizedText title;
  final int passMark;
  final List<QuizQuestion> questions;
  final QuizAttempt? bestAttempt;

  static QuizPaper fromJson(Map<String, dynamic> json) => QuizPaper(
    id: (json['id'] as num).toInt(),
    title: LocalizedText.fromJson(json['title'])!,
    passMark: (json['pass_mark'] as num?)?.toInt() ?? 60,
    questions: (json['questions'] as List<dynamic>? ?? const [])
        .map(
          (item) =>
              QuizQuestion.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(),
    bestAttempt: json['best_attempt'] == null
        ? null
        : QuizAttempt.fromJson(
            Map<String, dynamic>.from(json['best_attempt'] as Map),
          ),
  );
}

/// One graded question: what was chosen, what was right, and why.
class GradedQuestion {
  const GradedQuestion({
    required this.id,
    required this.position,
    required this.prompt,
    required this.explanation,
    required this.options,
    required this.isCorrect,
    this.selectedOptionId,
    this.correctOptionId,
  });

  final int id;
  final int position;
  final LocalizedText prompt;

  /// Shown after answering, right or wrong. The explanation is the point.
  final LocalizedText explanation;
  final List<QuizOption> options;
  final bool isCorrect;
  final int? selectedOptionId;
  final int? correctOptionId;

  static GradedQuestion fromJson(Map<String, dynamic> json) => GradedQuestion(
    id: (json['id'] as num).toInt(),
    position: (json['position'] as num?)?.toInt() ?? 0,
    prompt: LocalizedText.fromJson(json['prompt'])!,
    explanation:
        LocalizedText.fromJson(json['explanation']) ??
        const LocalizedText.same(''),
    options: (json['options'] as List<dynamic>? ?? const [])
        .map(
          (item) => QuizOption.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(),
    isCorrect: json['is_correct'] == true,
    selectedOptionId: (json['selected_option_id'] as num?)?.toInt(),
    correctOptionId: (json['correct_option_id'] as num?)?.toInt(),
  );
}

/// A graded attempt: the score, and the per-question feedback behind it.
class GradedAttempt {
  const GradedAttempt({
    required this.attempt,
    required this.questions,
    required this.passMark,
    required this.passed,
    required this.offersSession,
  });

  final QuizAttempt attempt;
  final List<GradedQuestion> questions;
  final int passMark;
  final bool passed;

  /// Below 60% the result offers ONE session on the topic. It never offers a
  /// package, and it never blocks a retake.
  final bool offersSession;

  static GradedAttempt fromJson(Map<String, dynamic> json) => GradedAttempt(
    attempt: QuizAttempt.fromJson(
      Map<String, dynamic>.from(json['attempt'] as Map),
    ),
    questions: (json['questions'] as List<dynamic>? ?? const [])
        .map(
          (item) =>
              GradedQuestion.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(),
    passMark: (json['pass_mark'] as num?)?.toInt() ?? 60,
    passed: json['passed'] == true,
    offersSession: json['offers_session'] == true,
  );
}
