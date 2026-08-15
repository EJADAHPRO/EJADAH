import 'package:ejadah_models/ejadah_models.dart';
import 'package:postgres/postgres.dart';

import '../../db/database.dart';
import 'flashcard_scheduler.dart';

/// A downloadable handout. There is no model for this in `ejadah_models`, and
/// it needs none: the row is three strings and a byte count.
class Handout {
  const Handout({
    required this.id,
    required this.courseId,
    required this.title,
    required this.storageKey,
    required this.bytes,
    required this.mimeType,
  });

  final int id;
  final int courseId;
  final LocalizedText title;
  final String storageKey;
  final int bytes;
  final String mimeType;

  Map<String, dynamic> toJson() => {
    'id': id,
    'course_id': courseId,
    'title': title.toJson(),
    'storage_key': storageKey,
    'bytes': bytes,
    'mime_type': mimeType,
  };
}

/// One question with its answer key attached.
///
/// This type never leaves the service layer. It exists so grading reads the key
/// from the database inside one query rather than trusting anything the client
/// sent, and so the client-facing shape can be built by deliberately dropping
/// fields rather than by remembering to.
class QuizQuestionWithKey {
  const QuizQuestionWithKey({
    required this.id,
    required this.position,
    required this.prompt,
    required this.explanation,
    required this.options,
  });

  final int id;
  final int position;
  final LocalizedText prompt;
  final LocalizedText explanation;
  final List<QuizOptionWithKey> options;

  int? get correctOptionId =>
      options.where((option) => option.isCorrect).firstOrNull?.id;
}

class QuizOptionWithKey {
  const QuizOptionWithKey({
    required this.id,
    required this.position,
    required this.label,
    required this.isCorrect,
  });

  final int id;
  final int position;
  final LocalizedText label;
  final bool isCorrect;
}

/// A quiz's identity, without its questions.
class QuizHeader {
  const QuizHeader({
    required this.id,
    required this.courseId,
    required this.title,
    required this.passMark,
  });

  final int id;
  final int courseId;
  final LocalizedText title;
  final int passMark;
}

/// The user's progress through one course.
class CourseProgress {
  const CourseProgress({
    required this.lessonCount,
    required this.completedCount,
    required this.startedAt,
    required this.completedAt,
  });

  final int lessonCount;
  final int completedCount;
  final DateTime? startedAt;
  final DateTime? completedAt;

  bool get isComplete => lessonCount > 0 && completedCount >= lessonCount;

  Map<String, dynamic> toJson() => {
    'lesson_count': lessonCount,
    'completed_count': completedCount,
    'started_at': startedAt?.toIso8601String(),
    'completed_at': completedAt?.toIso8601String(),
    'is_complete': isComplete,
  };
}

/// All database access for the Learn tab.
///
/// Three rules are enforced here rather than above, because a route that forgets
/// them is a security defect and not a cosmetic one:
///
/// * **Ownership is read, never written, from the client.** `is_owned` comes
///   from a join against `entitlements`; nothing the caller sends can set it.
/// * **A locked lesson carries no video URL.** Withholding the row is not
///   enough — the address of the media is the media.
/// * **The answer key stays in [QuizQuestionWithKey].** The client-facing quiz
///   is built by dropping fields from it, so adding a column cannot leak one.
class LearnRepository {
  const LearnRepository(this._database);

  final Database _database;

  // --- Catalogue ------------------------------------------------------------

  /// The published catalogue, optionally narrowed to one department.
  Future<List<Course>> listCourses({
    Department? department,
    String? userId,
  }) async {
    final rows = await _query(
      '''
      SELECT ${_courseColumns(userId)}
      FROM courses c
      ${_entitlementJoin(userId)}
      WHERE c.is_published
        ${department == null ? '' : 'AND c.department = @department::department'}
      ORDER BY c.department, c.id
      ''',
      {
        if (department != null) 'department': department.wire,
        if (userId != null) 'owner_id': userId,
      },
    );
    return rows.map(_toCourse).toList();
  }

