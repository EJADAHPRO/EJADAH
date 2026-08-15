import 'dart:convert';
import 'dart:io';

import 'package:postgres/postgres.dart';

import '../db/database.dart';
import '../observability/logger.dart';

/// Imports the 23 country licensing guides from `data/countries.js`.
///
/// Reproducible and idempotent: every row upserts on its natural key, so
/// re-running after a data correction updates in place rather than duplicating.
/// Nothing here is authored by hand and nothing is estimated — a value the
/// source marks unverified is stored as `NULL` with `pending` status so the app
/// prints "Pending source".
class CountryImporter {
  CountryImporter(this._database, {AppLogger? logger})
    : _logger = logger ?? AppLogger('import.countries');

  final Database _database;
  final AppLogger _logger;

  /// The exact token the dataset uses for a fact it cannot source.
  static const String pendingSourceMarker = 'Pending source';

  /// The dataset's own "no value" marker in cost tables.
  static const String emDash = '—';

  Future<CountryImportReport> importFrom(File file) async {
    final countries = _parse(file.readAsStringSync());
    final report = CountryImportReport();

    await _database.runTx((tx) async {
      for (final entry in countries.entries) {
        await _importCountry(entry.key, entry.value, tx, report);
      }
    });

    _logger.info('country guides imported', {
      'countries': report.countries,
      'steps': report.steps,
      'exams': report.exams,
      'pending_fees': report.pendingFees,
    });
    return report;
  }

  /// `data/countries.js` is a browser bundle: `window.EJADAH_COUNTRIES = {...};`
  /// The JSON object is extracted rather than the file being retyped.
  Map<String, dynamic> _parse(String source) {
    final start = source.indexOf('{');
    if (start < 0) {
      throw FormatException('No JSON object found in the countries dataset.');
    }
    final json = source
        .substring(start)
        .trim()
        .replaceAll(RegExp(r';\s*$'), '');
    final decoded = jsonDecode(json);
    if (decoded is! Map) {
      throw const FormatException('Countries dataset is not an object.');
    }
    return Map<String, dynamic>.from(decoded);
  }

