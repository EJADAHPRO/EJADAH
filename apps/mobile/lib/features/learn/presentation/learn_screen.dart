import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/learn_controllers.dart';
import '../data/learn_models.dart';
import 'course_detail_screen.dart';
import 'course_list_screen.dart';
import 'widgets/course_card.dart';
import 'widgets/learn_labels.dart';
import 'widgets/learn_skeletons.dart';

/// LN-01 · The Learn hub.
///
/// Three department doors, each quoting how many courses sit behind it, plus a
/// "continue" row for anything already started. Browsing is open to a guest by
/// design: the gate is purchasing, not looking.
///
/// The loading state is a skeleton shaped like the cards that are coming — the
/// handoff flags this screen's skeleton as a gap, and a spinner would not close
/// it.
class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final catalogue = ref.watch(catalogueProvider(null));

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: EjadahPageBody(
          child: RefreshIndicator(
            onRefresh: () async => ref.invalidate(catalogueProvider(null)),
            child: ListView(
              key: const PageStorageKey('learn-hub'),
              children: [
                const SizedBox(height: EjadahSpacing.md),
                PageHeader(
                  eyebrow: strings.coursesEyebrow,
                  title: strings.coursesTitle,
                  subtitle: strings.pickDept,
                ),
                const SizedBox(height: EjadahSpacing.lg),
                catalogue.when(
                  loading: () => const LearnHubSkeleton(),
                  error: (error, _) => _HubError(error: error),
                  data: (data) => _HubBody(catalogue: data),
                ),
                const SizedBox(height: EjadahSpacing.section),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HubError extends ConsumerWidget {
  const _HubError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
    padding: const EdgeInsets.only(top: EjadahSpacing.xl),
    child: EjadahErrorState(
      title: FailureCopy.errorTitle(context),
      body: error is Failure
          ? (error as Failure).message(context)
          : FailureCopy.server(context),
      retryLabel: context.strings.retry,
      onRetry: () => ref.invalidate(catalogueProvider(null)),
    ),
  );
}

class _HubBody extends ConsumerWidget {
  const _HubBody({required this.catalogue});

  final Catalogue catalogue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;

    if (catalogue.courses.isEmpty) {
      // An empty state must route somewhere, so this one re-reads the
      // catalogue rather than sitting there as a dead end.
      return Padding(
        padding: const EdgeInsets.only(top: EjadahSpacing.xl),
        child: EjadahEmptyState(
          title: strings.coursesTitle,
          body: strings.pickDept,
          actionLabel: strings.retry,
          onAction: () => ref.invalidate(catalogueProvider(null)),
        ),
      );
    }

    final started = catalogue.courses.where((c) => c.isOwned).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final department in Department.values) ...[
          _DepartmentCard(
            department: department,
            courseCount: catalogue.countFor(department),
          ),
          const SizedBox(height: EjadahSpacing.cardGap),
        ],
        if (started.isNotEmpty) ...[
          const SizedBox(height: EjadahSpacing.md),
          SectionHeader(title: strings.myLearning),
          const SizedBox(height: EjadahSpacing.xs),
          for (final course in started) ...[
            CourseCard(
              course: course,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CourseDetailScreen(slug: course.slug),
                ),
              ),
            ),
            const SizedBox(height: EjadahSpacing.cardGap),
          ],
        ],
      ],
    );
  }
}

/// One department door, with the count of what is behind it.
class _DepartmentCard extends StatelessWidget {
  const _DepartmentCard({required this.department, required this.courseCount});

  final Department department;
  final int courseCount;

  @override
  Widget build(BuildContext context) {
    final label = departmentLabel(context, department);

    return EjadahCard(
      semanticLabel: label,
      onTap: courseCount == 0
          ? null
          : () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => CourseListScreen(department: department),
              ),
            ),
      // A department with nothing in it is shown, dimmed, rather than hidden:
      // the three departments are the shape of the product.
      isDimmed: courseCount == 0,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: EjadahColors.inset,
              borderRadius: EjadahRadius.all(EjadahRadius.md),
            ),
            child: const Icon(
              EjadahIcons.learn,
              size: EjadahIconSize.nav,
              color: EjadahColors.labelStrong,
            ),
          ),
          const SizedBox(width: EjadahSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: context.type.h6()),
                const SizedBox(height: EjadahSpacing.xxs),
                Row(
                  children: [
                    LtrIsland(
                      child: Text(
                        '$courseCount',
                        style: context.type.tabular(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: EjadahSpacing.xxs),
                    Text(
                      context.strings.coursesEyebrow.toLowerCase(),
                      style: context.type.micro(color: EjadahColors.labelMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const DirectionalIcon(
            EjadahIcons.chevronForward,
            color: EjadahColors.labelMuted,
          ),
        ],
      ),
    );
  }
}