  /// How many published courses each department holds, for the hub cards.
  Future<Map<Department, int>> courseCountsByDepartment() async {
    final rows = await _query(
      'SELECT department, count(*) AS total FROM courses '
      'WHERE is_published GROUP BY department',
      const {},
    );
    return {
      for (final row in rows)
        Department.fromWire(row.str('department')): row.intAt('total'),
    };
  }

  Future<Course?> findCourseBySlug(String slug, {String? userId}) =>
      _findCourse('c.slug = @slug', {'slug': slug}, userId);

  Future<Course?> findCourseById(int id, {String? userId}) =>
      _findCourse('c.id = @id', {'id': id}, userId);

  Future<Course?> _findCourse(
    String where,
    Map<String, Object?> parameters,
    String? userId,
  ) async {
    final rows = await _query(
      '''
      SELECT ${_courseColumns(userId)}
      FROM courses c
      ${_entitlementJoin(userId)}
      WHERE $where AND c.is_published
      ''',
      {...parameters, if (userId != null) 'owner_id': userId},
    );
    return rows.isEmpty ? null : _toCourse(rows.first);
  }

  // --- Lessons and progress -------------------------------------------------

  /// The course's lessons with this user's own playback position.
  ///
  /// [isOwned] decides unlocking for every lesson after the first; lesson one is
  /// unlocked unconditionally, in every course, because that is a product rule
  /// and not a per-row data decision.
  Future<List<Lesson>> lessonsForCourse(
    int courseId, {
    String? userId,
    required bool isOwned,
  }) async {
    final rows = await _query(
      '''
      SELECT l.id, l.course_id, l.position, l.title_en, l.title_ar,
             l.duration_seconds, l.video_url, l.is_free_preview,
             ${userId == null ? '0' : 'coalesce(p.position_seconds, 0)'} AS position_seconds,
             ${userId == null ? 'false' : 'coalesce(p.is_complete, false)'} AS is_complete
      FROM lessons l
      ${userId == null ? '' : 'LEFT JOIN lesson_progress p ON p.lesson_id = l.id AND p.user_id = @viewer_id'}
      WHERE l.course_id = @course_id
      ORDER BY l.position
      ''',
      {'course_id': courseId, if (userId != null) 'viewer_id': userId},
    );
    return rows.map((row) => _toLesson(row, isOwned: isOwned)).toList();
  }

  /// One lesson, with the course it belongs to.
  Future<({Lesson lesson, int courseId, bool isOwned})?> findLesson(
    int lessonId, {
    String? userId,
  }) async {
    final rows = await _query(
      '''
      SELECT l.id, l.course_id, l.position, l.title_en, l.title_ar,
             l.duration_seconds, l.video_url, l.is_free_preview,
             ${userId == null ? '0' : 'coalesce(p.position_seconds, 0)'} AS position_seconds,
             ${userId == null ? 'false' : 'coalesce(p.is_complete, false)'} AS is_complete,
             ${userId == null ? 'false' : 'e.user_id IS NOT NULL'} AS is_owned
      FROM lessons l
      ${userId == null ? '' : '''
      LEFT JOIN lesson_progress p ON p.lesson_id = l.id AND p.user_id = @viewer_id
      LEFT JOIN entitlements e ON e.course_id = l.course_id AND e.user_id = @viewer_id
      '''}
      WHERE l.id = @lesson_id
      ''',
      {'lesson_id': lessonId, if (userId != null) 'viewer_id': userId},
    );
    if (rows.isEmpty) return null;

    final row = rows.first;
    final isOwned = row.boolAt('is_owned');
    return (
      lesson: _toLesson(row, isOwned: isOwned),
      courseId: row.intAt('course_id'),
      isOwned: isOwned,
    );
  }

  /// Stores where the user stopped.
  ///
  /// Position lives here rather than in client state because the criteria
  /// require it to survive a reinstall, and only the server can do that.
  Future<void> saveProgress({
    required String userId,
    required int lessonId,
    required int positionSeconds,
  }) => _execute(
    '''
    INSERT INTO lesson_progress (user_id, lesson_id, position_seconds, updated_at)
    VALUES (@user_id, @lesson_id, @position_seconds, now())
    ON CONFLICT (user_id, lesson_id) DO UPDATE
      SET position_seconds = EXCLUDED.position_seconds,
          updated_at = now()
    ''',
    {
      'user_id': userId,
      'lesson_id': lessonId,
      'position_seconds': positionSeconds,
    },
  );

