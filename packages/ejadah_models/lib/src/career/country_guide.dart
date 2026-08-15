import '../common/localized_text.dart';
import '../common/sourced.dart';
import '../common/value.dart';

/// How a country's licensing route is shaped.
///
/// The roadmap generator weights these; the guide list filters by them.
enum PathwayClass {
  /// Recognition/assessment only — no exam, no language barrier.
  fast('fast'),

  /// A licensing exam is the main gate.
  exam('exam'),

  /// A language qualification precedes the clinical assessment.
  language('lang'),

  /// Multi-stage: exam plus practical plus residency-style requirements.
  complex('complex');

  const PathwayClass(this.wire);

  final String wire;

  static PathwayClass fromWire(String? value) => switch (value) {
    'fast' => PathwayClass.fast,
    'exam' => PathwayClass.exam,
    'lang' => PathwayClass.language,
    'complex' => PathwayClass.complex,
    _ => PathwayClass.exam,
  };
}

/// One step of a country's licensing pathway, copied verbatim from the guide.
class CountryStep extends ValueObject {
  const CountryStep({
    required this.position,
    required this.title,
    required this.detail,
    required this.whenLabel,
    required this.isOptional,
  });

  final int position;
  final LocalizedText title;
  final LocalizedText detail;

  /// The guide's own projected timing, e.g. "~ Oct 2026". Kept as authored;
  /// the roadmap projects its own dates rather than rewriting this.
  final String? whenLabel;
  final bool isOptional;

  factory CountryStep.fromJson(Map<String, dynamic> json) => CountryStep(
    position: jsonInt(json['position']) ?? 0,
    title: LocalizedText.fromJson(json['title'])!,
    detail:
        LocalizedText.fromJson(json['detail']) ?? const LocalizedText.same(''),
    whenLabel: json['when_label'] as String?,
    isOptional: jsonBool(json['is_optional']) ?? false,
  );

  Map<String, dynamic> toJson() => {
    'position': position,
    'title': title.toJson(),
    'detail': detail.toJson(),
    'when_label': whenLabel,
    'is_optional': isOptional,
  };

  @override
  List<Object?> get props => [position, title, detail, whenLabel, isOptional];
}

/// A licensing exam, with its fee carried as a [Sourced] fact.
class CountryExam extends ValueObject {
  const CountryExam({
    required this.position,
    required this.name,
    required this.description,
    required this.dates,
    required this.fee,
    required this.passMark,
  });

  final int position;

  /// Exam names stay Latin in both languages and are bidi-isolated on screen
  /// (ORE, ADC, SDLE, DHA…). Never transliterated.
  final LocalizedText name;
  final LocalizedText description;
  final LocalizedText dates;

  /// Eleven regulator fees are unverified and print "Pending source" verbatim.
  final Sourced<String> fee;
  final LocalizedText passMark;

  factory CountryExam.fromJson(Map<String, dynamic> json) => CountryExam(
    position: jsonInt(json['position']) ?? 0,
    name: LocalizedText.fromJson(json['name'])!,
    description:
        LocalizedText.fromJson(json['description']) ??
        const LocalizedText.same(''),
    dates:
        LocalizedText.fromJson(json['dates']) ?? const LocalizedText.same(''),
    fee:
        Sourced.fromJson<String>(json['fee'], (v) => v as String?) ??
        const Sourced<String>.pending(),
    passMark:
        LocalizedText.fromJson(json['pass_mark']) ??
        const LocalizedText.same(''),
  );

  Map<String, dynamic> toJson() => {
    'position': position,
    'name': name.toJson(),
    'description': description.toJson(),
    'dates': dates.toJson(),
    'fee': fee.toJson((value) => value),
    'pass_mark': passMark.toJson(),
  };

  @override
  List<Object?> get props => [position, name, fee];
}

/// One row of a country's cost table.
class CountryCost extends ValueObject {
  const CountryCost({
    required this.position,
    required this.label,
    required this.localAmount,
    required this.usdAmount,
  });

