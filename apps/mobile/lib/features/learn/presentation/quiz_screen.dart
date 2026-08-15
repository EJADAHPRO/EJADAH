import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/learn_controllers.dart';
import 'widgets/learn_skeletons.dart';

/// LN-09 · The course quiz.
///
/// Three phases: answer, review, score.
///
/// The order is forced by a rule that outranks the layout: the answer key never
/// reaches the device before an attempt is graded. So the questions are
/// answered first, the attempt is submitted, and only then does the app walk
/// back through each question showing what was chosen, what was right, and the
/// explanation — which is the part that actually teaches. The percentage comes
/// last, because it is the least useful thing on the screen.
///
/// Below 60% the score offers **one** session on the topic. Never a package,
/// and never in place of a retake: the retake button is always there.
class QuizScreen extends ConsumerWidget {
  const QuizScreen({required this.quizId, required this.courseSlug, super.key});

  final int quizId;
  final String courseSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final state = ref.watch(quizControllerProvider(quizId));
    final controller = ref.read(quizControllerProvider(quizId).notifier);

    return GradientBudget(
      screenName: 'quiz',
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              EjadahAppBar(
                title: strings.quiz,
                backLabel: strings.back,
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: EjadahPageBody(
                  child: switch (state) {
                    QuizLoading() => ListView(
                      children: const [
                        SizedBox(height: EjadahSpacing.md),
                        Skeleton(width: 120, height: 12),
                        SizedBox(height: EjadahSpacing.md),
                        Skeleton(width: double.infinity, height: 60),
                        SizedBox(height: EjadahSpacing.md),
                        LearnRowsSkeleton(),
                      ],
                    ),
                    QuizFailed(:final failure) => EjadahErrorState(
                      title: FailureCopy.errorTitle(context),
                      body: failure.message(context),
                      retryLabel: strings.retry,
                      onRetry: controller.load,
                    ),
                    final QuizAnswering answering => _Answering(
                      state: answering,
                      onChoose: controller.choose,
                      onNext: controller.next,
                      onPrevious: controller.previous,
                      onSubmit: controller.submit,
                    ),
                    final QuizReviewing reviewing => _Feedback(
                      state: reviewing,
                      onNext: controller.nextFeedback,
                    ),
                    final QuizScored scored => _Score(
                      state: scored,
                      onRetake: controller.retake,
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

/// Phase one: answering. No option is marked right or wrong here, because the
/// app does not know and must not guess.
class _Answering extends StatelessWidget {
  const _Answering({
    required this.state,
    required this.onChoose,
    required this.onNext,
    required this.onPrevious,
    required this.onSubmit,
  });

  final QuizAnswering state;
  final ValueChanged<int> onChoose;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Column(
      children: [
        const SizedBox(height: EjadahSpacing.sm),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            strings.stepOfSteps(state.position, state.total),
            style: context.type.micro(color: EjadahColors.labelMuted),
          ),
        ),
        const SizedBox(height: EjadahSpacing.sm),
        Expanded(
          child: ListView(
            key: PageStorageKey('quiz-${state.paper.id}-${state.index}'),
            children: [
              Text(state.question.prompt(context), style: context.type.h5()),
              const SizedBox(height: EjadahSpacing.md),
              for (final option in state.question.options) ...[
                _OptionRow(
                  label: option.label(context),
                  isSelected: state.selected == option.id,
                  onTap: () => onChoose(option.id),
                ),
                const SizedBox(height: EjadahSpacing.xs),
              ],
            ],
          ),
        ),
        const SizedBox(height: EjadahSpacing.sm),
        // Never disabled. A question left unanswered is graded as wrong and
        // still gets its explanation, so blocking the button would only hide
        // the teaching behind a rule the server does not need.
        EjadahPrimaryButton(
          label: state.isLast ? strings.done : strings.nextQuestion,
          isLoading: state.isSubmitting,
          onPressed: state.isLast ? () => onSubmit() : onNext,
        ),
        if (state.index > 0) ...[
          const SizedBox(height: EjadahSpacing.xxs),
          EjadahGhostButton(label: strings.back, onPressed: onPrevious),
        ],
        const SizedBox(height: EjadahSpacing.md),
      ],
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.tone,
    this.trailing,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  /// Set only after grading.
  final Color? tone;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final border = tone ?? (isSelected ? EjadahColors.orange : null);

    return Semantics(
      selected: isSelected,
      child: EjadahPressable(
        onTap: onTap,
        isButton: false,
        enforceMinimumTarget: false,
        semanticLabel: label,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: EjadahSizes.tapTargetMin,
          ),
          padding: const EdgeInsets.all(EjadahSpacing.sm),
          decoration: BoxDecoration(
            color: border == null
                ? EjadahColors.card
                : EjadahColors.tint(border),
            borderRadius: EjadahRadius.all(EjadahRadius.md),
            border: Border.all(
              color: border ?? EjadahColors.border,
              width: EjadahSizes.cardBorderWidth,
            ),
          ),
          child: Row(
            children: [
              Expanded(child: Text(label, style: context.type.bodyText())),
              if (trailing != null) ...[
                const SizedBox(width: EjadahSpacing.xs),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Phase two: per-question feedback with the explanation.
class _Feedback extends StatelessWidget {
  const _Feedback({required this.state, required this.onNext});

  final QuizReviewing state;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final question = state.question;

    return Column(
      children: [
        const SizedBox(height: EjadahSpacing.sm),
        Row(
          children: [
            Expanded(
              child: Text(
                strings.stepOfSteps(state.position, state.total),
                style: context.type.micro(color: EjadahColors.labelMuted),
              ),
            ),
            // Right or wrong is carried by words and an icon, never by colour
            // alone.
            EjadahBadge(
              label: question.isCorrect ? strings.gotIt : strings.again,
              foreground: question.isCorrect
                  ? EjadahColors.successText
                  : EjadahColors.dangerText,
              background: EjadahColors.tint(
                question.isCorrect ? EjadahColors.success : EjadahColors.danger,
              ),
              icon: question.isCorrect
                  ? EjadahIcons.check
                  : EjadahIcons.warning,
            ),
          ],
        ),
        const SizedBox(height: EjadahSpacing.sm),
        Expanded(
          child: ListView(
            children: [
              Text(question.prompt(context), style: context.type.h5()),
              const SizedBox(height: EjadahSpacing.md),
              for (final option in question.options) ...[
                _OptionRow(
                  label: option.label(context),
                  isSelected: option.id == question.selectedOptionId,
                  onTap: null,
                  tone: switch (option.id) {
                    final id when id == question.correctOptionId =>
                      EjadahColors.success,
                    final id
                        when id == question.selectedOptionId &&
                            !question.isCorrect =>
                      EjadahColors.danger,
                    _ => null,
                  },
                  trailing: option.id == question.correctOptionId
                      ? const Icon(
                          EjadahIcons.check,
                          size: EjadahIconSize.inline,
                          color: EjadahColors.successText,
                        )
                      : null,
                ),
                const SizedBox(height: EjadahSpacing.xs),
              ],
              if (question.explanation.isNotEmpty) ...[
                const SizedBox(height: EjadahSpacing.sm),
                InlineAlert(
                  tone: AlertTone.info,
                  title: strings.whatYouLearn,
                  message: question.explanation(context),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: EjadahSpacing.sm),
        EjadahPrimaryButton(
          label: state.isLast ? strings.done : strings.nextQuestion,
          onPressed: onNext,
        ),
        const SizedBox(height: EjadahSpacing.md),
      ],
    );
  }
}

/// Phase three: the score, and what to do about it.
class _Score extends StatelessWidget {
  const _Score({required this.state, required this.onRetake});

  final QuizScored state;
  final Future<void> Function() onRetake;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final attempt = state.graded.attempt;

    return ListView(
      children: [
        const SizedBox(height: EjadahSpacing.section),
        Icon(
          state.graded.passed ? EjadahIcons.check : EjadahIcons.warning,
          size: EjadahIconSize.feature,
          color: state.graded.passed
              ? EjadahColors.successText
              : EjadahColors.warningText,
        ),
        const SizedBox(height: EjadahSpacing.md),
        Text(state.paper.title(context), style: context.type.h5()),
        const SizedBox(height: EjadahSpacing.xs),
        // The whole score line is one Latin-context island: percentages and
        // "3 of 5" must not be reordered in Arabic.
        LtrIsland(
          child: Text(
            strings.quizScore(
              attempt.scorePercent,
              attempt.correctCount,
              attempt.questionCount,
            ),
            style: context.type.h4(),
          ),
        ),
        const SizedBox(height: EjadahSpacing.lg),
        if (state.graded.offersSession) ...[
          InlineAlert(message: strings.quizOfferSession),
          const SizedBox(height: EjadahSpacing.sm),
          // Exactly one session, on this topic. Never a package.
          EjadahSecondaryButton(
            label: strings.bookSession,
            onPressed: () => context.push('/people'),
          ),
          const SizedBox(height: EjadahSpacing.sm),
        ],
        // A retake is never blocked, whatever the score.
        EjadahPrimaryButton(label: strings.retakeQuiz, onPressed: onRetake),
        const SizedBox(height: EjadahSpacing.xs),
        EjadahGhostButton(
          label: strings.backToCourse,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(height: EjadahSpacing.section),
      ],
    );
  }
}
