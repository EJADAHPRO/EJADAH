import 'package:ejadah_models/ejadah_models.dart';
import 'package:postgres/postgres.dart';

import '../../db/database.dart';

/// All database access for programmes, country guides and the shortlist.
///
/// Filtering, searching, sorting and paging happen here in SQL. The client never
/// downloads the database to filter it locally — that is a stated requirement,
/// and it is what keeps the list honest about its own count.
class CareerRepository {
  const CareerRepository(this._database);

  final Database _database;

  static const String _summaryColumns = '''
    p.id, p.university, p.programme_name, p.country, p.country_iso, p.city,
    p.region, p.specialty, p.degree_type, p.deadline, p.deadline_status,
    p.days_remaining, p.tuition_usd, p.currency, p.local_cost, p.duration_raw
  ''';

  // --- Programmes -----------------------------------------------------------

  Future<Paginated<ProgrammeSummary>> searchProgrammes(
    ProgrammeQuery query, {
    String? userId,
  }) async {
    final where = _buildWhere(query);
    final parameters = <String, Object?>{...where.parameters};

    final countRows = await _query(
      'SELECT count(*) AS total FROM programmes p ${where.sql}',
      parameters,
      null,
    );
    final total = countRows.first.intAt('total');

    final offset = (query.page - 1) * query.pageSize;
    final rows = await _query(
      '''
      SELECT $_summaryColumns,
             ${userId == null ? 'false' : 's.user_id IS NOT NULL'} AS is_saved
      FROM programmes p
      ${userId == null ? '' : 'LEFT JOIN saved_programmes s ON s.programme_id = p.id AND s.user_id = @saved_user'}
      ${where.sql}
      ORDER BY ${_orderBy(query.sort)}
      LIMIT @limit OFFSET @offset
      ''',
      {
        ...parameters,
        if (userId != null) 'saved_user': userId,
        'limit': query.pageSize,
        'offset': offset,
      },
      null,
    );

    return Paginated(
      items: rows.map(_toSummary).toList(),
      total: total,
      page: query.page,
      pageSize: query.pageSize,
    );
  }

  Future<Programme?> findProgramme(int id, {String? userId}) async {
    final rows = await _query(
      '''
      SELECT p.*,
             ${userId == null ? 'false' : 's.user_id IS NOT NULL'} AS is_saved,
             -- The regulator for this country, where a guide exists. A
             -- programme in a country we have no guide for carries no
             -- regulator, and the detail screen says so rather than naming one.
             c.authority_en, c.authority_ar, c.updated_label
      FROM programmes p
      LEFT JOIN countries c ON c.iso = p.country_iso
      ${userId == null ? '' : 'LEFT JOIN saved_programmes s ON s.programme_id = p.id AND s.user_id = @saved_user'}
      WHERE p.id = @id
      ''',
      {'id': id, if (userId != null) 'saved_user': userId},
      null,
    );
    if (rows.isEmpty) return null;
    return _toProgramme(rows.first);
  }

  Future<List<Programme>> findProgrammes(
    List<int> ids, {
    String? userId,
  }) async {
    if (ids.isEmpty) return const [];
    final rows = await _query(
      '''
      SELECT p.*,
             ${userId == null ? 'false' : 's.user_id IS NOT NULL'} AS is_saved
      FROM programmes p
      ${userId == null ? '' : 'LEFT JOIN saved_programmes s ON s.programme_id = p.id AND s.user_id = @saved_user'}
      WHERE p.id = ANY(@ids)
      ORDER BY array_position(@ids, p.id)
      ''',
      {'ids': ids, if (userId != null) 'saved_user': userId},
      null,
    );
    return rows.map(_toProgramme).toList();
  }

  /// The distinct values the filter sheet offers, so the sheet never shows a
  /// filter that matches nothing.
  Future<Map<String, List<String>>> filterFacets() async {
    Future<List<String>> distinct(String column) async {
      final rows = await _query(
        'SELECT DISTINCT $column AS value FROM programmes '
        "WHERE $column <> '' ORDER BY value",
        const {},
        null,
      );
      return rows.map((row) => row.str('value')).toList();
    }

    return {
      'regions': await distinct('region'),
      'countries': await distinct('country'),
      'specialties': await distinct('specialty'),
      'degree_types': await distinct('degree_type'),
      'intake_months': await distinct('intake_month'),
    };
  }

