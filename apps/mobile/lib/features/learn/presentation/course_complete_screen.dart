import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/learn_controllers.dart';
import '../data/learn_models.dart';
import 'quiz_screen.dart';
import 'widgets/learn_skeletons.dart';

/// LN-10 · Course complete.
///
/// The certificate is earned rather than announced: this screen is reachable
/// only once every lesson is marked complete on the server, so the claim on it
/// is one Ejadah can stand behind — which is the whole point of the verified
/// versus stated distinction elsewhere in the product.
class CourseCompleteScreen extends ConsumerWidget {
  const CourseCompleteScreen({required this.slug, super.key});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final detail = ref.watch(courseDetailProvider(slug));

    return GradientBudget(
      screenName: 'course-complete',
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              EjadahAppBar(
                title: strings.coursesEyebrow,
                backLabel: strings.back,
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: EjadahPageBody(
                  child: detail.when(
                    loading: () => ListView(
                      children: const [
                        SizedBox(height: EjadahSpacing.md),
                        CourseDetailSkeleton(),
                      ],
                    ),
                    error: (error, _) => EjadahErrorState(
                      title: FailureCopy.errorTitle(context),
                      body: error is Failure
                          ? error.message(context)
                          : FailureCopy.server(context),
                      retryLabel: strings.retry,
                      onRetry: () => ref.invalidate(courseDetailProvider(slug)),
                    ),
                    data: (data) => _Body(detail: data, slug: slug),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.detail, required this.slug});

  final CourseDetail detail;
  final String slug;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final progress = detail.progress;

    if (progress == null || !progress.isComplete) {
      // Reached before the course is finished: an honest state with the way
      // forward, rather than a certificate nobody earned.
      return EjadahEmptyState(
        title: detail.course.title(context),
        body: strings.continueCourse,
        actionLabel: strings.back,
        onAction: () => Navigator.of(context).maybePop(),
      );
    }

    return ListView(
      children: [
        const SizedBox(height: EjadahSpacing.section),
        const Icon(
          EjadahIcons.certificate,
          size: EjadahIconSize.feature,
          color: EjadahColors.successText,
        ),
        const SizedBox(height: EjadahSpacing.md),
        Text(
          detail.course.title(context),
          style: context.type.h4(text: detail.course.title(context)),
        ),
        const SizedBox(height: EjadahSpacing.xs),
        Text(
          strings.incCert,
          style: context.type.bodyText(color: EjadahColors.textSecondary),
        ),
        const SizedBox(height: EjadahSpacing.lg),
        Row(
          children: [
            Expanded(
              child: StatCard(
                value: LtrIsland(child: Text('${progress.lessonCount}')),
                label: strings.lessons,
              ),
            ),
            if (detail.course.cpdPoints > 0) ...[
              const SizedBox(width: EjadahSpacing.sm),
              Expanded(
                child: StatCard(
                  value: LtrIsland(child: Text('${detail.course.cpdPoints}')),
                  label: strings.incCpd,
                  emphasis: EjadahColors.successText,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: EjadahSpacing.lg),
        if (detail.quizzes.isNotEmpty)
          EjadahPrimaryButton(
            label: strings.quiz,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => QuizScreen(
                  quizId: detail.quizzes.first.id,
                  courseSlug: slug,
                ),
              ),
            ),
          ),
        const SizedBox(height: EjadahSpacing.xs),
        EjadahSecondaryButton(
          label: strings.backToCourse,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(height: EjadahSpacing.section),
      ],
    );
  }
}
