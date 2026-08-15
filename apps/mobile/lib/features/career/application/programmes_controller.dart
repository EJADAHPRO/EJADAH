import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../data/career_repository.dart';

/// What the programme database screen is showing.
///
/// The states are explicit rather than implied by null checks, because the
/// screen must render a distinct treatment for each: a skeleton while loading,
/// a relaxation offer when empty, and a retry when it failed.
sealed class ProgrammesState {
  const ProgrammesState();
}

class ProgrammesLoading extends ProgrammesState {
  const ProgrammesLoading();
}

class ProgrammesReady extends ProgrammesState {
  const ProgrammesReady({
    required this.page,
    required this.query,
    this.relaxation,
    this.isRefreshing = false,
  });

  final Paginated<ProgrammeSummary> page;
  final ProgrammeQuery query;
  final FilterRelaxation? relaxation;

  /// A filter changed and new results are on the way. The current rows stay on
  /// screen so the list does not blink back to a skeleton.
  final bool isRefreshing;

  bool get isEmpty => page.isEmpty;

  ProgrammesReady copyWith({
    Paginated<ProgrammeSummary>? page,
    ProgrammeQuery? query,
    FilterRelaxation? relaxation,
    bool? isRefreshing,
  }) => ProgrammesReady(
    page: page ?? this.page,
    query: query ?? this.query,
    relaxation: relaxation,
    isRefreshing: isRefreshing ?? this.isRefreshing,
  );
}

class ProgrammesFailed extends ProgrammesState {
  const ProgrammesFailed(this.failure, this.query);

  final Failure failure;
  final ProgrammeQuery query;
}

final programmesControllerProvider =
    NotifierProvider<ProgrammesController, ProgrammesState>(
      ProgrammesController.new,
    );

/// Owns the programme database's query and results.
///
/// Business logic lives here, never in the widget: the screen renders a state
/// and calls intents.
class ProgrammesController extends Notifier<ProgrammesState> {
  ProgrammeQuery _query = const ProgrammeQuery();

  @override
  ProgrammesState build() {
    // Restoring the stored filters and running the first search happen off the
    // build, so the screen can show its skeleton immediately.
    Future.microtask(_restoreAndLoad);
    return const ProgrammesLoading();
  }

  ProgrammeQuery get query => _query;

  Future<void> _restoreAndLoad() async {
    // Filters persist across sessions — re-applying them by hand every launch
    // is friction the design explicitly removes.
    final stored = await ref.read(localStoreProvider).programmeFilters();
    if (stored != null) _query = ProgrammeQuery.fromJson(stored);
    await _load();
  }

  /// Opens the list already filtered to one country.
  ///
  /// The country-guide crossing lands here. It replaces the country filter
  /// rather than adding to it — arriving from Germany's guide and seeing
  /// Germany *and* whatever was filtered last week is not what the tap meant —
  /// and it deliberately does not persist, so the next visit is the user's own
  /// filters again.
  Future<void> showCountry(String iso) =>
      _applyQuery(_query.copyWith(countries: [iso], page: 1), persist: false);

  Future<void> _load({bool keepCurrentResults = false}) async {
    final current = state;
    if (keepCurrentResults && current is ProgrammesReady) {
      state = current.copyWith(isRefreshing: true);
    } else {
      state = const ProgrammesLoading();
    }

    try {
      final result = await ref
          .read(careerRepositoryProvider)
          .searchProgrammes(_query);
      state = ProgrammesReady(
        page: result.page,
        query: _query,
        relaxation: result.relaxation,
      );
    } on Failure catch (failure) {
      state = ProgrammesFailed(failure, _query);
    }
  }

  Future<void> _applyQuery(ProgrammeQuery query, {bool persist = true}) async {
    _query = query;
    // A filter the user chose is remembered; one a crossing applied on their
    // behalf is not, or every country guide they open rewrites their filters.
    if (persist) {
      await ref.read(localStoreProvider).saveProgrammeFilters(query.toJson());
    }
    await _load(keepCurrentResults: true);
  }

  /// Submitting a search resets to page 1 — staying on page 4 of a different
  /// result set shows the user an empty screen for no reason.
  Future<void> search(String? text) => _applyQuery(
    text == null || text.trim().isEmpty
        ? _query.copyWith(clearSearch: true, page: 1)
        : _query.copyWith(search: text, page: 1),
  );

  Future<void> applyFilters(ProgrammeQuery filters) =>
      _applyQuery(filters.copyWith(page: 1));

  Future<void> clearFilters() async {
    _query = const ProgrammeQuery();
    await ref.read(localStoreProvider).clearProgrammeFilters();
    await _load(keepCurrentResults: true);
  }

  Future<void> showExpired() =>
      _applyQuery(_query.copyWith(showExpired: true, page: 1));

  Future<void> goToPage(int page) => _applyQuery(_query.copyWith(page: page));

  Future<void> retry() => _load();

  /// Applies the offered single-filter relaxation.
  Future<void> relax(FilterRelaxation relaxation) =>
      _applyQuery(switch (relaxation.field) {
        'show_expired' => _query.copyWith(showExpired: true, page: 1),
        'max_tuition_usd' => _query.copyWith(clearMaxTuition: true, page: 1),
        'specialties' => _query.copyWith(specialties: const [], page: 1),
        'regions' => _query.copyWith(regions: const [], page: 1),
        'degree_types' => _query.copyWith(degreeTypes: const [], page: 1),
        _ => const ProgrammeQuery(),
      });

  /// Saves or removes a programme, optimistically.
  ///
  /// The heart fills immediately and reverts if the server refuses — the design
  /// allows optimism precisely because the rollback is real.
  Future<bool> toggleSaved(ProgrammeSummary programme) async {
    final current = state;
    if (current is! ProgrammesReady) return programme.isSaved;

    final wantSaved = !programme.isSaved;
    state = current.copyWith(
      page: current.page.copyWith(
        items: [
          for (final item in current.page.items)
            item.id == programme.id ? item.copyWith(isSaved: wantSaved) : item,
        ],
      ),
    );

    try {
      final repository = ref.read(careerRepositoryProvider);
      if (wantSaved) {
        await repository.save(programme.id);
        await ref
            .read(analyticsProvider)
            .track(AnalyticsEvents.programmeSaved, {
              'id': programme.id,
              'country': programme.country,
              'days_to_deadline': programme.daysRemaining,
            });
      } else {
        await repository.unsave(programme.id);
      }
      return wantSaved;
    } on Failure {
      // Revert. The caller surfaces the failure copy.
      final reverted = state;
      if (reverted is ProgrammesReady) {
        state = reverted.copyWith(
          page: reverted.page.copyWith(
            items: [
              for (final item in reverted.page.items)
                item.id == programme.id
                    ? item.copyWith(isSaved: !wantSaved)
                    : item,
            ],
          ),
        );
      }
      rethrow;
    }
  }
}