  /// How many rows a query would return with exactly one filter dropped.
  ///
  /// Powers "Nothing matches those filters. Nearest match: {relaxation}." — the
  /// empty state routes to action rather than dead-ending.
  Future<int> countWithRelaxation(ProgrammeQuery query) async {
    final where = _buildWhere(query);
    final rows = await _query(
      'SELECT count(*) AS total FROM programmes p ${where.sql}',
      where.parameters,
      null,
    );
    return rows.first.intAt('total');
  }

  /// The count the Home deadline strip and the database header both quote.
  Future<int> countOpenProgrammes() async {
    final rows = await _query(
      "SELECT count(*) AS total FROM programmes WHERE deadline_status = 'open'",
      const {},
      null,
    );
    return rows.first.intAt('total');
  }

  // --- Shortlist ------------------------------------------------------------

  Future<void> saveProgramme(String userId, int programmeId) => _execute(
    'INSERT INTO saved_programmes (user_id, programme_id) '
    'VALUES (@user_id, @programme_id) ON CONFLICT DO NOTHING',
    {'user_id': userId, 'programme_id': programmeId},
    null,
  );

  Future<void> removeSavedProgramme(String userId, int programmeId) => _execute(
    'DELETE FROM saved_programmes '
    'WHERE user_id = @user_id AND programme_id = @programme_id',
    {'user_id': userId, 'programme_id': programmeId},
    null,
  );

  Future<bool> isSaved(String userId, int programmeId) async {
    final rows = await _query(
      'SELECT 1 AS present FROM saved_programmes '
      'WHERE user_id = @user_id AND programme_id = @programme_id',
      {'user_id': userId, 'programme_id': programmeId},
      null,
    );
    return rows.isNotEmpty;
  }

  /// The shortlist, urgency first.
  ///
  /// Open intakes lead, sorted by how soon they close; expired ones sink to the
  /// bottom rather than disappearing, because the user chose to save them.
  Future<List<ProgrammeSummary>> savedProgrammes(String userId) async {
    final rows = await _query(
      '''
      SELECT $_summaryColumns, true AS is_saved
      FROM saved_programmes s
      JOIN programmes p ON p.id = s.programme_id
      WHERE s.user_id = @user_id
      ORDER BY
        CASE p.deadline_status
          WHEN 'closing_soon' THEN 0
          WHEN 'open' THEN 1
          ELSE 2
        END,
        p.deadline NULLS LAST,
        s.saved_at DESC
      ''',
      {'user_id': userId},
      null,
    );
    return rows.map(_toSummary).toList();
  }

  /// Saved programmes whose deadline falls exactly [daysOut] days from today —
  /// the 30/14/7 alert windows.
  Future<
    List<({String userId, int programmeId, String university, String country})>
  >
  savedProgrammesDueIn(int daysOut) async {
    final rows = await _query(
      '''
      SELECT s.user_id, p.id AS programme_id, p.university, p.country
      FROM saved_programmes s
      JOIN programmes p ON p.id = s.programme_id
      JOIN notification_preferences np ON np.user_id = s.user_id
      WHERE np.deadline_alerts = true
        AND p.deadline = (CURRENT_DATE + @days_out * INTERVAL '1 day')::date
      ''',
      {'days_out': daysOut},
      null,
    );
    return rows
        .map(
          (row) => (
            userId: row.str('user_id'),
            programmeId: row.intAt('programme_id'),
            university: row.str('university'),
            country: row.str('country'),
          ),
        )
        .toList();
  }

  // --- Country guides -------------------------------------------------------

  Future<List<CountryGuideSummary>> listCountries({
    List<String> regions = const [],
    List<PathwayClass> classes = const [],
  }) async {
    final conditions = <String>[];
    final parameters = <String, Object?>{};

    if (regions.isNotEmpty) {
      conditions.add('region = ANY(@regions)');
      parameters['regions'] = regions;
    }
    if (classes.isNotEmpty) {
      conditions.add('pathway_class = ANY(@classes::pathway_class[])');
      parameters['classes'] = classes.map((c) => c.wire).toList();
    }

    final rows = await _query(
      'SELECT * FROM countries '
      '${conditions.isEmpty ? '' : 'WHERE ${conditions.join(' AND ')}'} '
      'ORDER BY is_popular DESC, name_en',
      parameters,
      null,
    );
    return rows.map(_toCountrySummary).toList();
  }