  Future<void> _importCountry(
    String iso,
    dynamic raw,
    Session tx,
    CountryImportReport report,
  ) async {
    final country = Map<String, dynamic>.from(raw as Map);
    final steps = _listOf(country['steps']);
    final exams = _listOf(country['exams']);
    final costs = _listOf(country['costs']);
    final documents = _listOf(country['docs']);
    final tips = _listOf(country['tips']);

    final months = _parseMonthRange(country['months'] as String? ?? '');
    final floorCost = _floorCostUsd(costs);

    await tx.execute(
      Sql.named('''
      INSERT INTO countries (
        iso, name_en, name_ar, region, exam_code, exam_full_en, exam_full_ar,
        pathway_class, pathway_class_en, pathway_class_ar, months_label,
        min_months, max_months, difficulty_en, difficulty_ar, market_en,
        market_ar, salary_band, salary_note_en, salary_note_ar, authority_en,
        authority_ar, authority_site, visa_en, visa_ar, overview_en, overview_ar,
        recognition_note_en, recognition_note_ar, cost_note_en, cost_note_ar,
        updated_label, is_popular, required_languages, floor_cost_usd,
        floor_cost_complete
      ) VALUES (
        @iso, @name_en, @name_ar, @region, @exam_code, @exam_full_en,
        @exam_full_ar, @pathway_class::pathway_class, @pathway_class_en,
        @pathway_class_ar, @months_label, @min_months, @max_months,
        @difficulty_en, @difficulty_ar, @market_en, @market_ar, @salary_band,
        @salary_note_en, @salary_note_ar, @authority_en, @authority_ar,
        @authority_site, @visa_en, @visa_ar, @overview_en, @overview_ar,
        @recognition_note_en, @recognition_note_ar, @cost_note_en,
        @cost_note_ar, @updated_label, @is_popular, @required_languages,
        @floor_cost_usd, @floor_cost_complete
      )
      ON CONFLICT (iso) DO UPDATE SET
        name_en = EXCLUDED.name_en, name_ar = EXCLUDED.name_ar,
        region = EXCLUDED.region, exam_code = EXCLUDED.exam_code,
        exam_full_en = EXCLUDED.exam_full_en,
        exam_full_ar = EXCLUDED.exam_full_ar,
        pathway_class = EXCLUDED.pathway_class,
        pathway_class_en = EXCLUDED.pathway_class_en,
        pathway_class_ar = EXCLUDED.pathway_class_ar,
        months_label = EXCLUDED.months_label,
        min_months = EXCLUDED.min_months, max_months = EXCLUDED.max_months,
        difficulty_en = EXCLUDED.difficulty_en,
        difficulty_ar = EXCLUDED.difficulty_ar,
        market_en = EXCLUDED.market_en, market_ar = EXCLUDED.market_ar,
        salary_band = EXCLUDED.salary_band,
        salary_note_en = EXCLUDED.salary_note_en,
        salary_note_ar = EXCLUDED.salary_note_ar,
        authority_en = EXCLUDED.authority_en,
        authority_ar = EXCLUDED.authority_ar,
        authority_site = EXCLUDED.authority_site,
        visa_en = EXCLUDED.visa_en, visa_ar = EXCLUDED.visa_ar,
        overview_en = EXCLUDED.overview_en, overview_ar = EXCLUDED.overview_ar,
        recognition_note_en = EXCLUDED.recognition_note_en,
        recognition_note_ar = EXCLUDED.recognition_note_ar,
        cost_note_en = EXCLUDED.cost_note_en,
        cost_note_ar = EXCLUDED.cost_note_ar,
        updated_label = EXCLUDED.updated_label,
        required_languages = EXCLUDED.required_languages,
        floor_cost_usd = EXCLUDED.floor_cost_usd,
        floor_cost_complete = EXCLUDED.floor_cost_complete,
        updated_at = now()
      '''),
      parameters: {
        'iso': iso,
        'name_en': _localized(country['name'], 'en'),
        'name_ar': _localized(country['name'], 'ar'),
        'region': _regionFor(iso),
        'exam_code': country['exam'] as String? ?? '',
        'exam_full_en': _localized(country['examFull'], 'en'),
        'exam_full_ar': _localized(country['examFull'], 'ar'),
        'pathway_class': country['cls'] as String? ?? 'exam',
        'pathway_class_en': _localized(country['clsL'], 'en'),
        'pathway_class_ar': _localized(country['clsL'], 'ar'),
        'months_label': country['months'] as String? ?? '',
        'min_months': months.min,
        'max_months': months.max,
        'difficulty_en': _localized(country['diff'], 'en'),
        'difficulty_ar': _localized(country['diff'], 'ar'),
        'market_en': _localized(country['market'], 'en'),
        'market_ar': _localized(country['market'], 'ar'),
        'salary_band': _salaryBand(country['salary']),
        'salary_note_en': _localized(_salaryNote(country['salary']), 'en'),
        'salary_note_ar': _localized(_salaryNote(country['salary']), 'ar'),
        'authority_en': _localized(country['authority'], 'en'),
        'authority_ar': _localized(country['authority'], 'ar'),
        'authority_site': country['site'] as String?,
        'visa_en': _localized(country['visa'], 'en'),
        'visa_ar': _localized(country['visa'], 'ar'),
        'overview_en': _localized(country['overview'], 'en'),
        'overview_ar': _localized(country['overview'], 'ar'),
        'recognition_note_en': _localized(country['recNote'], 'en'),
        'recognition_note_ar': _localized(country['recNote'], 'ar'),
        'cost_note_en': _localized(country['costNote'], 'en'),
        'cost_note_ar': _localized(country['costNote'], 'ar'),
        'updated_label': country['updated'] as String? ?? '',
        'is_popular': _popularIsos.contains(iso),
        'required_languages': _requiredLanguages(iso, steps),
        'floor_cost_usd': floorCost.total,
        'floor_cost_complete': floorCost.complete,
      },
    );

    // Children are replaced wholesale so a removed step in a corrected dataset
    // does not linger.
    for (final table in const [
      'country_steps',
      'country_exams',
      'country_costs',
      'country_documents',
      'country_tips',
    ]) {
      await tx.execute(
        Sql.named('DELETE FROM $table WHERE country_iso = @iso'),
        parameters: {'iso': iso},
      );
    }

    for (var i = 0; i < steps.length; i++) {
      final step = steps[i];
      await tx.execute(
        Sql.named('''
        INSERT INTO country_steps (country_iso, position, title_en, title_ar,
          detail_en, detail_ar, when_label, is_optional)
        VALUES (@iso, @position, @title_en, @title_ar, @detail_en, @detail_ar,
          @when_label, @is_optional)
        '''),
        parameters: {
          'iso': iso,
          'position': i + 1,
          'title_en': _localized(step['t'], 'en'),
          'title_ar': _localized(step['t'], 'ar'),
          'detail_en': _localized(step['d'], 'en'),
          'detail_ar': _localized(step['d'], 'ar'),
          'when_label': step['when'] as String?,
          'is_optional': step['opt'] == true,
        },
      );
      report.steps++;
    }

    for (var i = 0; i < exams.length; i++) {
      final exam = exams[i];
      final fee = _sourcedText(exam['fee'] as String?);
      if (fee.status == 'pending') report.pendingFees++;

      await tx.execute(
        Sql.named('''
        INSERT INTO country_exams (country_iso, position, name_en, name_ar,
          description_en, description_ar, dates_en, dates_ar, fee_value,
          fee_status, fee_source_name, pass_mark_en, pass_mark_ar)
        VALUES (@iso, @position, @name_en, @name_ar, @description_en,
          @description_ar, @dates_en, @dates_ar, @fee_value,
          @fee_status::source_status, @fee_source_name, @pass_mark_en,
          @pass_mark_ar)
        '''),
        parameters: {
          'iso': iso,
          'position': i + 1,
          'name_en': _localized(exam['n'], 'en'),
          'name_ar': _localized(exam['n'], 'ar'),
          'description_en': _localized(exam['d'], 'en'),
          'description_ar': _localized(exam['d'], 'ar'),
          'dates_en': _localized(exam['dates'], 'en'),
          'dates_ar': _localized(exam['dates'], 'ar'),
          'fee_value': fee.value,
          'fee_status': fee.status,
          // The regulator named by the guide is the source of a verified fee.
          'fee_source_name': fee.status == 'verified'
              ? _localized(country['authority'], 'en')
              : null,
          'pass_mark_en': _localized(exam['pass'], 'en'),
          'pass_mark_ar': _localized(exam['pass'], 'ar'),
        },
      );
      report.exams++;
    }

    for (var i = 0; i < costs.length; i++) {
      final cost = costs[i];
      final local = _sourcedText(cost['v'] as String?);
      final usd = _sourcedText(cost['usd'] as String?);
      await tx.execute(
        Sql.named('''
        INSERT INTO country_costs (country_iso, position, label_en, label_ar,
          local_value, local_status, usd_value, usd_status)
        VALUES (@iso, @position, @label_en, @label_ar, @local_value,
          @local_status::source_status, @usd_value, @usd_status::source_status)
        '''),
        parameters: {
          'iso': iso,
          'position': i + 1,
          'label_en': _localized(cost['l'], 'en'),
          'label_ar': _localized(cost['l'], 'ar'),
          'local_value': local.value,
          'local_status': local.status,
          'usd_value': usd.value,
          'usd_status': usd.status,
        },
      );
      report.costs++;
    }

    for (var i = 0; i < documents.length; i++) {
      await tx.execute(
        Sql.named(
          'INSERT INTO country_documents (country_iso, position, label_en, '
          'label_ar) VALUES (@iso, @position, @label_en, @label_ar)',
        ),
        parameters: {
          'iso': iso,
          'position': i + 1,
          'label_en': _localized(documents[i], 'en'),
          'label_ar': _localized(documents[i], 'ar'),
        },
      );
    }

    for (var i = 0; i < tips.length; i++) {
      await tx.execute(
        Sql.named(
          'INSERT INTO country_tips (country_iso, position, body_en, body_ar) '
          'VALUES (@iso, @position, @body_en, @body_ar)',
        ),
        parameters: {
          'iso': iso,
          'position': i + 1,
          'body_en': _localized(tips[i], 'en'),
          'body_ar': _localized(tips[i], 'ar'),
        },
      );
    }

    report.countries++;
  }

