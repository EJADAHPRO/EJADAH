import 'package:ejadah_models/ejadah_models.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../http/context.dart';
import '../../http/responses.dart';
import 'career_service.dart';

/// `/api/v1/career` — programmes, country guides and the shortlist.
///
/// Browsing is open to guests by design; only the shortlist requires an account,
/// because saving is one of the five gates.
Router careerRoutes(CareerService service) {
  final router = Router();

  router.get('/programmes', (Request request) async {
    final result = await service.searchProgrammes(
      _queryFrom(request),
      // Guests get results; they just never get `is_saved: true`.
      userId: request.ctx.userId,
    );
    return Json.ok(result.toJson());
  });

  router.get('/programmes/facets', (Request request) async {
    return Json.ok(await service.filterFacets());
  });

  router.get('/programmes/compare', (Request request) async {
    final ids = _intList(request.url.queryParameters['ids']);
    final programmes = await service.compareProgrammes(
      ids,
      userId: request.ctx.userId,
    );
    return Json.ok({
      'items': programmes.map((p) => p.toJson()).toList(),
      'max_items': CareerService.maxComparisonItems,
    });
  });

  router.get('/programmes/<id>', (Request request, String id) async {
    final programme = await service.programme(
      int.parse(id),
      userId: request.ctx.userId,
    );
    return Json.ok(programme.toJson());
  });

  // --- Shortlist ------------------------------------------------------------

  router.get('/shortlist', (Request request) async {
    final saved = await service.shortlist(request.ctx.requireUser());
    return Json.ok({
      'items': saved.map((item) => item.toJson()).toList(),
      // The empty state quotes this: "No saved programmes yet — 17 are open
      // right now."
      'open_programme_count': await service.openProgrammeCount(),
    });
  });

  router.put('/shortlist/<id>', (Request request, String id) async {
    final saved = await service.saveProgramme(
      request.ctx.requireUser(),
      int.parse(id),
    );
    return Json.ok(saved.toJson());
  });

  router.delete('/shortlist/<id>', (Request request, String id) async {
    await service.removeSavedProgramme(
      request.ctx.requireUser(),
      int.parse(id),
    );
    return Json.noContent();
  });

  // --- Country guides -------------------------------------------------------

  router.get('/countries', (Request request) async {
    final params = request.url.queryParameters;
    final guides = await service.countries(
      regions: _stringList(params['region']),
      classes: _stringList(params['class']).map(PathwayClass.fromWire).toList(),
    );
    return Json.ok({
      'items': guides.map((guide) => guide.toJson()).toList(),
      'total': guides.length,
    });
  });

  router.get('/countries/compare', (Request request) async {
    final guides = await service.compareCountries(
      _stringList(request.url.queryParameters['iso']),
    );
    return Json.ok({
      'items': guides.map((guide) => guide.toJson()).toList(),
      'max_items': CareerService.maxComparisonItems,
    });
  });

  router.get('/countries/<iso>', (Request request, String iso) async {
    final guide = await service.country(iso, userId: request.ctx.userId);
    return Json.ok(guide.toJson());
  });

  router.get('/countries/<iso>/programmes', (
    Request request,
    String iso,
  ) async {
    final programmes = await service.programmesInCountry(
      iso,
      userId: request.ctx.userId,
    );
    return Json.ok({'items': programmes.map((p) => p.toJson()).toList()});
  });

  return router;
}

ProgrammeQuery _queryFrom(Request request) {
  final params = request.url.queryParameters;
  return ProgrammeQuery(
    search: params['q'],
    regions: _stringList(params['region']),
    countries: _stringList(params['country']),
    specialties: _stringList(params['specialty']),
    degreeTypes: _stringList(params['degree']),
    intakeMonths: _stringList(params['intake']),
    maxTuitionUsd: int.tryParse(params['max_tuition_usd'] ?? ''),
    maxYears: int.tryParse(params['max_years'] ?? ''),
    minIelts: double.tryParse(params['min_ielts'] ?? ''),
    requiresScholarship: params['scholarship'] == 'true',
    excludeThesis: params['no_thesis'] == 'true',
    excludeInterview: params['no_interview'] == 'true',
    showExpired: params['show_expired'] == 'true',
    sort: ProgrammeSort.fromWire(params['sort']),
    page: (int.tryParse(params['page'] ?? '') ?? 1).clamp(1, 1000),
    // Twelve per page is the designed page size; the cap stops a caller asking
    // for the whole table in one request.
    pageSize: (int.tryParse(params['page_size'] ?? '') ?? 12).clamp(1, 50),
  );
}

List<String> _stringList(String? value) => value == null || value.isEmpty
    ? const []
    : value.split(',').map((v) => v.trim()).where((v) => v.isNotEmpty).toList();

List<int> _intList(String? value) =>
    _stringList(value).map(int.tryParse).whereType<int>().toList();