  Future<CountryGuide?> findCountry(String iso) async {
    final rows = await _query('SELECT * FROM countries WHERE iso = @iso', {
      'iso': iso.toLowerCase(),
    }, null);
    if (rows.isEmpty) return null;

    final country = rows.first;
    final steps = await _query(
      'SELECT * FROM country_steps WHERE country_iso = @iso ORDER BY position',
      {'iso': country.str('iso')},
      null,
    );
    final exams = await _query(
      'SELECT * FROM country_exams WHERE country_iso = @iso ORDER BY position',
      {'iso': country.str('iso')},
      null,
    );
    final costs = await _query(
      'SELECT * FROM country_costs WHERE country_iso = @iso ORDER BY position',
      {'iso': country.str('iso')},
      null,
    );
    final documents = await _query(
      'SELECT * FROM country_documents WHERE country_iso = @iso ORDER BY position',
      {'iso': country.str('iso')},
      null,
    );
    final tips = await _query(
      'SELECT * FROM country_tips WHERE country_iso = @iso ORDER BY position',
      {'iso': country.str('iso')},
      null,
    );

    return CountryGuide(
      summary: _toCountrySummary(country),
      examFull: LocalizedText(
        en: country.str('exam_full_en'),
        ar: country.str('exam_full_ar'),
      ),
      overview: LocalizedText(
        en: country.str('overview_en'),
        ar: country.str('overview_ar'),
      ),
      authority: LocalizedText(
        en: country.str('authority_en'),
        ar: country.str('authority_ar'),
      ),
      authoritySite: country.strOrNull('authority_site'),
      visa: LocalizedText(
        en: country.str('visa_en'),
        ar: country.str('visa_ar'),
      ),
      market: LocalizedText(
        en: country.str('market_en'),
        ar: country.str('market_ar'),
      ),
      salaryBand: country.strOrNull('salary_band'),
      salaryNote: LocalizedText(
        en: country.str('salary_note_en'),
        ar: country.str('salary_note_ar'),
      ),
      recognitionNote: LocalizedText(
        en: country.str('recognition_note_en'),
        ar: country.str('recognition_note_ar'),
      ),
      costNote: LocalizedText(
        en: country.str('cost_note_en'),
        ar: country.str('cost_note_ar'),
      ),
      updatedLabel: country.str('updated_label'),
      steps: steps
          .map(
            (row) => CountryStep(
              position: row.intAt('position'),
              title: LocalizedText(
                en: row.str('title_en'),
                ar: row.str('title_ar'),
              ),
              detail: LocalizedText(
                en: row.str('detail_en'),
                ar: row.str('detail_ar'),
              ),
              whenLabel: row.strOrNull('when_label'),
              isOptional: row.boolAt('is_optional'),
            ),
          )
          .toList(),
      exams: exams.map(_toExam).toList(),
      costs: costs
          .map(
            (row) => CountryCost(
              position: row.intAt('position'),
              label: LocalizedText(
                en: row.str('label_en'),
                ar: row.str('label_ar'),
              ),
              localAmount: _sourced(
                row.strOrNull('local_value'),
                row.str('local_status'),
              ),
              usdAmount: _sourced(
                row.strOrNull('usd_value'),
                row.str('usd_status'),
              ),
            ),
          )
          .toList(),
      documents: documents
          .map(
            (row) =>
                LocalizedText(en: row.str('label_en'), ar: row.str('label_ar')),
          )
          .toList(),
      tips: tips
          .map(
            (row) =>
                LocalizedText(en: row.str('body_en'), ar: row.str('body_ar')),
          )
          .toList(),
    );
  }

  /// Programmes that sit in a guide's country — the guide → database crossing.
  Future<List<ProgrammeSummary>> programmesForCountry(
    String iso, {
    int limit = 6,
    String? userId,
  }) async {
    final rows = await _query(
      '''
      SELECT $_summaryColumns,
             ${userId == null ? 'false' : 's.user_id IS NOT NULL'} AS is_saved
      FROM programmes p
      ${userId == null ? '' : 'LEFT JOIN saved_programmes s ON s.programme_id = p.id AND s.user_id = @saved_user'}
      WHERE p.country_iso = @iso AND p.deadline_status <> 'expired'
      ORDER BY p.deadline NULLS LAST
      LIMIT @limit
      ''',
      {
        'iso': iso.toLowerCase(),
        'limit': limit,
        if (userId != null) 'saved_user': userId,
      },
      null,
    );
    return rows.map(_toSummary).toList();
  }

  // --- Recently viewed ------------------------------------------------------

