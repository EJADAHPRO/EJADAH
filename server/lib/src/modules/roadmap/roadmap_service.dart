import 'package:ejadah_models/ejadah_models.dart';

import '../../http/api_error.dart';
import 'roadmap_engine.dart';
import 'roadmap_repository.dart';

/// What a caller is allowed to see of a roadmap.
///
/// A guest reads the first two stages; the rest are withheld by the *server*.
/// Blurring them in the client would leave the full result one inspector away,
/// which is not a gate.
class RoadmapView {
  const RoadmapView({
    required this.roadmap,
    required this.isGated,
    required this.totalStageCount,
  });

  final Roadmap roadmap;
  final bool isGated;
  final int totalStageCount;

  Map<String, dynamic> toJson() => {
    ...roadmap.toJson(),
    'is_gated': isGated,
    'total_stage_count': totalStageCount,
    'visible_stage_count': roadmap.stages.length,
  };
}

/// Roadmap use-cases: draft, generate, gate, save, what-if.
class RoadmapService {
  RoadmapService({
    required RoadmapRepository repository,
    RoadmapEngine engine = const RoadmapEngine(),
    DateTime Function()? clock,
  }) : _repository = repository,
       _engine = engine,
       _now = clock ?? (() => DateTime.now().toUtc());

  final RoadmapRepository _repository;
  final RoadmapEngine _engine;
  final DateTime Function() _now;

  Future<Map<String, dynamic>?> loadDraft({
    String? userId,
    String? deviceToken,
  }) => _repository.loadDraft(userId: userId, deviceToken: deviceToken);

  Future<void> saveDraft({
    String? userId,
    String? deviceToken,
    required Map<String, dynamic> answers,
    required int lastStep,
  }) {
    if (userId == null && (deviceToken == null || deviceToken.isEmpty)) {
      // Without an owner the draft could not be found again, and silently
      // dropping the user's answers is the failure this guards.
      throw ApiException(
        ApiErrorCode.validation,
        details: 'A draft needs either a signed-in user or a device token.',
      );
    }
    return _repository.saveDraft(
      userId: userId,
      deviceToken: deviceToken,
      answers: answers,
      lastStep: lastStep,
    );
  }

  /// Generates a roadmap from a complete set of answers.
  ///
  /// Guests may generate. The result is stored against their device token so
  /// that signing up at the gate lands them on this same roadmap, full.
  Future<RoadmapView> generate({
    String? userId,
    String? deviceToken,
    required RoadmapAnswers answers,
  }) async {
    if (!answers.isComplete) {
      throw ApiException(
        ApiErrorCode.validation,
        details: 'The funnel must be complete before generating.',
      );
    }
    if (userId == null && (deviceToken == null || deviceToken.isEmpty)) {
      // The same guard `saveDraft` carries, and for the same reason: a roadmap
      // with no owner could never be read back. Without it the row reaches the
      // `roadmaps_has_owner` constraint and the caller gets a 500 for what is
      // really a missing header.
      throw ApiException(
        ApiErrorCode.validation,
        details:
            'Generating needs either a signed-in user or a device token. '
            'Send x-device-token.',
      );
    }

    final candidates = await _repository.loadCandidates();
    final version = await _repository.referenceDataVersion();
    final generated = _engine.generate(
      answers: answers,
      candidates: candidates,
      today: _now(),
    );

    final roadmap = await _repository.insertRoadmap(
      userId: userId,
      deviceToken: userId == null ? deviceToken : null,
      generated: generated,
      answers: answers,
      referenceDataVersion: version,
      // A signed-in user's generated roadmap is theirs immediately; a guest's is
      // provisional until they have an account to save it to.
      isSaved: userId != null,
    );

    return _view(roadmap, isGuest: userId == null);
  }

  /// A roadmap is only ever readable by the caller who owns it.
  ///
  /// A roadmap holds the user's specialty, budget and target regions — their
  /// private career and financial profile. Someone else's id resolves to "not
  /// found", the same answer as an id that never existed, so the endpoint does
  /// not confirm which roadmaps are real.
  Future<RoadmapView> roadmap(
    String id, {
    String? userId,
    String? deviceToken,
  }) async {
    final roadmap = await _repository.findRoadmapFor(
      id,
      userId: userId,
      deviceToken: deviceToken,
    );
    if (roadmap == null) throw ApiException.notFound();
    return _view(roadmap, isGuest: userId == null);
  }

  Future<List<Roadmap>> myRoadmaps(String userId) =>
      _repository.listRoadmaps(userId);

  /// Claims a roadmap for an account.
  ///
  /// The caller must already own it — either as the signed-in user, or as the
  /// guest whose device token created it and who has just signed in.
  Future<RoadmapView> save(
    String id,
    String userId, {
    String? deviceToken,
  }) async {
    final roadmap = await _repository.findRoadmapFor(
      id,
      userId: userId,
      deviceToken: deviceToken,
    );
    if (roadmap == null) throw ApiException.notFound();

    // A guest's draft becomes theirs on save; it is not another user's row.
    await _repository.claimForUser(id, userId);
    await _repository.setSaved(id, true, userId: userId);

    final saved = await _repository.findRoadmapFor(id, userId: userId);
    return _view(saved!, isGuest: false);
  }

