import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/auth_controller.dart';
import '../application/compare_controller.dart';
import '../application/programmes_controller.dart';
import '../data/career_repository.dart';
import 'widgets/programme_card.dart';

/// The programme database — 199 records, twelve to a page.
///
/// Every state the design requires is here: skeleton while loading, results,
/// a zero-result state that offers the nearest relaxation, and a failure that
/// retries. None of them is a spinner on an empty screen.
class ProgrammesScreen extends ConsumerStatefulWidget {
  const ProgrammesScreen({this.countryIso, super.key});

  /// Set when a country guide sent the user here. The list opens filtered to
  /// that country, so the crossing lands on results rather than on all 199.
  final String? countryIso;

  @override
  ConsumerState<ProgrammesScreen> createState() => _ProgrammesScreenState();
}

class _ProgrammesScreenState extends ConsumerState<ProgrammesScreen> {
  final TextEditingController _search = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    final iso = widget.countryIso;
    if (iso != null) {
      Future.microtask(
        () => ref.read(programmesControllerProvider.notifier).showCountry(iso),
      );
    }
  }

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final state = ref.watch(programmesControllerProvider);

    return GradientBudget(
      screenName: 'programmes',
      child: Scaffold(
        // Appears only once something is selected, so the bar is never a
        // permanent tax on the list's height.
        bottomNavigationBar: const _CompareBar(),
        body: SafeArea(
          bottom: false,
          child: EjadahPageBody(
            child: CustomScrollView(
              // Per-tab scroll position is restored when the user returns.
              key: const PageStorageKey('programmes'),
              controller: _scroll,
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: EjadahSpacing.md),
                      PageHeader(
                        eyebrow: strings.mastersEyebrow,
                        title: strings.mastersTitle,
                      ),
                      const SizedBox(height: EjadahSpacing.md),
                      EjadahSearchField(
                        controller: _search,
                        hint: strings.searchPlaceholder,
                        clearLabel: strings.clearField,
                        onSubmitted: (value) => ref
                            .read(programmesControllerProvider.notifier)
                            .search(value),
                      ),
                      const SizedBox(height: EjadahSpacing.sm),
                      _FilterBar(state: state),
                      const SizedBox(height: EjadahSpacing.sm),
                    ],
                  ),
                ),
                ..._slivers(context, state),
                const SliverToBoxAdapter(
                  child: SizedBox(height: EjadahSpacing.section),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _slivers(BuildContext context, ProgrammesState state) =>
      switch (state) {
        ProgrammesLoading() => [
          // Shapes of the coming content, not a spinner.
          SliverList.separated(
            itemCount: 4,
            separatorBuilder: (_, _) =>
                const SizedBox(height: EjadahSpacing.cardGap),
            itemBuilder: (_, _) => const CardSkeleton(),
          ),
        ],
        ProgrammesFailed(:final failure) => [
          SliverFillRemaining(
            hasScrollBody: false,
            child: EjadahErrorState(
              title: FailureCopy.errorTitle(context),
              body: failure.message(context),
              retryLabel: context.strings.retry,
              onRetry: () =>
                  ref.read(programmesControllerProvider.notifier).retry(),
            ),
          ),
        ],
        final ProgrammesReady ready when ready.isEmpty => [
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyResults(state: ready),
          ),
        ],
        final ProgrammesReady ready => [
          SliverToBoxAdapter(child: _ResultCount(page: ready.page)),
          const SliverToBoxAdapter(child: SizedBox(height: EjadahSpacing.xs)),
          // 1 → 2 → 3 columns with the window. On a phone this is the same
          // single-column list it has always been.
          SliverCardGrid(
            itemCount: ready.page.items.length,
            itemBuilder: (context, index) {
              final programme = ready.page.items[index];
              return ProgrammeCard(
                programme: programme,
                onTap: () => context.push('/programme/${programme.id}'),
                onToggleSave: () => _toggleSave(programme),
                isCompareSelected: ref
                    .watch(programmeComparisonProvider)
                    .contains(programme.id),
                onToggleCompare: () => _toggleCompare(programme.id),
              );
            },
          ),
          SliverToBoxAdapter(child: _Pagination(page: ready.page)),
        ],
      };

  void _toggleCompare(int id) {
    final accepted = ref
        .read(programmeComparisonProvider.notifier)
        .toggle(id);
    if (accepted) return;
    // A tap that does nothing has to say why. Three is a design limit, not a
    // technical one, and the user cannot see it from the card.
    showEjadahToast(
      context,
      message: context.strings.compareLimit(maxComparisonItems),
    );
  }

  Future<void> _toggleSave(ProgrammeSummary programme) async {
    // Saving is one of the five gates. A guest is taken to sign-up and comes
    // straight back to this list.
    if (!ref.read(authControllerProvider).isAuthenticated) {
      final signedIn = await context.push<bool>('/sign-up?intent=save');
      if (signedIn != true) return;
    }

    try {
      final saved = await ref
          .read(programmesControllerProvider.notifier)
          .toggleSaved(programme);
      if (!mounted) return;

      showEjadahToast(
        context,
        message: saved
            ? context.strings.savedToast
            : context.strings.undoRemove,
        undoLabel: saved ? null : context.strings.undo,
        // Removal is reversible for five seconds.
        onUndo: saved
            ? null
            : () => ref
                  .read(programmesControllerProvider.notifier)
                  .toggleSaved(programme.copyWith(isSaved: false)),
      );
    } on Failure catch (failure) {
      if (!mounted) return;
      showEjadahToast(context, message: failure.message(context));
    }
  }
}