  Future<void> recordView({
    required String userId,
    required String resource,
    required String resourceId,
  }) => _execute(
    '''
    INSERT INTO recently_viewed (user_id, resource, resource_id)
    VALUES (@user_id, @resource, @resource_id)
    ON CONFLICT (user_id, resource, resource_id)
    DO UPDATE SET viewed_at = now()
    ''',
    {'user_id': userId, 'resource': resource, 'resource_id': resourceId},
    null,
  );

  // --- Query building -------------------------------------------------------

  _WhereClause _buildWhere(ProgrammeQuery query) {
    final conditions = <String>[];
    final parameters = <String, Object?>{};

    // Expired intakes are hidden unless asked for: 150 of 199 have passed, and
    // leading with them makes a live database look dead.
    if (!query.showExpired) {
      conditions.add("p.deadline_status <> 'expired'");
    }

    final search = query.search?.trim();
    if (search != null && search.isNotEmpty) {
      // Matches the search field's own promise: "University, programme or city".
      conditions.add('''(
          to_tsvector('simple',
            p.university || ' ' || p.programme_name || ' ' || p.city || ' ' || p.country
          ) @@ plainto_tsquery('simple', @search)
          OR p.university ILIKE @search_like
          OR p.programme_name ILIKE @search_like
          OR p.city ILIKE @search_like
        )''');
      parameters['search'] = search;
      parameters['search_like'] = '%$search%';
    }

    void inList(String column, List<String> values, String key) {
      if (values.isEmpty) return;
      conditions.add('p.$column = ANY(@$key)');
      parameters[key] = values;
    }

    inList('region', query.regions, 'regions');
    inList('country', query.countries, 'countries');
    inList('specialty', query.specialties, 'specialties');
    inList('degree_type', query.degreeTypes, 'degree_types');
    inList('intake_month', query.intakeMonths, 'intake_months');

    if (query.maxTuitionUsd != null) {
      // A programme with no recorded tuition is not silently excluded by a
      // budget filter — an unknown cost is a real state, not an infinite one.
      conditions.add(
        '(p.tuition_usd IS NULL OR p.tuition_usd <= @max_tuition)',
      );
      parameters['max_tuition'] = query.maxTuitionUsd;
    }
    if (query.maxYears != null) {
      conditions.add('(p.max_years IS NULL OR p.max_years <= @max_years)');
      parameters['max_years'] = query.maxYears;
    }
    if (query.minIelts != null) {
      conditions.add('(p.ielts_score IS NULL OR p.ielts_score <= @min_ielts)');
      parameters['min_ielts'] = query.minIelts;
    }
    if (query.requiresScholarship) {
      conditions.add('p.has_scholarship = true');
    }
    if (query.excludeThesis) {
      conditions.add('p.thesis_required IS DISTINCT FROM true');
    }
    if (query.excludeInterview) {
      conditions.add('p.interview_required IS DISTINCT FROM true');
    }

    return _WhereClause(
      sql: conditions.isEmpty ? '' : 'WHERE ${conditions.join(' AND ')}',
      parameters: parameters,
    );
  }

  /// Ordering is fully specified in every branch.
  ///
  /// A trailing `p.id` keeps paging stable: without a unique final key, two rows
  /// with equal sort values can swap between pages and a user sees one twice.
  static String _orderBy(ProgrammeSort sort) => switch (sort) {
    ProgrammeSort.deadline => 'p.deadline_status, p.deadline NULLS LAST, p.id',
    ProgrammeSort.tuitionAsc => 'p.tuition_usd NULLS LAST, p.id',
    ProgrammeSort.tuitionDesc => 'p.tuition_usd DESC NULLS LAST, p.id',
    ProgrammeSort.rank => 'p.qs_rank NULLS LAST, p.id',
    ProgrammeSort.university => 'p.university, p.id',
  };

  // --- Row mapping ----------------------------------------------------------

  ProgrammeSummary _toSummary(Map<String, dynamic> row) => ProgrammeSummary(
    id: row.intAt('id'),
    university: row.str('university'),
    programmeName: row.str('programme_name'),
    country: row.str('country'),
    countryIso: row.strOrNull('country_iso'),
    city: row.str('city'),
    region: row.str('region'),
    specialty: row.str('specialty'),
    degreeType: row.str('degree_type'),
    deadline: row.dateOrNull('deadline'),
    deadlineStatus: DeadlineStatus.fromWire(row.str('deadline_status')),
    daysRemaining: row.intOrNull('days_remaining'),
    tuitionUsd: row.intOrNull('tuition_usd'),
    currency: row.strOrNull('currency'),
    localCost: row.intOrNull('local_cost'),
    durationRaw: row.str('duration_raw'),
    isSaved: row.boolOrNull('is_saved') ?? false,
  );

