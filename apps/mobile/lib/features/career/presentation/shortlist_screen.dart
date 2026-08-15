import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/career_repository.dart';
import 'widgets/programme_card.dart';

final shortlistProvider =
    FutureProvider<({List<ProgrammeSummary> items, int openCount})>(
      (ref) => ref.watch(careerRepositoryProvider).shortlist(),
    );

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
    try {
      await repository.unsave(programme.id);
      ref.invalidate(shortlistProvider);
      if (!context.mounted) return;

      showEjadahToast(
        context,
        message: context.strings.undoRemove,
        undoLabel: context.strings.undo,
        onUndo: () async {
          await repository.save(programme.id);
          ref.invalidate(shortlistProvider);
        },
      );
    } on Failure catch (failure) {
      if (!context.mounted) return;
      showEjadahToast(context, message: failure.message(context));
    }
  }
}
