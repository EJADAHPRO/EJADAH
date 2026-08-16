import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/professional_list_controller.dart';
import '../data/people_repository.dart';
import 'widgets/professional_card.dart';

/// PE-02 — one marketplace door.
///
/// Filters persist across launches, per door. The "New this month" rail sits
/// above the results and is deliberately *not* narrowed by the filters: it
/// exists so a professional with no reviews yet gets a first booking, and
/// filtering it away would defeat the only mechanism that does that.
class ProfessionalListScreen extends ConsumerStatefulWidget {
  const ProfessionalListScreen({
    required this.kind,
    this.destinationIso,
    super.key,
  });

  final ServiceKind kind;

  /// Set when a country guide sent the user here, so "mentors who made this
  /// move" means this move.
  final String? destinationIso;

  @override
  ConsumerState<ProfessionalListScreen> createState() =>
      _ProfessionalListScreenState();
}

class _ProfessionalListScreenState
    extends ConsumerState<ProfessionalListScreen> {
  @override
  void initState() {
    super.initState();
    final iso = widget.destinationIso;
    if (iso != null) {
      Future.microtask(
        () => ref
            .read(professionalListControllerProvider(widget.kind).notifier)
            .showDestination(iso),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final kind = widget.kind;
    final strings = context.strings;
    final state = ref.watch(professionalListControllerProvider(kind));

    final title = switch (kind) {
      ServiceKind.tutoring => strings.peopleTutoringDoor,
      ServiceKind.mentoring => strings.peopleMentoringDoor,
      ServiceKind.consulting => strings.peopleConsultingDoor,
    };

    return GradientBudget(
      screenName: 'people-${kind.wire}',
      child: Scaffold(
        appBar: EjadahAppBar(
          title: title,
          backLabel: strings.back,
          onBack: () => context.pop(),
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: EjadahPageBody(
            // The group is what makes the stagger play once: it remembers, so
            // a row recycled back into view appears instead of re-animating.
            child: StaggerGroup(
              child: CustomScrollView(
                key: PageStorageKey('people-list-${kind.wire}'),
                slivers: [
                  SliverToBoxAdapter(
                    child: _FilterBar(kind: kind, state: state),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: EjadahSpacing.sm),
                  ),
                  ..._body(context, ref, state),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: EjadahSpacing.section),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _body(
    BuildContext context,
    WidgetRef ref,
    ProfessionalListState state,
  ) {
    final strings = context.strings;
    final controller = ref.read(
      professionalListControllerProvider(widget.kind).notifier,
    );

    return switch (state) {
      ProfessionalListLoading() => [
        SliverList.separated(
          itemCount: 4,
          separatorBuilder: (_, _) =>
              const SizedBox(height: EjadahSpacing.cardGap),
          itemBuilder: (_, _) => const ProfessionalCardSkeleton(),
        ),
      ],
      ProfessionalListFailed(:final failure) => [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EjadahErrorState(
            title: FailureCopy.errorTitle(context),
            body: failure.message(context),
            retryLabel: strings.retry,
            onRetry: controller.retry,
          ),
        ),
      ],
      final ProfessionalListReady ready when ready.isEmpty => [
        SliverToBoxAdapter(child: _NewThisMonthRail(result: ready.result)),
        SliverFillRemaining(
          hasScrollBody: false,
          child: EjadahEmptyState(
            title: strings.emptyMastersTitle,
            // Names what is actually wrong — the filters, not the roster.
            body: strings.noProfessionals,
            actionLabel: strings.clearFiltersAction,
            onAction: controller.clearFilters,
          ),
        ),
      ],
      final ProfessionalListReady ready => [
        SliverToBoxAdapter(child: _NewThisMonthRail(result: ready.result)),
        SliverToBoxAdapter(child: _ResultCount(page: ready.page)),
        const SliverToBoxAdapter(child: SizedBox(height: EjadahSpacing.xs)),
        SliverList.separated(
          itemCount: ready.page.items.length,
          separatorBuilder: (_, _) =>
              const SizedBox(height: EjadahSpacing.cardGap),
          itemBuilder: (context, index) {
            final professional = ready.page.items[index];
            return StaggeredIn(
              index: index,
              child: ProfessionalCard(
                professional: professional,
                onTap: () => context.push('/people/who/${professional.slug}'),
                onBook: () => context.push('/people/who/${professional.slug}'),
              ),
            );
          },
        ),
        SliverToBoxAdapter(
          child: _Pagination(kind: widget.kind, page: ready.page),
        ),
      ],
    };
  }
}

/// "1–12 of 40" — the list always states its own size.
class _ResultCount extends StatelessWidget {
  const _ResultCount({required this.page});

  final Paginated<Professional> page;

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: LtrIsland(
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

/// The cold-start rail.
///
/// Hidden entirely when nobody was approved this month — an empty rail with a
/// heading is worse than no rail.
class _NewThisMonthRail extends StatelessWidget {
  const _NewThisMonthRail({required this.result});

  final ProfessionalListPage result;

  @override
  Widget build(BuildContext context) {
    if (result.newThisMonth.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionHeader(title: context.strings.newThisMonth),
        const SizedBox(height: EjadahSpacing.xs),
        // The rail's height is whatever its tallest card needs, measured
        // rather than guessed. A fixed 172 fitted at normal type and clipped
        // the card at 200% — the name alone doubles, and the badges and rate
        // row with it.
        //
        // A `Row` in a horizontal scroll view rather than a horizontal
        // `ListView`, because `ListView` has no intrinsic height for
        // `IntrinsicHeight` to measure and would throw. The rail is a handful
        // of new tutors, so building them all is cheaper than the alternative.
        IntrinsicHeight(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (index, professional)
                    in result.newThisMonth.indexed) ...[
                  if (index > 0) const SizedBox(width: EjadahSpacing.cardGap),
                  SizedBox(
                    width: EjadahSizes.railCardWidth,
                    child: ProfessionalCard(
                      professional: professional,
                      onTap: () =>
                          context.push('/people/who/${professional.slug}'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: EjadahSpacing.md),
      ],
    );
  }
}

/// The persistent filter row.
class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.kind, required this.state});

  final ServiceKind kind;
  final ProfessionalListState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final controller = ref.read(
      professionalListControllerProvider(kind).notifier,
    );
    final (query, facets) = switch (state) {
      ProfessionalListReady(:final query, :final result) => (
        query,
        result.facets,
      ),
      ProfessionalListFailed(:final query) => (
        query,
        const <String, List<String>>{},
      ),
      _ => (ProfessionalQuery(kind: kind), const <String, List<String>>{}),
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          EjadahFilterChip(
            label: strings.filters,
            isSelected: query.hasActiveFilters,
            count: query.hasActiveFilters ? query.activeFilterCount : null,
            onTap: () => _openSheet(context, ref, query, facets),
          ),
          const SizedBox(width: EjadahSpacing.xs),
          EjadahFilterChip(
            label: strings.freeIntroCall,
            isSelected: query.freeIntroCallOnly,
            onTap: () => controller.applyFilters(
              query.copyWith(freeIntroCallOnly: !query.freeIntroCallOnly),
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

  Future<void> _openSheet(
    BuildContext context,
    WidgetRef ref,
    ProfessionalQuery query,
    Map<String, List<String>> facets,
  ) async {
    final applied = await showEjadahSheet<ProfessionalQuery>(
      context: context,
      builder: (context) => _FilterSheet(query: query, facets: facets),
    );
    if (applied != null) {
      await ref
          .read(professionalListControllerProvider(kind).notifier)
          .applyFilters(applied);
    }
  }
}

/// The filter sheet.
///
/// Built from the door's own facets, so it never offers a filter that matches
/// nobody. The destination group renders only for mentoring, because only a
/// mentor has a move to match on.
class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.query, required this.facets});

  final ProfessionalQuery query;
  final Map<String, List<String>> facets;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late ProfessionalQuery _draft = widget.query;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final destinations = widget.facets['destinations'] ?? const <String>[];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(strings.filters, style: context.type.h5()),
        const SizedBox(height: EjadahSpacing.md),
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FacetGroup(
                  label: strings.fSpecialty,
                  options: widget.facets['specialties'] ?? const [],
                  selected: _draft.specialties,
                  onChanged: (values) => setState(
                    () => _draft = _draft.copyWith(specialties: values),
                  ),
                ),
                _FacetGroup(
                  label: strings.fLanguage,
                  options: widget.facets['languages'] ?? const [],
                  selected: _draft.languages,
                  onChanged: (values) => setState(
                    () => _draft = _draft.copyWith(languages: values),
                  ),
                ),
                if (destinations.isNotEmpty)
                  _FacetGroup(
                    // A mentor is matched on the move they made — the
                    // destination, which is not the same facet as region.
                    label: strings.fDestination,
                    options: destinations,
                    selected: _draft.destinations,
                    onChanged: (values) => setState(
                      () => _draft = _draft.copyWith(destinations: values),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: EjadahSpacing.md),
        EjadahPrimaryButton(
          label: strings.continueAction,
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
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();

    return Column(
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
}

class _Pagination extends ConsumerWidget {
  const _Pagination({required this.kind, required this.page});

  final ServiceKind kind;
  final Paginated<Professional> page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (page.pageCount <= 1) return const SizedBox.shrink();
    final controller = ref.read(
      professionalListControllerProvider(kind).notifier,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: EjadahSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          EjadahIconButton(
            icon: EjadahIcons.chevronBack,
            semanticLabel: context.strings.back,
            onPressed: page.page > 1
                ? () => controller.goToPage(page.page - 1)
                : null,
            color: page.page > 1
                ? EjadahColors.textPrimary
                : EjadahColors.labelMuted,
          ),
          const SizedBox(width: EjadahSpacing.md),
          LtrIsland(
            child: Text(
              '${page.page} / ${page.pageCount}',
              style: context.type.tabular(),
            ),
          ),
          const SizedBox(width: EjadahSpacing.md),
          EjadahIconButton(
            icon: EjadahIcons.chevronForward,
            semanticLabel: context.strings.continueAction,
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
