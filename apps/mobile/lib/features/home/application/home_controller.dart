import 'package:ejadah_core/ejadah_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/auth_controller.dart';
import '../data/home_repository.dart';

/// What Home is showing.
///
/// Six states, all of them designed: loading, the returning feed, the first-use
/// feed, a partial feed where some sections failed, a whole-page failure, and
/// offline with cached content.
sealed class HomeState {
  const HomeState();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

/// A guest has no feed to assemble — Home invites them into the funnel.
class HomeSignedOut extends HomeState {
  const HomeSignedOut();
}

class HomeReady extends HomeState {
  const HomeReady(this.feed, {this.isOffline = false});

  final HomeFeed feed;

  /// The feed came from cache because the network was unreachable.
  final bool isOffline;

  bool get isFirstRun => feed.isFirstRun;

  bool get isPartial => feed.isPartial;
}

class HomeFailed extends HomeState {
  const HomeFailed(this.failure);

  final Failure failure;
}

final homeControllerProvider = NotifierProvider<HomeController, HomeState>(
  HomeController.new,
);

class HomeController extends Notifier<HomeState> {
  /// The last feed that loaded. Kept so a dropped connection shows real content
  /// behind an offline banner rather than an empty screen.
  HomeFeed? _cached;

  @override
  HomeState build() {
    // Re-assembles whenever the user signs in or out.
    ref.listen(authControllerProvider, (_, _) => Future.microtask(load));
    Future.microtask(load);
    return const HomeLoading();
  }

  Future<void> load() async {
    if (!ref.read(authControllerProvider).isAuthenticated) {
      state = const HomeSignedOut();
      return;
    }

    final cached = _cached;
    if (cached == null) state = const HomeLoading();

    try {
      final feed = await ref.read(homeRepositoryProvider).feed();
      _cached = feed;
      state = HomeReady(feed);
    } on NetworkFailure {
      // Offline is a condition, not an error: saved content is still readable.
      state = cached != null
          ? HomeReady(cached, isOffline: true)
          : const HomeFailed(NetworkFailure());
    } on Failure catch (failure) {
      state = cached != null ? HomeReady(cached) : HomeFailed(failure);
    }
  }

  Future<void> refresh() => load();
}