/// "1–12 of 199" — the list always states its own size.
class _ResultCount extends StatelessWidget {
  const _ResultCount({required this.page});

  final Paginated<ProgrammeSummary> page;

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.ltr,
    child: Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        context.strings.showingRange(
          page.firstIndex,
          page.lastIndex,
          page.total,
        ),
        style: context.type.micro(color: EjadahColors.labelMuted),
      ),
    ),
  );
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.state});

  final ProgrammesState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final query = switch (state) {
      ProgrammesReady(:final query) => query,
      ProgrammesFailed(:final query) => query,
      _ => const ProgrammeQuery(),
    };
    final controller = ref.read(programmesControllerProvider.notifier);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          EjadahFilterChip(
            label: query.activeFilterCount > 0
                ? '${strings.filters} (${query.activeFilterCount})'
                : strings.filters,
            isSelected: query.activeFilterCount > 0,
            onTap: () => _openFilterSheet(context, ref, query),
          ),
          const SizedBox(width: EjadahSpacing.xs),
          // Expired intakes are hidden by default: 150 of 199 have passed, and
          // leading with them makes a live database look dead.
          EjadahFilterChip(
            label: query.showExpired
                ? strings.showExpired
                : strings.hideExpired,
            isSelected: query.showExpired,
            onTap: () => controller.applyFilters(
              query.copyWith(showExpired: !query.showExpired),
            ),
          ),
          if (query.hasActiveFilters) ...[
            const SizedBox(width: EjadahSpacing.xs),
            EjadahGhostButton(
              label: strings.clearAll,
              onPressed: controller.clearFilters,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openFilterSheet(
    BuildContext context,
    WidgetRef ref,
    ProgrammeQuery query,
  ) async {
    final applied = await showEjadahSheet<ProgrammeQuery>(
      context: context,
      builder: (context) => _FilterSheet(query: query),
    );
    if (applied != null) {
      await ref
          .read(programmesControllerProvider.notifier)
          .applyFilters(applied);
    }
  }
}

/// The zero-result state.
///
/// It names the nearest relaxation and offers it as a tap, because an empty
/// state that does not route anywhere is a dead end.
class _EmptyResults extends ConsumerWidget {
  const _EmptyResults({required this.state});

  final ProgrammesReady state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final relaxation = state.relaxation;
    final controller = ref.read(programmesControllerProvider.notifier);

    if (relaxation == null) {
      return EjadahEmptyState(
        title: strings.emptyMastersTitle,
        body: strings.emptyMastersBody,
        actionLabel: strings.clearAll,
        onAction: controller.clearFilters,
      );
    }

    return EjadahEmptyState(
      title: strings.emptyMastersTitle,
      body: strings.noResultsNearest(relaxation.label(context)),
      actionLabel: '${relaxation.label(context)} (${relaxation.resultCount})',
      onAction: () => controller.relax(relaxation),
    );
  }
}

class _Pagination extends ConsumerWidget {
  const _Pagination({required this.page});

  final Paginated<ProgrammeSummary> page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (page.pageCount <= 1) return const SizedBox.shrink();
    final controller = ref.read(programmesControllerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: EjadahSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          EjadahIconButton(
            // Mirrors in Arabic — "previous" is on the reading-start side.
            icon: EjadahIcons.chevronBack,
            semanticLabel: context.strings.previousPage,
            onPressed: page.page > 1
                ? () => controller.goToPage(page.page - 1)
                : null,
            color: page.page > 1
                ? EjadahColors.textPrimary
                : EjadahColors.labelMuted,
          ),
          const SizedBox(width: EjadahSpacing.md),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              '${page.page} / ${page.pageCount}',
              style: context.type.tabular(),
            ),
          ),
          const SizedBox(width: EjadahSpacing.md),
          EjadahIconButton(
            icon: EjadahIcons.chevronForward,
            semanticLabel: context.strings.nextPage,
            onPressed: page.hasMore
                ? () => controller.goToPage(page.page + 1)
                : null,
            color: page.hasMore
                ? EjadahColors.textPrimary
                : EjadahColors.labelMuted,
          ),
        ],
      ),
    );
  }
}

