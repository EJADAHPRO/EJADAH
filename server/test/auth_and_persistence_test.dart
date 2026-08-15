import 'dart:io';

import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_server/src/db/database.dart';
import 'package:ejadah_server/src/http/api_error.dart';
import 'package:ejadah_server/src/modules/auth/auth_repository.dart';
import 'package:ejadah_server/src/modules/auth/auth_service.dart';
import 'package:ejadah_server/src/modules/career/career_repository.dart';
import 'package:ejadah_server/src/modules/career/career_service.dart';
import 'package:ejadah_server/src/modules/roadmap/roadmap_repository.dart';
import 'package:ejadah_server/src/observability/logger.dart';
import 'package:ejadah_server/src/services/mailer.dart';
import 'package:ejadah_server/src/services/password_hasher.dart';
import 'package:ejadah_server/src/services/token_service.dart';
import 'package:test/test.dart';

import 'support/test_database.dart';

/// Identity, authorization and persistence.
///
/// The persistence tests are the ones that matter most: the acceptance criteria
/// require that saved work survives a restart, and only server-side storage can
/// deliver that. Client state alone does not count.
void main() {
  late TestDatabase db;
  late AuthService auth;
  late AuthRepository authRepository;
  late CareerService career;
  late CareerRepository careerRepository;
  late RoadmapRepository roadmaps;

  setUpAll(() async {
    db = await TestDatabase.open();
  });

  tearDownAll(() async {
    await db.close();
  });

  setUp(() async {
    await db.reset();

    authRepository = AuthRepository(db.database);
    careerRepository = CareerRepository(db.database);
    roadmaps = RoadmapRepository(db.database);
    career = CareerService(careerRepository);

    auth = AuthService(
      database: db.database,
      repository: authRepository,
      roadmaps: roadmaps,
      // Test-strength Argon2: still Argon2id, just not spending a minute
      // deriving keys for a suite that creates dozens of accounts.
      hasher: PasswordHasher.forTests(),
      tokens: TokenService(db.config),
      mailer: const NoopMailer(),
      config: db.config,
      logger: AppLogger('test', sink: _silent),
    );

    await _seedProgramme(db, 1);
  });

  group('registration and sign-in', () {
    test('a password is never stored in a recoverable form', () async {
      await _register(auth, 'khaled@ejadah.test');

      final rows = await db.execute(
        'SELECT password_hash FROM users WHERE email = @email',
        {'email': 'khaled@ejadah.test'},
      );
      final hash = rows.first[0]! as String;

      expect(hash, isNot(contains('SuperSecret1')));
      expect(hash, startsWith(r'$argon2id$'));
    });

    test('sign-in works and the wrong password does not', () async {
      await _register(auth, 'khaled@ejadah.test');

      final session = await auth.login(
        email: 'khaled@ejadah.test',
        password: 'SuperSecret1',
      );
      expect(session.user.email, 'khaled@ejadah.test');
      expect(session.tokens.accessToken, isNotEmpty);

      await expectLater(
        auth.login(email: 'khaled@ejadah.test', password: 'wrong-password'),
        throwsA(isA<ApiException>()),
      );
    });

    test('an unknown address fails exactly like a wrong password', () async {
      await _register(auth, 'khaled@ejadah.test');

      // Identical failures, so the response cannot be used to discover which
      // addresses have accounts.
      final wrongPassword = await _captureFailure(
        () => auth.login(email: 'khaled@ejadah.test', password: 'nope1234'),
      );
      final unknownUser = await _captureFailure(
        () => auth.login(email: 'nobody@ejadah.test', password: 'nope1234'),
      );

      expect(unknownUser.code, wrongPassword.code);
      expect(unknownUser.message.en, wrongPassword.message.en);
      expect(unknownUser.message.ar, wrongPassword.message.ar);
    });

    test('a weak password is rejected with the approved copy', () async {
      final failure = await _captureFailure(
        () => auth.register(
          email: 'weak@ejadah.test',
          password: 'short',
          fullNameEn: 'Weak',
          fullNameAr: 'ضعيف',
          stage: CareerStage.generalDentist,
          language: AppLanguage.en,
        ),
      );

      expect(failure.code, ApiErrorCode.validation);
      expect(failure.fields['password']?.en, contains('8 characters'));
      expect(failure.fields['password']?.ar, isNotEmpty);
    });
  });

  group('refresh tokens', () {
    test('rotate on use, and a replay revokes the whole family', () async {
      final session = await _register(auth, 'khaled@ejadah.test');
      final original = session.tokens.refreshToken;

      final rotated = await auth.refresh(refreshToken: original);
      expect(rotated.tokens.refreshToken, isNot(original));

      // Replaying the consumed token proves it leaked.
      await expectLater(
        auth.refresh(refreshToken: original),
        throwsA(
          isA<ApiException>().having(
            (e) => e.code,
            'code',
            ApiErrorCode.authentication,
          ),
        ),
      );

      // And the token issued from it is revoked too, ending every descendant
      // session rather than only the replayed one.
      await expectLater(
        auth.refresh(refreshToken: rotated.tokens.refreshToken),
        throwsA(isA<ApiException>()),
      );
    });

    test('are stored only as a hash', () async {
      final session = await _register(auth, 'khaled@ejadah.test');

      final rows = await db.execute('SELECT token_hash FROM refresh_tokens');
      expect(rows, isNotEmpty);
      expect(rows.first[0], isNot(session.tokens.refreshToken));
    });
  });

  group('persistence survives a restart', () {
    test('a saved programme is still saved after reconnecting', () async {
      final session = await _register(auth, 'khaled@ejadah.test');
      await career.saveProgramme(session.user.id, 1);

      // A completely separate connection pool, opened after the write and with
      // no shared in-memory state — the closest a test can get to restarting
      // both the app and the server. If the shortlist lived in process memory
      // rather than in PostgreSQL, this read would come back empty.
      final reopened = await Database.connect(_testDatabaseUrl);
      final freshService = CareerService(CareerRepository(reopened));

      final shortlist = await freshService.shortlist(session.user.id);
      expect(shortlist, hasLength(1));
      expect(shortlist.single.id, 1);
      expect(shortlist.single.isSaved, isTrue);

      await reopened.close();

      // And once more through a third pool, after the second was closed.
      final third = await Database.connect(_testDatabaseUrl);
      final survived = await CareerService(
        CareerRepository(third),
      ).shortlist(session.user.id);
      expect(survived, hasLength(1));
      await third.close();
    });

    test('removing is idempotent, so a repeated undo cannot fail', () async {
      final session = await _register(auth, 'khaled@ejadah.test');
      await career.saveProgramme(session.user.id, 1);

      await career.removeSavedProgramme(session.user.id, 1);
      // The client removes optimistically with a five-second undo; a repeated
      // call after a slow network must not error.
      await career.removeSavedProgramme(session.user.id, 1);

      expect(await career.shortlist(session.user.id), isEmpty);
    });
  });

  group('guest work migrates to the account', () {
    test('a roadmap generated as a guest belongs to the new user', () async {
      const deviceToken = 'device-abc';

      // A guest completes the funnel and generates a result.
      await roadmaps.saveDraft(
        deviceToken: deviceToken,
        answers: const {'path': 'gp_abroad'},
        lastStep: 2,
      );
      await db.execute(
        '''
        INSERT INTO roadmaps (
          device_token, destination_name_en, destination_name_ar, fit_score,
          headline_en, headline_ar, answers, reference_data_version
        ) VALUES (
          @token, 'Bahrain', 'البحرين', 74, 'Bahrain is your strongest route',
          'البحرين أقوى مسار لك', '{}'::jsonb, 'test'
        )
        ''',
        {'token': deviceToken},
      );

      // They sign up at the gate.
      final session = await auth.register(
        email: 'guest@ejadah.test',
        password: 'SuperSecret1',
        fullNameEn: 'Guest',
        fullNameAr: 'ضيف',
        stage: CareerStage.freshGraduate,
        language: AppLanguage.ar,
        deviceToken: deviceToken,
      );

      // Losing this work at the gate is a critical defect, so it is asserted.
      final owned = await roadmaps.listRoadmaps(session.user.id);
      expect(owned, isEmpty, reason: 'guest results are adopted but not saved');

      final rows = await db.execute(
        'SELECT count(*) AS n FROM roadmaps WHERE user_id = @id',
        {'id': session.user.id},
      );
      expect(rows.first[0], 1);

      final drafts = await roadmaps.loadDraft(userId: session.user.id);
      expect(drafts, isNotNull);
      expect(drafts!['last_step'], 2);
    });
  });

  group('authorization is enforced on the server', () {
    test('one user cannot read another user\'s shortlist', () async {
      final first = await _register(auth, 'one@ejadah.test');
      final second = await _register(auth, 'two@ejadah.test');

      await career.saveProgramme(first.user.id, 1);

      // Ownership is a column, not a client-side filter.
      expect(await career.shortlist(second.user.id), isEmpty);
      expect(await career.shortlist(first.user.id), hasLength(1));
    });
  });
}

String get _testDatabaseUrl =>
    Platform.environment['TEST_DATABASE_URL'] ??
    'postgres://ejadah:ejadah_dev@localhost:5432/ejadah_test?sslmode=disable';

Future<AuthSession> _register(AuthService auth, String email) => auth.register(
  email: email,
  password: 'SuperSecret1',
  fullNameEn: 'Khaled Test',
  fullNameAr: 'خالد تجريبي',
  stage: CareerStage.generalDentist,
  language: AppLanguage.en,
);

Future<ApiException> _captureFailure(Future<void> Function() action) async {
  try {
    await action();
  } on ApiException catch (error) {
    return error;
  }
  fail('expected the call to fail');
}

Future<void> _seedProgramme(TestDatabase db, int id) => db.execute(
  '''
  INSERT INTO programmes (
    id, region, country, university, programme_name, deadline_status
  ) VALUES (
    @id, 'Middle East', 'United Arab Emirates', 'Test University',
    'MSc in Endodontics', 'open'
  )
  ON CONFLICT (id) DO NOTHING
  ''',
  {'id': id},
);

final IOSink _silent = _NullSink();

class _NullSink implements IOSink {
  @override
  void writeln([Object? object = '']) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
