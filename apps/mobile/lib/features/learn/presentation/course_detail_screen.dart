import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/learn_controllers.dart';
import '../data/learn_models.dart';
import 'course_complete_screen.dart';
import 'flashcards_screen.dart';
import 'handouts_screen.dart';
import 'iap_purchase_sheet.dart';
import 'player_screen.dart';
import 'quiz_screen.dart';
import 'widgets/learn_labels.dart';
import 'widgets/learn_skeletons.dart';
import 'widgets/lesson_row.dart';

/// LN-03 · Course detail.
///
/// The curriculum is visible to everyone, signed in or not. Lesson one is
/// always a free preview; the rest carry a padlock and the words "Not included"
/// until the course is owned. The primary action is Buy or Start depending on
/// ownership, and it is the only primary action on the screen.
class CourseDetailScreen extends ConsumerWidget {
  const CourseDetailScreen({required this.slug, super.key});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final detail = ref.watch(courseDetailProvider(slug));

    return GradientBudget(
      screenName: 'course-detail',
      child: Scaffold(
        body: SafeArea(
          bottom: false,
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
                    data: (data) => _Detail(detail: data, slug: slug),
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

class _Detail extends ConsumerWidget {
  const _Detail({required this.detail, required this.slug});

  final CourseDetail detail;
  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final type = context.type;
    final course = detail.course;
    final progress = detail.progress;

    return Stack(
      children: [
        ListView(
          key: PageStorageKey('course-$slug'),
          padding: const EdgeInsets.only(bottom: 120),
          children: [
            const SizedBox(height: EjadahSpacing.xs),
            PageHeader(
              eyebrow: departmentLabel(context, course.department),
              title: course.title(context),
              subtitle: course.subtitle.isEmpty
                  ? null
                  : course.subtitle(context),
            ),
            const SizedBox(height: EjadahSpacing.md),
            _Facts(course: course),
            if (course.description != null &&
                course.description!.isNotEmpty) ...[
              const SizedBox(height: EjadahSpacing.md),
              Text(
                course.description!(context),
                style: type.bodyText(color: EjadahColors.textSecondary),
              ),
            ],
            if (progress != null && progress.hasStarted) ...[
              const SizedBox(height: EjadahSpacing.md),
              _ProgressPanel(detail: detail, slug: slug),
            ],
            const SizedBox(height: EjadahSpacing.lg),
            SectionHeader(title: strings.includes),
            const SizedBox(height: EjadahSpacing.xs),
            _Included(detail: detail),
            const SizedBox(height: EjadahSpacing.lg),
            SectionHeader(title: strings.curriculum),
            const SizedBox(height: EjadahSpacing.xs),
            for (final lesson in detail.lessons)
              LessonRow(
                lesson: lesson,
                onTap: () => _openLesson(context, ref, lesson),
                onLockedTap: () => _openPurchase(context, ref),
              ),
            if (detail.handouts.isNotEmpty ||
                detail.decks.isNotEmpty ||
                detail.quizzes.isNotEmpty) ...[
              const SizedBox(height: EjadahSpacing.lg),
              SectionHeader(title: strings.toolsLabel),
              const SizedBox(height: EjadahSpacing.xs),
              _Tools(detail: detail, slug: slug),
            ],
            const SizedBox(height: EjadahSpacing.lg),
            SectionHeader(title: strings.instructorLabel),
            const SizedBox(height: EjadahSpacing.xs),
            _Instructor(course: course),
            const SizedBox(height: EjadahSpacing.section),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _StickyBar(detail: detail, slug: slug),
        ),
      ],
    );
  }

  void _openLesson(BuildContext context, WidgetRef ref, Lesson lesson) {
    if (!lesson.isUnlocked) {
      _openPurchase(context, ref);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlayerScreen(slug: slug, lessonId: lesson.id),
      ),
    );
  }

  void _openPurchase(BuildContext context, WidgetRef ref) =>
      showIapPurchaseSheet(context: context, ref: ref, slug: slug);
}

/// Level, CPD and length. Every number sits in its own island.
class _Facts extends StatelessWidget {
  const _Facts({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Wrap(
      spacing: EjadahSpacing.xs,
      runSpacing: EjadahSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (course.level.isNotEmpty)
          EjadahBadge(
            label: '${strings.level}: ${course.level(context)}',
            foreground: EjadahColors.labelStrong,
            background: EjadahColors.inset,
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            LtrIsland(
              child: Text(
                '${course.lessonCount}',
                style: context.type.tabular(fontSize: EjadahTypeSize.caption),
              ),
            ),
            const SizedBox(width: EjadahSpacing.xxs),
            Text(
              strings.lessons,
              style: context.type.micro(color: EjadahColors.labelMuted),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            LtrIsland(
              child: Text(
                '${course.totalMinutes}',
                style: context.type.tabular(fontSize: EjadahTypeSize.caption),
              ),
            ),
            const SizedBox(width: EjadahSpacing.xxs),
            Text(
              strings.totalTime,
              style: context.type.micro(color: EjadahColors.labelMuted),
            ),
          ],
        ),
        if (course.isOwned)
          EjadahBadge(
            label: strings.ownedCourse,
            foreground: EjadahColors.successText,
            background: EjadahColors.tint(EjadahColors.success),
            icon: EjadahIcons.check,
          ),
      ],
    );
  }
}

class _Included extends StatelessWidget {
  const _Included({required this.detail});

  final CourseDetail detail;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final items = <String>[
      strings.incLifetime,
      if (detail.handouts.isNotEmpty) strings.incHandouts,
      if (detail.course.cpdPoints > 0) strings.incCpd,
      strings.incCert,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: EjadahSpacing.xs),
            child: Row(
              children: [
                const Icon(
                  EjadahIcons.check,
                  size: EjadahIconSize.inline,
                  color: EjadahColors.successText,
                ),
                const SizedBox(width: EjadahSpacing.xs),
                Expanded(child: Text(item, style: context.type.small())),
              ],
            ),
          ),
      ],
    );
  }
}

