import '../common/localized_text.dart';
import '../common/sourced.dart';
import '../common/value.dart';

/// The four directions out of the same qualification (funnel step 1).
///
/// Canonical set from the prototype's `PATHS`. Direction changes what the
/// generator is allowed to recommend — `digital` and `business` must never
/// produce a licensing exam or a clinical Master's.
enum RoadmapPath {
  /// Work abroad as a GP — licensing exam, registration, visa.
  generalPractice('gp_abroad'),

  /// Specialise clinically — MSc, residency or board.
  specialise('specialise'),

  /// Digital and freelance — from Cairo, paid in USD.
  digital('digital'),

  /// Business and industry — no clinical Master's needed.
  business('business');

  const RoadmapPath(this.wire);

  final String wire;

  static RoadmapPath fromWire(String? value) => RoadmapPath.values.firstWhere(
    (path) => path.wire == value,
    orElse: () => RoadmapPath.generalPractice,
  );

  /// True where a licensing pathway is a legitimate recommendation.
  bool get allowsLicensingRoute =>
      this == RoadmapPath.generalPractice || this == RoadmapPath.specialise;
}

/// Where the user is in their career (funnel step 2).
enum CareerStage {
  student('student'),
  freshGraduate('fresh_graduate'),
  generalDentist('general_dentist'),
  specialist('specialist'),
  consultantOwner('consultant_owner');

  const CareerStage(this.wire);

  final String wire;

  static CareerStage fromWire(String? value) => CareerStage.values.firstWhere(
    (stage) => stage.wire == value,
    orElse: () => CareerStage.generalDentist,
  );

  /// A student's route must not be an emigration route — the funnel branches
  /// here (`PRODUCT_CORE.md` §3, persona visibility notes).
  bool get isStillStudying => this == CareerStage.student;
}

/// Region preferences (funnel step 4). "Stay in Egypt" is a destination in its
/// own right, never a consolation prize.
enum RoadmapRegion {
  gulf('gulf'),
  ukIreland('uk_ireland'),
  europe('europe'),
  northAmerica('north_america'),
  stayEgypt('stay_egypt');

  const RoadmapRegion(this.wire);

  final String wire;

  static RoadmapRegion fromWire(String? value) =>
      RoadmapRegion.values.firstWhere(
        (region) => region.wire == value,
        orElse: () => RoadmapRegion.gulf,
      );
}

/// The four funnel answers.
///
/// Budget and study time are **hard limits, not preferences** — a route the
/// user cannot afford is a wrong answer, so these become SQL pre-filters
/// rather than scoring nudges (`EJADAH-BUILD-STORY.md`, Tab 4, rule 1).
class RoadmapAnswers extends ValueObject {
  const RoadmapAnswers({
    required this.path,
    required this.stage,
    required this.yearsQualified,
    required this.budgetUsd,
    required this.monthsAvailable,
    required this.regions,
    required this.languages,
    this.specialty,
  });

  final RoadmapPath path;
  final CareerStage stage;
  final int yearsQualified;

  /// A ceiling, not a target.
  final int budgetUsd;

  /// A ceiling, not a target.
  final int monthsAvailable;
  final List<RoadmapRegion> regions;

  /// Language codes the user can work in, e.g. `['en', 'ar']`.
  final List<String> languages;
  final String? specialty;

  /// True once every question needed to generate has an answer.
  bool get isComplete =>
      budgetUsd > 0 &&
      monthsAvailable > 0 &&
      regions.isNotEmpty &&
      languages.isNotEmpty;

  factory RoadmapAnswers.fromJson(Map<String, dynamic> json) => RoadmapAnswers(
    path: RoadmapPath.fromWire(json['path'] as String?),
    stage: CareerStage.fromWire(json['stage'] as String?),
    yearsQualified: jsonInt(json['years_qualified']) ?? 0,
    budgetUsd: jsonInt(json['budget_usd']) ?? 0,
    monthsAvailable: jsonInt(json['months_available']) ?? 0,
    regions: (json['regions'] as List<dynamic>? ?? const [])
        .map((r) => RoadmapRegion.fromWire(r as String?))
        .toList(),
    languages: (json['languages'] as List<dynamic>? ?? const [])
        .map((l) => l.toString())
        .toList(),
    specialty: json['specialty'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'path': path.wire,
    'stage': stage.wire,
    'years_qualified': yearsQualified,
    'budget_usd': budgetUsd,
    'months_available': monthsAvailable,
    'regions': regions.map((r) => r.wire).toList(),
    'languages': languages,
    'specialty': specialty,
  };

  RoadmapAnswers copyWith({
    RoadmapPath? path,
    CareerStage? stage,
    int? yearsQualified,
    int? budgetUsd,
    int? monthsAvailable,
    List<RoadmapRegion>? regions,
    List<String>? languages,
    String? specialty,
  }) => RoadmapAnswers(
    path: path ?? this.path,
    stage: stage ?? this.stage,
    yearsQualified: yearsQualified ?? this.yearsQualified,
    budgetUsd: budgetUsd ?? this.budgetUsd,
    monthsAvailable: monthsAvailable ?? this.monthsAvailable,
    regions: regions ?? this.regions,
    languages: languages ?? this.languages,
    specialty: specialty ?? this.specialty,
  );

  @override
  List<Object?> get props => [
    path,
    stage,
    yearsQualified,
    budgetUsd,
    monthsAvailable,
    regions,
    languages,
    specialty,
  ];
}

/// One dated stage of a generated roadmap.
///
/// Every stage is a **copy of a row**. The generator sequences and personalises
/// which stages appear and in what order; it never rewrites their content
/// (`EJADAH-BUILD-STORY.md`, Tab 4, rule 4).
class RoadmapStage extends ValueObject {
  const RoadmapStage({
    required this.position,
    required this.title,
    required this.detail,
    required this.projectedStart,
    required this.projectedEnd,
    required this.isOptional,
    required this.cost,
    required this.isComplete,
    this.sourceCountryIso,
    this.linkedCourseId,
  });