  /// Marks a lesson complete. Idempotent: completing twice keeps the first
  /// timestamp, so a double-tap does not rewrite history.
  Future<void> completeLesson({
    required String userId,
    required int lessonId,
    required int positionSeconds,
  }) => _execute(
    '''
    INSERT INTO lesson_progress (
      user_id, lesson_id, position_seconds, is_complete, completed_at, updated_at
    )
    VALUES (@user_id, @lesson_id, @position_seconds, true, now(), now())
    ON CONFLICT (user_id, lesson_id) DO UPDATE
      SET is_complete = true,
          position_seconds = GREATEST(
            lesson_progress.position_seconds, EXCLUDED.position_seconds
          ),
          completed_at = coalesce(lesson_progress.completed_at, now()),
          updated_at = now()
    ''',
    {
      'user_id': userId,
      'lesson_id': lessonId,
      'position_seconds': positionSeconds,
    },
  );

  Future<void> ensureEnrollment({
    required String userId,
    required int courseId,
    Session? session,
  }) => _execute(
    'INSERT INTO enrollments (user_id, course_id) '
    'VALUES (@user_id, @course_id) ON CONFLICT DO NOTHING',
    {'user_id': userId, 'course_id': courseId},
    session,
  );

  /// Stamps the course complete once every lesson is. Returns the progress
  /// either way, so the caller can render the completion screen from one read.
  Future<CourseProgress> refreshCourseCompletion({
    required String userId,
    required int courseId,
  }) async {
    final progress = await courseProgress(userId: userId, courseId: courseId);
    if (!progress.isComplete || progress.completedAt != null) return progress;

    await _execute(
      'UPDATE enrollments SET completed_at = now() '
      'WHERE user_id = @user_id AND course_id = @course_id '
      'AND completed_at IS NULL',
      {'user_id': userId, 'course_id': courseId},
    );
    return courseProgress(userId: userId, courseId: courseId);
  }

  Future<CourseProgress> courseProgress({
    required String userId,
    required int courseId,
  }) async {
    final rows = await _query(
      '''
      SELECT
        (SELECT count(*) FROM lessons WHERE course_id = @course_id)
          AS lesson_count,
        (SELECT count(*) FROM lesson_progress p
          JOIN lessons l ON l.id = p.lesson_id
          WHERE l.course_id = @course_id AND p.user_id = @user_id
            AND p.is_complete) AS completed_count,
        (SELECT started_at FROM enrollments
          WHERE user_id = @user_id AND course_id = @course_id) AS started_at,
        (SELECT completed_at FROM enrollments
          WHERE user_id = @user_id AND course_id = @course_id) AS completed_at
      ''',
      {'course_id': courseId, 'user_id': userId},
    );
    final row = rows.first;
    return CourseProgress(
      lessonCount: row.intAt('lesson_count'),
      completedCount: row.intAt('completed_count'),
      startedAt: row.dateOrNull('started_at'),
      completedAt: row.dateOrNull('completed_at'),
    );
  }

  // --- Handouts -------------------------------------------------------------

  Future<List<Handout>> handoutsForCourse(int courseId) async {
    final rows = await _query(
      'SELECT * FROM handouts WHERE course_id = @course_id ORDER BY id',
      {'course_id': courseId},
    );
    return rows
        .map(
          (row) => Handout(
            id: row.intAt('id'),
            courseId: row.intAt('course_id'),
            title: LocalizedText(
              en: row.str('title_en'),
              ar: row.str('title_ar'),
            ),
            storageKey: row.str('storage_key'),
            bytes: row.intAt('bytes'),
            mimeType: row.str('mime_type'),
          ),
        )
        .toList();
  }

