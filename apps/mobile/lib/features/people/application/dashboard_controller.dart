import 'package:ejadah_core/ejadah_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dashboard_repository.dart';

final dashboardControllerProvider =
    AsyncNotifierProvider<DashboardController, TutorDashboard>(
      DashboardController.new,
    );

/// PE-13's state.
class DashboardController extends AsyncNotifier<TutorDashboard> {
  @override
  Future<TutorDashboard> build() =>
      ref.read(dashboardRepositoryProvider).load();

  DashboardRepository get _repository => ref.read(dashboardRepositoryProvider);

  Future<void> refresh() async {
    state = await AsyncValue.guard(_repository.load);
  }

  /// Marks a session as held.
  ///
  /// Not optimistic. This moves money — the same reason the payout request is
  /// not optimistic — and a row that ticks and then untricks because the write
  /// failed is worse on a screen about being paid than a moment's wait.
  Future<Failure?> mark(String sessionId) =>
      _write(() => _repository.mark(sessionId));

  Future<Failure?> setHidden(bool hidden) =>
      _write(() => _repository.setHidden(hidden));

  Future<Failure?> setMeetingUrl(String? url) =>
      _write(() => _repository.setMeetingUrl(url));

  Future<Failure?> _write(Future<void> Function() action) async {
    try {
      await action();
      state = AsyncData(await _repository.load());
      return null;
    } on Failure catch (failure) {
      // Re-read anyway: a refusal usually means this screen's picture is stale,
      // and leaving the old one up invites the same tap again.
      await refresh();
      return failure;
    }
  }
}
