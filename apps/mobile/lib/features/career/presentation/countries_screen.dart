import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/career_repository.dart';

final countriesProvider = FutureProvider<List<CountryGuideSummary>>(
  (ref) => ref.watch(careerRepositoryProvider).countries(),
);

/// The 23 country licensing guides.
class CountriesScreen extends ConsumerWidget {
  const CountriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final guides = ref.watch(countriesProvider);

    return Scaffold(
      appBar: EjadahAppBar(
        title: strings.tileCountries,
        onBack: () => context.pop(),
        backLabel: strings.back,
      ),
      body: SafeArea(
        top: false,
        child: EjadahPageBody(
          child: guides.when(
            loading: () => ListView.separated(
              itemCount: 5,
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
              onRetry: () => ref.invalidate(countriesProvider),
            ),
            // 1 → 2 → 3 columns with the window, single-column on a phone.
            data: (items) => CustomScrollView(
              key: const PageStorageKey('countries'),
              slivers: [
                SliverCardGrid(
                  itemCount: items.length,
                  itemBuilder: (context, index) =>
                      _CountryCard(guide: items[index]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The canonical country card.
class _CountryCard extends StatelessWidget {
  const _CountryCard({required this.guide});

  final CountryGuideSummary guide;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return EjadahCard(
      onTap: () => context.push('/country/${guide.iso}'),
      semanticLabel: guide.name(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(guide.name(context), style: context.type.h6()),
              ),
              // Exam codes stay Latin in both languages.
              CodeText(
                guide.examCode,
                style: context.type.caption(color: EjadahColors.warningText),
              ),
            ],
          ),
          const SizedBox(height: EjadahSpacing.xs),
          Wrap(
            spacing: EjadahSpacing.xs,
            runSpacing: EjadahSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              EjadahTag(guide.pathwayClassLabel(context)),
              RangeText(
                from: guide.minMonths,
                to: guide.maxMonths,
                suffix: strings.monthsTypical,
                style: context.type.tabular(fontSize: EjadahTypeSize.caption),
              ),
              EjadahTag(guide.difficulty(context)),
            ],
          ),
        ],
      ),
    );
  }
}
