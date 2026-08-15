import 'package:ejadah_models/ejadah_models.dart';

import '../../http/api_error.dart';
import 'career_repository.dart';

/// The result of a programme search, including what to offer when it is empty.
class ProgrammeSearchResult {
  const ProgrammeSearchResult({required this.page, required this.relaxation});

  final Paginated<ProgrammeSummary> page;

  /// Present only when the search returned nothing and dropping exactly one
  /// filter would return something.
  final FilterRelaxation? relaxation;

  Map<String, dynamic> toJson() => {
    ...page.toJson((item) => item.toJson()),
    if (relaxation != null) 'relaxation': relaxation!.toJson(),
  };
}

/// Career use-cases: the programme database, country guides and the shortlist.
class CareerService {
  const CareerService(this._repository);

  final CareerRepository _repository;

  /// The most a user may put side by side. Beyond three, a comparison stops
  /// being readable on a phone.
  static const int maxComparisonItems = 3;

  /// How many searches one account may watch.
  ///
  /// Each one costs a query on every sweep and can produce a notification, and
  /// the daily cap means a user watching twenty searches would simply never see
  /// most of them. Five is what a person actually tracks.
  static const int maxSavedFilters = 5;

  Future<List<SavedFilter>> savedFilters(String userId) =>
      _repository.savedFilters(userId);

  Future<SavedFilter> saveFilter({
    required String userId,
    required String label,
    required ProgrammeQuery query,
  }) async {
    final trimmed = label.trim();
    if (trimmed.isEmpty) {
      throw ApiException(
        ApiErrorCode.validation,
        details: 'A saved search needs a name.',
      );
    }
    if ((await _repository.savedFilters(userId)).length >= maxSavedFilters) {
      throw ApiException(
        ApiErrorCode.validation,
        details: 'You can watch up to $maxSavedFilters searches.',
      );
    }
    return _repository.insertSavedFilter(
      userId: userId,
      label: trimmed,
      query: query,
    );
  }

  Future<void> deleteFilter(String id, String userId) =>
      _repository.deleteSavedFilter(id, userId);

  Future<void> setFilterAlerts({
    required String id,
    required String userId,
    required bool alertsOn,
  }) => _repository.setSavedFilterAlerts(
    id: id,
    userId: userId,
    alertsOn: alertsOn,
  );

  Future<ProgrammeSearchResult> searchProgrammes(
    ProgrammeQuery query, {
    String? userId,
  }) async {
    final page = await _repository.searchProgrammes(query, userId: userId);
    if (page.items.isNotEmpty || !query.hasActiveFilters) {
      return ProgrammeSearchResult(page: page, relaxation: null);
    }
    return ProgrammeSearchResult(
      page: page,
      relaxation: await _findRelaxation(query),
    );
  }

  Future<Programme> programme(int id, {String? userId}) async {
    final programme = await _repository.findProgramme(id, userId: userId);
    if (programme == null) throw ApiException.notFound();
    if (userId != null) {
      await _repository.recordView(
        userId: userId,
        resource: 'programme',
        resourceId: '$id',
      );
    }
    return programme;
  }

  /// Side-by-side comparison of up to three programmes.
  ///
  /// A single-item comparison is an honest state, not an error — the user may
  /// simply have removed the others.
  Future<List<Programme>> compareProgrammes(
    List<int> ids, {
    String? userId,
  }) async {
    if (ids.isEmpty) return const [];
    if (ids.length > maxComparisonItems) {
      throw ApiException(
        ApiErrorCode.validation,
        details: 'At most $maxComparisonItems programmes can be compared.',
      );
    }
    return _repository.findProgrammes(ids, userId: userId);
  }

  Future<Map<String, List<String>>> filterFacets() =>
      _repository.filterFacets();

  Future<int> openProgrammeCount() => _repository.countOpenProgrammes();

  // --- Shortlist ------------------------------------------------------------

