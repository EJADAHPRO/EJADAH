import 'dart:io';

import 'package:ejadah_server/src/config/config.dart';
import 'package:ejadah_server/src/db/database.dart';
import 'package:ejadah_server/src/observability/logger.dart';
import 'package:postgres/postgres.dart';

/// Seeds the Profile tab's development fixtures.
///
///     dart run tool/seed_profile.dart
///
/// Gives the demo student a public handle, one **verified** Ejadah certificate,
/// one **stated** certificate they added themselves, and a small CPD ledger —
/// so `/dr/{slug}` and `/verify/{code}` have something real to render on a
/// fresh clone, and so the certificate list shows the verified/stated
/// distinction side by side.
///
/// Run `tool/seed.dart` first: this tool seeds the profile layer on top of the
/// demo accounts, not the accounts themselves.
///
/// Development and test only. It refuses to run against a production
/// configuration rather than trusting the operator to remember, exactly as
/// `tool/seed.dart` does.
Future<void> main() async {
  final logger = AppLogger('seed-profile');
  final config = AppConfig.fromEnvironment();

  if (!config.environment.allowsDevelopmentAffordances) {
    stderr.writeln(
      'Refusing to seed: demo profiles carry published handles and fixture '
      'certificates, which must never exist outside development or test.',
    );
    exitCode = 1;
    return;
  }

  final database = await Database.connect(config.databaseUrl);

  try {
    final userId = await _findUser(database, 'student@ejadah.test');
    if (userId == null) {
      stderr.writeln(
        'No student@ejadah.test account found. Run tool/seed.dart first.',
      );
      exitCode = 1;
      return;
    }

    const slug = 'nour-hassan';
    await _claimSlug(database, userId: userId, slug: slug);
    await _upsertCard(database, userId);

    // A verified certificate is Ejadah-issued by definition: the schema's
    // `certificates_verified_are_ejadah_issued` check refuses one without a
    // course. If the Learn seed has not run there is no course to point at, so
    // the verified fixture is skipped rather than forced — a fake "verified"
    // certificate is the one thing this product must never manufacture.
    final courseId = await _anyCourseId(database);
    if (courseId == null) {
      stdout.writeln(
        'No courses found — skipping the verified certificate. '
        'Run the Learn seed, then run this tool again.',
      );
    } else {
      await _upsertVerifiedCertificate(
        database,
        userId: userId,
        courseId: courseId,
      );
    }

    await _upsertStatedCertificate(database, userId);
    await _upsertCpdEntries(database, userId);

    final publicUrl = '${config.publicBaseUrl}/dr/$slug';
    stdout
      ..writeln('Seeded the profile fixtures for student@ejadah.test.')
      ..writeln('  public card   $publicUrl')
      ..writeln(
        courseId == null
            ? '  certificates  1 stated (verified skipped: no course)'
            : '  certificates  1 verified (code EJ-DEMO-0001) + 1 stated',
      )
      ..writeln('  verification  ${config.publicBaseUrl}/verify/EJ-DEMO-0001')
      ..writeln('')
      ..writeln('Both public URLs render for a signed-out visitor, by design.');

    logger.info('profile seed complete', {'slug': slug});
  } finally {
    await database.close();
  }
}

Future<String?> _findUser(Database database, String email) async {
  final rows = await database.run(
    (s) => s.execute(
      Sql.named(
        'SELECT id FROM users WHERE lower(email) = @email '
        'AND deleted_at IS NULL',
      ),
      parameters: {'email': email.toLowerCase()},
    ),
  );
  if (rows.isEmpty) return null;
  return rows.first[0].toString();
}

/// Claims the handle, unless another live account already holds it.
Future<void> _claimSlug(
  Database database, {
  required String userId,
  required String slug,
}) => database.run(
  (s) => s.execute(
    Sql.named('''
      UPDATE users SET public_slug = @slug, updated_at = now()
      WHERE id = @user
        AND NOT EXISTS (
          SELECT 1 FROM users other
          WHERE other.public_slug = @slug
            AND other.id <> @user
            AND other.deleted_at IS NULL
        )
    '''),
    parameters: {'slug': slug, 'user': userId},
  ),
);

