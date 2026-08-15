import 'package:ejadah_core/ejadah_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/people_repository.dart';

/// What the People hub is showing.
///
/// The counts are part of the design, not decoration: a door that leads to an
/// empty roster must say so on the door rather than after the tap.
sealed class PeopleHubState {
  const PeopleHubState();
}

class PeopleHubLoading extends PeopleHubState {
  const PeopleHubLoading();
}

class PeopleHubReady extends PeopleHubState {
  const PeopleHubReady(this.counts);

  final PeopleHubCounts counts;
}

class PeopleHubFailed extends PeopleHubState {
  const PeopleHubFailed(this.failure);

  final Failure failure;
}

final peopleHubControllerProvider =
    NotifierProvider<PeopleHubController, PeopleHubState>(
      PeopleHubController.new,
    );

class PeopleHubController extends Notifier<PeopleHubState> {
  @override
  PeopleHubState build() {
    Future.microtask(load);
    return const PeopleHubLoading();
  }

  Future<void> load() async {
    state = const PeopleHubLoading();
    try {
      state = PeopleHubReady(await ref.read(peopleRepositoryProvider).hub());
    } on Failure catch (failure) {
      state = PeopleHubFailed(failure);
    }
  }

  Future<void> retry() => load();
}