  Future<Handout?> findHandout(int handoutId) async {
    final rows = await _query('SELECT * FROM handouts WHERE id = @id', {
      'id': handoutId,
    });
    if (rows.isEmpty) return null;

    final row = rows.first;
    return Handout(
      id: row.intAt('id'),
      courseId: row.intAt('course_id'),
      title: LocalizedText(en: row.str('title_en'), ar: row.str('title_ar')),
      storageKey: row.str('storage_key'),
      bytes: row.intAt('bytes'),
      mimeType: row.str('mime_type'),
    );
  }

  // --- Entitlements ---------------------------------------------------------

  Future<bool> hasEntitlement({
    required String userId,
    required int courseId,
  }) async {
    final rows = await _query(
      'SELECT 1 AS present FROM entitlements '
      'WHERE user_id = @user_id AND course_id = @course_id',
      {'user_id': userId, 'course_id': courseId},
    );
    return rows.isNotEmpty;
  }

  /// Every course this user owns. This is what makes "restore purchases" work
  /// on a new device: the entitlement is server-side, so restoring is a read.
  Future<List<int>> entitledCourseIds(String userId) async {
    final rows = await _query(
      'SELECT course_id FROM entitlements WHERE user_id = @user_id '
      'ORDER BY granted_at',
      {'user_id': userId},
    );
    return rows.map((row) => row.intAt('course_id')).toList();
  }

  /// Grants ownership and enrols in one transaction.
  ///
  /// A replayed receipt cannot grant twice: `external_ref` is uniquely indexed,
  /// and re-granting the same course is a no-op rather than a second row.
  Future<void> grantEntitlement({
    required String userId,
    required int courseId,
    required String source,
    String? externalRef,
  }) => _database.runTx((tx) async {
    await _execute(
      '''
      INSERT INTO entitlements (user_id, course_id, source, external_ref)
      VALUES (@user_id, @course_id, @source, @external_ref)
      ON CONFLICT (user_id, course_id) DO NOTHING
      ''',
      {
        'user_id': userId,
        'course_id': courseId,
        'source': source,
        'external_ref': externalRef,
      },
      tx,
    );
    await ensureEnrollment(userId: userId, courseId: courseId, session: tx);
  });

  /// Whether this store transaction has already been redeemed — by anyone.
  Future<bool> isReceiptRedeemed(String externalRef) async {
    final rows = await _query(
      'SELECT user_id FROM entitlements WHERE external_ref = @ref',
      {'ref': externalRef},
    );
    return rows.isNotEmpty;
  }

  Future<String?> receiptOwner(String externalRef) async {
    final rows = await _query(
      'SELECT user_id FROM entitlements WHERE external_ref = @ref',
      {'ref': externalRef},
    );
    return rows.isEmpty ? null : rows.first.str('user_id');
  }

  // --- Flashcards -----------------------------------------------------------

  Future<List<FlashcardDeck>> decksForCourse(
    int courseId, {
    String? userId,
    required DateTime today,
  }) async {
    final rows = await _query(
      '''
      SELECT d.id, d.course_id, d.title_en, d.title_ar,
             (SELECT count(*) FROM flashcards f WHERE f.deck_id = d.id)
               AS card_count,
             ${userId == null ? '0' : '''
             (SELECT count(*) FROM flashcards f
               LEFT JOIN flashcard_states s
                 ON s.flashcard_id = f.id AND s.user_id = @viewer_id
               WHERE f.deck_id = d.id
                 AND (s.due_on IS NULL OR s.due_on <= @today::date))'''}
               AS due_count
      FROM flashcard_decks d
      WHERE d.course_id = @course_id
      ORDER BY d.id
      ''',
      {
        'course_id': courseId,
        // The date only appears in the SQL when there is a user to count due
        // cards for; passing it unconditionally is a superfluous parameter.
        if (userId != null) ...{'today': _isoDate(today), 'viewer_id': userId},
      },
    );
    return rows.map(_toDeck).toList();
  }

