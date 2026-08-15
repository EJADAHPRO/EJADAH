import 'dart:io';

import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_server/src/config/config.dart';
import 'package:ejadah_server/src/db/database.dart';
import 'package:ejadah_server/src/modules/auth/auth_repository.dart';
import 'package:ejadah_server/src/observability/logger.dart';
import 'package:ejadah_server/src/services/password_hasher.dart';
import 'package:postgres/postgres.dart';

/// Seeds development data.
///
///     dart run tool/seed.dart
///
/// Development and test only — it creates accounts with published passwords and
/// professionals whose photos are placeholders. It refuses to run against a
/// production configuration rather than trusting the operator to remember.
///
/// The canonical datasets are NOT seeded here: `tool/import_data.dart` imports
/// the real 199 programmes and 23 country guides. This file adds only the
/// authored fixtures the datasets do not cover — accounts, courses and a
/// marketplace roster.
Future<void> main() async {
  final logger = AppLogger('seed');
  final config = AppConfig.fromEnvironment();

  if (!config.environment.allowsDevelopmentAffordances) {
    stderr.writeln(
      'Refusing to seed: demo accounts with known passwords must never exist '
      'outside development or test.',
    );
    exitCode = 1;
    return;
  }

  final database = await Database.connect(config.databaseUrl);
  final hasher = PasswordHasher.forTests();
  final auth = AuthRepository(database);

  try {
    // --- Demo accounts -------------------------------------------------------
    // Credentials are documented in docs/demo.md.
    final student = await _upsertUser(
      auth,
      hasher,
      email: 'student@ejadah.test',
      nameEn: 'Dr. Nour Hassan',
      nameAr: 'د. نور حسن',
      stage: CareerStage.generalDentist,
    );
    final professional = await _upsertUser(
      auth,
      hasher,
      email: 'tutor@ejadah.test',
      nameEn: 'Dr. Mona Adel',
      nameAr: 'د. منى عادل',
      stage: CareerStage.specialist,
    );
    final admin = await _upsertUser(
      auth,
      hasher,
      email: 'admin@ejadah.test',
      nameEn: 'Ejadah Admin',
      nameAr: 'مشرف إجادة',
      stage: CareerStage.consultantOwner,
    );

    await database.run(
      (s) => s.execute(
        Sql.named("UPDATE users SET role = 'admin' WHERE id = @id"),
        parameters: {'id': admin},
      ),
    );
    await database.run(
      (s) => s.execute(
        Sql.named(
          "UPDATE users SET role = 'professional', "
          "professional_status = 'approved' WHERE id = @id",
        ),
        parameters: {'id': professional},
      ),
    );

    // --- A returning student's saved work ------------------------------------
    // So Home, the shortlist and the deadline strip all have something real to
    // render on a fresh clone.
    await database.run(
      (s) => s.execute(
        Sql.named('''
        INSERT INTO saved_programmes (user_id, programme_id)
        SELECT @user_id, id FROM programmes
        WHERE deadline_status <> 'expired'
        ORDER BY deadline NULLS LAST
        LIMIT 4
        ON CONFLICT DO NOTHING
        '''),
        parameters: {'user_id': student},
      ),
    );

    // --- The marketplace roster ----------------------------------------------
    // Every photo in the handoff's roster is a placeholder and unlicensed for
    // production, so no image URLs are seeded: the app falls back to initials
    // rather than to a broken image or an unlicensed portrait.
    final professionalId = await _seedProfessional(
      database,
      userId: professional,
    );
    await _seedAvailability(database, professionalId);

    stdout
      ..writeln('Seeded development data.')
      ..writeln('  student@ejadah.test   / EjadahDemo1')
      ..writeln(
        '  tutor@ejadah.test     / EjadahDemo1  (approved professional)',
      )
      ..writeln('  admin@ejadah.test     / EjadahDemo1  (admin)')
      ..writeln('')
      ..writeln('Credentials are development-only. See docs/demo.md.');

    logger.info('seed complete');
  } finally {
    await database.close();
  }
}

