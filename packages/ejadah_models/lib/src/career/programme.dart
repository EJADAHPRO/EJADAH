import '../common/localized_text.dart';
import '../common/value.dart';

/// Where a programme's intake stands today.
///
/// 150 of the 199 canonical records are already expired, which is why expired
/// intakes are hidden by default — showing them first makes a live database
/// look dead (`EJADAH-BUILD-STORY.md`, Tab 4).
enum DeadlineStatus {
  open('open'),
  closingSoon('closing_soon'),
  expired('expired');

  const DeadlineStatus(this.wire);

  final String wire;

  static DeadlineStatus fromWire(String? value) => switch (value) {
    'open' => DeadlineStatus.open,
    'closing_soon' => DeadlineStatus.closingSoon,
    _ => DeadlineStatus.expired,
  };

  /// Maps the source dataset's own wording onto the canonical states.
  static DeadlineStatus fromSourceText(String? value) {
    final text = value?.trim().toLowerCase() ?? '';
    if (text == 'open') return DeadlineStatus.open;
    if (text.startsWith('closing')) return DeadlineStatus.closingSoon;
    return DeadlineStatus.expired;
  }
}

/// The card-level view of a programme, as the database list renders it.
///
/// Deliberately smaller than [Programme]: the list ships 12 rows per page and
/// must not carry detail-only fields over the wire (`SCREENS.md` §3).
class ProgrammeSummary extends ValueObject {
  const ProgrammeSummary({
    required this.id,
    required this.university,
    required this.programmeName,
    required this.country,
    required this.countryIso,
    required this.city,
    required this.region,
    required this.specialty,
    required this.degreeType,
    required this.deadline,
    required this.deadlineStatus,
    required this.daysRemaining,
    required this.tuitionUsd,
    required this.currency,
    required this.localCost,
    required this.durationRaw,
    required this.isSaved,
  });

  final int id;
  final String university;
  final String programmeName;
  final String country;

  /// Two-letter code used for the bundled flag asset. `null` where the source
  /// country has no guide — the card then renders without a flag rather than a
  /// broken image.
  final String? countryIso;
  final String city;
  final String region;
  final String specialty;
  final String degreeType;
  final DateTime? deadline;
  final DeadlineStatus deadlineStatus;
  final int? daysRemaining;
  final int? tuitionUsd;
  final String? currency;
  final int? localCost;
  final String durationRaw;

  /// Whether the signed-in user has this on their shortlist. Always false for
  /// guests — saving is one of the five gates.
  final bool isSaved;

  factory ProgrammeSummary.fromJson(Map<String, dynamic> json) =>
      ProgrammeSummary(
        id: jsonRequire<int>(json, 'id'),
        university: jsonRequire<String>(json, 'university'),
        programmeName: jsonRequire<String>(json, 'programme_name'),
        country: jsonRequire<String>(json, 'country'),
        countryIso: json['country_iso'] as String?,
        city: (json['city'] ?? '') as String,
        region: (json['region'] ?? '') as String,
        specialty: (json['specialty'] ?? '') as String,
        degreeType: (json['degree_type'] ?? '') as String,
        deadline: jsonDate(json['deadline']),
        deadlineStatus: DeadlineStatus.fromWire(
          json['deadline_status'] as String?,
        ),
        daysRemaining: jsonInt(json['days_remaining']),
        tuitionUsd: jsonInt(json['tuition_usd']),
        currency: json['currency'] as String?,
        localCost: jsonInt(json['local_cost']),
        durationRaw: (json['duration_raw'] ?? '') as String,
        isSaved: jsonBool(json['is_saved']) ?? false,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'university': university,
    'programme_name': programmeName,
    'country': country,
    'country_iso': countryIso,
    'city': city,
    'region': region,
    'specialty': specialty,
    'degree_type': degreeType,
    'deadline': deadline?.toIso8601String(),
    'deadline_status': deadlineStatus.wire,
    'days_remaining': daysRemaining,
    'tuition_usd': tuitionUsd,
    'currency': currency,
    'local_cost': localCost,
    'duration_raw': durationRaw,
    'is_saved': isSaved,
  };

  ProgrammeSummary copyWith({bool? isSaved}) => ProgrammeSummary(
    id: id,
    university: university,
    programmeName: programmeName,
    country: country,
    countryIso: countryIso,
    city: city,
    region: region,
    specialty: specialty,
    degreeType: degreeType,
    deadline: deadline,
    deadlineStatus: deadlineStatus,
    daysRemaining: daysRemaining,
    tuitionUsd: tuitionUsd,
    currency: currency,
    localCost: localCost,
    durationRaw: durationRaw,
    isSaved: isSaved ?? this.isSaved,
  );