  final int position;
  final LocalizedText label;

  /// Kept as authored strings ("€1,500–4,000") because the guides carry ranges,
  /// not point values. Rendered as an LTR-isolated island.
  final Sourced<String> localAmount;
  final Sourced<String> usdAmount;

  factory CountryCost.fromJson(Map<String, dynamic> json) => CountryCost(
    position: jsonInt(json['position']) ?? 0,
    label: LocalizedText.fromJson(json['label'])!,
    localAmount:
        Sourced.fromJson<String>(json['local_amount'], (v) => v as String?) ??
        const Sourced<String>.pending(),
    usdAmount:
        Sourced.fromJson<String>(json['usd_amount'], (v) => v as String?) ??
        const Sourced<String>.pending(),
  );

  Map<String, dynamic> toJson() => {
    'position': position,
    'label': label.toJson(),
    'local_amount': localAmount.toJson((value) => value),
    'usd_amount': usdAmount.toJson((value) => value),
  };

  @override
  List<Object?> get props => [position, label, localAmount, usdAmount];
}

/// Card-level view of a country guide, for the guide list and compare picker.
class CountryGuideSummary extends ValueObject {
  const CountryGuideSummary({
    required this.iso,
    required this.name,
    required this.examCode,
    required this.pathwayClass,
    required this.pathwayClassLabel,
    required this.monthsLabel,
    required this.difficulty,
    required this.region,
    required this.isPopular,
    required this.minMonths,
    required this.maxMonths,
    required this.floorCostUsd,
  });

  final String iso;
  final LocalizedText name;

  /// Latin always ("ORE", "Approbation", "SDLE").
  final String examCode;
  final PathwayClass pathwayClass;
  final LocalizedText pathwayClassLabel;

  /// The guide's own wording, e.g. "12–24".
  final String monthsLabel;
  final LocalizedText difficulty;
  final String region;
  final bool isPopular;

  /// Parsed from [monthsLabel] at import time so the roadmap can filter on time
  /// without re-parsing strings at request time.
  final int minMonths;
  final int maxMonths;

  /// Lowest total cost the guide's own cost table implies, in USD. Used as the
  /// roadmap's budget pre-filter and as its deterministic tie-break.
  final int? floorCostUsd;

  factory CountryGuideSummary.fromJson(Map<String, dynamic> json) =>
      CountryGuideSummary(
        iso: jsonRequire<String>(json, 'iso'),
        name: LocalizedText.fromJson(json['name'])!,
        examCode: (json['exam_code'] ?? '') as String,
        pathwayClass: PathwayClass.fromWire(json['pathway_class'] as String?),
        pathwayClassLabel:
            LocalizedText.fromJson(json['pathway_class_label']) ??
            const LocalizedText.same(''),
        monthsLabel: (json['months_label'] ?? '') as String,
        difficulty:
            LocalizedText.fromJson(json['difficulty']) ??
            const LocalizedText.same(''),
        region: (json['region'] ?? '') as String,
        isPopular: jsonBool(json['is_popular']) ?? false,
        minMonths: jsonInt(json['min_months']) ?? 0,
        maxMonths: jsonInt(json['max_months']) ?? 0,
        floorCostUsd: jsonInt(json['floor_cost_usd']),
      );

  Map<String, dynamic> toJson() => {
    'iso': iso,
    'name': name.toJson(),
    'exam_code': examCode,
    'pathway_class': pathwayClass.wire,
    'pathway_class_label': pathwayClassLabel.toJson(),
    'months_label': monthsLabel,
    'difficulty': difficulty.toJson(),
    'region': region,
    'is_popular': isPopular,
    'min_months': minMonths,
    'max_months': maxMonths,
    'floor_cost_usd': floorCostUsd,
  };

  @override
  List<Object?> get props => [
    iso,
    pathwayClass,
    minMonths,
    maxMonths,
    floorCostUsd,
  ];
}