  /// Runs a what-if preset.
  ///
  /// Changes exactly one variable and generates a NEW roadmap linked to the
  /// original. The original is never overwritten — the comparison is the value.
  Future<RoadmapView> whatIf({
    required String parentId,
    required WhatIfPreset preset,
    required String userId,
  }) async {
    // A scenario is cloned from the parent's private answers, so the caller
    // must own the parent — otherwise "what if" is a read of someone else's
    // budget wearing a different name.
    final parent = await _repository.findRoadmapFor(parentId, userId: userId);
    if (parent == null) throw ApiException.notFound();

    final candidates = await _repository.loadCandidates();
    final version = await _repository.referenceDataVersion();
    final answers = preset.apply(parent.answers);

    final generated = _engine.generate(
      answers: answers,
      candidates: candidates,
      today: _now(),
    );

    final scenario = await _repository.insertRoadmap(
      userId: userId,
      generated: generated,
      answers: answers,
      referenceDataVersion: version,
      // Scenarios nest under their parent in "My roadmaps".
      parentId: parent.parentId ?? parent.id,
      scenarioLabel: _scenarioLabel(preset),
      isSaved: true,
    );

    return _view(scenario, isGuest: false);
  }

  Future<RoadmapView> setStageComplete({
    required String roadmapId,
    required int position,
    required bool isComplete,
    required String userId,
  }) async {
    final roadmap = await _repository.findRoadmapFor(roadmapId, userId: userId);
    if (roadmap == null) throw ApiException.notFound();
    await _repository.setStageComplete(
      roadmapId: roadmapId,
      position: position,
      isComplete: isComplete,
      userId: userId,
    );
    final updated = await _repository.findRoadmapFor(
      roadmapId,
      userId: userId,
    );
    return _view(updated!, isGuest: false);
  }

  RoadmapView _view(Roadmap roadmap, {required bool isGuest}) {
    if (!isGuest || roadmap.stages.length <= Roadmap.guestVisibleStages) {
      return RoadmapView(
        roadmap: roadmap,
        isGated: false,
        totalStageCount: roadmap.stages.length,
      );
    }

    // Two stages readable, the rest withheld. Four answers are already invested
    // by this point, which is why the gate falls here and not at the entrance.
    return RoadmapView(
      roadmap: Roadmap(
        id: roadmap.id,
        destinationIso: roadmap.destinationIso,
        destinationName: roadmap.destinationName,
        fitScore: roadmap.fitScore,
        headline: roadmap.headline,
        summary: roadmap.summary,
        watchOut: roadmap.watchOut,
        thisMonthAction: roadmap.thisMonthAction,
        stages: roadmap.stages.take(Roadmap.guestVisibleStages).toList(),
        alternatives: roadmap.alternatives,
        answers: roadmap.answers,
        createdAt: roadmap.createdAt,
        referenceDataVersion: roadmap.referenceDataVersion,
        isSaved: roadmap.isSaved,
        parentId: roadmap.parentId,
        scenarioLabel: roadmap.scenarioLabel,
      ),
      isGated: true,
      totalStageCount: roadmap.stages.length,
    );
  }

  /// The six presets and the labels a scenario will be stored under.
  ///
  /// Served rather than duplicated in the string tables: the chip the user taps
  /// and the label the scenario is saved with are then the same words by
  /// construction, and there is one place to change them.
  static List<Map<String, dynamic>> get whatIfPresets => [
    for (final preset in WhatIfPreset.values)
      {'preset': preset.wire, 'label': _scenarioLabel(preset).toJson()},
  ];

  static LocalizedText _scenarioLabel(WhatIfPreset preset) => switch (preset) {
    WhatIfPreset.budgetPlus50 => const LocalizedText(
      en: 'Budget +50%',
      ar: 'الميزانية +50%',
    ),
    WhatIfPreset.budgetMinus25 => const LocalizedText(
      en: 'Budget −25%',
      ar: 'الميزانية −25%',
    ),
    WhatIfPreset.moreTime => const LocalizedText(
      en: '12 months more',
      ar: '12 شهرًا إضافية',
    ),
    WhatIfPreset.lessTime => const LocalizedText(
      en: '6 months less',
      ar: '6 أشهر أقل',
    ),
    WhatIfPreset.addGulf => const LocalizedText(
      en: 'Include the Gulf',
      ar: 'مع الخليج',
    ),
    WhatIfPreset.stayEgypt => const LocalizedText(
      en: 'Stay in Egypt',
      ar: 'البقاء في مصر',
    ),
  };
}
