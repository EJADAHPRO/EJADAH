import 'package:ejadah_core/ejadah_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/earnings_repository.dart';

final earningsControllerProvider =
    AsyncNotifierProvider<EarningsController, Earnings>(EarningsController.new);

/// The tutor's ledger.
class EarningsController extends AsyncNotifier<Earnings> {
  @override
  Future<Earnings> build() => ref.read(earningsRepositoryProvider).load();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(earningsRepositoryProvider).load(),
    );
  }

  /// Asks to be paid, then re-reads.
  ///
  /// Deliberately **not** optimistic, unlike the playbook's ticks: this moves
  /// money. A balance that drops to zero on screen and then comes back because
  /// the request failed is the one place in this product where a hopeful
  /// update is worse than a moment's wait.
  ///
  /// Returns the failure rather than throwing, so the screen can show the
  /// server's own reason — which is usually the shortfall, and is the most
  /// useful sentence on the page.
  Future<Failure?> requestPayout() async {
    try {
      await ref.read(earningsRepositoryProvider).requestPayout();
      state = AsyncData(await ref.read(earningsRepositoryProvider).load());
      return null;
    } on Failure catch (failure) {
      // Re-read anyway: a refusal usually means this screen's picture of the
      // balance is out of date, and leaving the stale one up invites the same
      // tap again.
      state = await AsyncValue.guard(
        () => ref.read(earningsRepositoryProvider).load(),
      );
      return failure;
    }
  }
}