/// The public card itself. No avatar: Phase 1 ships no licensed portraits and
/// the card renders initials rather than a broken image.
Future<void> _upsertCard(Database database, String userId) => database.run(
  (s) => s.execute(
    Sql.named('''
      INSERT INTO profiles (
        user_id, title_en, title_ar, clinic_en, clinic_ar,
        bio_en, bio_ar, phone, links, is_public, updated_at
      ) VALUES (
        @user,
        'General dentist · Endodontics',
        'طبيبة أسنان عامة · علاج الجذور',
        'Nile Dental Studio, Zamalek, Cairo',
        'نايل دنتال ستوديو، الزمالك، القاهرة',
        'Root canal treatment and digital workflows. Cairo University, 2023.',
        'علاج الجذور وسير العمل الرقمي. جامعة القاهرة، 2023.',
        '+20 100 123 4567',
        '{"website": "https://ejadah.international",
          "linkedin": "https://www.linkedin.com/in/nour-hassan"}'::jsonb,
        true,
        now()
      )
      ON CONFLICT (user_id) DO UPDATE SET
        title_en = EXCLUDED.title_en,
        title_ar = EXCLUDED.title_ar,
        clinic_en = EXCLUDED.clinic_en,
        clinic_ar = EXCLUDED.clinic_ar,
        bio_en = EXCLUDED.bio_en,
        bio_ar = EXCLUDED.bio_ar,
        phone = EXCLUDED.phone,
        links = EXCLUDED.links,
        is_public = true,
        updated_at = now()
    '''),
    parameters: {'user': userId},
  ),
);

Future<int?> _anyCourseId(Database database) async {
  final rows = await database.run(
    (s) => s.execute('SELECT id FROM courses ORDER BY id LIMIT 1'),
  );
  if (rows.isEmpty) return null;
  return (rows.first[0]! as num).toInt();
}

/// The one certificate that may carry a public verification code.
Future<void> _upsertVerifiedCertificate(
  Database database, {
  required String userId,
  required int courseId,
}) => database.run(
  (s) => s.execute(
    Sql.named('''
      INSERT INTO certificates (
        user_id, title_en, title_ar, issuer_en, issuer_ar, issued_on,
        evidence, cpd_points, course_id, verification_code
      )
      SELECT @user,
             c.title_en, c.title_ar,
             'Ejadah International Academy', 'أكاديمية إجادة الدولية',
             DATE '2026-05-12', 'verified', 8, c.id, 'EJ-DEMO-0001'
      FROM courses c WHERE c.id = @course
      ON CONFLICT (verification_code) DO NOTHING
    '''),
    parameters: {'user': userId, 'course': courseId},
  ),
);

/// A certificate the user states themselves. No code, no course — and the
/// schema would refuse one even if this asked for it.
Future<void> _upsertStatedCertificate(Database database, String userId) =>
    database.run(
      (s) => s.execute(
        Sql.named('''
          INSERT INTO certificates (
            user_id, title_en, title_ar, issuer_en, issuer_ar, issued_on,
            evidence, cpd_points
          )
          SELECT @user,
                 'Clear aligner therapy weekend',
                 'ورشة التقويم الشفاف',
                 'Cairo Dental Congress', 'مؤتمر القاهرة لطب الأسنان',
                 DATE '2025-11-02', 'stated', 3
          WHERE NOT EXISTS (
            SELECT 1 FROM certificates
            WHERE user_id = @user AND title_en = 'Clear aligner therapy weekend'
          )
        '''),
        parameters: {'user': userId},
      ),
    );

Future<void> _upsertCpdEntries(Database database, String userId) =>
    database.run(
      (s) => s.execute(
        Sql.named('''
          INSERT INTO cpd_entries (
            user_id, title_en, title_ar, points, earned_on, evidence,
            certificate_id
          )
          SELECT @user, c.title_en, c.title_ar, c.cpd_points, c.issued_on,
                 c.evidence, c.id
          FROM certificates c
          WHERE c.user_id = @user
            AND c.cpd_points > 0
            AND NOT EXISTS (
              SELECT 1 FROM cpd_entries e WHERE e.certificate_id = c.id
            )
        '''),
        parameters: {'user': userId},
      ),
    );
