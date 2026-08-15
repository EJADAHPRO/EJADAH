import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/people_repository.dart';

/// What one marketplace door is showing.
///
/// The states are explicit rather than implied by null checks, because the
/// screen renders a different treatment for each: skeletons while loading, a
/// zero-result state that offers to clear the filters, and a retry on failure.
sealed class ProfessionalListState {
  const ProfessionalListState();
}

class ProfessionalListLoading extends ProfessionalListState {
  const ProfessionalListLoading();
}

class ProfessionalListReady extends ProfessionalListState {
  const ProfessionalListReady({
    required this.result,
    required this.query,
    this.isRefreshing = false,
  });

  final ProfessionalListPage result;
  final ProfessionalQuery query;

  /// A filter changed and new rows are on the way. The current rows stay on
  /// screen so the list does not blink back to a skeleton.
  final bool isRefreshing;

  Paginated<Professional> get page => result.page;

  bool get isEmpty => result.page.isEmpty;

  ProfessionalListReady copyWith({
    ProfessionalListPage? result,
    ProfessionalQuery? query,
    bool? isRefreshing,
  }) => ProfessionalListReady(
    result: result ?? this.result,
    query: query ?? this.query,
    isRefreshing: isRefreshing ?? this.isRefreshing,
  );
}

class ProfessionalListFailed extends ProfessionalListState {
  const ProfessionalListFailed(this.failure, this.query);

  final Failure failure;
  final ProfessionalQuery query;
}

/// One controller per door, keyed by kind, so the three lists keep independent
/// filters and scroll positions.
final professionalListControllerProvider = NotifierProvider.family<
  ProfessionalListController,
  ProfessionalListState,
  ServiceKind
>(ProfessionalListController.new);

class ProfessionalListController
    extends FamilyNotifier<ProfessionalListState, ServiceKind> {
  late ProfessionalQuery _query;

  @override
  ProfessionalListState build(ServiceKind arg) {
    _query = ProfessionalQuery(kind: arg);
    // Restoring the stored filters and running the first search happen off the
    // build, so the screen can show its skeleton immediately.
    Future.microtask(_restoreAndLoad);
    return const ProfessionalListLoading();
  }

  ProfessionalQuery get query => _query;

  Future<void> _restoreAndLoad() async {
    final stored = await ref.read(peopleRepositoryProvider).storedFilters(arg);
    if (stored != null) _query = stored;
    await _load();
  }

  Future<void> _load({bool keepCurrentResults = false}) async {
    final current = state;
    if (keepCurrentResults && current is ProfessionalListReady) {
      state = current.copyWith(isRefreshing: true);
    } else {
      state = const ProfessionalListLoading();
    }

    try {
      final result = await ref.read(peopleRepositoryProvider).browse(_query);
      state = ProfessionalListReady(result: result, query: _query);
    } on Failure catch (failure) {
      state = ProfessionalListFailed(failure, _query);
    }
  }

  Future<void> _apply(ProfessionalQuery query) async {
    _query = query;
    // Filters persist across launches, per door.
    await ref.read(peopleRepositoryProvider).saveFilters(query);
    await _load(keepCurrentResults: true);
  }

  /// Applying a filter resets to page one — staying on page three of a
  /// different result set shows an empty screen for no reason.
  Future<void> applyFilters(ProfessionalQuery filters) =>
      _apply(filters.copyWith(page: 1));

  Future<void> clearFilters() async {
    _query = ProfessionalQuery(kind: arg, sort: _query.sort);
    await ref.read(peopleRepositoryProvider).clearFilters(arg);
    await _load(keepCurrentResults: true);
  }

  Future<void> sortBy(ProfessionalSort sort) =>
      _apply(_query.copyWith(sort: sort, page: 1));

  Future<void> goToPage(int page) => _apply(_query.copyWith(page: page));

  Future<void> retry() => _load();
}
