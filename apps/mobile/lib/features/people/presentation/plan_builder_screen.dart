import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
// The booking components are not yet exported from the `ejadah_ui` barrel; the
// export is owned by whoever assembles that file.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/plan_controller.dart';
import 'widgets/cairo_time.dart';
import 'widgets/slot_grid.dart';

/// PE-05 — the custom plan builder.
///
/// Cadence dials, then a week stepper: fill week 1, tick, advance. The one
/// question this screen must never ask is the aggregate one — "how many hours
/// do you want in total?" makes the student do the scheduling arithmetic the
/// product exists to do for them.
///
/// "Same time every week" copies week one forward and **reports** the weeks it
/// could not fill. Submit stays disabled, with the reason named, until every
/// week is placed.
class PlanBuilderScreen extends ConsumerWidget {
  const PlanBuilderScreen({
    required this.professional,
    required this.onSubmit,
    super.key,
  });

  final Professional professional;

  /// Handed the placed plan. Confirmation itself belongs to the booking flow.
  final void Function(PlanState plan) onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final state = ref.watch(planControllerProvider(professional));
    final controller = ref.read(planControllerProvider(professional).notifier);
    final week = state.weeks[state.currentWeek];

    return GradientBudget(
      screenName: 'plan-builder',
      child: Scaffold(
        appBar: EjadahAppBar(
          title: strings.plansTitle,
          backLabel: strings.back,
          onBack: () => Navigator.of(context).pop(),
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: EjadahPageBody(
            child: ListView(
              key: const PageStorageKey('plan-builder'),
              children: [
                const SizedBox(height: EjadahSpacing.md),
                _Cadence(state: state, controller: controller),
                const SizedBox(height: EjadahSpacing.md),
                _Quote(state: state),
                const SizedBox(height: EjadahSpacing.section),
                WeekStepper(
                  weeks: [
                    for (final item in state.weeks)
                      WeekStep(
                        label: strings.weekLabel(item.index + 1),
                        isComplete: item.isComplete(state.sessionsPerWeek),
                        statusLine: _statusLine(context, state, item),
                      ),
                  ],
                  currentWeek: state.currentWeek,
                  onSelectWeek: controller.selectWeek,
                  statusLabel: strings.weekLabel(state.currentWeek + 1),
                ),
                const SizedBox(height: EjadahSpacing.md),
                EjadahSecondaryButton(
                  label: strings.pickAnotherWeek,
                  expand: false,
                  onPressed: state.weeks.first.chosen.isEmpty
                      ? null
                      : controller.copyFirstWeekForward,
                  // Copying forward needs something to copy. Saying so beats a
                  // control whose precondition is invisible.
                  disabledReason: strings.pickWeekOneFirst,
                  onDisabledTap: (reason) =>
                      showEjadahToast(context, message: reason),
                ),
                const SizedBox(height: EjadahSpacing.md),
                if (week.isLoading)
                  const SlotGridSkeleton()
                else if (week.failure != null)
                  EjadahErrorState(
                    title: FailureCopy.errorTitle(context),
                    body: week.failure!.message(context),
                    retryLabel: strings.retry,
                    onRetry: () => controller.loadWeek(week.index),
                  )
                else if (!week.slots.any((slot) => slot.isAvailable))
                  EjadahEmptyState(
                    title: strings.noSlots,
                    body: strings.pickAnotherWeek,
                    actionLabel: strings.pickAnotherWeek,
                    onAction: () => controller.selectWeek(
                      (week.index + 1).clamp(0, state.weekCount - 1),
                    ),
                  )
                else
                  SlotGrid(
                    slots: week.slots,
                    selected: week.chosen.isEmpty ? null : week.chosen.last,
                    onSelect: controller.toggleSlot,
                  ),
                const SizedBox(height: EjadahSpacing.section),
              ],
            ),
          ),
        ),
        bottomNavigationBar: EjadahStickyBar(
          background: EjadahColors.background,
          // Named, not merely disabled: "fill week 3" beats a grey button
          // that does nothing, and it is on screen rather than behind a tap.
          reason: state.isComplete
              ? null
              : strings.weekLabel(state.filledWeeks + 1),
          child: EjadahPrimaryButton(
            label: strings.continueAction,
            onPressed: state.isComplete ? () => onSubmit(state) : null,
            disabledReason: strings.weekLabel(state.filledWeeks + 1),
            onDisabledTap: (reason) =>
                showEjadahToast(context, message: reason),
          ),
        ),
      ),
    );
  }

  /// The server's own words where there are any; otherwise what this week
  /// still needs.
  String _statusLine(BuildContext context, PlanState state, PlanWeek week) {
    final strings = context.strings;
    if (week.unfillable) return strings.noSlots;
    if (week.isComplete(state.sessionsPerWeek)) {
      return CairoTime.stamp(week.chosen.first.startsAt);
    }
    return strings.pickSlotFirst;
  }
}

/// The cadence dials: sessions a week, how long, for how many weeks.
class _Cadence extends StatelessWidget {
  const _Cadence({required this.state, required this.controller});

  final PlanState state;
  final PlanController controller;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _Dial(
          label: strings.sessionsLabel,
          options: const [1, 2, 3],
          value: state.sessionsPerWeek,
          onChanged: controller.setSessionsPerWeek,
        ),
        const SizedBox(height: EjadahSpacing.sm),
        _Dial(
          label: strings.durationLabel,
          options: const [30, 60, 90],
          value: state.sessionMinutes,
          onChanged: controller.setSessionMinutes,
        ),
        const SizedBox(height: EjadahSpacing.sm),
        _Dial(
          label: strings.weekLabel(state.weekCount),
          options: const [4, 8, 12],
          value: state.weekCount,
          onChanged: controller.setWeekCount,
        ),
      ],
    );
  }
}

class _Dial extends StatelessWidget {
  const _Dial({
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final List<int> options;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        context.type.eyebrowText(label),
        style: context.type.eyebrow(color: EjadahColors.labelMuted),
      ),
      const SizedBox(height: EjadahSpacing.xxs),
      Wrap(
        spacing: EjadahSpacing.xs,
        runSpacing: EjadahSpacing.xs,
        children: [
          for (final option in options)
            EjadahFilterChip(
              // Western digits in both languages.
              label: '$option',
              isSelected: option == value,
              onTap: () => onChanged(option),
            ),
        ],
      ),
    ],
  );
}

/// The live quote, and the plan's own sentence about itself.
class _Quote extends StatelessWidget {
  const _Quote({required this.state});

  final PlanState state;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return EjadahCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              LtrIsland(
                child: Text(
                  '${state.totalSessions}',
                  style: context.type.bodyStrong(),
                ),
              ),
              const SizedBox(width: EjadahSpacing.xxs),
              Text(
                strings.sessionsLabel,
                style: context.type.small(color: EjadahColors.textSecondary),
              ),
              const Spacer(),
              CurrencyText(
                amount: state.quotedEgp,
                currency: 'EGP',
                style: context.type.bodyStrong(),
              ),
            ],
          ),
          const SizedBox(height: EjadahSpacing.xxs),
          Text(
            strings.payNoteExternal,
            style: context.type.micro(color: EjadahColors.labelMuted),
          ),
          if (state.unfillableWeeks.isNotEmpty) ...[
            const SizedBox(height: EjadahSpacing.sm),
            // Named, not silently dropped.
            InlineAlert(
              title: strings.pickAnotherWeek,
              message: state.unfillableWeeks
                  .map((week) => strings.weekLabel(week))
                  .join(' · '),
            ),
          ],
        ],
      ),
    );
  }
}
