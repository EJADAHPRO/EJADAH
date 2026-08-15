import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_server/src/http/api_error.dart';
import 'package:ejadah_server/src/http/middleware.dart';
import 'package:ejadah_server/src/modules/roadmap/roadmap_repository.dart';
import 'package:ejadah_server/src/modules/roadmap/roadmap_service.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

import 'support/test_database.dart';

/// The ownership proof.
///
/// A roadmap holds the user's specialty, budget and target regions — their
/// private career and financial profile. An id alone must never be enough to
/// read it, and certainly never enough to write it.
///
/// This suite exists because that was once untrue: `findRoadmap` matched on id
/// with no owner predicate, so any signed-in caller could read another
/// account's roadmap and flip its stages. These tests fail against that code.
void main() {
  late TestDatabase db;
  late RoadmapRepository repository;
  late RoadmapService service;

  late String alice;
  late String bob;
  late String aliceRoadmap;

  setUpAll(() async {
    db = await TestDatabase.open();
  });

  tearDownAll(() async {
    await db.close();
  });

  setUp(() async {
    await db.reset();
    repository = RoadmapRepository(db.database);
    service = RoadmapService(repository: repository);

    alice = await _createUser(db, 'alice@ejadah.test');
    bob = await _createUser(db, 'bob@ejadah.test');
    aliceRoadmap = await _createRoadmap(db, userId: alice);
  });

  group('reading someone else\'s roadmap', () {
    test('the owner reads it', () async {
      final view = await service.roadmap(aliceRoadmap, userId: alice);
      expect(view.roadmap.id, aliceRoadmap);
    });

    test('another signed-in user gets not-found, not the data', () async {
      // Not-found rather than forbidden: a 403 would confirm the id is real,
      // which is itself a disclosure.
      await expectLater(
        service.roadmap(aliceRoadmap, userId: bob),
        throwsA(
          isA<ApiException>().having(
            (error) => error.code,
            'code',
            ApiErrorCode.notFound,
          ),
        ),
      );
    });

    test('a caller with no identity at all gets nothing', () async {
      // Neither a user nor a device token owns anything. Without an explicit
      // guard this call would match the `user_id IS NULL` branch.
      expect(await repository.findRoadmapFor(aliceRoadmap), isNull);
    });

    test('a guest reads their own draft through the device token', () async {
      final guestRoadmap = await _createRoadmap(db, deviceToken: 'device-1');

      expect(
        (await repository.findRoadmapFor(
          guestRoadmap,
          deviceToken: 'device-1',
        ))?.id,
        guestRoadmap,
      );
      // A different device is a different guest.
      expect(
        await repository.findRoadmapFor(guestRoadmap, deviceToken: 'device-2'),
        isNull,
      );
      // And a signed-in stranger is still a stranger.
      expect(await repository.findRoadmapFor(guestRoadmap, userId: bob), isNull);
    });
  });

  group('writing someone else\'s roadmap', () {
    test('a stranger cannot complete a stage', () async {
      await expectLater(
        service.setStageComplete(
          roadmapId: aliceRoadmap,
          position: 1,
          isComplete: true,
          userId: bob,
        ),
        throwsA(isA<ApiException>()),
      );

      final stage = await db.execute(
        'SELECT is_complete FROM roadmap_stages '
        'WHERE roadmap_id = @id AND position = 1',
        {'id': aliceRoadmap},
      );
      expect(stage.first[0], isFalse, reason: 'the write must not have landed');
    });

    test('the repository write is scoped even called directly', () async {
      // Defence in depth: the check-then-write pair can be separated by a
      // refactor, so the predicate lives on the write itself.
      await repository.setStageComplete(
        roadmapId: aliceRoadmap,
        position: 1,
        isComplete: true,
        userId: bob,
      );

      final stage = await db.execute(
        'SELECT is_complete FROM roadmap_stages '
        'WHERE roadmap_id = @id AND position = 1',
        {'id': aliceRoadmap},
      );
      expect(stage.first[0], isFalse);
    });

    test('setSaved is scoped to the owner', () async {
      await repository.setSaved(aliceRoadmap, true, userId: bob);
      var saved = await db.execute(
        'SELECT is_saved FROM roadmaps WHERE id = @id',
        {'id': aliceRoadmap},
      );
      expect(saved.first[0], isFalse);

      await repository.setSaved(aliceRoadmap, true, userId: alice);
      saved = await db.execute('SELECT is_saved FROM roadmaps WHERE id = @id', {
        'id': aliceRoadmap,
      });
      expect(saved.first[0], isTrue);
    });

    test('a stranger cannot clone the answers through what-if', () async {
      await expectLater(
        service.whatIf(
          parentId: aliceRoadmap,
          preset: WhatIfPreset.budgetPlus50,
          userId: bob,
        ),
        throwsA(isA<ApiException>()),
      );
    });

    test('a stranger cannot save it into their own account', () async {
      await expectLater(
        service.save(aliceRoadmap, bob),
        throwsA(isA<ApiException>()),
      );

      final owner = await db.execute(
        'SELECT user_id FROM roadmaps WHERE id = @id',
        {'id': aliceRoadmap},
      );
      expect(owner.first[0], alice, reason: 'ownership must not transfer');
    });

    test('claiming only ever takes an unowned roadmap', () async {
      final guestRoadmap = await _createRoadmap(db, deviceToken: 'device-1');

      // The guest signs in and saves the draft they made: a claim.
      final view = await service.save(
        guestRoadmap,
        bob,
        deviceToken: 'device-1',
      );
      expect(view.roadmap.id, guestRoadmap);

      final claimed = await db.execute(
        'SELECT user_id, device_token, is_saved FROM roadmaps WHERE id = @id',
        {'id': guestRoadmap},
      );
      expect(claimed.first[0], bob);
      expect(claimed.first[1], isNull, reason: 'the device token is spent');
      expect(claimed.first[2], isTrue);

      // The same claim cannot then be pointed at a roadmap someone owns.
      await repository.claimForUser(aliceRoadmap, bob);
      final owner = await db.execute(
        'SELECT user_id FROM roadmaps WHERE id = @id',
        {'id': aliceRoadmap},
      );
      expect(owner.first[0], alice);
    });
  });

  group('generating without an owner', () {
    test('is a validation error, not a constraint violation', () async {
      // A guest generates against their device token. With neither that nor a
      // user, the row cannot be read back afterwards — and the caller used to
      // get a 500 from `roadmaps_has_owner` for what is a missing header.
      await expectLater(
        service.generate(
          answers: const RoadmapAnswers(
            path: RoadmapPath.generalPractice,
            stage: CareerStage.generalDentist,
            yearsQualified: 4,
            budgetUsd: 8000,
            monthsAvailable: 18,
            regions: [RoadmapRegion.gulf],
            languages: ['ar', 'en'],
          ),
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
  });

  group('the rate limiter key', () {
    test('X-Forwarded-For is ignored unless a proxy of ours is declared', () {
      // Rotating this header was enough to defeat the limiter entirely: 30
      // sign-in attempts, 30 distinct keys, no 429. The header is written by
      // the client and is not evidence of anything on its own.
      final request = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/auth/login'),
        headers: {'x-forwarded-for': '198.51.100.7'},
      );

      expect(clientAddress(request, trustedProxyCount: 0), 'unknown');
    });

    test('with one trusted proxy, the last hop is the client', () {
      final request = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/auth/login'),
        headers: {
          // The left entries are whatever the caller chose to write; only the
          // rightmost was appended by our own proxy.
          'x-forwarded-for': '10.0.0.9, 203.0.113.5',
        },
      );

      expect(clientAddress(request, trustedProxyCount: 1), '203.0.113.5');
    });

    test('a forged header shorter than the proxy chain is discarded', () {
      final request = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/auth/login'),
        headers: {'x-forwarded-for': '198.51.100.7'},
      );

      // Two proxies declared, one entry present: the chain does not add up, so
      // the header is not used at all.
      expect(clientAddress(request, trustedProxyCount: 2), 'unknown');
    });

    test('the limiter still fires on a stable key', () {
      final limiter = RateLimiter(limit: 3, window: const Duration(minutes: 5));
      final now = DateTime.utc(2026, 9, 10, 9);

      expect(limiter.consume('login:1.2.3.4', now: now), isNull);
      expect(limiter.consume('login:1.2.3.4', now: now), isNull);
      expect(limiter.consume('login:1.2.3.4', now: now), isNull);
      expect(limiter.consume('login:1.2.3.4', now: now), isNotNull);
    });
  });
}

Future<String> _createUser(TestDatabase db, String email) async {
  final result = await db.execute(
    '''
    INSERT INTO users (email, password_hash, full_name_en, full_name_ar)
    VALUES (@email, 'x', 'Test User', 'مستخدم')
    RETURNING id
    ''',
    {'email': email},
  );
  return result.first[0]! as String;
}

/// A roadmap carrying a value that must never appear in a stranger's response.
Future<String> _createRoadmap(
  TestDatabase db, {
  String? userId,
  String? deviceToken,
}) async {
  final result = await db.execute(
    '''
    INSERT INTO roadmaps (
      user_id, device_token, destination_name_en, destination_name_ar,
      fit_score, headline_en, headline_ar, answers, reference_data_version
    ) VALUES (
      @user_id, @device_token, 'Germany', 'ألمانيا', 74,
      'Germany fits your answers', 'ألمانيا تناسب إجاباتك',
      '{"specialty":"private-to-alice","budget_usd":8000}'::jsonb,
      'test'
    )
    RETURNING id
    ''',
    {'user_id': userId, 'device_token': deviceToken},
  );
  final id = result.first[0]! as String;

  await db.execute(
    '''
    INSERT INTO roadmap_stages (
      roadmap_id, position, title_en, title_ar, projected_start, projected_end
    ) VALUES (
      @id, 1, 'Approbation paperwork', 'أوراق الاعتماد',
      DATE '2026-09-01', DATE '2026-12-01'
    )
    ''',
    {'id': id},
  );
  return id;
}