/// The filter sheet.
///
/// A sheet carries options and filters — never a long form. Applying resets to
/// page one and persists the selection across launches.
class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet({required this.query});

  final ProgrammeQuery query;

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late ProgrammeQuery _draft = widget.query;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final facets = ref.watch(filterFacetsProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(strings.filterSheetTitle, style: context.type.h5()),
        const SizedBox(height: EjadahSpacing.md),
        Flexible(
          child: SingleChildScrollView(
            child: facets.when(
              loading: () => const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton.line(width: 120),
                  SizedBox(height: EjadahSpacing.xs),
                  Skeleton(width: double.infinity, height: 36),
                ],
              ),
              error: (_, _) => Text(
                FailureCopy.generic(context),
                style: context.type.small(color: EjadahColors.dangerText),
              ),
              data: (data) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FacetGroup(
                    label: strings.fSpecialty,
                    options: data['specialties'] ?? const [],
                    selected: _draft.specialties,
                    onChanged: (values) => setState(
                      () => _draft = _draft.copyWith(specialties: values),
                    ),
                  ),
                  _FacetGroup(
                    label: strings.fRegion,
                    options: data['regions'] ?? const [],
                    selected: _draft.regions,
                    onChanged: (values) => setState(
                      () => _draft = _draft.copyWith(regions: values),
                    ),
                  ),
                  _FacetGroup(
                    label: strings.fDegreeType,
                    options: data['degree_types'] ?? const [],
                    selected: _draft.degreeTypes,
                    onChanged: (values) => setState(
                      () => _draft = _draft.copyWith(degreeTypes: values),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: EjadahSpacing.md),
        EjadahPrimaryButton(
          label: strings.showResults,
          onPressed: () => Navigator.of(context).pop(_draft),
        ),
      ],
    );
  }
}

class _FacetGroup extends StatelessWidget {
  const _FacetGroup({
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final List<String> options;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        context.type.eyebrowText(label),
        style: context.type.eyebrow(color: EjadahColors.labelMuted),
      ),
      const SizedBox(height: EjadahSpacing.xs),
      Wrap(
        spacing: EjadahSpacing.xs,
        runSpacing: EjadahSpacing.xs,
        children: [
          for (final option in options)
            EjadahFilterChip(
              label: option,
              isSelected: selected.contains(option),
              onTap: () => onChanged(
                selected.contains(option)
                    ? (selected.toList()..remove(option))
                    : [...selected, option],
              ),
            ),
        ],
      ),
      const SizedBox(height: EjadahSpacing.md),
    ],
  );
}

/// The filter options the database actually contains, so the sheet never offers
/// a filter that matches nothing.
final filterFacetsProvider = FutureProvider<Map<String, List<String>>>(
  (ref) => ref.watch(careerRepositoryProvider).filterFacets(),
);


/// The compare bar: how many are picked, and the way to see them side by side.
///
/// Selection survives paging, filtering and searching, which is why it is worth
/// a persistent bar rather than a mode — picking one programme on page 1 and
/// another on page 4 is the normal way this gets used.
class _CompareBar extends ConsumerWidget {
  const _CompareBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(programmeComparisonProvider);
    if (selected.isEmpty) return const SizedBox.shrink();

    final strings = context.strings;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(EjadahSpacing.gutter),
        child: Row(
          children: [
            LtrIsland(
              child: Text(
                '${selected.length}/$maxComparisonItems',
                style: context.type.tabular(),
              ),
            ),
            const SizedBox(width: EjadahSpacing.xxs),
            Text(
              strings.compareCount,
              style: context.type.small(color: EjadahColors.textSecondary),
            ),
            const Spacer(),
            EjadahGhostButton(
              label: strings.clearAll,
              onPressed: () =>
                  ref.read(programmeComparisonProvider.notifier).clear(),
            ),
            const SizedBox(width: EjadahSpacing.xs),
            EjadahSecondaryButton(
              label: strings.compareCta,
              expand: false,
              // Two is the fewest that can differ from each other.
              onPressed: selected.length >= 2
                  ? () => context.push('/compare/programmes')
                  : null,
              disabledReason: strings.compareNeedsTwo,
              onDisabledTap: (reason) =>
                  showEjadahToast(context, message: reason),
            ),
          ],
        ),
      ),
    );
  }
}