  Future<FlashcardDeck?> findDeck(
    int deckId, {
    String? userId,
    required DateTime today,
  }) async {
    final rows = await _query(
      '''
      SELECT d.id, d.course_id, d.title_en, d.title_ar,
             (SELECT count(*) FROM flashcards f WHERE f.deck_id = d.id)
               AS card_count,
             ${userId == null ? '0' : '''
             (SELECT count(*) FROM flashcards f
               LEFT JOIN flashcard_states s
                 ON s.flashcard_id = f.id AND s.user_id = @viewer_id
               WHERE f.deck_id = d.id
                 AND (s.due_on IS NULL OR s.due_on <= @today::date))'''}
               AS due_count
      FROM flashcard_decks d
      WHERE d.id = @deck_id
      ''',
      {
        'deck_id': deckId,
        if (userId != null) ...{'today': _isoDate(today), 'viewer_id': userId},
      },
    );
    return rows.isEmpty ? null : _toDeck(rows.first);
  }

  /// The cards due today, hardest-overdue first.
  ///
  /// A card with no state has never been seen and is due immediately; that is
  /// why the join is a LEFT JOIN and NULL sorts first.
  Future<List<Flashcard>> dueCards({
    required int deckId,
    required String userId,
    required DateTime today,
    int limit = 40,
  }) async {
    final rows = await _query(
      '''
      SELECT f.id, f.deck_id, f.front_en, f.front_ar, f.back_en, f.back_ar,
             coalesce(s.interval_days, 0) AS interval_days,
             coalesce(s.repetitions, 0) AS repetitions,
             s.ease, s.due_on
      FROM flashcards f
      LEFT JOIN flashcard_states s
        ON s.flashcard_id = f.id AND s.user_id = @user_id
      WHERE f.deck_id = @deck_id
        AND (s.due_on IS NULL OR s.due_on <= @today::date)
      ORDER BY s.due_on NULLS FIRST, f.position
      LIMIT @limit
      ''',
      {
        'deck_id': deckId,
        'user_id': userId,
        'today': _isoDate(today),
        'limit': limit,
      },
    );
    return rows.map(_toFlashcard).toList();
  }

  Future<int> dueCount({
    required int deckId,
    required String userId,
    required DateTime today,
  }) async {
    final rows = await _query(
      '''
      SELECT count(*) AS total
      FROM flashcards f
      LEFT JOIN flashcard_states s
        ON s.flashcard_id = f.id AND s.user_id = @user_id
      WHERE f.deck_id = @deck_id
        AND (s.due_on IS NULL OR s.due_on <= @today::date)
      ''',
      {'deck_id': deckId, 'user_id': userId, 'today': _isoDate(today)},
    );
    return rows.first.intAt('total');
  }

  /// The card's deck, and its current spacing state for this user.
  Future<({int deckId, int? courseId, FlashcardSchedule schedule})?>
  flashcardState({
    required int flashcardId,
    required String userId,
    required DateTime today,
  }) async {
    final rows = await _query(
      '''
      SELECT f.deck_id, d.course_id,
             s.interval_days, s.repetitions, s.ease, s.due_on
      FROM flashcards f
      JOIN flashcard_decks d ON d.id = f.deck_id
      LEFT JOIN flashcard_states s
        ON s.flashcard_id = f.id AND s.user_id = @user_id
      WHERE f.id = @flashcard_id
      ''',
      {'flashcard_id': flashcardId, 'user_id': userId},
    );
    if (rows.isEmpty) return null;

    final row = rows.first;
    final dueOn = row.dateOrNull('due_on');
    return (
      deckId: row.intAt('deck_id'),
      courseId: row.intOrNull('course_id'),
      schedule: dueOn == null
          ? FlashcardSchedule.fresh(today)
          : FlashcardSchedule(
              intervalDays: row.intOrNull('interval_days') ?? 0,
              repetitions: row.intOrNull('repetitions') ?? 0,
              ease: row.doubleOrNull('ease') ?? FlashcardScheduler.startingEase,
              dueOn: FlashcardScheduler.dateOnly(dueOn),
            ),
    );
  }

