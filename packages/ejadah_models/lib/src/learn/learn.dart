import '../common/localized_text.dart';
import '../common/value.dart';

/// The three Learn departments.
enum Department {
  orthodontics('orthodontics'),
  digital('digital'),
  businessParadental('business_paradental');

  const Department(this.wire);

  final String wire;

  static Department fromWire(String? value) => Department.values.firstWhere(
    (department) => department.wire == value,
    orElse: () => Department.orthodontics,
  );
}

/// A recorded course.
///
/// Courses are bought individually through in-app purchase — never a
/// subscription, never an external checkout. That split is law, not preference
/// (Apple §3.1.1), and must never be harmonised with session payments.
class Course extends ValueObject {
  const Course({
    required this.id,
    required this.slug,
    required this.title,
    required this.subtitle,
    required this.department,
    required this.lessonCount,
    required this.totalMinutes,
    required this.cpdPoints,
    required this.instructorName,
    required this.instructorBio,
    required this.iapProductId,
    required this.isOwned,
    required this.level,
    this.description,
    this.thumbnailUrl,
  });

  final int id;
  final String slug;
  final LocalizedText title;
  final LocalizedText subtitle;
  final Department department;
  final int lessonCount;
  final int totalMinutes;
  final int cpdPoints;
  final LocalizedText instructorName;
  final LocalizedText instructorBio;

  /// The store product identifier. The client never carries a price of its own;
  /// the store is the pricing authority for courses.
  final String iapProductId;

  /// Server-derived from the user's entitlements, never asserted by the client.
  final bool isOwned;
  final LocalizedText level;
  final LocalizedText? description;
  final String? thumbnailUrl;

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    id: jsonRequire<int>(json, 'id'),
    slug: jsonRequire<String>(json, 'slug'),
    title: LocalizedText.fromJson(json['title'])!,
    subtitle:
        LocalizedText.fromJson(json['subtitle']) ?? const LocalizedText.same(''),
    department: Department.fromWire(json['department'] as String?),
    lessonCount: jsonInt(json['lesson_count']) ?? 0,
    totalMinutes: jsonInt(json['total_minutes']) ?? 0,
    cpdPoints: jsonInt(json['cpd_points']) ?? 0,
    instructorName:
        LocalizedText.fromJson(json['instructor_name']) ??
        const LocalizedText.same(''),
    instructorBio:
        LocalizedText.fromJson(json['instructor_bio']) ??
        const LocalizedText.same(''),
    iapProductId: (json['iap_product_id'] ?? '') as String,
    isOwned: jsonBool(json['is_owned']) ?? false,
    level: LocalizedText.fromJson(json['level']) ?? const LocalizedText.same(''),
    description: LocalizedText.fromJson(json['description']),
    thumbnailUrl: json['thumbnail_url'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'slug': slug,
    'title': title.toJson(),
    'subtitle': subtitle.toJson(),
    'department': department.wire,
    'lesson_count': lessonCount,
    'total_minutes': totalMinutes,
    'cpd_points': cpdPoints,
    'instructor_name': instructorName.toJson(),
    'instructor_bio': instructorBio.toJson(),
    'iap_product_id': iapProductId,
    'is_owned': isOwned,
    'level': level.toJson(),
    'description': description?.toJson(),
    'thumbnail_url': thumbnailUrl,
  };

  @override
  List<Object?> get props => [id, isOwned, lessonCount];
}

/// A lesson within a course, carrying this user's own playback position.
class Lesson extends ValueObject {
  const Lesson({
    required this.id,
    required this.courseId,
    required this.position,
    required this.title,
    required this.durationSeconds,
    required this.isFreePreview,
    required this.isUnlocked,
    required this.positionSeconds,
    required this.isComplete,
    this.videoUrl,
  });

  final int id;
  final int courseId;
  final int position;
  final LocalizedText title;
  final int durationSeconds;

  /// Lesson one is always a free preview, in every course.
  final bool isFreePreview;