  @override
  List<Object?> get props => [id, isSaved, deadlineStatus, daysRemaining];
}

/// The full programme record backing the detail screen.
class Programme extends ValueObject {
  const Programme({
    required this.summary,
    required this.studyType,
    required this.intakeMonth,
    required this.cohortSize,
    required this.minYears,
    required this.maxYears,
    required this.studyMode,
    required this.costRaw,
    required this.language,
    required this.qsRank,
    required this.acceptanceRate,
    required this.ieltsScore,
    required this.ieltsRequirement,
    required this.gpaRequirement,
    required this.experienceRequirement,
    required this.hasScholarship,
    required this.hasEgyptianGovtFunding,
    required this.thesisRequired,
    required this.interviewRequired,
    required this.rating,
    required this.sourceDeadlineText,
    required this.dataQualityNote,
    this.regulator,
    this.regulatorUpdatedLabel,
  });

  final ProgrammeSummary summary;

  /// The same record with a different summary.
  ///
  /// Exists for the one field a screen legitimately moves ahead of the server:
  /// the shortlist heart, which must respond within 100ms and roll back if the
  /// request fails. Everything else here is the server's to state.
  Programme withSummary(ProgrammeSummary value) => Programme(
    summary: value,
    studyType: studyType,
    intakeMonth: intakeMonth,
    cohortSize: cohortSize,
    minYears: minYears,
    maxYears: maxYears,
    studyMode: studyMode,
    costRaw: costRaw,
    language: language,
    qsRank: qsRank,
    acceptanceRate: acceptanceRate,
    ieltsScore: ieltsScore,
    ieltsRequirement: ieltsRequirement,
    gpaRequirement: gpaRequirement,
    experienceRequirement: experienceRequirement,
    hasScholarship: hasScholarship,
    hasEgyptianGovtFunding: hasEgyptianGovtFunding,
    thesisRequired: thesisRequired,
    interviewRequired: interviewRequired,
    rating: rating,
    sourceDeadlineText: sourceDeadlineText,
    dataQualityNote: dataQualityNote,
    regulator: regulator,
    regulatorUpdatedLabel: regulatorUpdatedLabel,
  );

  final String studyType;
  final String intakeMonth;
  final String cohortSize;
  final int? minYears;
  final int? maxYears;
  final String studyMode;

  /// The dataset's own cost wording, kept verbatim. Never re-derived.
  final String costRaw;
  final String language;
  final int? qsRank;
  final double? acceptanceRate;
  final double? ieltsScore;
  final String ieltsRequirement;
  final String gpaRequirement;
  final String experienceRequirement;
  final bool? hasScholarship;
  final bool? hasEgyptianGovtFunding;
  final bool? thesisRequired;
  final bool? interviewRequired;
  final double? rating;
  final String sourceDeadlineText;
  final String dataQualityNote;

  /// The licensing regulator for this programme's country.
  ///
  /// Null where the country has no guide in the dataset. The sources block then
  /// names no regulator rather than inventing one — recognition and licensing
  /// facts are exactly what this product refuses to manufacture.
  final LocalizedText? regulator;

  /// When the regulator's own figures were last read, e.g. "Jul 2026".
  final String? regulatorUpdatedLabel;

  int get id => summary.id;

  factory Programme.fromJson(Map<String, dynamic> json) => Programme(
    summary: ProgrammeSummary.fromJson(json),
    studyType: (json['study_type'] ?? '') as String,
    intakeMonth: (json['intake_month'] ?? '') as String,
    cohortSize: (json['cohort_size'] ?? '') as String,
    minYears: jsonInt(json['min_years']),
    maxYears: jsonInt(json['max_years']),
    studyMode: (json['study_mode'] ?? '') as String,
    costRaw: (json['cost_raw'] ?? '') as String,
    language: (json['language'] ?? '') as String,
    qsRank: jsonInt(json['qs_rank']),
    acceptanceRate: jsonDouble(json['acceptance_rate']),
    ieltsScore: jsonDouble(json['ielts_score']),
    ieltsRequirement: (json['ielts_requirement'] ?? '') as String,
    gpaRequirement: (json['gpa_requirement'] ?? '') as String,
    experienceRequirement: (json['experience_requirement'] ?? '') as String,
    hasScholarship: jsonBool(json['has_scholarship']),
    hasEgyptianGovtFunding: jsonBool(json['has_egyptian_govt_funding']),
    thesisRequired: jsonBool(json['thesis_required']),
    interviewRequired: jsonBool(json['interview_required']),
    rating: jsonDouble(json['rating']),
    sourceDeadlineText: (json['source_deadline_text'] ?? '') as String,
    dataQualityNote: (json['data_quality_note'] ?? '') as String,
    regulator: LocalizedText.fromJson(json['regulator']),
    regulatorUpdatedLabel: json['regulator_updated_label'] as String?,
  );

