import 'dart:convert';
import 'dart:io';

import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_server/src/http/api_error.dart';
import 'package:ejadah_server/src/http/middleware.dart';
import 'package:ejadah_server/src/modules/profile/profile_repository.dart';
import 'package:ejadah_server/src/modules/profile/cv_service.dart';
import 'package:ejadah_server/src/modules/profile/profile_routes.dart';
import 'package:ejadah_server/src/modules/profile/profile_service.dart';
import 'package:ejadah_server/src/observability/logger.dart';
import 'package:ejadah_server/src/services/token_service.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:test/test.dart';

import 'support/test_database.dart';

/// The growth and trust loops.
///
/// `/dr/{slug}` and `/verify/{code}` are the only organic growth in the
/// product, and the only thing a stranger checking a credential ever sees. Two
/// properties are load-bearing and are asserted here rather than assumed:
///
/// * **They work signed out.** Every request in this file is made with no
///   Authorization header at all, through the same middleware stack the real
///   server uses.
/// * **They leak nothing.** The public payload is checked against the actual
///   private values seeded into the row — email, phone, the private document
///   key, the stated certificate, a saved programme — not against a hand-written
///   list of field names that could drift.
void main() {
  late TestDatabase db;
  late ProfileService service;
  late Handler handler;

  setUpAll(() async {
    db = await TestDatabase.open();
  });

  tearDownAll(() async {
    await db.close();
  });

  setUp(() async {
    await db.reset();
    service = ProfileService(
      repository: ProfileRepository(db.database),
      config: db.config,
    );

    // The real pipeline, minus logging noise. contextMiddleware is what turns
    // a missing Authorization header into a guest context rather than a 401,
    // so including it is the point.
    final router = Router()..mount('/profile', profileRoutes(service, CvService(db.database)).call);
    handler = const Pipeline()
        .addMiddleware(contextMiddleware(TokenService(db.config)))
        .addMiddleware(errorMiddleware(AppLogger('test', sink: _silent)))
        .addHandler(router.call);
  });

  group('public profile — /profile/public/{slug}', () {
    test('renders for a visitor with no account and no token', () async {
      await _seedPublishedProfile(db);

      final response = await handler(
        Request('GET', Uri.parse('http://localhost/profile/public/yasmine')),
      );

      expect(response.statusCode, 200);
      final body = jsonDecode(await response.readAsString()) as Map;
      expect((body['display_name'] as Map)['ar'], 'د. ياسمين حسن');
      expect((body['title'] as Map)['en'], 'Endodontist');
      expect(body['share_url'], contains('/dr/yasmine'));
    });

    test('leaks no private field of the account behind it', () async {
      final seeded = await _seedPublishedProfile(db);

      final response = await handler(
        Request('GET', Uri.parse('http://localhost/profile/public/yasmine')),
      );
      final raw = await response.readAsString();

      // Checked against the values actually stored, so a renamed column or a
      // newly added one cannot slip through a stale list of key names.
      for (final secret in [
        seeded.email,
        seeded.phone,
        seeded.userId,
        seeded.documentKey,
        seeded.statedCertificateTitle,
        seeded.savedProgrammeName,
        seeded.bookingNote,
      ]) {
        expect(
          raw,
          isNot(contains(secret)),
          reason: 'the public card must not carry "$secret"',
        );
      }

      final body = jsonDecode(raw) as Map;
      for (final forbidden in [
        'email',
        'phone',
        'user_id',
        'document_url',
        'saved_programmes',
        'bookings',
        'is_premium',
        'view_count',
        'public_view_count',
      ]) {
        expect(body.containsKey(forbidden), isFalse, reason: forbidden);
      }
    });

    test('publishes verified certificates only', () async {
      await _seedPublishedProfile(db);

      final response = await handler(
        Request('GET', Uri.parse('http://localhost/profile/public/yasmine')),
      );
      final body = jsonDecode(await response.readAsString()) as Map;
      final certificates = (body['certificates'] as List)
          .cast<Map<String, dynamic>>();

      expect(certificates, hasLength(1));
      expect(certificates.single['evidence'], 'verified');
      expect(
        (certificates.single['title'] as Map)['en'],
        'Rotary endodontics',
      );
      // The stated one the same user holds is absent, and so is the revoked
      // verified one.
      expect(
        certificates.every((c) => c['evidence'] == 'verified'),
        isTrue,
      );
    });

    test('a revoked certificate never appears on the public card', () async {
      final seeded = await _seedPublishedProfile(db);
      await db.execute(
        "UPDATE certificates SET revoked_at = now(), revoked_reason = 'test' "
        'WHERE id = @id',
        {'id': seeded.verifiedCertificateId},
      );

      final response = await handler(
        Request('GET', Uri.parse('http://localhost/profile/public/yasmine')),
      );
      final body = jsonDecode(await response.readAsString()) as Map;
      expect(body['certificates'], isEmpty);
    });

    test('an unpublished card is not found', () async {
      await _seedPublishedProfile(db, isPublic: false);

      final response = await handler(
        Request('GET', Uri.parse('http://localhost/profile/public/yasmine')),
      );
      expect(response.statusCode, 404);
    });

    test('a deleted account stops resolving immediately', () async {
      await _seedPublishedProfile(db);
      await db.execute('UPDATE users SET deleted_at = now()');

      final response = await handler(
        Request('GET', Uri.parse('http://localhost/profile/public/yasmine')),
      );
      // The undo window keeps the row; it does not keep the card online.
      expect(response.statusCode, 404);
    });

    test('views are counted in aggregate and name no viewer', () async {
      await _seedPublishedProfile(db);

      for (var i = 0; i < 3; i++) {
        await handler(
          Request('GET', Uri.parse('http://localhost/profile/public/yasmine')),
        );
      }

      final rows = await db.execute(
        'SELECT slug, viewed_on, view_count FROM public_profile_views',
      );
      expect(rows, hasLength(1));
      expect(rows.first.toColumnMap()['view_count'], 3);

      // There is no column that could identify a viewer, so no future feature
      // can show the owner who looked.
      final columns = await db.execute(
        "SELECT column_name FROM information_schema.columns "
        "WHERE table_name = 'public_profile_views'",
      );
      final names = columns
          .map((row) => row.toColumnMap()['column_name'].toString())
          .toSet();
      expect(names, {'id', 'slug', 'viewed_on', 'view_count'});
    });
  });

  group('public verification — /profile/verify/{code}', () {
    test('a valid code verifies, with no account and no charge', () async {
      await _seedPublishedProfile(db);

      final response = await handler(
        Request('GET', Uri.parse('http://localhost/profile/verify/EJ-2026-001')),
      );

      expect(response.statusCode, 200);
      final body = jsonDecode(await response.readAsString()) as Map;
      expect(body['outcome'], 'verified');
      expect((body['holder_name'] as Map)['en'], 'Dr Yasmine Hassan');
      expect((body['title'] as Map)['en'], 'Rotary endodontics');
      expect(body['issued_on'], isNotNull);
      expect(body['cpd_points'], 8);
    });

    test('carries the holder, title, date and points — and nothing else',
        () async {
      final seeded = await _seedPublishedProfile(db);

      final response = await handler(
        Request('GET', Uri.parse('http://localhost/profile/verify/EJ-2026-001')),
      );
      final raw = await response.readAsString();
      final body = jsonDecode(raw) as Map<String, dynamic>;

      expect(
        body.keys.toSet(),
        {'outcome', 'holder_name', 'title', 'issued_on', 'cpd_points',
         'share_url'},
      );
      for (final secret in [seeded.email, seeded.phone, seeded.documentKey]) {
        expect(raw, isNot(contains(secret)));
      }
    });

    test('an unknown code is not_found, not an error', () async {
      final response = await handler(
        Request('GET', Uri.parse('http://localhost/profile/verify/NOPE-1')),
      );

      // 200: "there is no such certificate" is the answer the checker asked
      // for, not a failed request.
      expect(response.statusCode, 200);
      final body = jsonDecode(await response.readAsString()) as Map;
      expect(body['outcome'], 'not_found');
      expect(body.containsKey('holder_name'), isFalse);
    });

    test('a revoked certificate returns revoked and withholds the body',
        () async {
      final seeded = await _seedPublishedProfile(db);
      await db.execute(
        "UPDATE certificates SET revoked_at = now(), "
        "revoked_reason = 'issued in error' WHERE id = @id",
        {'id': seeded.verifiedCertificateId},
      );

      final response = await handler(
        Request('GET', Uri.parse('http://localhost/profile/verify/EJ-2026-001')),
      );
      final raw = await response.readAsString();
      final body = jsonDecode(raw) as Map;

      expect(body['outcome'], 'revoked');
      expect(body.containsKey('holder_name'), isFalse);
      expect(body.containsKey('title'), isFalse);
      expect(body.containsKey('cpd_points'), isFalse);
      expect(raw, isNot(contains('Rotary endodontics')));
      expect(raw, isNot(contains(seeded.email)));
      // The reason is internal; a checker sees the state, not our notes.
      expect(raw, isNot(contains('issued in error')));
    });

    test('all three outcomes are reachable from one seeded account', () async {
      final seeded = await _seedPublishedProfile(db);

      expect(
        (await service.verifyCertificate('EJ-2026-001')).outcome,
        VerificationOutcome.verified,
      );
      expect(
        (await service.verifyCertificate('does-not-exist')).outcome,
        VerificationOutcome.notFound,
      );
      await db.execute(
        'UPDATE certificates SET revoked_at = now() WHERE id = @id',
        {'id': seeded.verifiedCertificateId},
      );
      expect(
        (await service.verifyCertificate('EJ-2026-001')).outcome,
        VerificationOutcome.revoked,
      );
    });
  });

  group('a stated certificate can never be verifiable', () {
    test('the database rejects a code on a stated certificate', () async {
      final seeded = await _seedPublishedProfile(db);

      await expectLater(
        db.execute(
          "UPDATE certificates SET verification_code = 'FORGED-1' "
          'WHERE id = @id',
          {'id': seeded.statedCertificateId},
        ),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'constraint',
            contains('certificates_only_verified_have_codes'),
          ),
        ),
      );
    });

    test('the database rejects promoting a stated certificate to verified',
        () async {
      final seeded = await _seedPublishedProfile(db);

      // No course_id, so `certificates_verified_are_ejadah_issued` refuses it:
      // "verified" is reserved for something Ejadah actually issued.
      await expectLater(
        db.execute(
          "UPDATE certificates SET evidence = 'verified' WHERE id = @id",
          {'id': seeded.statedCertificateId},
        ),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'constraint',
            contains('certificates_verified_are_ejadah_issued'),
          ),
        ),
      );
    });

    test('the service creates stated certificates only', () async {
      final seeded = await _seedPublishedProfile(db);

      final created = await service.addStatedCertificate(
        userId: seeded.userId,
        title: const LocalizedText(en: 'Implant course', ar: 'دورة زراعة'),
        issuer: const LocalizedText(en: 'Cairo University', ar: 'جامعة القاهرة'),
        issuedOn: DateTime.utc(2025, 3, 1),
        cpdPoints: 5,
      );

      expect(created.evidence, CredentialEvidence.statedByProfessional);
      expect(created.verificationCode, isNull);
      expect(created.isEjadahIssued, isFalse);

      // And it does not become publicly visible.
      final response = await handler(
        Request('GET', Uri.parse('http://localhost/profile/public/yasmine')),
      );
      expect(await response.readAsString(), isNot(contains('Implant course')));
    });

    test('a future issue date is refused', () async {
      final seeded = await _seedPublishedProfile(db);
      await expectLater(
        service.addStatedCertificate(
          userId: seeded.userId,
          title: const LocalizedText.same('Time travel'),
          issuer: const LocalizedText.same('Nowhere'),
          issuedOn: DateTime.utc(2099, 1, 1),
        ),
        throwsA(
          isA<ApiException>().having(
            (e) => e.code,
            'code',
            ApiErrorCode.validation,
          ),
        ),
      );
    });
  });

  group('the owner card', () {
    test('a link that is not https is refused', () async {
      final seeded = await _seedPublishedProfile(db);

      await expectLater(
        service.saveOwnerProfile(
          userId: seeded.userId,
          isPublic: true,
          title: const LocalizedText.same('Endodontist'),
          clinic: const LocalizedText.same('Nile Dental'),
          bio: const LocalizedText.same(''),
          links: const {'website': 'http://example.com'},
        ),
        throwsA(
          isA<ApiException>().having(
            (e) => e.fields.keys,
            'fields',
            contains('links.website'),
          ),
        ),
      );
    });

    test('a taken handle is refused rather than silently reassigned', () async {
      final seeded = await _seedPublishedProfile(db);
      final otherId = await _insertUser(
        db,
        email: 'other@ejadah.test',
        slug: null,
      );

      await expectLater(
        service.saveOwnerProfile(
          userId: otherId,
          slug: seeded.slug,
          isPublic: true,
          title: const LocalizedText.same(''),
          clinic: const LocalizedText.same(''),
          bio: const LocalizedText.same(''),
        ),
        throwsA(
          isA<ApiException>().having(
            (e) => e.fields.keys,
            'fields',
            contains('slug'),
          ),
        ),
      );
    });

    test('the owner sees a view count and never a viewer', () async {
      final seeded = await _seedPublishedProfile(db);
      await handler(
        Request('GET', Uri.parse('http://localhost/profile/public/yasmine')),
      );

      final owner = await service.ownerProfile(seeded.userId);
      expect(owner.publicViewCount, 1);
      // OwnerProfile carries a number. There is no viewer list to expose.
      expect(owner.toJson()['public_view_count'], 1);
      expect(owner.toJson().containsKey('viewers'), isFalse);
    });

    test('the private card carries the phone the public one hides', () async {
      final seeded = await _seedPublishedProfile(db);
      final owner = await service.ownerProfile(seeded.userId);
      expect(owner.phone, seeded.phone);
    });
  });

  group('the CPD ledger', () {
    test('totals the entries and carries each evidence level', () async {
      final seeded = await _seedPublishedProfile(db);
      final ledger = await service.cpdLedger(seeded.userId);

      expect(ledger.entries, hasLength(2));
      expect(ledger.totalPoints, 11);
      expect(
        ledger.entries.map((e) => e.evidence).toSet(),
        {
          CredentialEvidence.verifiedByEjadah,
          CredentialEvidence.statedByProfessional,
        },
      );
    });
  });

  group('notification preferences', () {
    test('there are exactly three categories and no marketing one', () async {
      final seeded = await _seedPublishedProfile(db);
      final preferences = await service.notificationPreferences(seeded.userId);

      expect(preferences.toJson().keys.toSet(), {
        'deadline_alerts',
        'session_reminders',
        'study_nudges',
      });

      final saved = await service.saveNotificationPreferences(
        seeded.userId,
        preferences.copyWith(studyNudges: false),
      );
      expect(saved.studyNudges, isFalse);
      expect(
        (await service.notificationPreferences(seeded.userId)).studyNudges,
        isFalse,
      );
    });
  });
}