  final int position;
  final LocalizedText title;
  final LocalizedText detail;
  final DateTime projectedStart;
  final DateTime projectedEnd;
  final bool isOptional;

  /// An unverified fee prints "Pending source" because that is literally what
  /// the row says.
  final Sourced<String> cost;
  final bool isComplete;
  final String? sourceCountryIso;

  /// Where a matching Ejadah course exists, the stage links to it. It never
  /// opens a practice question — exams are a cut feature.
  final int? linkedCourseId;

  factory RoadmapStage.fromJson(Map<String, dynamic> json) => RoadmapStage(
    position: jsonInt(json['position']) ?? 0,
    title: LocalizedText.fromJson(json['title'])!,
    detail:
        LocalizedText.fromJson(json['detail']) ?? const LocalizedText.same(''),
    projectedStart: jsonDate(json['projected_start'])!,
    projectedEnd: jsonDate(json['projected_end'])!,
    isOptional: jsonBool(json['is_optional']) ?? false,
    cost:
        Sourced.fromJson<String>(json['cost'], (v) => v as String?) ??
        const Sourced<String>.pending(),
    isComplete: jsonBool(json['is_complete']) ?? false,
    sourceCountryIso: json['source_country_iso'] as String?,
    linkedCourseId: jsonInt(json['linked_course_id']),
  );

  Map<String, dynamic> toJson() => {
    'position': position,
    'title': title.toJson(),
    'detail': detail.toJson(),
    'projected_start': projectedStart.toIso8601String(),
    'projected_end': projectedEnd.toIso8601String(),
    'is_optional': isOptional,
    'cost': cost.toJson((value) => value),
    'is_complete': isComplete,
    'source_country_iso': sourceCountryIso,
    'linked_course_id': linkedCourseId,
  };

  @override
  List<Object?> get props => [
    position,
    title,
    projectedStart,
    projectedEnd,
    isOptional,
    cost,
    isComplete,
  ];
}

/// A destination that scored but did not win — the "also worth considering"
/// cards. Keeping runners-up visible is part of the honesty proposition.
class RoadmapAlternative extends ValueObject {
  const RoadmapAlternative({
    required this.countryIso,
    required this.countryName,
    required this.fitScore,
    required this.reason,
  });

  final String countryIso;
  final LocalizedText countryName;
  final int fitScore;
  final LocalizedText reason;

  factory RoadmapAlternative.fromJson(Map<String, dynamic> json) =>
      RoadmapAlternative(
        countryIso: jsonRequire<String>(json, 'country_iso'),
        countryName: LocalizedText.fromJson(json['country_name'])!,
        fitScore: jsonInt(json['fit_score']) ?? 0,
        reason:
            LocalizedText.fromJson(json['reason']) ??
            const LocalizedText.same(''),
      );

  Map<String, dynamic> toJson() => {
    'country_iso': countryIso,
    'country_name': countryName.toJson(),
    'fit_score': fitScore,
    'reason': reason.toJson(),
  };

  @override
  List<Object?> get props => [countryIso, fitScore];
}

/// A generated roadmap.
///
/// The same answers against the same reference-data version always produce the
/// same roadmap — that reproducibility *is* the trust claim, so
/// [referenceDataVersion] is stored alongside the result.
class Roadmap extends ValueObject {
  const Roadmap({
    required this.id,
    required this.destinationIso,
    required this.destinationName,
    required this.fitScore,
    required this.headline,
    required this.summary,
    required this.watchOut,
    required this.thisMonthAction,
    required this.stages,
    required this.alternatives,
    required this.answers,
    required this.createdAt,
    required this.referenceDataVersion,
    required this.isSaved,
    this.parentId,
    this.scenarioLabel,
  });

  final String id;

  /// `null` for a "stay in Egypt" or remote-work outcome, which is a real
  /// destination rather than a country guide.
  final String? destinationIso;
  final LocalizedText destinationName;

  /// 0–100. An unaffordable destination is mathematically incapable of scoring
  /// above 60.
  final int fitScore;
  final LocalizedText headline;
  final LocalizedText summary;

