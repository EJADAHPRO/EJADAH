import 'package:ejadah_server/src/modules/career/career_repository.dart';
import 'package:test/test.dart';

import 'support/test_database.dart';

/// The sources block's data.
///
/// Story E2-02 asks the programme detail to name where its figures came from.
/// The programme dataset carries no regulator of its own — that fact lives on
/// the country guide — so the detail query joins it. A country with no guide
/// must yield no regulator rather than a plausible-looking one: recognition
/// and licensing facts are exactly what this product refuses to manufacture.
void main() {
  late TestDatabase db;
  late CareerRepository repository;

  setUpAll(() async {
    db = await TestDatabase.open();
  });

  tearDownAll(() async {
    await db.close();
  });

  setUp(() async {
    await db.reset();
    await db.resetReferenceData();
    repository = CareerRepository(db.database);
    await _createCountry(db);
  });

  test('a programme in a guided country names its regulator', () async {
    await _createProgramme(db, id: 9001, countryIso: 'uk');

    final programme = await repository.findProgramme(9001);
    expect(programme, isNotNull);
    expect(programme!.regulator?.en, 'General Dental Council');
    expect(programme.regulator?.ar, 'المجلس العام لطب الأسنان');
    expect(programme.regulatorUpdatedLabel, 'Jul 2026');
  });

  test('a programme with no guide names none', () async {
    await _createProgramme(db, id: 9002, countryIso: null);

    final programme = await repository.findProgramme(9002);
    expect(programme, isNotNull);
    // Null, not an empty string: the screen shows "Not verified" rather than a
    // blank line that reads as a rendering fault.
    expect(programme!.regulator, isNull);
    expect(programme.regulatorUpdatedLabel, isNull);
  });
}

Future<void> _createCountry(TestDatabase db) => db.execute('''
  INSERT INTO countries (
    iso, name_en, name_ar, region, exam_code, exam_full_en, exam_full_ar,
    pathway_class, pathway_class_en, pathway_class_ar, months_label,
    min_months, max_months, difficulty_en, difficulty_ar,
    market_en, market_ar, authority_en, authority_ar, updated_label
  ) VALUES (
    'uk', 'United Kingdom', 'المملكة المتحدة', 'europe', 'ORE',
    'Overseas Registration Exam', 'امتحان التسجيل للخارج',
    'exam', 'Exam heavy', 'كثيف الامتحانات', '12–24', 12, 24,
    'Hard', 'صعب', 'Competitive', 'تنافسي',
    'General Dental Council', 'المجلس العام لطب الأسنان', 'Jul 2026'
  )
  ON CONFLICT (iso) DO NOTHING
  ''');

Future<void> _createProgramme(
  TestDatabase db, {
  required int id,
  required String? countryIso,
}) => db.execute(
  '''
  INSERT INTO programmes (
    id, region, country, country_iso, university, programme_name,
    source_deadline_text, deadline
  ) VALUES (
    @id, 'Europe', 'United Kingdom', @iso, 'King''s College London',
    'MSc Endodontics', 'Deadline read 1 Jul 2026',
    (now() + interval '60 days')::date
  )
  ''',
  {'id': id, 'iso': countryIso},
);