  Map<String, dynamic> toJson() => {
    ...summary.toJson(),
    'regulator': regulator?.toJson(),
    'regulator_updated_label': regulatorUpdatedLabel,
    'study_type': studyType,
    'intake_month': intakeMonth,
    'cohort_size': cohortSize,
    'min_years': minYears,
    'max_years': maxYears,
    'study_mode': studyMode,
    'cost_raw': costRaw,
    'language': language,
    'qs_rank': qsRank,
    'acceptance_rate': acceptanceRate,
    'ielts_score': ieltsScore,
    'ielts_requirement': ieltsRequirement,
    'gpa_requirement': gpaRequirement,
    'experience_requirement': experienceRequirement,
    'has_scholarship': hasScholarship,
    'has_egyptian_govt_funding': hasEgyptianGovtFunding,
    'thesis_required': thesisRequired,
    'interview_required': interviewRequired,
    'rating': rating,
    'source_deadline_text': sourceDeadlineText,
    'data_quality_note': dataQualityNote,
  };

  @override
  List<Object?> get props => [summary.id];
}

/// The filter state of the programme database.
///
/// Filters persist across sessions (`FLOWS_STORIES_CRITERIA.md` E2-04) and are
/// applied server-side — the client never downloads 199 rows to filter locally.
class ProgrammeQuery extends ValueObject {
  const ProgrammeQuery({
    this.search,
    this.regions = const [],
    this.countries = const [],
    this.specialties = const [],
    this.degreeTypes = const [],
    this.intakeMonths = const [],
    this.maxTuitionUsd,
    this.maxYears,
    this.minIelts,
    this.requiresScholarship = false,
    this.excludeThesis = false,
    this.excludeInterview = false,
    this.showExpired = false,
    this.sort = ProgrammeSort.deadline,
    this.page = 1,
    this.pageSize = 12,
  });

  final String? search;
  final List<String> regions;
  final List<String> countries;
  final List<String> specialties;
  final List<String> degreeTypes;
  final List<String> intakeMonths;
  final int? maxTuitionUsd;
  final int? maxYears;
  final double? minIelts;
  final bool requiresScholarship;
  final bool excludeThesis;
  final bool excludeInterview;

  /// Expired intakes are hidden by default; the user can opt in.
  final bool showExpired;
  final ProgrammeSort sort;
  final int page;
  final int pageSize;

  /// True when any filter beyond paging and the default sort is active — drives
  /// the "clear all" affordance and the zero-result relaxation copy.
  bool get hasActiveFilters =>
      (search?.trim().isNotEmpty ?? false) ||
      regions.isNotEmpty ||
      countries.isNotEmpty ||
      specialties.isNotEmpty ||
      degreeTypes.isNotEmpty ||
      intakeMonths.isNotEmpty ||
      maxTuitionUsd != null ||
      maxYears != null ||
      minIelts != null ||
      requiresScholarship ||
      excludeThesis ||
      excludeInterview ||
      showExpired;

  int get activeFilterCount => [
    regions.isNotEmpty,
    countries.isNotEmpty,
    specialties.isNotEmpty,
    degreeTypes.isNotEmpty,
    intakeMonths.isNotEmpty,
    maxTuitionUsd != null,
    maxYears != null,
    minIelts != null,
    requiresScholarship,
    excludeThesis,
    excludeInterview,
  ].where((active) => active).length;

  ProgrammeQuery copyWith({
    String? search,
    bool clearSearch = false,
    List<String>? regions,
    List<String>? countries,
    List<String>? specialties,
    List<String>? degreeTypes,
    List<String>? intakeMonths,
    int? maxTuitionUsd,
    bool clearMaxTuition = false,
    int? maxYears,
    bool clearMaxYears = false,
    double? minIelts,
    bool clearMinIelts = false,
    bool? requiresScholarship,
    bool? excludeThesis,
    bool? excludeInterview,
    bool? showExpired,
    ProgrammeSort? sort,
    int? page,
    int? pageSize,
  }) => ProgrammeQuery(
    search: clearSearch ? null : (search ?? this.search),
    regions: regions ?? this.regions,
    countries: countries ?? this.countries,
    specialties: specialties ?? this.specialties,
    degreeTypes: degreeTypes ?? this.degreeTypes,
    intakeMonths: intakeMonths ?? this.intakeMonths,
    maxTuitionUsd: clearMaxTuition
        ? null
        : (maxTuitionUsd ?? this.maxTuitionUsd),
    maxYears: clearMaxYears ? null : (maxYears ?? this.maxYears),
    minIelts: clearMinIelts ? null : (minIelts ?? this.minIelts),
    requiresScholarship: requiresScholarship ?? this.requiresScholarship,
    excludeThesis: excludeThesis ?? this.excludeThesis,
    excludeInterview: excludeInterview ?? this.excludeInterview,
    showExpired: showExpired ?? this.showExpired,
    sort: sort ?? this.sort,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
  );