  /// Writes the new spacing state and the review that produced it.
  ///
  /// Both rows go in one transaction: a session summary that reports what
  /// happened must not be able to disagree with the schedule it produced.
  Future<void> recordReview({
    required String userId,
    required int flashcardId,
    required ReviewOutcome outcome,
    required FlashcardSchedule schedule,
  }) => _database.runTx((tx) async {
    await _execute(
      '''
      INSERT INTO flashcard_states (
        user_id, flashcard_id, interval_days, repetitions, ease, due_on,
        updated_at
      )
      VALUES (
        @user_id, @flashcard_id, @interval_days, @repetitions,
        @ease::numeric, @due_on::date, now()
      )
      ON CONFLICT (user_id, flashcard_id) DO UPDATE
        SET interval_days = EXCLUDED.interval_days,
            repetitions = EXCLUDED.repetitions,
            ease = EXCLUDED.ease,
            due_on = EXCLUDED.due_on,
            updated_at = now()
      ''',
      {
        'user_id': userId,
        'flashcard_id': flashcardId,
        'interval_days': schedule.intervalDays,
        'repetitions': schedule.repetitions,
        'ease': schedule.ease.toStringAsFixed(2),
        'due_on': _isoDate(schedule.dueOn),
      },
      tx,
    );
    await _execute(
      'INSERT INTO flashcard_reviews (user_id, flashcard_id, outcome) '
      'VALUES (@user_id, @flashcard_id, @outcome)',
      {'user_id': userId, 'flashcard_id': flashcardId, 'outcome': outcome.wire},
      tx,
    );
  });

  /// What the user actually did in a session, read back from the reviews
  /// table rather than from anything the client remembers.
  Future<({int again, int gotIt})> reviewTotalsSince({
    required String userId,
    required int deckId,
    required DateTime since,
  }) async {
    final rows = await _query(
      '''
      SELECT r.outcome, count(*) AS total
      FROM flashcard_reviews r
      JOIN flashcards f ON f.id = r.flashcard_id
      WHERE r.user_id = @user_id AND f.deck_id = @deck_id
        AND r.reviewed_at >= @since
      GROUP BY r.outcome
      ''',
      {'user_id': userId, 'deck_id': deckId, 'since': since.toUtc()},
    );
    var again = 0;
    var gotIt = 0;
    for (final row in rows) {
      if (row.str('outcome') == ReviewOutcome.gotIt.wire) {
        gotIt = row.intAt('total');
      } else {
        again = row.intAt('total');
      }
    }
    return (again: again, gotIt: gotIt);
  }

  // --- Quizzes --------------------------------------------------------------

  Future<List<QuizHeader>> quizzesForCourse(int courseId) async {
    final rows = await _query(
      'SELECT id, course_id, title_en, title_ar, pass_mark FROM quizzes '
      'WHERE course_id = @course_id ORDER BY id',
      {'course_id': courseId},
    );
    return rows.map(_toQuizHeader).toList();
  }

  Future<QuizHeader?> findQuiz(int quizId) async {
    final rows = await _query(
      'SELECT id, course_id, title_en, title_ar, pass_mark FROM quizzes '
      'WHERE id = @quiz_id',
      {'quiz_id': quizId},
    );
    return rows.isEmpty ? null : _toQuizHeader(rows.first);
  }

  /// The questions **with** their answer key.
  ///
  /// Only the service calls this, and only two things happen to the result:
  /// grading, or being stripped into the client-facing shape.
  Future<List<QuizQuestionWithKey>> questionsWithKey(int quizId) async {
    final questionRows = await _query(
      'SELECT id, position, prompt_en, prompt_ar, explanation_en, '
      'explanation_ar FROM quiz_questions WHERE quiz_id = @quiz_id '
      'ORDER BY position',
      {'quiz_id': quizId},
    );
    if (questionRows.isEmpty) return const [];

    final optionRows = await _query(
      'SELECT id, question_id, position, label_en, label_ar, is_correct '
      'FROM quiz_options WHERE question_id = ANY(@ids) '
      'ORDER BY question_id, position',
      {'ids': questionRows.map((row) => row.intAt('id')).toList()},
    );

    final optionsByQuestion = <int, List<QuizOptionWithKey>>{};
    for (final row in optionRows) {
      optionsByQuestion
          .putIfAbsent(row.intAt('question_id'), () => [])
          .add(
            QuizOptionWithKey(
              id: row.intAt('id'),
              position: row.intAt('position'),
              label: LocalizedText(
                en: row.str('label_en'),
                ar: row.str('label_ar'),
              ),
              isCorrect: row.boolAt('is_correct'),
            ),
          );
    }

    return questionRows
        .map(
          (row) => QuizQuestionWithKey(
            id: row.intAt('id'),
            position: row.intAt('position'),
            prompt: LocalizedText(
              en: row.str('prompt_en'),
              ar: row.str('prompt_ar'),
            ),
            explanation: LocalizedText(
              en: row.str('explanation_en'),
              ar: row.str('explanation_ar'),
            ),
            options: optionsByQuestion[row.intAt('id')] ?? const [],
          ),
        )
        .toList();
  }