  // --- Value parsing --------------------------------------------------------

  /// Splits a source value into a storable value and its source status.
  ///
  /// "Pending source" and the em-dash placeholder both mean "we do not know",
  /// and both become a null value with `pending` status. An estimate is never
  /// substituted — that discipline is what makes every other figure credible.
  ({String? value, String status}) _sourcedText(String? raw) {
    final text = raw?.trim() ?? '';
    if (text.isEmpty || text == emDash || text == pendingSourceMarker) {
      return (value: null, status: 'pending');
    }
    return (value: text, status: 'verified');
  }

  /// The minimum total the guide's own USD cost rows imply.
  ///
  /// A lower bound by construction: each row contributes the bottom of its
  /// range, and unsourced rows contribute nothing. Used as the roadmap's budget
  /// pre-filter and as its cost tie-break. Null when no row is sourced at all.
  ///
  /// [complete] reports whether every row was sourced. Without it, a guide with
  /// missing fees would look cheaper than one that documented everything, and
  /// incomplete data would win the tie-break.
  ({int? total, bool complete}) _floorCostUsd(
    List<Map<String, dynamic>> costs,
  ) {
    var total = 0;
    var sourced = 0;
    var missing = 0;
    for (final cost in costs) {
      final usd = _sourcedText(cost['usd'] as String?);
      final low = usd.value == null ? null : _lowestNumber(usd.value!);
      if (low == null) {
        missing++;
        continue;
      }
      total += low;
      sourced++;
    }
    return (
      total: sourced == 0 ? null : total,
      complete: sourced > 0 && missing == 0,
    );
  }