/// What the fixture wrote, so assertions compare against real stored values.
class _Seeded {
  const _Seeded({
    required this.userId,
    required this.slug,
    required this.email,
    required this.phone,
    required this.documentKey,
    required this.verifiedCertificateId,
    required this.statedCertificateId,
    required this.statedCertificateTitle,
    required this.savedProgrammeName,
    required this.bookingNote,
  });

  final String userId;
  final String slug;
  final String email;
  final String phone;
  final String documentKey;
  final String verifiedCertificateId;
  final String statedCertificateId;
  final String statedCertificateTitle;
  final String savedProgrammeName;
  final String bookingNote;
}

/// One account carrying every kind of record the public card must not leak.
Future<_Seeded> _seedPublishedProfile(
  TestDatabase db, {
  bool isPublic = true,
}) async {
  const email = 'yasmine@ejadah.test';
  const phone = '+201001234567';
  const documentKey = 'private/uploads/yasmine-certificate.pdf';
  const statedTitle = 'Aligner therapy weekend';
  const savedProgrammeName = 'MSc in Endodontology';
  const bookingNote = 'private booking note';

  final userId = await _insertUser(db, email: email, slug: 'yasmine');

  await db.execute(
    '''
    INSERT INTO profiles (
      user_id, title_en, title_ar, clinic_en, clinic_ar, bio_en, bio_ar,
      phone, links, is_public
    ) VALUES (
      @user, 'Endodontist', 'أخصائية علاج جذور',
      'Nile Dental Studio', 'نايل دنتال ستوديو',
      'Root canal treatment and digital workflows.',
      'علاج الجذور وسير العمل الرقمي.',
      @phone, '{"website": "https://example.com"}'::jsonb, @is_public
    )
    ''',
    {'user': userId, 'phone': phone, 'is_public': isPublic},
  );

  // A verified certificate needs a course: the schema will not let one exist
  // without an Ejadah course behind it.
  await db.execute(
    '''
    INSERT INTO courses (id, slug, title_en, title_ar, department, iap_product_id)
    VALUES (1, 'rotary-endo', 'Rotary endodontics', 'المعالجة اللبية الدوّارة',
            'orthodontics', 'com.ejadah.rotary')
    ''',
  );

  final verified = await db.execute(
    '''
    INSERT INTO certificates (
      user_id, title_en, title_ar, issuer_en, issuer_ar, issued_on,
      evidence, cpd_points, course_id, verification_code, document_key
    ) VALUES (
      @user, 'Rotary endodontics', 'المعالجة اللبية الدوّارة',
      'Ejadah', 'إجادة', DATE '2026-05-12',
      'verified', 8, 1, 'EJ-2026-001', @document_key
    ) RETURNING id
    ''',
    {'user': userId, 'document_key': documentKey},
  );

  final stated = await db.execute(
    '''
    INSERT INTO certificates (
      user_id, title_en, title_ar, issuer_en, issuer_ar, issued_on,
      evidence, cpd_points, document_key
    ) VALUES (
      @user, @title, 'ورشة التقويم الشفاف', 'Cairo Dental', 'كايرو دنتال',
      DATE '2025-11-02', 'stated', 3, @document_key
    ) RETURNING id
    ''',
    {'user': userId, 'title': statedTitle, 'document_key': documentKey},
  );

  await db.execute(
    '''
    INSERT INTO cpd_entries (user_id, title_en, title_ar, points, earned_on, evidence)
    VALUES (@user, 'Rotary endodontics', 'المعالجة اللبية', 8,
            DATE '2026-05-12', 'verified'),
           (@user, 'Aligner weekend', 'ورشة التقويم', 3,
            DATE '2025-11-02', 'stated')
    ''',
    {'user': userId},
  );

  // Private records that live elsewhere in the account and must not surface.
  await db.execute(
    '''
    INSERT INTO programmes (
      id, university, programme_name, country, region, specialty, degree_type
    ) VALUES (
      901, 'Kings College London', @name, 'United Kingdom',
      'UK & Ireland', 'Endodontics', 'MSc'
    )
    ON CONFLICT (id) DO NOTHING
    ''',
    {'name': savedProgrammeName},
  );
  await db.execute(
    'INSERT INTO saved_programmes (user_id, programme_id) VALUES (@user, 901)',
    {'user': userId},
  );
  await db.execute(
    '''
    INSERT INTO notifications (user_id, category, title_en, title_ar, body_en)
    VALUES (@user, 'session', 'Session tomorrow', 'جلسة غدًا', @note)
    ''',
    {'user': userId, 'note': bookingNote},
  );

  return _Seeded(
    userId: userId,
    slug: 'yasmine',
    email: email,
    phone: phone,
    documentKey: documentKey,
    verifiedCertificateId: verified.first.toColumnMap()['id'].toString(),
    statedCertificateId: stated.first.toColumnMap()['id'].toString(),
    statedCertificateTitle: statedTitle,
    savedProgrammeName: savedProgrammeName,
    bookingNote: bookingNote,
  );
}

Future<String> _insertUser(
  TestDatabase db, {
  required String email,
  required String? slug,
}) async {
  final rows = await db.execute(
    '''
    INSERT INTO users (
      email, password_hash, full_name_en, full_name_ar, public_slug
    ) VALUES (
      @email, 'x', 'Dr Yasmine Hassan', 'د. ياسمين حسن', @slug
    ) RETURNING id
    ''',
    {'email': email, 'slug': slug},
  );
  return rows.first.toColumnMap()['id'].toString();
}

final IOSink _silent = _NullSink();

class _NullSink implements IOSink {
  @override
  void writeln([Object? object = '']) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
