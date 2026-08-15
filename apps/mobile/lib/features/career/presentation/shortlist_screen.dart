import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/career_repository.dart';
import 'widgets/programme_card.dart';

typedef ShortlistData = ({List<ProgrammeSummary> items, int openCount});

final shortlistProvider =
    AsyncNotifierProvider<ShortlistController, ShortlistData>(
      ShortlistController.new,
    );

/// The shortlist, with a removal the screen can show before the server has
/// agreed to it.
class ShortlistController extends AsyncNotifier<ShortlistData> {
  @override
  Future<ShortlistData> build() =>
      ref.watch(careerRepositoryProvider).shortlist();

  /// Drops a row immediately, and puts it back if the request fails.
  ///
  /// The list version of this action has always been optimistic; this one
  /// awaited the network and then invalidated, so the same gesture felt
  /// different depending on which screen it was made from.
  void removeLocally(int programmeId) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData((
      items: current.items.where((item) => item.id != programmeId).toList(),
      openCount: current.openCount,
    ));
  }

  void restore(ShortlistData previous) => state = AsyncData(previous);

  ShortlistData? get snapshot => state.valueOrNull;
}

/// The shortlist, urgency first.
///
/// Saving persists server-side, so it survives an app restart and a reinstall.
/// Removal is optimistic with a five-second Undo.
class ShortlistScreen extends ConsumerWidget {
  const ShortlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final shortlist = ref.watch(shortlistProvider);

    return Scaffold(
      appBar: EjadahAppBar(
        title: strings.myShortlist,
        onBack: () => context.pop(),
        backLabel: strings.back,
      ),
      body: SafeArea(
        top: false,
        child: EjadahPageBody(
          child: shortlist.when(
            loading: () => ListView.separated(
              itemCount: 3,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: EjadahSpacing.cardGap),
              itemBuilder: (_, _) => const CardSkeleton(),
            ),
            error: (error, _) => EjadahErrorState(
              title: FailureCopy.errorTitle(context),
              body: error is Failure
                  ? error.message(context)
                  : FailureCopy.server(context),
              retryLabel: strings.retry,
              onRetry: () => ref.invalidate(shortlistProvider),
            ),
            data: (data) => data.items.isEmpty
                // The empty state names a real number and routes to action.
                ? EjadahEmptyState(
                    title: strings.emptySavedTitle,
                    body: strings.emptySavedRelaxed(data.openCount),
                    actionLabel: strings.browseProgrammes,
                    onAction: () => context.push('/programmes'),
                  )
                : ListView.separated(
                    key: const PageStorageKey('shortlist'),
                    itemCount: data.items.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: EjadahSpacing.cardGap),
                    itemBuilder: (context, index) {
                      final programme = data.items[index];
                      return ProgrammeCard(
                        programme: programme,
                        onTap: () => context.push('/programme/${programme.id}'),
                        onToggleSave: () => _remove(context, ref, programme),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    ProgrammeSummary programme,
  ) async {
    final repository = ref.read(careerRepositoryProvider);
    final controller = ref.read(shortlistProvider.notifier);
    final previous = controller.snapshot;

    // The row goes now; the network catches up.
    controller.removeLocally(programme.id);

    try {
      await repository.unsave(programme.id);
      if (!context.mounted) return;

      showEjadahToast(
        context,
        message: context.strings.undoRemove,
        undoLabel: context.strings.undo,
        onUndo: () async {
          // Put it back on screen first, then tell the server.
          if (previous != null) controller.restore(previous);
          await repository.save(programme.id);
          ref.invalidate(shortlistProvider);
        },
      );
    } on Failure catch (failure) {
      // The row comes back: the shortlist still holds it.
      if (previous != null) controller.restore(previous);
      if (!context.mounted) return;
      showEjadahToast(context, message: failure.message(context));
    }
  }
}
