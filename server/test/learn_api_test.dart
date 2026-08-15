import 'dart:convert';
import 'dart:io';

import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_server/src/http/middleware.dart';
import 'package:ejadah_server/src/modules/learn/learn_repository.dart';
import 'package:ejadah_server/src/modules/learn/learn_routes.dart';
import 'package:ejadah_server/src/modules/learn/learn_service.dart';
import 'package:ejadah_server/src/observability/logger.dart';
import 'package:ejadah_server/src/services/token_service.dart';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:test/test.dart';

import 'support/test_database.dart';

/// The Learn HTTP surface, over a real socket and a real database.
///
/// The module is exercised through the wire rather than through the service,
/// because the things most worth proving here are wire-level: that a guest can
/// browse, that a locked lesson's video URL is absent from the JSON, and that
/// playback position survives a restart because it lives on the server.
void main() {
  late TestDatabase db;
  late HttpServer server;
  late String baseUrl;
  late LearnRepository repository;
  late TokenService tokens;

  late String ownerId;
  late String ownerToken;
  late String strangerId;
  late String strangerToken;
  late int courseId;
  late List<int> lessonIds;
  late int deckId;
  late List<int> cardIds;

  setUpAll(() async {
    db = await TestDatabase.open();
    repository = LearnRepository(db.database);
    tokens = TokenService(db.config);

    final handler = const Pipeline()
        .addMiddleware(contextMiddleware(tokens))
        .addMiddleware(errorMiddleware(AppLogger('test', sink: _Silent())))
        .addHandler(
          learnRoutes(
            LearnService(repository: repository, config: db.config),
          ).call,
        );

    // Port 0 asks the OS for a free port, so the suite cannot collide with a
    // development server someone left running.
    server = await shelf_io.serve(handler, InternetAddress.loopbackIPv4, 0);
    baseUrl = 'http://${server.address.host}:${server.port}';
  });

  tearDownAll(() async {
    await server.close(force: true);
    await db.close();
  });

  setUp(() async {
    await db.reset();

    ownerId = await _createUser(db, 'owner@ejadah.test');
    strangerId = await _createUser(db, 'stranger@ejadah.test');
    ownerToken = tokens.issueAccessToken(
      userId: ownerId,
      role: UserRole.student,
    );
    strangerToken = tokens.issueAccessToken(
      userId: strangerId,
      role: UserRole.student,
    );

    courseId = await _createCourse(db, slug: 'aligner-basics');
    lessonIds = await _createLessons(db, courseId);
    (deckId, cardIds) = await _createDeck(db, courseId);
  });

  Future<http.Response> get(String path, {String? token}) => http.get(
    Uri.parse('$baseUrl$path'),
    headers: {if (token != null) 'authorization': 'Bearer $token'},
  );

  Future<http.Response> send(
    String method,
    String path, {
    String? token,
    Object? body,
  }) async {
    final request = http.Request(method, Uri.parse('$baseUrl$path'))
      ..headers['content-type'] = 'application/json';
    if (token != null) request.headers['authorization'] = 'Bearer $token';
    if (body != null) request.body = jsonEncode(body);
    return http.Response.fromStream(await request.send());
  }

  Map<String, dynamic> decode(http.Response response) =>
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

  group('catalogue', () {
    test('a guest can browse and never sees ownership', () async {
      final response = await get('/courses');
      expect(response.statusCode, 200);

      final body = decode(response);
      expect(body['total'], 1);
      expect((body['items'] as List).first['is_owned'], isFalse);
      // The hub cards need a count per department even where it is zero.
      expect((body['departments'] as List).length, 3);
    });

    test('the catalogue narrows by department', () async {
      expect(decode(await get('/courses?department=orthodontics'))['total'], 1);
      expect(decode(await get('/courses?department=digital'))['total'], 0);
    });

    test('a course carries no price, anywhere', () async {
      final wire = utf8.decode((await get('/courses')).bodyBytes);
      // Courses are in-app purchase only and the store is the pricing
      // authority. A price on this wire would be the beginning of a §3.1.1
      // violation.
      expect(wire, isNot(contains('price')));
      expect(wire, contains('iap_product_id'));
    });

    test('course detail assembles the whole screen in one read', () async {
      final body = decode(await get('/courses/aligner-basics'));
      expect((body['course'] as Map)['slug'], 'aligner-basics');
      expect((body['lessons'] as List).length, 4);
      expect((body['decks'] as List).length, 1);
      // A guest has no progress, and the field says so rather than inventing
      // zeroes that look like a started course.
      expect(body['progress'], isNull);
    });

    test('an unknown slug is a not-found, not a crash', () async {
      final response = await get('/courses/does-not-exist');
      expect(response.statusCode, 404);
      expect(decode(response)['error'], isNotNull);
    });
  });

  group('lesson one is always free', () {
    test(
      'lesson one is unlocked and playable without owning anything',
      () async {
        final body = decode(await get('/courses/$courseId/lessons'));
        final lessons = (body['items'] as List).cast<Map<String, dynamic>>();

        expect(lessons.first['position'], 1);
        expect(lessons.first['is_free_preview'], isTrue);
        expect(lessons.first['is_unlocked'], isTrue);
        expect(lessons.first['video_url'], isNotNull);
      },
    );

    test('a locked lesson carries no video URL on the wire', () async {
      final body = decode(await get('/courses/$courseId/lessons'));
      final lessons = (body['items'] as List).cast<Map<String, dynamic>>();

      for (final lesson in lessons.skip(1)) {
        expect(lesson['is_unlocked'], isFalse);
        expect(
          lesson['video_url'],
          isNull,
          reason: 'the address of the media is the media',
        );
      }
    });

    test('owning the course unlocks the rest', () async {
      await repository.grantEntitlement(
        userId: ownerId,
        courseId: courseId,
        source: 'dev',
        externalRef: 'dev:$ownerId:$courseId',
      );

      final body = decode(
        await get('/courses/$courseId/lessons', token: ownerToken),
      );
      final lessons = (body['items'] as List).cast<Map<String, dynamic>>();
      expect(lessons.every((lesson) => lesson['is_unlocked'] == true), isTrue);
      expect(lessons.last['video_url'], isNotNull);
    });
  });

  group('playback position', () {
    test(
      'a free preview saves and restores position for a signed-in user',
      () async {
        final saved = await send(
          'PUT',
          '/lessons/${lessonIds.first}/progress',
          token: ownerToken,
          body: {'position_seconds': 143},
        );
        expect(saved.statusCode, 200);
        expect(decode(saved)['position_seconds'], 143);

        // Read back through a different request — this is the "survives a
        // restart" claim, and only server-side storage can make it.
        final reread = decode(
          await get('/courses/$courseId/lessons', token: ownerToken),
        );
        final lesson = (reread['items'] as List).first as Map<String, dynamic>;
        expect(lesson['position_seconds'], 143);
      },
    );

    test('position is clamped to the lesson duration', () async {
      final saved = await send(
        'PUT',
        '/lessons/${lessonIds.first}/progress',
        token: ownerToken,
        body: {'position_seconds': 99999},
      );
      expect(decode(saved)['position_seconds'], 600);
    });

    test('a locked lesson refuses to store progress', () async {
      final response = await send(
        'PUT',
        '/lessons/${lessonIds[1]}/progress',
        token: ownerToken,
        body: {'position_seconds': 10},
      );
      expect(response.statusCode, 403);
    });

    test('a guest cannot store progress at all', () async {
      final response = await send(
        'PUT',
        '/lessons/${lessonIds.first}/progress',
        body: {'position_seconds': 10},
      );
      expect(response.statusCode, 401);
    });

    test(
      'completing a lesson names the next one and tracks the course',
      () async {
        await repository.grantEntitlement(
          userId: ownerId,
          courseId: courseId,
          source: 'dev',
          externalRef: 'dev:$ownerId:$courseId',
        );

        final first = decode(
          await send(
            'POST',
            '/lessons/${lessonIds.first}/complete',
            token: ownerToken,
          ),
        );
        expect((first['progress'] as Map)['completed_count'], 1);
        expect(first['course_complete'], isFalse);
        // The server chooses the auto-advance target, so it can never skip into
        // something the user does not own.
        expect((first['next_lesson'] as Map)['id'], lessonIds[1]);

        for (final id in lessonIds.skip(1)) {
          await send('POST', '/lessons/$id/complete', token: ownerToken);
        }

        final finished = decode(
          await get('/courses/aligner-basics', token: ownerToken),
        );
        final progress = finished['progress']! as Map;
        expect(progress['is_complete'], isTrue);
        expect(progress['completed_at'], isNotNull);
      },
    );
  });

  group('entitlement', () {
    test('the development simulator grants and enrols', () async {
      final response = await send(
        'POST',
        '/courses/$courseId/entitlement',
        token: ownerToken,
        body: {'source': 'dev'},
      );
      expect(response.statusCode, 201);
      expect(decode(response)['granted'], isTrue);
      expect((decode(response)['course'] as Map)['is_owned'], isTrue);

      final enrolled = await db.execute(
        'SELECT count(*) FROM enrollments WHERE user_id = @id::uuid',
        {'id': ownerId},
      );
      expect((enrolled.first[0]! as num).toInt(), 1);
    });

    test('granting twice is a no-op rather than a second row', () async {
      await send(
        'POST',
        '/courses/$courseId/entitlement',
        token: ownerToken,
        body: {'source': 'dev'},
      );
      final second = await send(
        'POST',
        '/courses/$courseId/entitlement',
        token: ownerToken,
        body: {'source': 'dev'},
      );
      expect(second.statusCode, 201);
      expect(decode(second)['granted'], isFalse);

      final rows = await db.execute(
        'SELECT count(*) FROM entitlements WHERE user_id = @id::uuid',
        {'id': ownerId},
      );
      expect((rows.first[0]! as num).toInt(), 1);
    });

    test('an in-app purchase without a receipt is refused', () async {
      final response = await send(
        'POST',
        '/courses/$courseId/entitlement',
        token: ownerToken,
        body: {'source': 'iap'},
      );
      expect(response.statusCode, 422);
    });

    test('one receipt cannot be redeemed by two accounts', () async {
      final first = await send(
        'POST',
        '/courses/$courseId/entitlement',
        token: ownerToken,
        body: {'source': 'iap', 'receipt': 'txn-1000000123'},
      );
      expect(first.statusCode, 201);

      final second = await send(
        'POST',
        '/courses/$courseId/entitlement',
        token: strangerToken,
        body: {'source': 'iap', 'receipt': 'txn-1000000123'},
      );
      expect(second.statusCode, 409);
    });

    test(
      'restore reads ownership back, which is what makes it cross-device',
      () async {
        await send(
          'POST',
          '/courses/$courseId/entitlement',
          token: ownerToken,
          body: {'source': 'dev'},
        );

        final restored = decode(await get('/entitlements', token: ownerToken));
        expect(restored['total'], 1);
        expect((restored['items'] as List).first['slug'], 'aligner-basics');

        // A different account restores nothing, which is the point of the check.
        expect(
          decode(await get('/entitlements', token: strangerToken))['total'],
          0,
        );
      },
    );
  });

  group('flashcards', () {
    setUp(() async {
      await repository.grantEntitlement(
        userId: ownerId,
        courseId: courseId,
        source: 'dev',
        externalRef: 'dev:$ownerId:$courseId',
      );
    });

    test('every unseen card is due', () async {
      final body = decode(await get('/decks/$deckId/due', token: ownerToken));
      expect(body['due_count'], cardIds.length);
      expect((body['items'] as List).length, cardIds.length);
    });

    test('"got it" pushes the card out and drops the due count', () async {
      final response = await send(
        'POST',
        '/flashcards/${cardIds.first}/review',
        token: ownerToken,
        body: {'outcome': 'got_it'},
      );
      expect(response.statusCode, 200);

      final body = decode(response);
      expect(body['interval_days'], 1);
      expect(body['repetitions'], 1);
      expect(body['got_it_count'], 1);
      expect(body['remaining_due'], cardIds.length - 1);

      final queue = decode(await get('/decks/$deckId/due', token: ownerToken));
      expect(queue['due_count'], cardIds.length - 1);
    });

    test('"again" keeps the card in today\'s queue', () async {
      final body = decode(
        await send(
          'POST',
          '/flashcards/${cardIds.first}/review',
          token: ownerToken,
          body: {'outcome': 'again'},
        ),
      );
      expect(body['interval_days'], 0);
      expect(body['again_count'], 1);
      expect(body['remaining_due'], cardIds.length);
    });

    test('the state and the review are both written', () async {
      await send(
        'POST',
        '/flashcards/${cardIds.first}/review',
        token: ownerToken,
        body: {'outcome': 'got_it'},
      );

      final states = await db.execute(
        'SELECT interval_days, repetitions, ease FROM flashcard_states '
        'WHERE user_id = @id::uuid',
        {'id': ownerId},
      );
      expect(states.length, 1);
      expect((states.first[0]! as num).toInt(), 1);

      final reviews = await db.execute(
        'SELECT outcome FROM flashcard_reviews WHERE user_id = @id::uuid',
        {'id': ownerId},
      );
      expect(reviews.length, 1);
      expect(reviews.first[0].toString(), 'got_it');
    });

    test('an unknown outcome is rejected before anything is written', () async {
      final response = await send(
        'POST',
        '/flashcards/${cardIds.first}/review',
        token: ownerToken,
        body: {'outcome': 'mastered'},
      );
      expect(response.statusCode, 422);

      final reviews = await db.execute(
        'SELECT count(*) FROM flashcard_reviews WHERE user_id = @id::uuid',
        {'id': ownerId},
      );
      expect((reviews.first[0]! as num).toInt(), 0);
    });

    test('a stranger cannot study a deck they did not buy', () async {
      expect(
        (await get('/decks/$deckId/due', token: strangerToken)).statusCode,
        403,
      );
      expect(
        (await send(
          'POST',
          '/flashcards/${cardIds.first}/review',
          token: strangerToken,
          body: {'outcome': 'got_it'},
        )).statusCode,
        403,
      );
    });
  });

  group('handouts', () {
    test('an owner lists them and a stranger does not', () async {
      await db.execute(
        '''
        INSERT INTO handouts (course_id, title_en, title_ar, storage_key, bytes)
        VALUES (@id, 'Checklist', 'قائمة فحص', 'handouts/checklist.pdf', 20480)
        ''',
        {'id': courseId},
      );

      expect(
        (await get(
          '/courses/$courseId/handouts',
          token: strangerToken,
        )).statusCode,
        403,
      );

      await repository.grantEntitlement(
        userId: ownerId,
        courseId: courseId,
        source: 'dev',
        externalRef: 'dev:$ownerId:$courseId',
      );
      final body = decode(
        await get('/courses/$courseId/handouts', token: ownerToken),
      );
      expect(body['total'], 1);
      expect((body['items'] as List).first['bytes'], 20480);
    });
  });

  test('a typo\'d id is a plain rejection, never a 500', () async {
    // A well-formed id for a course that does not exist is a not-found.
    expect((await get('/courses/999999/lessons')).statusCode, 404);
    // A malformed one is a rejection, not a driver crash surfacing as a 500.
    expect(
      (await get('/decks/not-a-number/due', token: ownerToken)).statusCode,
      422,
    );
  });
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

class _Silent implements IOSink {
  @override
  void writeln([Object? object = '']) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

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

Future<int> _createCourse(TestDatabase db, {required String slug}) async {
  final rows = await db.execute(
    '''
    INSERT INTO courses (
      slug, title_en, title_ar, department, iap_product_id, level_en, level_ar,
      cpd_points
    ) VALUES (
      @slug, 'Aligner basics', 'أساسيات المصففات', 'orthodontics',
      'international.ejadah.course.test', 'Intermediate', 'متوسط', 6
    )
    RETURNING id
    ''',
    {'slug': slug},
  );
  return (rows.first[0]! as num).toInt();
}

Future<List<int>> _createLessons(TestDatabase db, int courseId) async {
  final ids = <int>[];
  for (var position = 1; position <= 4; position++) {
    final rows = await db.execute(
      '''
      INSERT INTO lessons (
        course_id, position, title_en, title_ar, duration_seconds, video_url,
        is_free_preview
      ) VALUES (
        @course_id, @position, @title_en, @title_ar, 600, @video, @free
      )
      RETURNING id
      ''',
      {
        'course_id': courseId,
        'position': position,
        'title_en': 'Lesson $position',
        'title_ar': 'الدرس $position',
        'video': 'https://media.example.test/lesson-$position.m3u8',
        // Deliberately false even for lesson one: the server must make lesson
        // one free by rule, not because a row happened to say so.
        'free': false,
      },
    );
    ids.add((rows.first[0]! as num).toInt());
  }
  return ids;
}

Future<(int, List<int>)> _createDeck(TestDatabase db, int courseId) async {
  final deckRows = await db.execute(
    '''
    INSERT INTO flashcard_decks (course_id, title_en, title_ar)
    VALUES (@course_id, 'Key numbers', 'الأرقام الأساسية')
    RETURNING id
    ''',
    {'course_id': courseId},
  );
  final deckId = (deckRows.first[0]! as num).toInt();

  final ids = <int>[];
  for (var position = 1; position <= 3; position++) {
    final rows = await db.execute(
      '''
      INSERT INTO flashcards (
        deck_id, position, front_en, front_ar, back_en, back_ar
      ) VALUES (@deck_id, @position, @front, @front_ar, @back, @back_ar)
      RETURNING id
      ''',
      {
        'deck_id': deckId,
        'position': position,
        'front': 'Front $position',
        'front_ar': 'الوجه $position',
        'back': 'Back $position',
        'back_ar': 'الظهر $position',
      },
    );
    ids.add((rows.first[0]! as num).toInt());
  }
  return (deckId, ids);
}