  /// Stores a graded attempt and its per-question answers atomically.
  Future<String> recordAttempt({
    required String userId,
    required int quizId,
    required int scorePercent,
    required int correctCount,
    required int questionCount,
    required Map<int, ({int? optionId, bool isCorrect})> answers,
  }) => _database.runTx((tx) async {
    final attemptRows = await _query(
      '''
      INSERT INTO quiz_attempts (
        user_id, quiz_id, score_percent, correct_count, question_count
      )
      VALUES (@user_id, @quiz_id, @score, @correct, @questions)
      RETURNING id
      ''',
      {
        'user_id': userId,
        'quiz_id': quizId,
        'score': scorePercent,
        'correct': correctCount,
        'questions': questionCount,
      },
      tx,
    );
    final attemptId = attemptRows.first.str('id');

    for (final entry in answers.entries) {
      await _execute(
        'INSERT INTO quiz_answers (attempt_id, question_id, option_id, '
        'is_correct) VALUES (@attempt_id::uuid, @question_id, @option_id, '
        '@is_correct)',
        {
          'attempt_id': attemptId,
          'question_id': entry.key,
          'option_id': entry.value.optionId,
          'is_correct': entry.value.isCorrect,
        },
        tx,
      );
    }
    return attemptId;
  });

  /// The user's best attempt at a quiz, for the course detail screen.
  Future<QuizAttempt?> bestAttempt({
    required String userId,
    required int quizId,
  }) async {
    final rows = await _query(
      '''
      SELECT id, quiz_id, score_percent, correct_count, question_count,
             submitted_at
      FROM quiz_attempts
      WHERE user_id = @user_id AND quiz_id = @quiz_id
      ORDER BY score_percent DESC, submitted_at DESC
      LIMIT 1
      ''',
      {'user_id': userId, 'quiz_id': quizId},
    );
    if (rows.isEmpty) return null;

    final row = rows.first;
    return QuizAttempt(
      id: row.str('id'),
      quizId: row.intAt('quiz_id'),
      scorePercent: row.intAt('score_percent'),
      correctCount: row.intAt('correct_count'),
      questionCount: row.intAt('question_count'),
      submittedAt: row.dateAt('submitted_at'),
      results: const {},
    );
  }

  // --- Mapping --------------------------------------------------------------

  static String _courseColumns(String? userId) =>
      '''
    c.id, c.slug, c.title_en, c.title_ar, c.subtitle_en, c.subtitle_ar,
    c.description_en, c.description_ar, c.department, c.level_en, c.level_ar,
    c.cpd_points, c.instructor_name_en, c.instructor_name_ar,
    c.instructor_bio_en, c.instructor_bio_ar, c.iap_product_id,
    c.thumbnail_url,
    (SELECT count(*) FROM lessons l WHERE l.course_id = c.id) AS lesson_count,
    (SELECT coalesce(sum(l.duration_seconds), 0) FROM lessons l
      WHERE l.course_id = c.id) AS total_seconds,
    ${userId == null ? 'false' : 'e.user_id IS NOT NULL'} AS is_owned
  ''';

  static String _entitlementJoin(String? userId) => userId == null
      ? ''
      : 'LEFT JOIN entitlements e ON e.course_id = c.id '
            'AND e.user_id = @owner_id';