/// A full country licensing guide — the four-tab detail screen.
class CountryGuide extends ValueObject {
  const CountryGuide({
    required this.summary,
    required this.examFull,
    required this.overview,
    required this.authority,
    required this.authoritySite,
    required this.visa,
    required this.market,
    required this.salaryBand,
    required this.salaryNote,
    required this.recognitionNote,
    required this.costNote,
    required this.updatedLabel,
    required this.steps,
    required this.exams,
    required this.costs,
    required this.documents,
    required this.tips,
  });

  final CountryGuideSummary summary;
  final LocalizedText examFull;
  final LocalizedText overview;
  final LocalizedText authority;
  final String? authoritySite;
  final LocalizedText visa;
  final LocalizedText market;
  final String? salaryBand;
  final LocalizedText salaryNote;
  final LocalizedText recognitionNote;
  final LocalizedText costNote;

  /// "Verified on" date as the guide states it, e.g. "Jul 2026".
  final String updatedLabel;
  final List<CountryStep> steps;
  final List<CountryExam> exams;
  final List<CountryCost> costs;
  final List<LocalizedText> documents;
  final List<LocalizedText> tips;

  String get iso => summary.iso;

  factory CountryGuide.fromJson(Map<String, dynamic> json) => CountryGuide(
    summary: CountryGuideSummary.fromJson(json),
    examFull:
        LocalizedText.fromJson(json['exam_full']) ??
        const LocalizedText.same(''),
    overview:
        LocalizedText.fromJson(json['overview']) ??
        const LocalizedText.same(''),
    authority:
        LocalizedText.fromJson(json['authority']) ??
        const LocalizedText.same(''),
    authoritySite: json['authority_site'] as String?,
    visa: LocalizedText.fromJson(json['visa']) ?? const LocalizedText.same(''),
    market:
        LocalizedText.fromJson(json['market']) ?? const LocalizedText.same(''),
    salaryBand: json['salary_band'] as String?,
    salaryNote:
        LocalizedText.fromJson(json['salary_note']) ??
        const LocalizedText.same(''),
    recognitionNote:
        LocalizedText.fromJson(json['recognition_note']) ??
        const LocalizedText.same(''),
    costNote:
        LocalizedText.fromJson(json['cost_note']) ??
        const LocalizedText.same(''),
    updatedLabel: (json['updated_label'] ?? '') as String,
    steps: _list(json['steps'], CountryStep.fromJson),
    exams: _list(json['exams'], CountryExam.fromJson),
    costs: _list(json['costs'], CountryCost.fromJson),
    documents: _localizedList(json['documents']),
    tips: _localizedList(json['tips']),
  );

  Map<String, dynamic> toJson() => {
    ...summary.toJson(),
    'exam_full': examFull.toJson(),
    'overview': overview.toJson(),
    'authority': authority.toJson(),
    'authority_site': authoritySite,
    'visa': visa.toJson(),
    'market': market.toJson(),
    'salary_band': salaryBand,
    'salary_note': salaryNote.toJson(),
    'recognition_note': recognitionNote.toJson(),
    'cost_note': costNote.toJson(),
    'updated_label': updatedLabel,
    'steps': steps.map((step) => step.toJson()).toList(),
    'exams': exams.map((exam) => exam.toJson()).toList(),
    'costs': costs.map((cost) => cost.toJson()).toList(),
    'documents': documents.map((doc) => doc.toJson()).toList(),
    'tips': tips.map((tip) => tip.toJson()).toList(),
  };

  static List<T> _list<T>(
    Object? value,
    T Function(Map<String, dynamic>) parse,
  ) => switch (value) {
    final List<dynamic> list =>
      list.map((e) => parse(Map<String, dynamic>.from(e as Map))).toList(),
    _ => const [],
  };

  static List<LocalizedText> _localizedList(Object? value) => switch (value) {
    final List<dynamic> list =>
      list.map(LocalizedText.fromJson).whereType<LocalizedText>().toList(),
    _ => const [],
  };

  @override
  List<Object?> get props => [summary.iso, steps.length, exams.length];
}