  /// Server-derived: free preview, or the user owns the course.
  final bool isUnlocked;

  /// Where this user stopped. The player must resume within 10 seconds of it.
  final int positionSeconds;
  final bool isComplete;
  final String? videoUrl;

  double get progress => durationSeconds == 0
      ? 0
      : (positionSeconds / durationSeconds).clamp(0.0, 1.0);

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
    id: jsonRequire<int>(json, 'id'),
    courseId: jsonInt(json['course_id']) ?? 0,
    position: jsonInt(json['position']) ?? 0,
    title: LocalizedText.fromJson(json['title'])!,
    durationSeconds: jsonInt(json['duration_seconds']) ?? 0,
    isFreePreview: jsonBool(json['is_free_preview']) ?? false,
    isUnlocked: jsonBool(json['is_unlocked']) ?? false,
    positionSeconds: jsonInt(json['position_seconds']) ?? 0,
    isComplete: jsonBool(json['is_complete']) ?? false,
    videoUrl: json['video_url'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'course_id': courseId,
    'position': position,
    'title': title.toJson(),
    'duration_seconds': durationSeconds,
    'is_free_preview': isFreePreview,
    'is_unlocked': isUnlocked,
    'position_seconds': positionSeconds,
    'is_complete': isComplete,
    'video_url': videoUrl,
  };

  @override
  List<Object?> get props => [id, positionSeconds, isComplete, isUnlocked];
}

/// How a flashcard review went. Drives the next due date.
enum ReviewOutcome {
  /// "Again" — the user did not recall it.
  again('again'),

  /// "Got it" — recalled.
  gotIt('got_it');

  const ReviewOutcome(this.wire);

  final String wire;

  static ReviewOutcome fromWire(String? value) =>
      value == 'got_it' ? ReviewOutcome.gotIt : ReviewOutcome.again;
}

/// A flashcard with this user's own scheduling state.
///
/// Real persistent learning objects with deterministic scheduling — never a
/// random "mastery" number (brief §38).
class Flashcard extends ValueObject {
  const Flashcard({
    required this.id,
    required this.deckId,
    required this.front,
    required this.back,
    required this.intervalDays,
    required this.repetitions,
    required this.dueOn,
  });

  final int id;
  final int deckId;
  final LocalizedText front;
  final LocalizedText back;

  /// Current spacing interval in days. 0 means never successfully reviewed.
  final int intervalDays;
  final int repetitions;
  final DateTime? dueOn;

  bool isDue(DateTime now) => dueOn == null || !dueOn!.isAfter(now);

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
    id: jsonRequire<int>(json, 'id'),
    deckId: jsonInt(json['deck_id']) ?? 0,
    front: LocalizedText.fromJson(json['front'])!,
    back: LocalizedText.fromJson(json['back'])!,
    intervalDays: jsonInt(json['interval_days']) ?? 0,
    repetitions: jsonInt(json['repetitions']) ?? 0,
    dueOn: jsonDate(json['due_on']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'deck_id': deckId,
    'front': front.toJson(),
    'back': back.toJson(),
    'interval_days': intervalDays,
    'repetitions': repetitions,
    'due_on': dueOn?.toIso8601String(),
  };

  @override
  List<Object?> get props => [id, intervalDays, repetitions, dueOn];
}

/// A deck plus the counts Home needs ("cards due today").
class FlashcardDeck extends ValueObject {
  const FlashcardDeck({
    required this.id,
    required this.courseId,
    required this.title,
    required this.cardCount,
    required this.dueCount,
  });

  final int id;
  final int? courseId;
  final LocalizedText title;
  final int cardCount;
  final int dueCount;

  factory FlashcardDeck.fromJson(Map<String, dynamic> json) => FlashcardDeck(
    id: jsonRequire<int>(json, 'id'),
    courseId: jsonInt(json['course_id']),
    title: LocalizedText.fromJson(json['title'])!,
    cardCount: jsonInt(json['card_count']) ?? 0,
    dueCount: jsonInt(json['due_count']) ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'course_id': courseId,
    'title': title.toJson(),
    'card_count': cardCount,
    'due_count': dueCount,
  };