  static Course _toCourse(Map<String, dynamic> row) => Course(
    id: row.intAt('id'),
    slug: row.str('slug'),
    title: LocalizedText(en: row.str('title_en'), ar: row.str('title_ar')),
    subtitle: LocalizedText(
      en: row.str('subtitle_en'),
      ar: row.str('subtitle_ar'),
    ),
    department: Department.fromWire(row.str('department')),
    lessonCount: row.intAt('lesson_count'),
    // Rounded up: a 90-second lesson is a minute of the course, not zero.
    totalMinutes: (row.intAt('total_seconds') + 59) ~/ 60,
    cpdPoints: row.intAt('cpd_points'),
    instructorName: LocalizedText(
      en: row.str('instructor_name_en'),
      ar: row.str('instructor_name_ar'),
    ),
    instructorBio: LocalizedText(
      en: row.str('instructor_bio_en'),
      ar: row.str('instructor_bio_ar'),
    ),
    iapProductId: row.str('iap_product_id'),
    isOwned: row.boolAt('is_owned'),
    level: LocalizedText(en: row.str('level_en'), ar: row.str('level_ar')),
    description: LocalizedText(
      en: row.str('description_en'),
      ar: row.str('description_ar'),
    ),
    thumbnailUrl: row.strOrNull('thumbnail_url'),
  );

  static Lesson _toLesson(Map<String, dynamic> row, {required bool isOwned}) {
    final position = row.intAt('position');
    // Lesson one is a free preview in every course, whatever the row says.
    final isFreePreview = position == 1 || row.boolAt('is_free_preview');
    final isUnlocked = isOwned || isFreePreview;

    return Lesson(
      id: row.intAt('id'),
      courseId: row.intAt('course_id'),
      position: position,
      title: LocalizedText(en: row.str('title_en'), ar: row.str('title_ar')),
      durationSeconds: row.intAt('duration_seconds'),
      isFreePreview: isFreePreview,
      isUnlocked: isUnlocked,
      positionSeconds: row.intAt('position_seconds'),
      isComplete: row.boolAt('is_complete'),
      // The address of the media is the media: a locked lesson carries no URL,
      // so a client that ignores `is_unlocked` still has nothing to play.
      videoUrl: isUnlocked ? row.strOrNull('video_url') : null,
    );
  }

  static FlashcardDeck _toDeck(Map<String, dynamic> row) => FlashcardDeck(
    id: row.intAt('id'),
    courseId: row.intOrNull('course_id'),
    title: LocalizedText(en: row.str('title_en'), ar: row.str('title_ar')),
    cardCount: row.intAt('card_count'),
    dueCount: row.intAt('due_count'),
  );

  static Flashcard _toFlashcard(Map<String, dynamic> row) => Flashcard(
    id: row.intAt('id'),
    deckId: row.intAt('deck_id'),
    front: LocalizedText(en: row.str('front_en'), ar: row.str('front_ar')),
    back: LocalizedText(en: row.str('back_en'), ar: row.str('back_ar')),
    intervalDays: row.intAt('interval_days'),
    repetitions: row.intAt('repetitions'),
    dueOn: row.dateOrNull('due_on'),
  );

  static QuizHeader _toQuizHeader(Map<String, dynamic> row) => QuizHeader(
    id: row.intAt('id'),
    courseId: row.intAt('course_id'),
    title: LocalizedText(en: row.str('title_en'), ar: row.str('title_ar')),
    passMark: row.intAt('pass_mark'),
  );

  static String _isoDate(DateTime value) {
    final day = FlashcardScheduler.dateOnly(value);
    return '${day.year.toString().padLeft(4, '0')}-'
        '${day.month.toString().padLeft(2, '0')}-'
        '${day.day.toString().padLeft(2, '0')}';
  }

  // --- Plumbing -------------------------------------------------------------

  Future<List<Map<String, dynamic>>> _query(
    String sql,
    Map<String, Object?> parameters, [
    Session? session,
  ]) async {
    Future<Result> run(Session s) =>
        s.execute(Sql.named(sql), parameters: parameters);
    final result = session != null
        ? await run(session)
        : await _database.run(run);
    return result.map((row) => row.toColumnMap()).toList();
  }

  Future<void> _execute(
    String sql,
    Map<String, Object?> parameters, [
    Session? session,
  ]) async {
    await _query(sql, parameters, session);
  }
}
