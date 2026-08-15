import 'dart:convert';
import 'dart:io';

import 'package:ejadah_models/ejadah_models.dart';
import 'package:postgres/postgres.dart';

import '../db/database.dart';
import '../observability/logger.dart';

/// Imports the 199 postgraduate programme records from `data/programmes.json`.
///
/// Idempotent: rows upsert on the dataset's own `ID`, so re-running after a
/// correction updates in place. Field values are carried across verbatim; where
/// the source has no value, the column is `NULL` rather than a stand-in.
class ProgrammeImporter {
  ProgrammeImporter(this._database, {AppLogger? logger})
    : _logger = logger ?? AppLogger('import.programmes');

  final Database _database;
  final AppLogger _logger;

  /// Excel's day-zero. The dataset's `Deadline` column is an Excel serial.
  static final DateTime _excelEpoch = DateTime.utc(1899, 12, 30);

  Future<ProgrammeImportReport> importFrom(File file) async {
    final decoded = jsonDecode(file.readAsStringSync());
    if (decoded is! List) {
      throw const FormatException('Programmes dataset is not an array.');
    }

    // The guides that exist, so a programme can be linked to one where its
    // country has a licensing guide.
    final knownCountries = await _countryIsoByName();
    final report = ProgrammeImportReport();

    await _database.runTx((tx) async {
      for (final raw in decoded) {
        final row = Map<String, dynamic>.from(raw as Map);
        await _importProgramme(row, knownCountries, tx, report);
      }
    });

    _logger.info('programmes imported', {
      'total': report.total,
      'expired': report.expired,
      'open': report.open,
      'closing_soon': report.closingSoon,
      'linked_to_guide': report.linkedToGuide,
    });
    return report;
  }

  Future<void> _importProgramme(
    Map<String, dynamic> row,
    Map<String, String> countryIsoByName,
    Session tx,
    ProgrammeImportReport report,
  ) async {
    final status = DeadlineStatus.fromSourceText(row['Deadline Status'] as String?);
    final countryName = _text(row['Country']);
    final iso = countryIsoByName[countryName.toLowerCase()];

    await tx.execute(
      Sql.named('''
      INSERT INTO programmes (
        id, region, country, country_iso, city, university, programme_name,
        specialty, original_specialty, degree_type, study_type, study_mode,
        intake_month, cohort_size, duration_raw, min_years, max_years, cost_raw,
        currency, local_cost, tuition_usd, language, qs_rank, acceptance_rate,
        ielts_requirement, ielts_score, gpa_requirement, experience_requirement,
        has_scholarship, has_egyptian_govt_funding, thesis_required,
        interview_required, rating, deadline, source_deadline_text,
        days_remaining, deadline_status, data_quality_note, source_file
      ) VALUES (
        @id, @region, @country, @country_iso, @city, @university,
        @programme_name, @specialty, @original_specialty, @degree_type,
        @study_type, @study_mode, @intake_month, @cohort_size, @duration_raw,
        @min_years, @max_years, @cost_raw, @currency, @local_cost, @tuition_usd,
        @language, @qs_rank, @acceptance_rate, @ielts_requirement, @ielts_score,
        @gpa_requirement, @experience_requirement, @has_scholarship,
        @has_egyptian_govt_funding, @thesis_required, @interview_required,
        @rating, @deadline, @source_deadline_text, @days_remaining,
        @deadline_status::deadline_status, @data_quality_note, @source_file
      )
      ON CONFLICT (id) DO UPDATE SET
        region = EXCLUDED.region, country = EXCLUDED.country,
        country_iso = EXCLUDED.country_iso, city = EXCLUDED.city,
        university = EXCLUDED.university,
        programme_name = EXCLUDED.programme_name,
        specialty = EXCLUDED.specialty,
        original_specialty = EXCLUDED.original_specialty,
        degree_type = EXCLUDED.degree_type, study_type = EXCLUDED.study_type,
        study_mode = EXCLUDED.study_mode, intake_month = EXCLUDED.intake_month,
        cohort_size = EXCLUDED.cohort_size, duration_raw = EXCLUDED.duration_raw,
        min_years = EXCLUDED.min_years, max_years = EXCLUDED.max_years,
        cost_raw = EXCLUDED.cost_raw, currency = EXCLUDED.currency,
        local_cost = EXCLUDED.local_cost, tuition_usd = EXCLUDED.tuition_usd,
        language = EXCLUDED.language, qs_rank = EXCLUDED.qs_rank,
        acceptance_rate = EXCLUDED.acceptance_rate,
        ielts_requirement = EXCLUDED.ielts_requirement,
        ielts_score = EXCLUDED.ielts_score,
        gpa_requirement = EXCLUDED.gpa_requirement,
        experience_requirement = EXCLUDED.experience_requirement,
        has_scholarship = EXCLUDED.has_scholarship,
        has_egyptian_govt_funding = EXCLUDED.has_egyptian_govt_funding,
        thesis_required = EXCLUDED.thesis_required,
        interview_required = EXCLUDED.interview_required,
        rating = EXCLUDED.rating, deadline = EXCLUDED.deadline,
        source_deadline_text = EXCLUDED.source_deadline_text,
        days_remaining = EXCLUDED.days_remaining,
        deadline_status = EXCLUDED.deadline_status,
        data_quality_note = EXCLUDED.data_quality_note,
        source_file = EXCLUDED.source_file,
        updated_at = now()
      '''),
      parameters: {
        'id': _int(row['ID'])!,
        'region': _text(row['Region']),
        'country': countryName,
        'country_iso': iso,
        'city': _text(row['City']),
        'university': _text(row['University']),
        'programme_name': _text(row['Program Name']),
        'specialty': _text(row['Specialty']),
        'original_specialty': _text(row['Original Specialty']),
        'degree_type': _text(row['Degree Type']),
        'study_type': _text(row['Study Type']),
        'study_mode': _text(row['Study Mode']),
        'intake_month': _text(row['Intake Month']),
        'cohort_size': _text(row['Cohort Size']),
        'duration_raw': _text(row['Duration (Raw)']),
        'min_years': _int(row['Min Years']),
        'max_years': _int(row['Max Years']),
        'cost_raw': _text(row['Cost (Raw)']),
        'currency': _textOrNull(row['Currency']),
        'local_cost': _int(row['Local Cost']),
        'tuition_usd': _int(row['Approx. USD']),
        'language': _text(row['Language']),
        'qs_rank': _int(row['QS Rank']),
        'acceptance_rate': _double(row['Acceptance Rate']),
        'ielts_requirement': _text(row['IELTS Requirement']),
        'ielts_score': _double(row['IELTS Score']),
        'gpa_requirement': _text(row['GPA Requirement']),
        'experience_requirement': _text(row['Experience Requirement']),
        'has_scholarship': _yesNo(row['Scholarship']),
        'has_egyptian_govt_funding': _yesNo(row['Egyptian Govt Funding']),
        'thesis_required': _yesNo(row['Thesis Required']),
        'interview_required': _yesNo(row['Interview Required']),
        'rating': _double(row['Rating']),
        'deadline': _excelSerialToDate(row['Deadline']),
        'source_deadline_text': _text(row['Source Deadline Text']),
        'days_remaining': _int(row['Days Remaining']),
        'deadline_status': status.wire,
        'data_quality_note': _text(row['Data Quality Note']),
        'source_file': _text(row['Source File']),
      },
    );

    report.total++;
    if (iso != null) report.linkedToGuide++;
    switch (status) {
      case DeadlineStatus.expired:
        report.expired++;
      case DeadlineStatus.open:
        report.open++;
      case DeadlineStatus.closingSoon:
        report.closingSoon++;
    }
  }