  @override
  List<Object?> get props => [id, cardCount, dueCount];
}

/// A quiz question with its options and explanation.
class QuizQuestion extends ValueObject {
  const QuizQuestion({
    required this.id,
    required this.position,
    required this.prompt,
    required this.options,
    required this.explanation,
  });

  final int id;
  final int position;
  final LocalizedText prompt;
  final List<QuizOption> options;

  /// Shown after answering, right or wrong. The explanation is the point.
  final LocalizedText explanation;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
    id: jsonRequire<int>(json, 'id'),
    position: jsonInt(json['position']) ?? 0,
    prompt: LocalizedText.fromJson(json['prompt'])!,
    options: (json['options'] as List<dynamic>? ?? const [])
        .map((o) => QuizOption.fromJson(Map<String, dynamic>.from(o as Map)))
        .toList(),
    explanation:
        LocalizedText.fromJson(json['explanation']) ??
        const LocalizedText.same(''),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'position': position,
    'prompt': prompt.toJson(),
    'options': options.map((option) => option.toJson()).toList(),
    'explanation': explanation.toJson(),
  };

  @override
  List<Object?> get props => [id, position, options];
}

/// One answer option.
///
/// [isCorrect] is `null` until the server grades the attempt — the client is
/// never handed the answer key up front.
class QuizOption extends ValueObject {
  const QuizOption({
    required this.id,
    required this.position,
    required this.label,
    this.isCorrect,
  });

  final int id;
  final int position;
  final LocalizedText label;
  final bool? isCorrect;

  factory QuizOption.fromJson(Map<String, dynamic> json) => QuizOption(
    id: jsonRequire<int>(json, 'id'),
    position: jsonInt(json['position']) ?? 0,
    label: LocalizedText.fromJson(json['label'])!,
    isCorrect: jsonBool(json['is_correct']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'position': position,
    'label': label.toJson(),
    if (isCorrect != null) 'is_correct': isCorrect,
  };

  @override
  List<Object?> get props => [id, position, isCorrect];
}

/// A graded quiz attempt.
///
/// Scoring happens on the server; the client displays a result it was given.
class QuizAttempt extends ValueObject {
  const QuizAttempt({
    required this.id,
    required this.quizId,
    required this.scorePercent,
    required this.correctCount,
    required this.questionCount,
    required this.submittedAt,
    required this.results,
  });

  final String id;
  final int quizId;
  final int scorePercent;
  final int correctCount;
  final int questionCount;
  final DateTime submittedAt;

  /// Question id → whether this attempt got it right.
  final Map<int, bool> results;

  /// Below 60% the result offers ONE session on that topic. It never blocks a
  /// retry, and it never offers a package.
  bool get offersSession => scorePercent < 60;

  factory QuizAttempt.fromJson(Map<String, dynamic> json) => QuizAttempt(
    id: jsonRequire<String>(json, 'id'),
    quizId: jsonInt(json['quiz_id']) ?? 0,
    scorePercent: jsonInt(json['score_percent']) ?? 0,
    correctCount: jsonInt(json['correct_count']) ?? 0,
    questionCount: jsonInt(json['question_count']) ?? 0,
    submittedAt: jsonDate(json['submitted_at'])!,
    results: (json['results'] as Map<dynamic, dynamic>? ?? const {}).map(
      (key, value) => MapEntry(int.parse(key.toString()), value == true),
    ),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'quiz_id': quizId,
    'score_percent': scorePercent,
    'correct_count': correctCount,
    'question_count': questionCount,
    'submitted_at': submittedAt.toIso8601String(),
    'results': results.map((key, value) => MapEntry('$key', value)),
  };

  @override
  List<Object?> get props => [id, scorePercent, correctCount, questionCount];
}