/// Handouts, flashcards and the quiz — all owner-only.
class _Tools extends ConsumerWidget {
  const _Tools({required this.detail, required this.slug});

  final CourseDetail detail;
  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final isOwned = detail.course.isOwned;

    void openOrBuy(WidgetBuilder builder) {
      if (!isOwned) {
        showIapPurchaseSheet(context: context, ref: ref, slug: slug);
        return;
      }
      Navigator.of(context).push(MaterialPageRoute<void>(builder: builder));
    }

    return Column(
      children: [
        if (detail.handouts.isNotEmpty)
          EjadahListRow(
            title: strings.handouts,
            subtitle: isOwned ? null : strings.notIncluded,
            leading: Icon(
              isOwned ? EjadahIcons.download : EjadahIcons.locked,
              size: EjadahIconSize.inline,
              color: EjadahColors.labelStrong,
            ),
            trailing: const DirectionalIcon(
              EjadahIcons.chevronForward,
              color: EjadahColors.labelMuted,
            ),
            onTap: () => openOrBuy(
              (_) => HandoutsScreen(
                courseId: detail.course.id,
                title: detail.course.title(context),
              ),
            ),
          ),
        for (final deck in detail.decks)
          EjadahListRow(
            title: deck.title(context),
            subtitle: isOwned
                ? strings.cardsDue(deck.dueCount)
                : strings.notIncluded,
            leading: Icon(
              isOwned ? EjadahIcons.learn : EjadahIcons.locked,
              size: EjadahIconSize.inline,
              color: EjadahColors.labelStrong,
            ),
            trailing: const DirectionalIcon(
              EjadahIcons.chevronForward,
              color: EjadahColors.labelMuted,
            ),
            onTap: () => openOrBuy((_) => FlashcardsScreen(deckId: deck.id)),
          ),
        for (final quiz in detail.quizzes)
          EjadahListRow(
            title: quiz.title(context),
            subtitle: isOwned ? null : strings.notIncluded,
            leading: Icon(
              isOwned ? EjadahIcons.certificate : EjadahIcons.locked,
              size: EjadahIconSize.inline,
              color: EjadahColors.labelStrong,
            ),
            trailing: const DirectionalIcon(
              EjadahIcons.chevronForward,
              color: EjadahColors.labelMuted,
            ),
            onTap: () =>
                openOrBuy((_) => QuizScreen(quizId: quiz.id, courseSlug: slug)),
          ),
      ],
    );
  }
}

class _Instructor extends StatelessWidget {
  const _Instructor({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) => EjadahCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(course.instructorName(context), style: context.type.bodyStrong()),
        if (course.instructorBio.isNotEmpty) ...[
          const SizedBox(height: EjadahSpacing.xxs),
          Text(
            course.instructorBio(context),
            style: context.type.small(color: EjadahColors.textSecondary),
          ),
        ],
      ],
    ),
  );
}

class _ProgressPanel extends StatelessWidget {
  const _ProgressPanel({required this.detail, required this.slug});

  final CourseDetail detail;
  final String slug;

  @override
  Widget build(BuildContext context) {
    final progress = detail.progress!;
    final strings = context.strings;

    return EjadahCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.type.eyebrowText(strings.myLearning),
            style: context.type.eyebrow(color: EjadahColors.labelMuted),
          ),
          const SizedBox(height: EjadahSpacing.xs),
          Row(
            children: [
              LtrIsland(
                child: Text(
                  '${progress.completedCount}/${progress.lessonCount}',
                  style: context.type.tabular(),
                ),
              ),
              const SizedBox(width: EjadahSpacing.xs),
              Text(
                strings.lessons,
                style: context.type.small(color: EjadahColors.textSecondary),
              ),
            ],
          ),
          if (progress.isComplete) ...[
            const SizedBox(height: EjadahSpacing.sm),
            EjadahSecondaryButton(
              label: strings.incCert,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CourseCompleteScreen(slug: slug),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The single main action, in a sticky bar because this screen is taller than
/// one viewport.
class _StickyBar extends ConsumerWidget {
  const _StickyBar({required this.detail, required this.slug});

  final CourseDetail detail;
  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final course = detail.course;
    final resume = detail.resumeLesson;
    final progress = detail.progress;

    final label = switch ((course.isOwned, progress?.hasStarted ?? false)) {
      (true, true) => strings.continueCourse,
      (true, false) => strings.startCourse,
      // A guest or a non-owner: lesson one is still free, and the sheet says so.
      (false, _) => strings.buyCourse,
    };

    return Container(
      padding: EdgeInsets.fromLTRB(
        EjadahSpacing.gutter,
        EjadahSpacing.sm,
        EjadahSpacing.gutter,
        EjadahSpacing.sm + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: EjadahColors.background,
        boxShadow: EjadahElevation.stickyTop,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!course.isOwned) ...[
            Text(
              strings.lessonOneFree,
              style: context.type.caption(color: EjadahColors.successText),
            ),
            const SizedBox(height: EjadahSpacing.xs),
          ],
          EjadahPrimaryButton(
            label: label,
            onPressed: () {
              if (!course.isOwned) {
                showIapPurchaseSheet(context: context, ref: ref, slug: slug);
                return;
              }
              final lesson = resume ?? detail.lessons.firstOrNull;
              if (lesson == null) return;
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PlayerScreen(slug: slug, lessonId: lesson.id),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
