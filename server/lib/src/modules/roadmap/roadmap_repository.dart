import 'dart:convert';

import 'package:ejadah_models/ejadah_models.dart';
import 'package:postgres/postgres.dart';

import '../../db/database.dart';
import 'roadmap_engine.dart';

/// Database access for roadmap drafts, results and scenarios.
class RoadmapRepository {
  const RoadmapRepository(this._database);

  final Database _database;

  /// The reference data the engine scores over, read straight from the guides.
  Future<List<RoadmapCandidate>> loadCandidates({Session? session}) async {
    final countries = await _query(
      'SELECT iso, name_en, name_ar, region, pathway_class, exam_code, '
      'min_months, max_months, floor_cost_usd, floor_cost_complete, '
      'required_languages, '
      'authority_en, authority_ar '
      'FROM countries ORDER BY iso',
      const {},
      session,
    );

    final steps = await _query(
      'SELECT country_iso, position, title_en, title_ar, detail_en, detail_ar, '
      'when_label, is_optional FROM country_steps ORDER BY country_iso, position',
      const {},
      session,
    );

    final costs = await _query(
      'SELECT country_iso, position, usd_value, usd_status '
      'FROM country_costs ORDER BY country_iso, position',
      const {},
      session,
    );

    final stepsByCountry = <String, List<CountryStep>>{};
    for (final row in steps) {
      stepsByCountry
          .putIfAbsent(row.str('country_iso'), () => [])
          .add(
            CountryStep(
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
          );
    }

    final costsByCountry = <String, Map<int, Sourced<String>>>{};
    for (final row in costs) {
      costsByCountry.putIfAbsent(row.str('country_iso'), () => {})[row.intAt(
        'position',
      )] = Sourced<String>(
        value: row.strOrNull('usd_value'),
        status: SourceStatus.fromWire(row.str('usd_status')),
      );
    }

    return countries
        .map(
          (row) => RoadmapCandidate(
            iso: row.str('iso'),
            name: LocalizedText(en: row.str('name_en'), ar: row.str('name_ar')),
            region: row.str('region'),
            pathwayClass: PathwayClass.fromWire(row.str('pathway_class')),
            examCode: row.str('exam_code'),
            minMonths: row.intAt('min_months'),
            maxMonths: row.intAt('max_months'),
            floorCostUsd: row.intOrNull('floor_cost_usd'),
            floorCostComplete: row.boolAt('floor_cost_complete'),
            requiredLanguages: row.stringList('required_languages'),
            steps: stepsByCountry[row.str('iso')] ?? const [],
            stepCosts: costsByCountry[row.str('iso')] ?? const {},
            authority: LocalizedText(
              en: row.str('authority_en'),
              ar: row.str('authority_ar'),
            ),
          ),
        )
        .toList();
  }

  /// A version stamp for the reference data.
  ///
  /// Stored on every generated roadmap so "same inputs, same output" can be
  /// asserted against a known dataset rather than against whatever is current.
  Future<String> referenceDataVersion({Session? session}) async {
    final rows = await _query(
      'SELECT count(*) AS countries, '
      "coalesce(max(updated_at)::text, '') AS updated FROM countries",
      const {},
      session,
    );
    final row = rows.first;
    return 'countries:${row.intAt('countries')}@${row.str('updated')}';
  }

  // --- Drafts ---------------------------------------------------------------

  Future<Map<String, dynamic>?> loadDraft({
    String? userId,
    String? deviceToken,
    Session? session,
  }) async {
    if (userId == null && deviceToken == null) return null;
    final rows = await _query(
      userId != null
          ? 'SELECT answers, last_step FROM roadmap_drafts WHERE user_id = @key'
          : 'SELECT answers, last_step FROM roadmap_drafts '
                'WHERE device_token = @key AND user_id IS NULL',
      {'key': userId ?? deviceToken},
      session,
    );
    if (rows.isEmpty) return null;
    return {
      'answers': rows.first['answers'],
      'last_step': rows.first.intAt('last_step'),
    };
  }

  /// Saves funnel progress after every step.
  ///
  /// A guest who kills the app mid-funnel must find their answers on relaunch,
  /// so this is written eagerly rather than on completion.
  Future<void> saveDraft({
    String? userId,
    String? deviceToken,
    required Map<String, dynamic> answers,
    required int lastStep,
    Session? session,
  }) async {
    if (userId != null) {
      await _execute(
        '''
        INSERT INTO roadmap_drafts (user_id, answers, last_step)
        VALUES (@user_id, @answers::jsonb, @last_step)
        ON CONFLICT (user_id) WHERE user_id IS NOT NULL
        DO UPDATE SET answers = @answers::jsonb, last_step = @last_step,
                      updated_at = now()
        ''',
        {
          'user_id': userId,
          'answers': jsonEncode(answers),
          'last_step': lastStep,
        },
        session,
      );
      return;
    }

    await _execute(
      '''
      INSERT INTO roadmap_drafts (device_token, answers, last_step)
      VALUES (@device_token, @answers::jsonb, @last_step)
      ON CONFLICT (device_token) WHERE device_token IS NOT NULL AND user_id IS NULL
      DO UPDATE SET answers = @answers::jsonb, last_step = @last_step,
                    updated_at = now()
      ''',
      {
        'device_token': deviceToken,
        'answers': jsonEncode(answers),
        'last_step': lastStep,
      },
      session,
    );
  }

  /// Moves a guest's draft and generated roadmaps onto their new account.
  ///
  /// Runs inside the registration transaction. If this fails, the account is
  /// not created either — a user who signs up at the gate and loses their four
  /// answers is a critical defect, not an acceptable edge case.
  Future<void> adoptGuestWork({
    required String deviceToken,
    required String userId,
    required Session session,
  }) async {
    await _execute(
      'UPDATE roadmaps SET user_id = @user_id, device_token = NULL '
      'WHERE device_token = @device_token AND user_id IS NULL',
      {'user_id': userId, 'device_token': deviceToken},
      session,
    );

    // The user may already have a draft (signed in elsewhere); the guest one
    // then has nothing to overwrite and is simply discarded.
    await _execute(
      '''
      UPDATE roadmap_drafts SET user_id = @user_id, device_token = NULL
      WHERE device_token = @device_token AND user_id IS NULL
        AND NOT EXISTS (SELECT 1 FROM roadmap_drafts WHERE user_id = @user_id)
      ''',
      {'user_id': userId, 'device_token': deviceToken},
      session,
    );

    await _execute(
      'DELETE FROM roadmap_drafts WHERE device_token = @device_token '
      'AND user_id IS NULL',
      {'device_token': deviceToken},
      session,
    );
  }

  // --- Results --------------------------------------------------------------

  Future<Roadmap> insertRoadmap({
    String? userId,
    String? deviceToken,
    required GeneratedRoadmap generated,
    required RoadmapAnswers answers,
    required String referenceDataVersion,
    String? parentId,
    LocalizedText? scenarioLabel,
    required bool isSaved,
    Session? session,
  }) async {
    Future<Roadmap> insert(Session s) async {
      final rows = await _query(
        '''
        INSERT INTO roadmaps (
          user_id, device_token, destination_iso, destination_name_en,
          destination_name_ar, fit_score, headline_en, headline_ar,
          summary_en, summary_ar, watch_out_en, watch_out_ar,
          this_month_action_en, this_month_action_ar, answers, alternatives,
          reference_data_version, parent_id, scenario_label_en,
          scenario_label_ar, is_saved
        ) VALUES (
          @user_id, @device_token, @destination_iso, @destination_name_en,
          @destination_name_ar, @fit_score, @headline_en, @headline_ar,
          @summary_en, @summary_ar, @watch_out_en, @watch_out_ar,
          @action_en, @action_ar, @answers::jsonb, @alternatives::jsonb,
          @reference_data_version, @parent_id, @scenario_label_en,
          @scenario_label_ar, @is_saved
        )
        RETURNING id, created_at
        ''',
        {
          'user_id': userId,
          'device_token': deviceToken,
          'destination_iso': generated.destinationIso,
          'destination_name_en': generated.destinationName.en,
          'destination_name_ar': generated.destinationName.ar,
          'fit_score': generated.fitScore,
          'headline_en': generated.headline.en,
          'headline_ar': generated.headline.ar,
          'summary_en': generated.summary.en,
          'summary_ar': generated.summary.ar,
          'watch_out_en': generated.watchOut.en,
          'watch_out_ar': generated.watchOut.ar,
          'action_en': generated.thisMonthAction.en,
          'action_ar': generated.thisMonthAction.ar,
          'answers': jsonEncode(answers.toJson()),
          'alternatives': jsonEncode(
            generated.alternatives.map((a) => a.toJson()).toList(),
          ),
          'reference_data_version': referenceDataVersion,
          'parent_id': parentId,
          'scenario_label_en': scenarioLabel?.en,
          'scenario_label_ar': scenarioLabel?.ar,
          'is_saved': isSaved,
        },
        s,
      );

      final id = rows.first.str('id');
      for (final stage in generated.stages) {
        await _execute(
          '''
          INSERT INTO roadmap_stages (
            roadmap_id, position, title_en, title_ar, detail_en, detail_ar,
            projected_start, projected_end, is_optional, cost_value,
            cost_status, source_country_iso, linked_course_id
          ) VALUES (
            @roadmap_id, @position, @title_en, @title_ar, @detail_en, @detail_ar,
            @projected_start, @projected_end, @is_optional, @cost_value,
            @cost_status::source_status, @source_country_iso, @linked_course_id
          )
          ''',
          {
            'roadmap_id': id,
            'position': stage.position,
            'title_en': stage.title.en,
            'title_ar': stage.title.ar,
            'detail_en': stage.detail.en,
            'detail_ar': stage.detail.ar,
            'projected_start': stage.projectedStart,
            'projected_end': stage.projectedEnd,
            'is_optional': stage.isOptional,
            'cost_value': stage.cost.value,
            'cost_status': stage.cost.status.wire,
            'source_country_iso': stage.sourceCountryIso,
            'linked_course_id': stage.linkedCourseId,
          },
          s,
        );
      }

      return (await _findRoadmap(id, session: s))!;
    }

    return session != null ? insert(session) : _database.runTx(insert);
  }

  /// Loads a roadmap **for the caller who owns it**, and nobody else.
  ///
  /// Ownership is a `WHERE` clause rather than an `if` in Dart, because an `if`
  /// is one refactor away from being dropped and this row holds the user's
  /// specialty, budget and target regions. A guest owns their draft through the
  /// device token that created it; once claimed, through `user_id`.
  ///
  /// Returns null — not a 403 — when the row exists but belongs to someone
  /// else, so the caller answers "not found" and never confirms that an id is
  /// real.
  Future<Roadmap?> findRoadmapFor(
    String id, {
    String? userId,
    String? deviceToken,
    Session? session,
  }) async {
    // No identity at all owns nothing. Without this an unauthenticated caller
    // with neither token would match the `user_id IS NULL` branch.
    if (userId == null && deviceToken == null) return null;

    final rows = await _query(
      'SELECT * FROM roadmaps WHERE id = @id AND ('
      '  (@user_id::uuid IS NOT NULL AND user_id = @user_id::uuid) '
      '  OR (user_id IS NULL AND @device_token::text IS NOT NULL '
      '      AND device_token = @device_token::text))',
      {'id': id, 'user_id': userId, 'device_token': deviceToken},
      session,
    );
    if (rows.isEmpty) return null;

    final stages = await _query(
      'SELECT * FROM roadmap_stages WHERE roadmap_id = @id ORDER BY position',
      {'id': id},
      session,
    );
    return _toRoadmap(rows.first, stages);
  }

  /// Loads a roadmap by id with no ownership predicate.
  ///
  /// Private on purpose. The only safe use is reading back a row this same
  /// repository has just written, where the id did not come from a request.
  /// Everything reachable from an HTTP route goes through [findRoadmapFor].
  Future<Roadmap?> _findRoadmap(String id, {Session? session}) async {
    final rows = await _query('SELECT * FROM roadmaps WHERE id = @id', {
      'id': id,
    }, session);
    if (rows.isEmpty) return null;

    final stages = await _query(
      'SELECT * FROM roadmap_stages WHERE roadmap_id = @id ORDER BY position',
      {'id': id},
      session,
    );
    return _toRoadmap(rows.first, stages);
  }

  Future<List<Roadmap>> listRoadmaps(String userId, {Session? session}) async {
    final rows = await _query(
      'SELECT * FROM roadmaps WHERE user_id = @user_id AND is_saved = true '
      'ORDER BY created_at DESC',
      {'user_id': userId},
      session,
    );
    if (rows.isEmpty) return const [];

    final stages = await _query(
      'SELECT s.* FROM roadmap_stages s '
      'JOIN roadmaps r ON r.id = s.roadmap_id '
      'WHERE r.user_id = @user_id ORDER BY s.roadmap_id, s.position',
      {'user_id': userId},
      session,
    );

    final byRoadmap = <String, List<Map<String, dynamic>>>{};
    for (final stage in stages) {
      byRoadmap.putIfAbsent(stage.str('roadmap_id'), () => []).add(stage);
    }

    return rows
        .map((row) => _toRoadmap(row, byRoadmap[row.str('id')] ?? const []))
        .toList();
  }

  /// Attaches an unclaimed guest roadmap to an account.
  ///
  /// Scoped to rows that have no owner yet, so this can never take a roadmap
  /// away from another user.
  Future<void> claimForUser(String id, String userId, {Session? session}) =>
      _execute(
        'UPDATE roadmaps SET user_id = @user_id, device_token = NULL '
        'WHERE id = @id AND user_id IS NULL',
        {'id': id, 'user_id': userId},
        session,
      );

  /// Every mutation below carries the owner in its own `WHERE` clause, not just
  /// in the read that preceded it. A check-then-write pair is two statements a
  /// refactor can separate; this cannot be separated from the write.
  Future<void> setSaved(
    String id,
    bool isSaved, {
    required String userId,
    Session? session,
  }) => _execute(
    'UPDATE roadmaps SET is_saved = @is_saved '
    'WHERE id = @id AND user_id = @user_id',
    {'id': id, 'is_saved': isSaved, 'user_id': userId},
    session,
  );

  Future<void> setStageComplete({
    required String roadmapId,
    required int position,
    required bool isComplete,
    required String userId,
    Session? session,
  }) => _execute(
    'UPDATE roadmap_stages SET is_complete = @is_complete, '
    'completed_at = CASE WHEN @is_complete THEN now() ELSE NULL END '
    'WHERE position = @position AND roadmap_id = ('
    '  SELECT id FROM roadmaps WHERE id = @roadmap_id AND user_id = @user_id)',
    {
      'roadmap_id': roadmapId,
      'position': position,
      'is_complete': isComplete,
      'user_id': userId,
    },
    session,
  );

  Roadmap _toRoadmap(
    Map<String, dynamic> row,
    List<Map<String, dynamic>> stageRows,
  ) => Roadmap(
    id: row.str('id'),
    destinationIso: row.strOrNull('destination_iso'),
    destinationName: LocalizedText(
      en: row.str('destination_name_en'),
      ar: row.str('destination_name_ar'),
    ),
    fitScore: row.intAt('fit_score'),
    headline: LocalizedText(
      en: row.str('headline_en'),
      ar: row.str('headline_ar'),
    ),
    summary: LocalizedText(
      en: row.str('summary_en'),
      ar: row.str('summary_ar'),
    ),
    watchOut: LocalizedText(
      en: row.str('watch_out_en'),
      ar: row.str('watch_out_ar'),
    ),
    thisMonthAction: LocalizedText(
      en: row.str('this_month_action_en'),
      ar: row.str('this_month_action_ar'),
    ),
    stages: stageRows
        .map(
          (stage) => RoadmapStage(
            position: stage.intAt('position'),
            title: LocalizedText(
              en: stage.str('title_en'),
              ar: stage.str('title_ar'),
            ),
            detail: LocalizedText(
              en: stage.str('detail_en'),
              ar: stage.str('detail_ar'),
            ),
            projectedStart: stage.dateAt('projected_start'),
            projectedEnd: stage.dateAt('projected_end'),
            isOptional: stage.boolAt('is_optional'),
            cost: Sourced<String>(
              value: stage.strOrNull('cost_value'),
              status: SourceStatus.fromWire(stage.str('cost_status')),
            ),
            isComplete: stage.boolAt('is_complete'),
            sourceCountryIso: stage.strOrNull('source_country_iso'),
            linkedCourseId: stage.intOrNull('linked_course_id'),
          ),
        )
        .toList(),
    alternatives: (_decodeJson(row['alternatives']) as List<dynamic>)
        .map(
          (a) =>
              RoadmapAlternative.fromJson(Map<String, dynamic>.from(a as Map)),
        )
        .toList(),
    answers: RoadmapAnswers.fromJson(
      Map<String, dynamic>.from(_decodeJson(row['answers']) as Map),
    ),
    createdAt: row.dateAt('created_at'),
    referenceDataVersion: row.str('reference_data_version'),
    isSaved: row.boolAt('is_saved'),
    parentId: row.strOrNull('parent_id'),
    scenarioLabel: row.strOrNull('scenario_label_en') == null
        ? null
        : LocalizedText(
            en: row.str('scenario_label_en'),
            ar: row.str('scenario_label_ar'),
          ),
  );

  /// jsonb columns arrive already decoded on some driver paths and as a string
  /// on others; normalise both.
  static Object? _decodeJson(Object? value) =>
      value is String ? jsonDecode(value) : value;

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