  Programme _toProgramme(Map<String, dynamic> row) => Programme(
    summary: _toSummary(row),
    studyType: row.str('study_type'),
    intakeMonth: row.str('intake_month'),
    cohortSize: row.str('cohort_size'),
    minYears: row.intOrNull('min_years'),
    maxYears: row.intOrNull('max_years'),
    studyMode: row.str('study_mode'),
    costRaw: row.str('cost_raw'),
    language: row.str('language'),
    qsRank: row.intOrNull('qs_rank'),
    acceptanceRate: row.doubleOrNull('acceptance_rate'),
    ieltsScore: row.doubleOrNull('ielts_score'),
    ieltsRequirement: row.str('ielts_requirement'),
    gpaRequirement: row.str('gpa_requirement'),
    experienceRequirement: row.str('experience_requirement'),
    hasScholarship: row.boolOrNull('has_scholarship'),
    hasEgyptianGovtFunding: row.boolOrNull('has_egyptian_govt_funding'),
    thesisRequired: row.boolOrNull('thesis_required'),
    interviewRequired: row.boolOrNull('interview_required'),
    rating: row.doubleOrNull('rating'),
    sourceDeadlineText: row.str('source_deadline_text'),
    dataQualityNote: row.str('data_quality_note'),
    // Present only on the detail query, which joins the country guide.
    regulator: row.containsKey('authority_en')
        ? LocalizedText.orNull(
            en: row.strOrNull('authority_en'),
            ar: row.strOrNull('authority_ar'),
          )
        : null,
    regulatorUpdatedLabel: row.strOrNull('updated_label'),
  );

  CountryGuideSummary _toCountrySummary(Map<String, dynamic> row) =>
      CountryGuideSummary(
        iso: row.str('iso'),
        name: LocalizedText(en: row.str('name_en'), ar: row.str('name_ar')),
        examCode: row.str('exam_code'),
        pathwayClass: PathwayClass.fromWire(row.str('pathway_class')),
        pathwayClassLabel: LocalizedText(
          en: row.str('pathway_class_en'),
          ar: row.str('pathway_class_ar'),
        ),
        monthsLabel: row.str('months_label'),
        difficulty: LocalizedText(
          en: row.str('difficulty_en'),
          ar: row.str('difficulty_ar'),
        ),
        region: row.str('region'),
        isPopular: row.boolAt('is_popular'),
        minMonths: row.intAt('min_months'),
        maxMonths: row.intAt('max_months'),
        floorCostUsd: row.intOrNull('floor_cost_usd'),
      );

  CountryExam _toExam(Map<String, dynamic> row) => CountryExam(
    position: row.intAt('position'),
    name: LocalizedText(en: row.str('name_en'), ar: row.str('name_ar')),
    description: LocalizedText(
      en: row.str('description_en'),
      ar: row.str('description_ar'),
    ),
    dates: LocalizedText(en: row.str('dates_en'), ar: row.str('dates_ar')),
    fee: Sourced<String>(
      value: row.strOrNull('fee_value'),
      status: SourceStatus.fromWire(row.str('fee_status')),
      sourceName: row.strOrNull('fee_source_name'),
      sourceUrl: row.strOrNull('fee_source_url'),
      verifiedOn: row.dateOrNull('fee_verified_on'),
    ),
    passMark: LocalizedText(
      en: row.str('pass_mark_en'),
      ar: row.str('pass_mark_ar'),
    ),
  );

  static Sourced<String> _sourced(String? value, String status) =>
      Sourced<String>(value: value, status: SourceStatus.fromWire(status));

  // --- Plumbing -------------------------------------------------------------

  Future<List<Map<String, dynamic>>> _query(
    String sql,
    Map<String, Object?> parameters,
    Session? session,
  ) async {
    Future<Result> run(Session s) =>
        s.execute(Sql.named(sql), parameters: parameters);
    final result = session != null
        ? await run(session)
        : await _database.run(run);
    return result.map((row) => row.toColumnMap()).toList();
  }

  Future<void> _execute(
    String sql,
    Map<String, Object?> parameters,
    Session? session,
  ) async {
    await _query(sql, parameters, session);
  }
}

class _WhereClause {
  const _WhereClause({required this.sql, required this.parameters});

  final String sql;
  final Map<String, Object?> parameters;
}
