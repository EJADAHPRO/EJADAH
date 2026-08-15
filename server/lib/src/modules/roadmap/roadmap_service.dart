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

  Future<RoadmapView> roadmap(String id, {String? userId, String? deviceToken}) async {
    final roadmap = await _repository.findRoadmap(id);
    if (roadmap == null) throw ApiException.notFound();
    return _view(roadmap, isGuest: userId == null);
  }

  Future<List<Roadmap>> myRoadmaps(String userId) =>
      _repository.listRoadmaps(userId);

  Future<RoadmapView> save(String id, String userId) async {
    final roadmap = await _repository.findRoadmap(id);
    if (roadmap == null) throw ApiException.notFound();
    await _repository.setSaved(id, true);
    return _view(
      (await _repository.findRoadmap(id))!,
      isGuest: false,
    );
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
    final parent = await _repository.findRoadmap(parentId);
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
    final roadmap = await _repository.findRoadmap(roadmapId);
    if (roadmap == null) throw ApiException.notFound();
    await _repository.setStageComplete(
      roadmapId: roadmapId,
      position: position,
      isComplete: isComplete,
    );
    return _view((await _repository.findRoadmap(roadmapId))!, isGuest: false);
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
