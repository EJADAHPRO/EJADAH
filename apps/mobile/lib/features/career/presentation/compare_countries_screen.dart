import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/compare_controller.dart';
import '../data/career_repository.dart';

final _comparisonProvider = FutureProvider.family<List<CountryGuide>, String>(
  (ref, isos) =>
      ref.watch(careerRepositoryProvider).compareCountries(isos.split(',')),
);

/// Two or three country guides, side by side.
///
/// The rows are the four things that decide a destination: which exam, how
/// long, how hard, and what it costs at the floor. A cost floor that is
/// incomplete says so rather than looking cheap — the same rule the roadmap
/// engine applies when it withholds the budget bonus from an undocumented
/// destination.
class CompareCountriesScreen extends ConsumerWidget {
  const CompareCountriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final isos = ref.watch(countryComparisonProvider);

    if (isos.isEmpty) {
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
            body: strings.countriesBlurb,
            actionLabel: strings.tileCountries,
            onAction: () => context.go('/countries'),
          ),
        ),
      );
    }

    final comparison = ref.watch(_comparisonProvider(isos.join(',')));

    return Scaffold(
      appBar: EjadahAppBar(
        title: strings.compareTitle,
        onBack: () => context.pop(),
        backLabel: strings.back,
        action: EjadahGhostButton(
          label: strings.clearAll,
          onPressed: () {
            ref.read(countryComparisonProvider.notifier).clear();
            context.pop();
          },
        ),
      ),
      body: SafeArea(
        top: false,
        child: comparison.when(
          loading: () => const EjadahPageBody(
            child: Column(
              children: [SizedBox(height: EjadahSpacing.md), CardSkeleton()],
            ),
          ),
          error: (error, _) => EjadahErrorState(
            title: FailureCopy.errorTitle(context),
            body: error is Failure
                ? error.message(context)
                : FailureCopy.server(context),
            retryLabel: strings.retry,
            onRetry: () => ref.invalidate(_comparisonProvider(isos.join(','))),
          ),
          data: (items) => _Table(items: items),
        ),
      ),
    );
  }
}

/// Wide enough for a regulator's full name to wrap to two lines.
const double _columnWidth = 168;

class _Table extends StatelessWidget {
  const _Table({required this.items});

  final List<CountryGuide> items;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return EjadahPageBody(
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: EjadahSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: _columnWidth * 0.7),
                  for (final guide in items)
                    SizedBox(
                      width: _columnWidth,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(
                          end: EjadahSpacing.sm,
                        ),
                        child: GestureDetector(
                          onTap: () =>
                              context.push('/country/${guide.summary.iso}'),
                          child: Text(
                            guide.summary.name(context),
                            style: context.type.bodyStrong(),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: EjadahSpacing.sm),
              _FactRow(
                label: strings.examLabel,
                // Exam codes stay Latin in both languages.
                values: [for (final g in items) g.summary.examCode],
                isLtr: true,
              ),
              _FactRow(
                label: strings.pathwayLabel,
                values: [
                  for (final g in items) g.summary.pathwayClassLabel(context),
                ],
              ),
              _FactRow(
                label: strings.timeLabel,
                values: [for (final g in items) g.summary.monthsLabel],
                isLtr: true,
              ),
              _FactRow(
                label: strings.difficultyLabel,
                values: [for (final g in items) g.summary.difficulty(context)],
              ),
              _FactRow(
                label: strings.estCost,
                values: [
                  for (final g in items)
                    // An unsourced floor is not a low floor. Saying so here is
                    // the same rule the roadmap engine enforces in its scoring.
                    g.summary.floorCostUsd == null
                        ? strings.pendingSource
                        : 'USD ${formatThousands(g.summary.floorCostUsd!)}+',
                ],
                isLtr: true,
              ),
              _FactRow(
                label: strings.authorityLabel,
                values: [for (final g in items) g.authority(context)],
              ),
              const SizedBox(height: EjadahSpacing.section),
            ],
          ),
        ),
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({
    required this.label,
    required this.values,
    this.isLtr = false,
  });

  final String label;
  final List<String> values;
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
