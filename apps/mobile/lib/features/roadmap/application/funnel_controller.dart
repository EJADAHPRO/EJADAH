import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../data/roadmap_repository.dart';

/// The four funnel answers, as they are being filled in.
class FunnelDraft {
  const FunnelDraft({
    this.path,
    this.stage,
    this.yearsQualified = 0,
    this.budgetUsd = 5000,
    this.monthsAvailable = 18,
    this.regions = const [],
    this.languages = const ['ar', 'en'],
    this.step = 1,
  });

  final RoadmapPath? path;
  final CareerStage? stage;
  final int yearsQualified;

  /// A ceiling, not a target. The helper text says exactly that.
  final int budgetUsd;

  /// Also a ceiling.
  final int monthsAvailable;
  final List<RoadmapRegion> regions;
  final List<String> languages;
  final int step;

  static const int stepCount = 4;

  /// Which steps are answered well enough to advance.
  bool canAdvanceFrom(int step) => switch (step) {
    1 => path != null,
    2 => stage != null,
    3 => budgetUsd > 0 && monthsAvailable > 0,
    4 => regions.isNotEmpty && languages.isNotEmpty,
    _ => false,
  };

  bool get isComplete => path != null && stage != null && canAdvanceFrom(4);

  RoadmapAnswers toAnswers() => RoadmapAnswers(
    path: path ?? RoadmapPath.generalPractice,
    stage: stage ?? CareerStage.generalDentist,
    yearsQualified: yearsQualified,
    budgetUsd: budgetUsd,
    monthsAvailable: monthsAvailable,
    regions: regions,
    languages: languages,
  );

  FunnelDraft copyWith({
    RoadmapPath? path,
    CareerStage? stage,
    int? yearsQualified,
    int? budgetUsd,
    int? monthsAvailable,
    List<RoadmapRegion>? regions,
    List<String>? languages,
    int? step,
  }) => FunnelDraft(
    path: path ?? this.path,
    stage: stage ?? this.stage,
    yearsQualified: yearsQualified ?? this.yearsQualified,
    budgetUsd: budgetUsd ?? this.budgetUsd,
    monthsAvailable: monthsAvailable ?? this.monthsAvailable,
    regions: regions ?? this.regions,
    languages: languages ?? this.languages,
    step: step ?? this.step,
  );
}

final funnelControllerProvider =
    NotifierProvider<FunnelController, FunnelDraft>(FunnelController.new);

/// Owns the roadmap funnel.
///
/// Guest-capable from end to end: nothing here requires an account, and the
/// draft is written to the server after every step so a killed app relaunches
/// where it left off.
class FunnelController extends Notifier<FunnelDraft> {
  @override
  FunnelDraft build() {
    Future.microtask(_restore);
    return const FunnelDraft();
  }

  Future<void> _restore() async {
    final draft = await ref.read(roadmapRepositoryProvider).loadDraft();
    final answers = draft?.answers;
    if (answers == null) return;

    state = FunnelDraft(
      path: answers.path,
      stage: answers.stage,
      yearsQualified: answers.yearsQualified,
      budgetUsd: answers.budgetUsd,
      monthsAvailable: answers.monthsAvailable,
      regions: answers.regions,
      languages: answers.languages,
      step: draft!.lastStep,
    );
  }

  void seedPath(RoadmapPath path) => state = state.copyWith(path: path);

  /// A single-select answer auto-advances; multi-select needs an explicit
  /// Continue, because the user is not finished until they say so.
  Future<void> choosePath(RoadmapPath path) async {
    state = state.copyWith(path: path);
    await advance();
  }

  Future<void> chooseStage(CareerStage stage) async {
    state = state.copyWith(stage: stage);
  }

  void setYears(int years) => state = state.copyWith(yearsQualified: years);

  void setBudget(int usd) => state = state.copyWith(budgetUsd: usd);

  void setMonths(int months) => state = state.copyWith(monthsAvailable: months);

  void toggleRegion(RoadmapRegion region) => state = state.copyWith(
    regions: state.regions.contains(region)
        ? (state.regions.toList()..remove(region))
        : [...state.regions, region],
  );

  void toggleLanguage(String code) => state = state.copyWith(
    languages: state.languages.contains(code)
        ? (state.languages.toList()..remove(code))
        : [...state.languages, code],
  );

  Future<void> advance() async {
    if (!state.canAdvanceFrom(state.step)) return;
    final next = state.step + 1;
    state = state.copyWith(step: next);
    await _persist();
    await ref.read(analyticsProvider).track(
      AnalyticsEvents.roadmapStepCompleted,
      {'step': next - 1},
    );
  }

  void back() {
    if (state.step > 1) state = state.copyWith(step: state.step - 1);
  }

  /// Written after every step. Leaving the funnel keeps the draft; returning
  /// restores it.
  Future<void> _persist() => ref
      .read(roadmapRepositoryProvider)
      .saveDraft(state.toAnswers(), state.step);
}