  Map<String, String> toQueryParameters() => {
    if (search != null && search!.trim().isNotEmpty) 'q': search!.trim(),
    if (regions.isNotEmpty) 'region': regions.join(','),
    if (countries.isNotEmpty) 'country': countries.join(','),
    if (specialties.isNotEmpty) 'specialty': specialties.join(','),
    if (degreeTypes.isNotEmpty) 'degree': degreeTypes.join(','),
    if (intakeMonths.isNotEmpty) 'intake': intakeMonths.join(','),
    if (maxTuitionUsd != null) 'max_tuition_usd': '$maxTuitionUsd',
    if (maxYears != null) 'max_years': '$maxYears',
    if (minIelts != null) 'min_ielts': '$minIelts',
    if (requiresScholarship) 'scholarship': 'true',
    if (excludeThesis) 'no_thesis': 'true',
    if (excludeInterview) 'no_interview': 'true',
    if (showExpired) 'show_expired': 'true',
    'sort': sort.wire,
    'page': '$page',
    'page_size': '$pageSize',
  };

  Map<String, dynamic> toJson() => {
    'search': search,
    'regions': regions,
    'countries': countries,
    'specialties': specialties,
    'degree_types': degreeTypes,
    'intake_months': intakeMonths,
    'max_tuition_usd': maxTuitionUsd,
    'max_years': maxYears,
    'min_ielts': minIelts,
    'requires_scholarship': requiresScholarship,
    'exclude_thesis': excludeThesis,
    'exclude_interview': excludeInterview,
    'show_expired': showExpired,
    'sort': sort.wire,
  };

  factory ProgrammeQuery.fromJson(Map<String, dynamic> json) => ProgrammeQuery(
    search: json['search'] as String?,
    regions: _stringList(json['regions']),
    countries: _stringList(json['countries']),
    specialties: _stringList(json['specialties']),
    degreeTypes: _stringList(json['degree_types']),
    intakeMonths: _stringList(json['intake_months']),
    maxTuitionUsd: jsonInt(json['max_tuition_usd']),
    maxYears: jsonInt(json['max_years']),
    minIelts: jsonDouble(json['min_ielts']),
    requiresScholarship: jsonBool(json['requires_scholarship']) ?? false,
    excludeThesis: jsonBool(json['exclude_thesis']) ?? false,
    excludeInterview: jsonBool(json['exclude_interview']) ?? false,
    showExpired: jsonBool(json['show_expired']) ?? false,
    sort: ProgrammeSort.fromWire(json['sort'] as String?),
  );

  static List<String> _stringList(Object? value) => switch (value) {
    final List<dynamic> list => list.map((e) => e.toString()).toList(),
    final String text when text.isNotEmpty => text.split(','),
    _ => const [],
  };

  @override
  List<Object?> get props => [
    search,
    regions,
    countries,
    specialties,
    degreeTypes,
    intakeMonths,
    maxTuitionUsd,
    maxYears,
    minIelts,
    requiresScholarship,
    excludeThesis,
    excludeInterview,
    showExpired,
    sort,
    page,
    pageSize,
  ];
}

enum ProgrammeSort {
  deadline('deadline'),
  tuitionAsc('tuition_asc'),
  tuitionDesc('tuition_desc'),
  rank('rank'),
  university('university');

  const ProgrammeSort(this.wire);

  final String wire;

  static ProgrammeSort fromWire(String? value) =>
      ProgrammeSort.values.firstWhere(
        (sort) => sort.wire == value,
        orElse: () => ProgrammeSort.deadline,
      );
}

/// A suggested single-filter relaxation for a zero-result search.
///
/// "Nothing matches those filters. Nearest match: {relaxation}." — the empty
/// state must route to action, never dead-end (`CONTENT.md`).
class FilterRelaxation extends ValueObject {
  const FilterRelaxation({
    required this.field,
    required this.label,
    required this.resultCount,
  });

  final String field;
  final LocalizedText label;
  final int resultCount;

  factory FilterRelaxation.fromJson(Map<String, dynamic> json) =>
      FilterRelaxation(
        field: jsonRequire<String>(json, 'field'),
        label: LocalizedText.fromJson(json['label'])!,
        resultCount: jsonInt(json['result_count']) ?? 0,
      );

  Map<String, dynamic> toJson() => {
    'field': field,
    'label': label.toJson(),
    'result_count': resultCount,
  };

  @override
  List<Object?> get props => [field, resultCount];
}
