import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/learn_controllers.dart';
import 'widgets/flashcard_view.dart';
import 'widgets/learn_skeletons.dart';

/// LN-08 · A flashcard session.
///
/// Deck → session → summary. Two outcomes only, "Again" and "Got it", each
/// recorded on the server before the next card appears. The counts in the
/// header come back from the server after every review, so what the summary
/// reports is what actually happened rather than what the device remembers.
///
/// There is no mastery percentage anywhere on this screen, by design: the
/// schedule is real, and a number invented to look like progress would make it
/// less trustworthy, not more motivating.
class FlashcardsScreen extends ConsumerWidget {
  const FlashcardsScreen({required this.deckId, super.key});

  final int deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final state = ref.watch(flashcardSessionProvider(deckId));
    final controller = ref.read(flashcardSessionProvider(deckId).notifier);

    return GradientBudget(
      screenName: 'flashcards',
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              EjadahAppBar(
                title: strings.flashcards,
                backLabel: strings.back,
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: EjadahPageBody(
                  child: switch (state) {
                    FlashcardsLoading() => ListView(
                      children: const [
                        SizedBox(height: EjadahSpacing.md),
                        Skeleton(width: 140, height: 12),
                        SizedBox(height: EjadahSpacing.md),
                        Skeleton(width: double.infinity, height: 260),
                        SizedBox(height: EjadahSpacing.md),
                        LearnRowsSkeleton(count: 1),
                      ],
                    ),
                    FlashcardsFailed(:final failure) => EjadahErrorState(
                      title: FailureCopy.errorTitle(context),
                      body: failure.message(context),
                      retryLabel: strings.retry,
                      onRetry: controller.load,
                    ),
                    final FlashcardsFinished finished => _Summary(
                      state: finished,
                      onRestart: controller.load,
                    ),
                    final FlashcardsStudying studying => _Session(
                      state: studying,
                      onFlip: controller.flip,
                      onAnswer: controller.answer,
                    ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Session extends StatelessWidget {
  const _Session({
    required this.state,
    required this.onFlip,
    required this.onAnswer,
  });

  final FlashcardsStudying state;
  final VoidCallback onFlip;
  final Future<void> Function(ReviewOutcome) onAnswer;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Column(
      children: [
        const SizedBox(height: EjadahSpacing.sm),
        Row(
          children: [
            Expanded(
              child: Text(
                state.deck.title(context),
                style: context.type.bodyStrong(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Counts are Latin-context islands in both languages.
            LtrIsland(
              child: Text(
                '${state.position}/${state.cards.length}',
                style: context.type.tabular(fontSize: EjadahTypeSize.caption),
              ),
            ),
          ],
        ),
        const SizedBox(height: EjadahSpacing.xs),
        Text(
          strings.cardsDue(state.remainingDue),
          style: context.type.small(color: EjadahColors.textSecondary),
        ),
        const SizedBox(height: EjadahSpacing.md),
        Expanded(
          child: SingleChildScrollView(
            child: FlashcardView(
              card: state.card,
              isFlipped: state.isFlipped,
              onFlip: onFlip,
            ),
          ),
        ),
        const SizedBox(height: EjadahSpacing.md),
        // The outcome buttons only appear once the answer has been seen:
        // grading recall before reading the back is not a review.
        if (state.isFlipped)
          Row(
            children: [
              Expanded(
                child: EjadahSecondaryButton(
                  label: strings.again,
                  // Its sibling showed a spinner while recording and this one
                  // just went grey. Same state, same explanation.
                  isLoading: state.isRecording,
                  onPressed: state.isRecording
                      ? null
                      : () => onAnswer(ReviewOutcome.again),
                ),
              ),
              const SizedBox(width: EjadahSpacing.sm),
              Expanded(
                child: EjadahPrimaryButton(
                  label: strings.gotIt,
                  isLoading: state.isRecording,
                  onPressed: state.isRecording
                      ? null
                      : () => onAnswer(ReviewOutcome.gotIt),
                ),
              ),
            ],
          )
        else
          EjadahSecondaryButton(label: strings.flipCard, onPressed: onFlip),
        const SizedBox(height: EjadahSpacing.lg),
      ],
    );
  }
}

/// The session summary — what happened, not a score.
class _Summary extends StatelessWidget {
  const _Summary({required this.state, required this.onRestart});

  final FlashcardsFinished state;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    if (state.reviewedNothing) {
      return EjadahEmptyState(
        title: state.deck.title(context),
        body: strings.cardsDue(0),
        actionLabel: strings.back,
        onAction: () => Navigator.of(context).maybePop(),
      );
    }

    return ListView(
      children: [
        const SizedBox(height: EjadahSpacing.section),
        Text(
          state.deck.title(context),
          // `text:` is what arms the Arabic long-heading reduction. Omitting it
          // does not fail — it silently measures an empty string, which is
          // never over the threshold — so a localized dynamic title like this
          // one keeps its full size and wraps where it should have shrunk.
          style: context.type.h4(text: state.deck.title(context)),
        ),
        const SizedBox(height: EjadahSpacing.lg),
        Row(
          children: [
            Expanded(
              child: StatCard(
                value: LtrIsland(child: Text('${state.gotItCount}')),
                label: strings.gotIt,
                emphasis: EjadahColors.successText,
              ),
            ),
            const SizedBox(width: EjadahSpacing.sm),
            Expanded(
              child: StatCard(
                value: LtrIsland(child: Text('${state.againCount}')),
                label: strings.again,
              ),
            ),
          ],
        ),
        const SizedBox(height: EjadahSpacing.md),
        Text(
          strings.cardsDue(state.remainingDue),
          style: context.type.bodyText(color: EjadahColors.textSecondary),
        ),
        const SizedBox(height: EjadahSpacing.lg),
        if (state.remainingDue > 0)
          EjadahPrimaryButton(
            label: strings.continueAction,
            onPressed: onRestart,
          )
        else
          EjadahSecondaryButton(
            label: strings.backToCourse,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        const SizedBox(height: EjadahSpacing.xs),
        EjadahGhostButton(
          label: strings.done,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(height: EjadahSpacing.section),
      ],
    );
  }
}
