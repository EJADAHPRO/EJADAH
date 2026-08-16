import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';

/// A roadmap plus how much of it the caller is allowed to read.
class RoadmapView {
  const RoadmapView({
    required this.roadmap,
    required this.isGated,
    required this.totalStageCount,
  });

  final Roadmap roadmap;

  /// True when the server withheld stages because the caller is a guest.
  final bool isGated;
  final int totalStageCount;

  int get hiddenStageCount => totalStageCount - roadmap.stages.length;

  static RoadmapView fromJson(Map<String, dynamic> json) => RoadmapView(
    roadmap: Roadmap.fromJson(json),
    isGated: json['is_gated'] == true,
    totalStageCount: (json['total_stage_count'] as num?)?.toInt() ?? 0,
  );
}

final roadmapRepositoryProvider = Provider<RoadmapRepository>(
  (ref) => RoadmapRepository(ref.watch(apiClientProvider)),
);

class RoadmapRepository {
  const RoadmapRepository(this._client);

  final ApiClient _client;

  /// The funnel draft. Guest-capable: the device token identifies the owner.
  Future<({RoadmapAnswers? answers, int lastStep})?> loadDraft() => _client.get(
    '/roadmap/draft',
    parse: (json) => (
      answers: json['answers'] == null
          ? null
          : RoadmapAnswers.fromJson(
              Map<String, dynamic>.from(json['answers'] as Map),
            ),
      lastStep: (json['last_step'] as num?)?.toInt() ?? 1,
    ),
  );

  /// Saved after every step, so killing the app mid-funnel loses nothing.
  Future<void> saveDraft(RoadmapAnswers answers, int lastStep) =>
      _client.putVoid(
        '/roadmap/draft',
        body: {'answers': answers.toJson(), 'last_step': lastStep},
      );

  Future<RoadmapView> generate(RoadmapAnswers answers) => _client.post(
    '/roadmap/generate',
    body: {'answers': answers.toJson()},
    parse: RoadmapView.fromJson,
  );

  Future<RoadmapView> roadmap(String id) =>
      _client.get('/roadmap/$id', parse: RoadmapView.fromJson);

  /// The six presets, with the labels their scenarios will be stored under.
  ///
  /// Fetched rather than held in the string tables so the chip the user taps
  /// and the label the scenario is saved with cannot drift apart.
  Future<List<({WhatIfPreset preset, LocalizedText label})>> whatIfPresets() =>
      _client.get(
        '/roadmap/what-if-presets',
        parse: (json) => [
          for (final item in json['items'] as List<dynamic>? ?? const [])
            (
              preset: WhatIfPreset.fromWire((item as Map)['preset'] as String?),
              label: LocalizedText.fromJson(item['label'])!,
            ),
        ],
      );

  Future<RoadmapView> whatIf(String id, WhatIfPreset preset) => _client.post(
    '/roadmap/$id/what-if',
    body: {'preset': preset.wire},
    parse: RoadmapView.fromJson,
  );

  Future<List<Roadmap>> mine() => _client.get(
    '/roadmap/mine',
    parse: (json) => (json['items'] as List<dynamic>)
        .map((item) => Roadmap.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList(),
  );
}