  Future<List<ProgrammeSummary>> shortlist(String userId) =>
      _repository.savedProgrammes(userId);

  /// Saves a programme, returning it so the client can confirm the deadline it
  /// just started watching.
  Future<ProgrammeSummary> saveProgramme(String userId, int programmeId) async {
    final programme = await _repository.findProgramme(programmeId);
    if (programme == null) throw ApiException.notFound();
    await _repository.saveProgramme(userId, programmeId);
    return programme.summary.copyWith(isSaved: true);
  }

  /// Removes a programme from the shortlist.
  ///
  /// Deliberately idempotent: the client removes optimistically and offers Undo
  /// for five seconds, so a repeated call after a slow network must not fail.
  Future<void> removeSavedProgramme(String userId, int programmeId) =>
      _repository.removeSavedProgramme(userId, programmeId);

  // --- Country guides -------------------------------------------------------

  Future<List<CountryGuideSummary>> countries({
    List<String> regions = const [],
    List<PathwayClass> classes = const [],
  }) => _repository.listCountries(regions: regions, classes: classes);

  Future<CountryGuide> country(String iso, {String? userId}) async {
    final guide = await _repository.findCountry(iso);
    if (guide == null) throw ApiException.notFound();
    if (userId != null) {
      await _repository.recordView(
        userId: userId,
        resource: 'country',
        resourceId: guide.iso,
      );
    }
    return guide;
  }

  Future<List<CountryGuide>> compareCountries(List<String> isos) async {
    if (isos.isEmpty) return const [];
    if (isos.length > maxComparisonItems) {
      throw ApiException(
        ApiErrorCode.validation,
        details: 'At most $maxComparisonItems countries can be compared.',
      );
    }
    final guides = <CountryGuide>[];
    for (final iso in isos) {
      final guide = await _repository.findCountry(iso);
      if (guide != null) guides.add(guide);
    }
    return guides;
  }

  Future<List<ProgrammeSummary>> programmesInCountry(
    String iso, {
    String? userId,
  }) => _repository.programmesForCountry(iso, userId: userId);

  /// Finds the single filter whose removal recovers the most results.
  ///
  /// Tried in the order a user is most likely to accept — showing expired
  /// intakes first, then loosening budget, then dropping category filters.
  Future<FilterRelaxation?> _findRelaxation(ProgrammeQuery query) async {
    final candidates =
        <({String field, LocalizedText label, ProgrammeQuery query})>[
          if (!query.showExpired)
            (
              field: 'show_expired',
              label: const LocalizedText(
                en: 'including expired intakes',
                ar: 'مع الدفعات المنتهية',
              ),
              query: query.copyWith(showExpired: true, page: 1),
            ),
          if (query.maxTuitionUsd != null)
            (
              field: 'max_tuition_usd',
              label: const LocalizedText(en: 'any tuition', ar: 'أي رسوم'),
              query: query.copyWith(clearMaxTuition: true, page: 1),
            ),
          if (query.specialties.isNotEmpty)
            (
              field: 'specialties',
              label: const LocalizedText(
                en: 'all specialties',
                ar: 'كل التخصصات',
              ),
              query: query.copyWith(specialties: const [], page: 1),
            ),
          if (query.regions.isNotEmpty)
            (
              field: 'regions',
              label: const LocalizedText(en: 'all regions', ar: 'كل المناطق'),
              query: query.copyWith(regions: const [], page: 1),
            ),
          if (query.degreeTypes.isNotEmpty)
            (
              field: 'degree_types',
              label: const LocalizedText(en: 'any degree', ar: 'أي درجة'),
              query: query.copyWith(degreeTypes: const [], page: 1),
            ),
        ];

    for (final candidate in candidates) {
      final count = await _repository.countWithRelaxation(candidate.query);
      if (count > 0) {
        return FilterRelaxation(
          field: candidate.field,
          label: candidate.label,
          resultCount: count,
        );
      }
    }
    return null;
  }
}
