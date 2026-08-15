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
///
/// CR-15: filter chips and a live count. The chips filter by pathway class —
/// how a country actually lets a foreign dentist in — because that is the
/// question a dentist is really asking, and because the label is bilingual in
/// the dataset itself.
///
/// There are deliberately no region chips: the dataset's regions ("Oceania",
/// "Middle East") exist in English only, and inventing Arabic names for them
/// would be exactly the manufactured data this product refuses to print.
class CountriesScreen extends ConsumerStatefulWidget {
  const CountriesScreen({super.key});

  @override
  ConsumerState<CountriesScreen> createState() => _CountriesScreenState();
}

class _CountriesScreenState extends ConsumerState<CountriesScreen> {
  PathwayClass? _pathway;

  @override
  Widget build(BuildContext context) {
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
            data: (items) {
              final classes =
                  items.map((guide) => guide.pathwayClass).toSet().toList()
                    ..sort((a, b) => a.index.compareTo(b.index));
              final visible = _pathway == null
                  ? items
                  : items
                        .where((guide) => guide.pathwayClass == _pathway)
                        .toList();

              return CustomScrollView(
                key: const PageStorageKey('countries'),
                slivers: [
                  SliverToBoxAdapter(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final pathway in classes) ...[
                            EjadahFilterChip(
                              // The label comes from the guide's own data, so
                              // it is right in both languages without a
                              // translation table to drift from.
                              label: items
                                  .firstWhere(
                                    (guide) => guide.pathwayClass == pathway,
                                  )
                                  .pathwayClassLabel(context),
                              isSelected: _pathway == pathway,
                              // Tapping the active chip clears it, so the
                              // filter is never a one-way door.
                              onTap: () => setState(
                                () => _pathway = _pathway == pathway
                                    ? null
                                    : pathway,
                              ),
                            ),
                            const SizedBox(width: EjadahSpacing.xs),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: EjadahSpacing.sm,
                      ),
                      // The count moves with the chips — a filter that does not
                      // say what it did is a filter the user has to count.
                      child: Text(
                        strings.guidesCount(visible.length),
                        style: context.type.small(
                          color: EjadahColors.labelMuted,
                        ),
                      ),
                    ),
                  ),
                  SliverCardGrid(
                    itemCount: visible.length,
                    itemBuilder: (context, index) =>
                        _CountryCard(guide: visible[index]),
                  ),
                ],
              );
            },
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
