import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/learn_controllers.dart';
import '../data/learn_models.dart';
import 'course_detail_screen.dart';
import 'widgets/course_card.dart';
import 'widgets/learn_labels.dart';
import 'widgets/learn_skeletons.dart';

/// LN-02 · The courses in one department.
///
/// The list states its own size, the filter selection persists, and the loading
/// state is a skeleton in the shape of the cards — the third of the three gaps
/// the state matrix flags for this screen.
class CourseListScreen extends ConsumerWidget {
  const CourseListScreen({required this.department, super.key});

  final Department department;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final catalogue = ref.watch(catalogueProvider(department));

    return GradientBudget(
      screenName: 'course-list',
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              EjadahAppBar(
                title: departmentLabel(context, department),
                backLabel: strings.back,
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: EjadahPageBody(
                  child: catalogue.when(
                    loading: () => ListView(
                      children: const [
                        SizedBox(height: EjadahSpacing.md),
                        CourseListSkeleton(),
                      ],
                    ),
                    error: (error, _) => EjadahErrorState(
                      title: FailureCopy.errorTitle(context),
                      body: error is Failure
                          ? error.message(context)
                          : FailureCopy.server(context),
                      retryLabel: strings.retry,
                      onRetry: () =>
                          ref.invalidate(catalogueProvider(department)),
                    ),
                    data: (data) =>
                        _Results(catalogue: data, department: department),
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

class _Results extends ConsumerWidget {
  const _Results({required this.catalogue, required this.department});

  final Catalogue catalogue;
  final Department department;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final filter = ref.watch(courseFilterProvider);
    final controller = ref.read(courseFilterProvider.notifier);
    final visible = controller.apply(catalogue.courses);

    return ListView(
      key: PageStorageKey('course-list-${department.wire}'),
      children: [
        const SizedBox(height: EjadahSpacing.sm),
        if (catalogue.levels.length > 1) ...[
          Text(
            context.type.eyebrowText(strings.filterBy),
            style: context.type.eyebrow(color: EjadahColors.labelMuted),
          ),
          const SizedBox(height: EjadahSpacing.xs),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final level in catalogue.levels) ...[
                  EjadahFilterChip(
                    label: level(context),
                    isSelected: filter.contains(level.en),
                    count: catalogue.courses
                        .where((course) => course.level.en == level.en)
                        .length,
                    onTap: () => controller.toggle(level.en),
                  ),
                  const SizedBox(width: EjadahSpacing.xs),
                ],
                if (filter.isNotEmpty)
                  EjadahGhostButton(
                    label: strings.clearAll,
                    onPressed: controller.clear,
                  ),
              ],
            ),
          ),
          const SizedBox(height: EjadahSpacing.sm),
        ],
        // The list always states its own size.
        Row(
          children: [
            LtrIsland(
              child: Text(
                '${visible.length}',
                style: context.type.tabular(fontSize: 12),
              ),
            ),
            const SizedBox(width: EjadahSpacing.xxs),
            Text(
              strings.coursesEyebrow.toLowerCase(),
              style: context.type.micro(color: EjadahColors.labelMuted),
            ),
          ],
        ),
        const SizedBox(height: EjadahSpacing.sm),
        if (visible.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: EjadahSpacing.lg),
            child: EjadahEmptyState(
              title: strings.emptyMastersTitle,
              body: strings.emptyMastersBody,
              // The empty state routes somewhere: clearing the filter is the
              // one action that brings the list back.
              actionLabel: strings.clearAll,
              onAction: controller.clear,
            ),
          )
        else
          for (final course in visible) ...[
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
        const SizedBox(height: EjadahSpacing.section),
      ],
    );
  }
}
