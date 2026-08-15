import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/compare_controller.dart';
import '../data/career_repository.dart';

final _comparisonProvider = FutureProvider.family<List<Programme>, String>(
  (ref, ids) => ref
      .watch(careerRepositoryProvider)
      .compareProgrammes(ids.split(',').map(int.parse).toList()),
);

/// Two or three programmes, side by side.
///
/// The comparison is a table rather than three cards because the question is
/// always "how do these differ", and differences only read across a shared row.
/// The rows are the facts a dentist actually decides on — cost, length, entry
/// requirement, deadline — in that order.
///
/// A fact the record does not carry renders "Not listed" rather than a blank
/// cell, because a blank in a comparison reads as zero or as "none required",
/// and both would be wrong.
class CompareProgrammesScreen extends ConsumerWidget {
  const CompareProgrammesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final ids = ref.watch(programmeComparisonProvider);

    if (ids.isEmpty) {
      return Scaffold(
        appBar: EjadahAppBar(
          title: strings.compareTitle,
          onBack: () => context.pop(),
          backLabel: strings.back,
        ),
        body: SafeArea(
          top: false,
          child: EjadahEmptyState(
            title: strings.compareTitle,
            body: strings.programmesBlurb,
            actionLabel: strings.browseProgrammes,
            onAction: () => context.go('/programmes'),
          ),
        ),
      );
    }

    final comparison = ref.watch(_comparisonProvider(ids.join(',')));

    return Scaffold(
      appBar: EjadahAppBar(
        title: strings.compareTitle,
        onBack: () => context.pop(),
        backLabel: strings.back,
        action: EjadahGhostButton(
          label: strings.clearAll,
          onPressed: () {
            ref.read(programmeComparisonProvider.notifier).clear();
            context.pop();
          },
        ),
      ),
      body: SafeArea(
        top: false,
        child: comparison.when(
          loading: () => const EjadahPageBody(
            child: Column(
              children: [
                SizedBox(height: EjadahSpacing.md),
                CardSkeleton(),
              ],
            ),
          ),
          error: (error, _) => EjadahErrorState(
            title: FailureCopy.errorTitle(context),
            body: error is Failure
                ? error.message(context)
                : FailureCopy.server(context),
            retryLabel: strings.retry,
            onRetry: () => ref.invalidate(_comparisonProvider(ids.join(','))),
          ),
          data: (items) => _Table(items: items),
        ),
      ),
    );
  }
}

class _Table extends StatelessWidget {
  const _Table({required this.items});

  final List<Programme> items;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return EjadahPageBody(
      // The table scrolls both ways: three columns of dense facts do not fit a
      // phone, and squeezing them to fit is what makes a comparison unreadable.
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: EjadahSpacing.md),
              _HeaderRow(items: items),
              const SizedBox(height: EjadahSpacing.sm),
              _FactRow(
                label: strings.fRegion,
                values: [
                  for (final item in items)
                    '${item.summary.city} · ${item.summary.country}',
                ],
              ),
              _FactRow(
                label: strings.fTuition,
                values: [
                  for (final item in items)
                    item.summary.tuitionUsd == null
                        ? strings.notListed
                        : 'USD ${formatThousands(item.summary.tuitionUsd!)}',
                ],
                isLtr: true,
              ),
              _FactRow(
                label: strings.fDuration,
                values: [
                  for (final item in items)
                    item.minYears == null
                        ? strings.notListed
                        : '${item.minYears}–${item.maxYears ?? item.minYears}',
                ],
                isLtr: true,
              ),
              _FactRow(
                label: strings.fDegreeType,
                values: [
                  for (final item in items)
                    item.summary.degreeType.isEmpty
                        ? strings.notListed
                        : item.summary.degreeType,
                ],
              ),
              _FactRow(
                label: strings.fLanguage,
                values: [
                  for (final item in items)
                    item.language.isEmpty ? strings.notListed : item.language,
                ],
              ),
              _FactRow(
                label: strings.fDeadline,
                values: [
                  for (final item in items)
                    item.summary.daysRemaining == null
                        ? strings.notListed
                        : strings.daysLeftCount(item.summary.daysRemaining!),
                ],
              ),
              _FactRow(
                label: strings.fIelts,
                values: [
                  for (final item in items)
                    item.ieltsScore == null
                        ? strings.notListed
                        : '${item.ieltsScore}',
                ],
                isLtr: true,
              ),
              _FactRow(
                label: strings.fScholarship,
                values: [
                  for (final item in items)
                    switch (item.hasScholarship) {
                      true => strings.schYes,
                      false => strings.schNo,
                      null => strings.notListed,
                    },
                ],
              ),
              const SizedBox(height: EjadahSpacing.section),
            ],
          ),
        ),
      ),
    );
  }
}

/// The column width. Wide enough for a university name to breathe, narrow
/// enough that three fit on a tablet without scrolling.
const double _columnWidth = 168;

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.items});

  final List<Programme> items;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(width: _columnWidth * 0.7),
      for (final item in items)
        SizedBox(
          width: _columnWidth,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(end: EjadahSpacing.sm),
            child: GestureDetector(
              onTap: () => context.push('/programme/${item.id}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Institution names stay Latin in both languages.
                  CodeText(
                    item.summary.university,
                    style: context.type.bodyStrong(),
                  ),
                  const SizedBox(height: EjadahSpacing.xxs),
                  Text(
                    item.summary.programmeName,
                    style: context.type.small(
                      color: EjadahColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    ],
  );
}

class _FactRow extends StatelessWidget {
  const _FactRow({
    required this.label,
    required this.values,
    this.isLtr = false,
  });

  final String label;
  final List<String> values;

  /// Figures and codes read left-to-right in both languages.
  final bool isLtr;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: EjadahSpacing.xs),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: _columnWidth * 0.7,
          child: Text(
            context.type.eyebrowText(label),
            style: context.type.eyebrow(color: EjadahColors.labelMuted),
          ),
        ),
        for (final value in values)
          SizedBox(
            width: _columnWidth,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: EjadahSpacing.sm),
              child: isLtr
                  ? LtrIsland(child: Text(value, style: context.type.bodyText()))
                  : Text(value, style: context.type.bodyText()),
            ),
          ),
      ],
    ),
  );
}
