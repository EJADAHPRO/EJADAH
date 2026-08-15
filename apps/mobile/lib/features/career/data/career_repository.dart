import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';

/// A page of programmes plus the relaxation to offer when it is empty.
class ProgrammePage {
  const ProgrammePage({required this.page, this.relaxation});

  final Paginated<ProgrammeSummary> page;

  /// Present only when the search found nothing and dropping one filter would
  /// find something.
  final FilterRelaxation? relaxation;
}

final careerRepositoryProvider = Provider<CareerRepository>(
  (ref) => CareerRepository(ref.watch(apiClientProvider)),
);

/// Everything the Career tab reads and writes.
///
/// Filtering, searching and paging all happen server-side: the client asks for
/// twelve rows at a time and never downloads the database to filter it locally.
class CareerRepository {
  const CareerRepository(this._client);

  final ApiClient _client;

  Future<ProgrammePage> searchProgrammes(ProgrammeQuery query) => _client.get(
    '/career/programmes',
    query: query.toQueryParameters(),
    parse: (json) => ProgrammePage(
      page: Paginated.fromJson(json, ProgrammeSummary.fromJson),
      relaxation: json['relaxation'] == null
          ? null
          : FilterRelaxation.fromJson(
              Map<String, dynamic>.from(json['relaxation'] as Map),
            ),
    ),
  );

  Future<Programme> programme(int id) =>
      _client.get('/career/programmes/$id', parse: Programme.fromJson);

  Future<List<Programme>> compareProgrammes(List<int> ids) => _client.get(
    '/career/programmes/compare',
    query: {'ids': ids.join(',')},
    parse: (json) => (json['items'] as List<dynamic>)
        .map(
          (item) => Programme.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(),
  );

  Future<Map<String, List<String>>> filterFacets() => _client.get(
    '/career/programmes/facets',
    parse: (json) => json.map(
      (key, value) => MapEntry(
        key,
        (value as List<dynamic>).map((v) => v.toString()).toList(),
      ),
    ),
  );

  // --- Shortlist ------------------------------------------------------------

  Future<({List<ProgrammeSummary> items, int openCount})> shortlist() =>
      _client.get(
        '/career/shortlist',
        parse: (json) => (
          items: (json['items'] as List<dynamic>)
              .map(
                (item) => ProgrammeSummary.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList(),
          openCount: (json['open_programme_count'] as num?)?.toInt() ?? 0,
        ),
      );

  Future<ProgrammeSummary> save(int programmeId) => _client.put(
    '/career/shortlist/$programmeId',
    parse: ProgrammeSummary.fromJson,
  );

  Future<void> unsave(int programmeId) =>
      _client.delete('/career/shortlist/$programmeId');

  // --- Country guides -------------------------------------------------------

  Future<List<CountryGuideSummary>> countries({
    List<String> regions = const [],
    List<PathwayClass> classes = const [],
  }) => _client.get(
    '/career/countries',
    query: {
      if (regions.isNotEmpty) 'region': regions.join(','),
      if (classes.isNotEmpty) 'class': classes.map((c) => c.wire).join(','),
    },
    parse: (json) => (json['items'] as List<dynamic>)
        .map(
          (item) => CountryGuideSummary.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList(),
  );

  Future<CountryGuide> country(String iso) =>
      _client.get('/career/countries/$iso', parse: CountryGuide.fromJson);

  Future<List<ProgrammeSummary>> programmesInCountry(String iso) => _client.get(
    '/career/countries/$iso/programmes',
    parse: (json) => (json['items'] as List<dynamic>)
        .map(
          (item) =>
              ProgrammeSummary.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(),
  );
}