  /// Names the cost in plain figures — "The typical cost runs about USD 3,000
  /// above your stated budget." Never soft hedging.
  final LocalizedText watchOut;
  final LocalizedText thisMonthAction;
  final List<RoadmapStage> stages;
  final List<RoadmapAlternative> alternatives;
  final RoadmapAnswers answers;
  final DateTime createdAt;
  final String referenceDataVersion;
  final bool isSaved;

  /// Set on what-if scenarios. The original is always preserved.
  final String? parentId;
  final LocalizedText? scenarioLabel;

  bool get isScenario => parentId != null;

  /// How many stages a guest may read before the gate. The rest are blurred.
  static const int guestVisibleStages = 2;

  int get completedStageCount =>
      stages.where((stage) => stage.isComplete).length;

  double get progress =>
      stages.isEmpty ? 0 : completedStageCount / stages.length;

  factory Roadmap.fromJson(Map<String, dynamic> json) => Roadmap(
    id: jsonRequire<String>(json, 'id'),
    destinationIso: json['destination_iso'] as String?,
    destinationName: LocalizedText.fromJson(json['destination_name'])!,
    fitScore: jsonInt(json['fit_score']) ?? 0,
    headline:
        LocalizedText.fromJson(json['headline']) ??
        const LocalizedText.same(''),
    summary:
        LocalizedText.fromJson(json['summary']) ?? const LocalizedText.same(''),
    watchOut:
        LocalizedText.fromJson(json['watch_out']) ??
        const LocalizedText.same(''),
    thisMonthAction:
        LocalizedText.fromJson(json['this_month_action']) ??
        const LocalizedText.same(''),
    stages: (json['stages'] as List<dynamic>? ?? const [])
        .map((s) => RoadmapStage.fromJson(Map<String, dynamic>.from(s as Map)))
        .toList(),
    alternatives: (json['alternatives'] as List<dynamic>? ?? const [])
        .map(
          (a) =>
              RoadmapAlternative.fromJson(Map<String, dynamic>.from(a as Map)),
        )
        .toList(),
    answers: RoadmapAnswers.fromJson(
      Map<String, dynamic>.from(json['answers'] as Map),
    ),
    createdAt: jsonDate(json['created_at'])!,
    referenceDataVersion: (json['reference_data_version'] ?? '') as String,
    isSaved: jsonBool(json['is_saved']) ?? false,
    parentId: json['parent_id'] as String?,
    scenarioLabel: LocalizedText.fromJson(json['scenario_label']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'destination_iso': destinationIso,
    'destination_name': destinationName.toJson(),
    'fit_score': fitScore,
    'headline': headline.toJson(),
    'summary': summary.toJson(),
    'watch_out': watchOut.toJson(),
    'this_month_action': thisMonthAction.toJson(),
    'stages': stages.map((stage) => stage.toJson()).toList(),
    'alternatives': alternatives.map((alt) => alt.toJson()).toList(),
    'answers': answers.toJson(),
    'created_at': createdAt.toIso8601String(),
    'reference_data_version': referenceDataVersion,
    'is_saved': isSaved,
    'parent_id': parentId,
    'scenario_label': scenarioLabel?.toJson(),
  };

  @override
  List<Object?> get props => [id, fitScore, destinationIso, stages, parentId];
}

/// A what-if preset: change exactly one variable and regenerate.
///
/// The result is a NEW roadmap with the original preserved and linked, because
/// the comparison is the whole value.
enum WhatIfPreset {
  budgetPlus50('budget_plus_50'),
  budgetMinus25('budget_minus_25'),
  moreTime('more_time'),
  lessTime('less_time'),
  addGulf('add_gulf'),
  stayEgypt('stay_egypt');

  const WhatIfPreset(this.wire);

  final String wire;

  static WhatIfPreset fromWire(String? value) => WhatIfPreset.values.firstWhere(
    (preset) => preset.wire == value,
    orElse: () => WhatIfPreset.budgetPlus50,
  );

  /// Applies exactly one change to [answers].
  RoadmapAnswers apply(RoadmapAnswers answers) => switch (this) {
    WhatIfPreset.budgetPlus50 => answers.copyWith(
      budgetUsd: (answers.budgetUsd * 1.5).round(),
    ),
    WhatIfPreset.budgetMinus25 => answers.copyWith(
      budgetUsd: (answers.budgetUsd * 0.75).round(),
    ),
    WhatIfPreset.moreTime => answers.copyWith(
      monthsAvailable: answers.monthsAvailable + 12,
    ),
    WhatIfPreset.lessTime => answers.copyWith(
      monthsAvailable: (answers.monthsAvailable - 6).clamp(1, 240),
    ),
    WhatIfPreset.addGulf => answers.copyWith(
      regions: {...answers.regions, RoadmapRegion.gulf}.toList(),
    ),
    WhatIfPreset.stayEgypt => answers.copyWith(
      regions: const [RoadmapRegion.stayEgypt],
    ),
  };
}