  /// Reads the first number out of "$1,640–4,360" or "$267".
  static int? _lowestNumber(String text) {
    final match = RegExp(r'[\d,]+').firstMatch(text);
    if (match == null) return null;
    return int.tryParse(match.group(0)!.replaceAll(',', ''));
  }

  /// Parses "12–24" into a month range. A single value means both ends match.
  static ({int min, int max}) _parseMonthRange(String label) {
    final numbers = RegExp(
      r'\d+',
    ).allMatches(label).map((m) => int.parse(m.group(0)!)).toList();
    if (numbers.isEmpty) return (min: 0, max: 0);
    if (numbers.length == 1) return (min: numbers.first, max: numbers.first);
    return (min: numbers.first, max: numbers[1]);
  }

  /// Which languages the route requires, derived from the guide's own steps.
  ///
  /// Germany's first step is "German Language — B2 level"; Sweden's names
  /// Swedish; Turkey's names Turkish. Where no step names a language, the route
  /// runs in English, which is what the exam-based pathways use. Egypt is the
  /// user's own country and runs in Arabic.
  static List<String> _requiredLanguages(
    String iso,
    List<Map<String, dynamic>> steps,
  ) {
    if (iso == 'eg') return const ['ar'];

    const named = {
      'German': 'de',
      'Dutch': 'nl',
      'Swedish': 'sv',
      'Spanish': 'es',
      'Turkish': 'tr',
      'French': 'fr',
    };

    final found = <String>{};
    for (final step in steps) {
      final text =
          '${_localized(step['t'], 'en')} ${_localized(step['d'], 'en')}';
      for (final entry in named.entries) {
        if (text.contains(entry.key)) found.add(entry.value);
      }
    }

    if (found.isEmpty) return const ['en'];
    // Where a guide names alternatives (Switzerland: French or German), one
    // suffices, so the lowest code is taken rather than demanding both.
    final sorted = found.toList()..sort();
    return [sorted.first];
  }

  /// The funnel's region grouping, which is what the guide list filters on.
  static String _regionFor(String iso) => switch (iso) {
    'ae' || 'sa' || 'qa' || 'kw' || 'om' || 'bh' || 'jo' => 'Middle East',
    'gb' || 'ie' => 'UK & Ireland',
    'de' || 'nl' || 'se' || 'ch' || 'es' || 'tr' => 'Europe',
    'us' || 'ca' => 'North America',
    'au' || 'nz' => 'Oceania',
    'eg' || 'za' => 'Africa',
    _ => 'Asia',
  };

  /// The guides the Career hub surfaces first, per the prototype's own ordering.
  static const Set<String> _popularIsos = {'ae', 'sa', 'gb', 'de', 'ca'};

  static String _localized(Object? value, String language) {
    if (value is Map) return (value[language] ?? value['en'] ?? '').toString();
    if (value is String) return value;
    return '';
  }

  static String? _salaryBand(Object? salary) =>
      salary is Map ? salary['band'] as String? : null;

  static Object? _salaryNote(Object? salary) =>
      salary is Map ? salary['note'] : null;

  static List<Map<String, dynamic>> _listOf(Object? value) => switch (value) {
    final List<dynamic> list =>
      list
          .map(
            (item) => item is Map
                ? Map<String, dynamic>.from(item)
                : <String, dynamic>{'en': item, 'ar': item},
          )
          .toList(),
    _ => const [],
  };
}

/// What an import run did, for validation and for the log.
class CountryImportReport {
  int countries = 0;
  int steps = 0;
  int exams = 0;
  int costs = 0;

  /// Fees the source could not vouch for. Expected to be non-zero — these are
  /// the rows that print "Pending source".
  int pendingFees = 0;

  @override
  String toString() =>
      '$countries countries, $steps steps, $exams exams, $costs cost rows, '
      '$pendingFees pending fees';
}