Future<String> _upsertUser(
  AuthRepository auth,
  PasswordHasher hasher, {
  required String email,
  required String nameEn,
  required String nameAr,
  required CareerStage stage,
}) async {
  final existing = await auth.findByEmail(email);
  if (existing != null) return existing.id;

  final record = await auth.createUser(
    email: email,
    passwordHash: hasher.hash('EjadahDemo1'),
    fullNameEn: nameEn,
    fullNameAr: nameAr,
    stage: stage,
    language: AppLanguage.ar,
  );
  return record.id;
}

Future<int> _seedProfessional(
  Database database, {
  required String userId,
}) async {
  final rows = await database.run(
    (s) => s.execute(
      Sql.named('''
      INSERT INTO professionals (
        user_id, slug, kind, display_name_en, display_name_ar,
        headline_en, headline_ar, specialties, languages, hourly_rate_egp,
        offers_free_intro_call, journey_from, journey_to, journey_year,
        cancellation_policy_en, cancellation_policy_ar, is_approved, approved_at
      ) VALUES (
        @user_id, 'dr-mona-adel', 'mentoring', 'Dr. Mona Adel', 'د. منى عادل',
        'Cairo to London, 2021. ORE Part 1 and 2 first attempt.',
        'من القاهرة إلى لندن 2021. اجتزت ORE من المحاولة الأولى.',
        ARRAY['Endodontics'], ARRAY['ar','en'], 800,
        true, 'Cairo', 'London', 2021,
        'Full refund up to 24 hours before. Half within 24 hours. Nothing within 2 hours.',
        'استرداد كامل قبل 24 ساعة. نصف المبلغ خلال 24 ساعة. لا استرداد خلال ساعتين.',
        true, now()
      )
      ON CONFLICT (slug) DO UPDATE SET hourly_rate_egp = EXCLUDED.hourly_rate_egp
      RETURNING id
      '''),
      parameters: {'user_id': userId},
    ),
  );
  final id = (rows.first[0]! as num).toInt();

  await database.run(
    (s) => s.execute(
      Sql.named('''
      INSERT INTO professional_qualifications (
        professional_id, position, title_en, title_ar, issuer_en, issuer_ar,
        evidence, year
      ) VALUES
        (@id, 1, 'ORE Part 1 and 2', 'ORE الجزء الأول والثاني',
         'General Dental Council', 'المجلس العام لطب الأسنان', 'verified', 2021),
        (@id, 2, 'MSc Endodontology', 'ماجستير علاج الجذور',
         'King''s College London', 'كينجز كوليدج لندن', 'stated', 2023)
      ON CONFLICT (professional_id, position) DO NOTHING
      '''),
      parameters: {'id': id},
    ),
  );

  await database.run(
    (s) => s.execute(
      Sql.named('''
      INSERT INTO professional_packages (
        professional_id, title_en, title_ar, session_count, session_minutes,
        price_egp, cadence_sentence_en, cadence_sentence_ar
      ) VALUES (
        @id, 'ORE Part 1 plan', 'خطة ORE الجزء الأول', 8, 60, 5600,
        'One 60-minute session a week for eight weeks.',
        'جلسة واحدة 60 دقيقة أسبوعيًا لمدة ثمانية أسابيع.'
      )
      ON CONFLICT DO NOTHING
      '''),
      parameters: {'id': id},
    ),
  );

  return id;
}

Future<void> _seedAvailability(Database database, int professionalId) =>
    database.run(
      (s) => s.execute(
        Sql.named('''
        INSERT INTO availability_rules (
          professional_id, weekday, start_minute, end_minute
        )
        SELECT @id, weekday, 600, 1080
        FROM generate_series(0, 4) AS weekday
        ON CONFLICT DO NOTHING
        '''),
        parameters: {'id': professionalId},
      ),
    );