  Future<Map<String, String>> _countryIsoByName() async {
    final rows = await _database.run(
      (session) => session.execute('SELECT iso, name_en FROM countries'),
    );
    return {
      for (final row in rows)
        (row[1]! as String).toLowerCase(): row[0]! as String,
      // The dataset writes some countries differently from the guides.
      'uk': 'gb',
      'united kingdom': 'gb',
      'uae': 'ae',
      'united arab emirates': 'ae',
      'usa': 'us',
      'united states': 'us',
      'saudi arabia': 'sa',
    };
  }

  // --- Field coercion -------------------------------------------------------

  static String _text(Object? value) => value?.toString().trim() ?? '';

  static String? _textOrNull(Object? value) {
    final text = _text(value);
    return text.isEmpty ? null : text;
  }

  static int? _int(Object? value) {
    final text = _text(value);
    if (text.isEmpty) return null;
    return int.tryParse(text) ?? double.tryParse(text)?.round();
  }

  static double? _double(Object? value) {
    final text = _text(value);
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  /// The dataset writes booleans as "Yes"/"No". Anything else — including the
  /// blank the source uses for "not stated" — stays null, because "we do not
  /// know" and "no" are different answers.
  static bool? _yesNo(Object? value) {
    final text = _text(value).toLowerCase();
    if (text == 'yes') return true;
    if (text == 'no') return false;
    return null;
  }

  /// The `Deadline` column is an Excel serial day number, not a date string.
  static DateTime? _excelSerialToDate(Object? value) {
    final serial = _int(value);
    if (serial == null || serial <= 0) return null;
    return _excelEpoch.add(Duration(days: serial));
  }
}

/// What an import run did. Checked against the dataset's known shape.
class ProgrammeImportReport {
  int total = 0;
  int expired = 0;
  int open = 0;
  int closingSoon = 0;
  int linkedToGuide = 0;

  /// The canonical dataset is 199 records of which 150 have already expired —
  /// which is exactly why the database hides expired intakes by default. An
  /// import that disagrees with this has read the wrong file.
  List<String> validate() => [
    if (total != 199) 'Expected 199 programmes, imported $total.',
    if (expired != 150) 'Expected 150 expired intakes, found $expired.',
  ];

  @override
  String toString() =>
      '$total programmes ($open open, $closingSoon closing soon, '
      '$expired expired), $linkedToGuide linked to a country guide';
}
