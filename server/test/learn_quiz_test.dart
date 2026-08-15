import 'dart:convert';

import 'package:ejadah_server/src/http/api_error.dart';
import 'package:ejadah_server/src/modules/learn/learn_repository.dart';
import 'package:ejadah_server/src/modules/learn/learn_service.dart';
import 'package:test/test.dart';

import 'support/test_database.dart';

/// Quiz grading.
///
/// Three properties are load-bearing and each is tested against the real
/// database rather than a double:
///
/// * grading happens on the server and the arithmetic matches what the screen
///   quotes ("{score}% — {correct} of {total}");
/// * the answer key never reaches the client before an attempt is graded —
///   not the `is_correct` flag, and not the explanation that gives it away;
/// * below 60% the result offers ONE session, never a package, and never
///   blocks a retake.
void main() {
  late TestDatabase db;
  late LearnService learn;
  late LearnRepository repository;

  late String ownerId;
  late String strangerId;
  late int courseId;
  late int quizId;
  late List<int> questionIds;
  late Map<int, int> correctOption;
  late Map<int, int> wrongOption;

  setUpAll(() async {
    db = await TestDatabase.open();
  });

  tearDownAll(() async {
    await db.close();
  });

  setUp(() async {
    await db.reset();
    repository = LearnRepository(db.database);
    learn = LearnService(repository: repository, config: db.config);

    ownerId = await _createUser(db, 'owner@ejadah.test');
    strangerId = await _createUser(db, 'stranger@ejadah.test');
    courseId = await _createCourse(db);
    await _createLesson(db, courseId);

    // The owner bought the course; the stranger did not.
    await repository.grantEntitlement(
      userId: ownerId,
      courseId: courseId,
      source: 'dev',
      externalRef: 'dev:$ownerId:$courseId',
    );

    final quiz = await _createQuiz(db, courseId);
    quizId = quiz.quizId;
    questionIds = quiz.questionIds;
    correctOption = quiz.correctOption;
    wrongOption = quiz.wrongOption;
  });

  group('grading correctness', () {
    test('all five right scores 100 and stores the attempt', () async {
      final graded = await learn.submitAttempt(
        userId: ownerId,
        quizId: quizId,
        answers: {for (final id in questionIds) id: correctOption[id]},
      );

      expect(graded.attempt.scorePercent, 100);
      expect(graded.attempt.correctCount, 5);
      expect(graded.attempt.questionCount, 5);
      expect(graded.passed, isTrue);
      expect(graded.attempt.results.values.every((value) => value), isTrue);

      // Stored, not merely returned: the certificate and the CPD ledger read
      // this row later.
      final stored = await db.execute(
        'SELECT score_percent, correct_count FROM quiz_attempts '
        'WHERE user_id = @user_id::uuid',
        {'user_id': ownerId},
      );
      expect(stored.length, 1);
      expect((stored.first[0]! as num).toInt(), 100);
      expect((stored.first[1]! as num).toInt(), 5);

      final answers = await db.execute(
        'SELECT count(*) FROM quiz_answers WHERE attempt_id = @id::uuid',
        {'id': graded.attempt.id},
      );
      expect((answers.first[0]! as num).toInt(), 5);
    });

    test(
      'three of five is 60 percent, and the per-question map agrees',
      () async {
        final graded = await learn.submitAttempt(
          userId: ownerId,
          quizId: quizId,
          answers: {
            questionIds[0]: correctOption[questionIds[0]],
            questionIds[1]: correctOption[questionIds[1]],
            questionIds[2]: correctOption[questionIds[2]],
            questionIds[3]: wrongOption[questionIds[3]],
            questionIds[4]: wrongOption[questionIds[4]],
          },
        );

        expect(graded.attempt.correctCount, 3);
        expect(graded.attempt.scorePercent, 60);
        expect(graded.attempt.results[questionIds[0]], isTrue);
        expect(graded.attempt.results[questionIds[3]], isFalse);

        final feedback = graded.questions;
        expect(feedback.length, 5);
        expect(feedback.first['is_correct'], isTrue);
        expect(feedback.last['is_correct'], isFalse);
        // The correct answer is revealed only now, after grading.
        expect(
          feedback.last['correct_option_id'],
          correctOption[questionIds[4]],
        );
      },
    );

    test('a skipped question is wrong, not an error', () async {
      final graded = await learn.submitAttempt(
        userId: ownerId,
        quizId: quizId,
        answers: {
          questionIds[0]: correctOption[questionIds[0]],
          // The other four are simply absent.
        },
      );

      expect(graded.attempt.correctCount, 1);
      expect(graded.attempt.scorePercent, 20);
      expect(graded.questions[1]['selected_option_id'], isNull);
      expect(graded.questions[1]['is_correct'], isFalse);
      // A skipped question still gets its explanation. The explanation is the
      // point of the quiz.
      expect((graded.questions[1]['explanation'] as Map)['en'], isNot(isEmpty));
    });

    test('every graded question carries both languages', () async {
      final graded = await learn.submitAttempt(
        userId: ownerId,
        quizId: quizId,
        answers: {for (final id in questionIds) id: correctOption[id]},
      );

      for (final question in graded.questions) {
        final explanation = question['explanation']! as Map;
        expect(explanation['en'], isNotEmpty);
        expect(explanation['ar'], isNotEmpty);
      }
    });

    test('an option belonging to another question is rejected', () async {
      expect(
        () => learn.submitAttempt(
          userId: ownerId,
          quizId: quizId,
          answers: {questionIds[0]: correctOption[questionIds[1]]},
        ),
        throwsA(
          isA<ApiException>().having(
            (error) => error.code,
            'code',
            ApiErrorCode.validation,
          ),
        ),
      );
    });

    test('a question from another quiz is rejected', () async {
      final other = await _createQuiz(db, courseId);
      expect(
        () => learn.submitAttempt(
          userId: ownerId,
          quizId: quizId,
          answers: {other.questionIds.first: null},
        ),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('the answer key never leaks', () {
    test(
      'the client-facing quiz carries no is_correct and no explanation',
      () async {
        final payload = await learn.quizForClient(
          userId: ownerId,
          quizId: quizId,
        );

        // Serialised, not walked: a key added to a nested map later would slip
        // past a structural check but not past a substring search of the wire.
        final wire = jsonEncode(payload);
        expect(wire, isNot(contains('is_correct')));
        expect(wire, isNot(contains('explanation')));
        expect(wire, isNot(contains('correct_option_id')));

        // And the marker text seeded into the explanations is nowhere in it.
        expect(wire, isNot(contains('BECAUSE-THE-KEY')));

        final questions = payload['questions']! as List;
        expect(questions.length, 5);
        for (final question in questions.cast<Map<String, dynamic>>()) {
          final options = question['options']! as List;
          expect(options.length, 4);
          for (final option in options.cast<Map<String, dynamic>>()) {
            expect(option.containsKey('is_correct'), isFalse);
            expect(option['label'], isNotNull);
          }
        }
      },
    );

    test('grading reveals the key only in the graded response', () async {
      final before = jsonEncode(
        await learn.quizForClient(userId: ownerId, quizId: quizId),
      );
      expect(before, isNot(contains('is_correct')));

      final graded = await learn.submitAttempt(
        userId: ownerId,
        quizId: quizId,
        answers: {for (final id in questionIds) id: wrongOption[id]},
      );
      final after = jsonEncode(graded.toJson());
      expect(after, contains('is_correct'));
      expect(after, contains('BECAUSE-THE-KEY'));
    });

    test('a stranger cannot read the quiz at all', () async {
      expect(
        () => learn.quizForClient(userId: strangerId, quizId: quizId),
        throwsA(
          isA<ApiException>().having(
            (error) => error.code,
            'code',
            ApiErrorCode.authorization,
          ),
        ),
      );
    });

    test('a stranger cannot submit an attempt to farm the key', () async {
      expect(
        () => learn.submitAttempt(
          userId: strangerId,
          quizId: quizId,
          answers: {questionIds.first: correctOption[questionIds.first]},
        ),
        throwsA(
          isA<ApiException>().having(
            (error) => error.code,
            'code',
            ApiErrorCode.authorization,
          ),
        ),
      );

      final stored = await db.execute(
        'SELECT count(*) FROM quiz_attempts WHERE user_id = @id::uuid',
        {'id': strangerId},
      );
      expect((stored.first[0]! as num).toInt(), 0);
    });
  });

  group('below 60 percent', () {
    Future<Map<String, dynamic>> scoreTwoOfFive() async {
      final graded = await learn.submitAttempt(
        userId: ownerId,
        quizId: quizId,
        answers: {
          questionIds[0]: correctOption[questionIds[0]],
          questionIds[1]: correctOption[questionIds[1]],
          questionIds[2]: wrongOption[questionIds[2]],
          questionIds[3]: wrongOption[questionIds[3]],
          questionIds[4]: wrongOption[questionIds[4]],
        },
      );
      return graded.toJson();
    }

    test('offers a session', () async {
      final json = await scoreTwoOfFive();
      expect(json['attempt'], isNotNull);
      expect((json['attempt']! as Map)['score_percent'], 40);
      expect(json['offers_session'], isTrue);
      expect(json['passed'], isFalse);
    });

    test('offers a session and never a package', () async {
      final json = await scoreTwoOfFive();
      final wire = jsonEncode(json);
      // The offer is one session on the topic. A package would be an upsell of
      // a person who has just been told they did badly.
      expect(wire, isNot(contains('package')));
      expect(wire, isNot(contains('bundle')));
    });

    test('never blocks a retake', () async {
      await scoreTwoOfFive();

      // Straight back in, no cooldown, no gate.
      final second = await learn.submitAttempt(
        userId: ownerId,
        quizId: quizId,
        answers: {for (final id in questionIds) id: correctOption[id]},
      );
      expect(second.attempt.scorePercent, 100);
      expect(second.toJson()['offers_session'], isFalse);

      final attempts = await db.execute(
        'SELECT count(*) FROM quiz_attempts WHERE user_id = @id::uuid',
        {'id': ownerId},
      );
      expect((attempts.first[0]! as num).toInt(), 2);
    });

    test('exactly 60 percent does not trigger the offer', () async {
      final graded = await learn.submitAttempt(
        userId: ownerId,
        quizId: quizId,
        answers: {
          questionIds[0]: correctOption[questionIds[0]],
          questionIds[1]: correctOption[questionIds[1]],
          questionIds[2]: correctOption[questionIds[2]],
          questionIds[3]: wrongOption[questionIds[3]],
          questionIds[4]: wrongOption[questionIds[4]],
        },
      );
      expect(graded.attempt.scorePercent, 60);
      expect(graded.toJson()['offers_session'], isFalse);
    });

    test('the best attempt is what the course screen reads back', () async {
      await scoreTwoOfFive();
      await learn.submitAttempt(
        userId: ownerId,
        quizId: quizId,
        answers: {for (final id in questionIds) id: correctOption[id]},
      );

      final payload = await learn.quizForClient(
        userId: ownerId,
        quizId: quizId,
      );
      final best = payload['best_attempt']! as Map;
      expect(best['score_percent'], 100);
      // Even the best-attempt summary carries no key.
      expect(jsonEncode(payload), isNot(contains('BECAUSE-THE-KEY')));
    });
  });
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

Future<String> _createUser(TestDatabase db, String email) async {
  final rows = await db.execute(
    '''
    INSERT INTO users (email, password_hash, full_name_en, full_name_ar)
    VALUES (@email, 'not-a-real-hash', 'Test User', 'مستخدم اختبار')
    RETURNING id
    ''',
    {'email': email},
  );
  return rows.first[0]!.toString();
}

Future<int> _createCourse(TestDatabase db) async {
  final rows = await db.execute('''
    INSERT INTO courses (
      slug, title_en, title_ar, department, iap_product_id, level_en, level_ar
    ) VALUES (
      'test-course', 'Test course', 'دورة اختبار', 'orthodontics',
      'international.ejadah.course.test', 'Intermediate', 'متوسط'
    )
    RETURNING id
    ''');
  return (rows.first[0]! as num).toInt();
}

Future<void> _createLesson(TestDatabase db, int courseId) => db.execute(
  '''
  INSERT INTO lessons (
    course_id, position, title_en, title_ar, duration_seconds, is_free_preview
  ) VALUES (@course_id, 1, 'Lesson one', 'الدرس الأول', 600, true)
  ''',
  {'course_id': courseId},
);

/// A five-question quiz with four options each, exactly one correct.
///
/// The explanations carry the marker "BECAUSE-THE-KEY" so a leak into the
/// client payload is detectable by searching the wire, not only by inspecting
/// field names.
Future<
  ({
    int quizId,
    List<int> questionIds,
    Map<int, int> correctOption,
    Map<int, int> wrongOption,
  })
>
_createQuiz(TestDatabase db, int courseId) async {
  final quizRows = await db.execute(
    '''
    INSERT INTO quizzes (course_id, title_en, title_ar, pass_mark)
    VALUES (@course_id, 'Course quiz', 'اختبار الدورة', 60)
    RETURNING id
    ''',
    {'course_id': courseId},
  );
  final quizId = (quizRows.first[0]! as num).toInt();

  final questionIds = <int>[];
  final correctOption = <int, int>{};
  final wrongOption = <int, int>{};

  for (var position = 1; position <= 5; position++) {
    final questionRows = await db.execute(
      '''
      INSERT INTO quiz_questions (
        quiz_id, position, prompt_en, prompt_ar, explanation_en, explanation_ar
      ) VALUES (
        @quiz_id, @position, @prompt_en, @prompt_ar, @explanation_en,
        @explanation_ar
      )
      RETURNING id
      ''',
      {
        'quiz_id': quizId,
        'position': position,
        'prompt_en': 'Question $position',
        'prompt_ar': 'السؤال $position',
        'explanation_en': 'Option 2 is right BECAUSE-THE-KEY $position.',
        'explanation_ar': 'الخيار الثاني صحيح BECAUSE-THE-KEY $position.',
      },
    );
    final questionId = (questionRows.first[0]! as num).toInt();
    questionIds.add(questionId);

    for (var option = 1; option <= 4; option++) {
      final optionRows = await db.execute(
        '''
        INSERT INTO quiz_options (
          question_id, position, label_en, label_ar, is_correct
        ) VALUES (@question_id, @position, @label_en, @label_ar, @correct)
        RETURNING id
        ''',
        {
          'question_id': questionId,
          'position': option,
          'label_en': 'Option $option',
          'label_ar': 'الخيار $option',
          'correct': option == 2,
        },
      );
      final optionId = (optionRows.first[0]! as num).toInt();
      if (option == 2) {
        correctOption[questionId] = optionId;
      } else if (option == 1) {
        wrongOption[questionId] = optionId;
      }
    }
  }

  return (
    quizId: quizId,
    questionIds: questionIds,
    correctOption: correctOption,
    wrongOption: wrongOption,
  );
}
