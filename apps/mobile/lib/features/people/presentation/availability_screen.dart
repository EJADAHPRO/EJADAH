import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/availability_controller.dart';
import '../data/availability_repository.dart';
import 'widgets/cairo_time.dart';

/// PE-14 — the availability editor.
///
/// Two halves, and they answer different questions. **Every week** is the shape
/// of an ordinary week: seven day rows, three preset blocks each, custom hours
/// where the presets do not fit. **Time off** is the exceptions to it — the
/// conference, the fortnight away — which is a different thought and lives in a
/// different section rather than as a mode on the same grid.
///
/// The rule that shapes everything else: **removing time somebody has booked is
/// refused, and the sessions are named.** A tutor who blocks a week for travel
/// is shown which students they would be standing up, because the alternative
/// is that the students find out by turning up to an empty call. Cancelling is
/// still possible — through the cancellation flow, which refunds and tells them.
class AvailabilityScreen extends ConsumerWidget {
  const AvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final state = ref.watch(availabilityControllerProvider);

    return GradientBudget(
      screenName: 'availability',
      child: Scaffold(
        appBar: EjadahAppBar(
          title: strings.availabilityTitle,
          backLabel: strings.back,
          onBack: () =>
              context.canPop() ? context.pop() : context.go('/teach/status'),
        ),
        bottomNavigationBar: state.whenOrNull(
          data: (draft) => EjadahStickyBar(
            // Below the floor this is not a suggestion — it is what will make
            // the tutor invisible, said before the save rather than after.
            reason: draft.meetsFloor
                ? null
                : strings.availabilityFloorHint(
                    draft.saved.minimumWeeklyHours,
                  ),
            child: EjadahPrimaryButton(
              label: strings.saveHours,
              isLoading: draft.isSaving,
              onPressed: draft.isDirty ? () => _save(context, ref) : null,
              disabledReason: strings.availabilitySaved,
              onDisabledTap: (reason) =>
                  showEjadahToast(context, message: reason),
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: switch (state) {
            AsyncData(:final value) => _Editor(draft: value),
            AsyncError(:final error) => EjadahErrorState(
              title: FailureCopy.errorTitle(context),
              body: error is Failure
                  ? error.message(context)
                  : FailureCopy.generic(context),
              retryLabel: strings.retry,
              onRetry: () =>
                  ref.read(availabilityControllerProvider.notifier).refresh(),
            ),
            _ => const _AvailabilitySkeleton(),
          },
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context, WidgetRef ref) async {
    final clash = await ref
        .read(availabilityControllerProvider.notifier)
        .save();
    if (!context.mounted) return;
    if (clash == null) {
      showEjadahToast(context, message: context.strings.availabilitySaved);
      return;
    }
    await showClashSheet(context, clash);
  }
}

/// Lists the sessions a change would have stranded.
///
/// A sheet rather than a toast: this is a list of people, and a toast that
/// disappears in four seconds is not where you put the names of students
/// somebody is about to stand up.
Future<void> showClashSheet(
  BuildContext context,
  AvailabilityClash clash,
) async {
  final strings = context.strings;
  await showEjadahSheet<void>(
    context: context,
    screenName: 'availability-clash',
    builder: (sheetContext) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(strings.clashTitle, style: sheetContext.type.h4()),
        const SizedBox(height: EjadahSpacing.xs),
        Text(
          clash.message(sheetContext),
          style: sheetContext.type.bodyText(color: EjadahColors.textSecondary),
        ),
        const SizedBox(height: EjadahSpacing.md),
        for (final session in clash.sessions)
          Padding(
            padding: const EdgeInsets.only(bottom: EjadahSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  EjadahIcons.calendar,
                  size: EjadahIconSize.inline,
                  color: EjadahColors.warningText,
                ),
                const SizedBox(width: EjadahSpacing.xs),
                Expanded(
                  child: Text(
                    session(sheetContext),
                    style: sheetContext.type.bodyText(),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: EjadahSpacing.md),
        EjadahSecondaryButton(
          label: strings.back,
          onPressed: () => Navigator.of(sheetContext).pop(),
        ),
        const SizedBox(height: EjadahSpacing.sm),
      ],
    ),
  );
}

class _Editor extends ConsumerWidget {
  const _Editor({required this.draft});

  final AvailabilityDraft draft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final type = context.type;

    return ListView(
      key: const PageStorageKey('availability'),
      padding: const EdgeInsets.only(bottom: EjadahSpacing.lg),
      children: [
        EjadahPageBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: EjadahSpacing.md),
              PageHeader(
                title: strings.availabilityTitle,
                subtitle: strings.availabilityLead,
              ),
              const SizedBox(height: EjadahSpacing.lg),

              SectionHeader(title: strings.weeklyShapeTitle),
              const SizedBox(height: EjadahSpacing.xs),
              for (var weekday = 0; weekday < 7; weekday++)
                Padding(
                  padding: const EdgeInsets.only(bottom: EjadahSpacing.sm),
                  child: _DayRow(weekday: weekday, draft: draft),
                ),

              const SizedBox(height: EjadahSpacing.sm),
              Text(
                strings.availabilityWeeklyTotal(draft.weeklyHours),
                style: type.bodyText(),
              ),
              const SizedBox(height: EjadahSpacing.xxs),
              Text(
                strings.availabilityFloorHint(draft.saved.minimumWeeklyHours),
                style: type.caption(
                  color: draft.meetsFloor
                      ? EjadahColors.textSecondary
                      : EjadahColors.warningText,
                ),
              ),

              const SizedBox(height: EjadahSpacing.xl),
              SectionHeader(title: strings.timeOffTitle),
              const SizedBox(height: EjadahSpacing.xxs),
              Text(
                strings.timeOffLead,
                style: type.caption(color: EjadahColors.textSecondary),
              ),
              const SizedBox(height: EjadahSpacing.sm),
              if (draft.saved.exceptions.isEmpty)
                Text(
                  strings.timeOffNone,
                  style: type.bodyText(color: EjadahColors.textSecondary),
                )
              else
                for (final exception in draft.saved.exceptions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: EjadahSpacing.xs),
                    child: _ExceptionRow(exception: exception),
                  ),
              const SizedBox(height: EjadahSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: EjadahSecondaryButton(
                      label: strings.addTimeOff,
                      onPressed: () => _pickPeriod(context, ref, block: true),
                    ),
                  ),
                  const SizedBox(width: EjadahSpacing.sm),
                  Expanded(
                    child: EjadahGhostButton(
                      label: strings.openExtraHours,
                      onPressed: () => _pickPeriod(context, ref, block: false),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Picks a date range, then blocks or opens it.
  Future<void> _pickPeriod(
    BuildContext context,
    WidgetRef ref, {
    required bool block,
  }) async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: now,
      // A year out. Beyond that a tutor is not planning, they are guessing.
      lastDate: now.add(const Duration(days: 365)),
    );
    if (range == null || !context.mounted) return;

    // Whole days, in Cairo — a tutor blocking "the 3rd to the 5th" means those
    // days entirely, not from the moment they tapped.
    final startsAt = DateTime(range.start.year, range.start.month, range.start.day);
    final endsAt = DateTime(
      range.end.year,
      range.end.month,
      range.end.day,
    ).add(const Duration(days: 1));

    final controller = ref.read(availabilityControllerProvider.notifier);
    if (!block) {
      await controller.open(startsAt: startsAt, endsAt: endsAt);
      return;
    }

    final clash = await controller.block(startsAt: startsAt, endsAt: endsAt);
    if (!context.mounted || clash == null) return;
    await showClashSheet(context, clash);
  }
}

/// One day: its blocks, and whatever custom hours it holds.
class _DayRow extends ConsumerWidget {
  const _DayRow({required this.weekday, required this.draft});

  final int weekday;
  final AvailabilityDraft draft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final type = context.type;
    final controller = ref.read(availabilityControllerProvider.notifier);

    // Anything that is not one of the three presets. Shown as its own chip so
    // a tutor who set 07:30–09:15 can see and remove it.
    final custom = draft
        .forDay(weekday)
        .where(
          (rule) => !TimeBlock.values.any(
            (block) => rule.matches(block.startMinute, block.endMinute),
          ),
        )
        .toList();

    return EjadahCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  weekdayShortLabel(context, weekday),
                  style: type.h6(),
                ),
              ),
              // The day's own total, so the week's figure can be checked
              // against its parts rather than taken on trust.
              LtrIsland(
                child: Text(
                  '${draft.forDay(weekday).fold(0, (t, r) => t + r.minutes) ~/ 60}h',
                  style: type.tabular(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: EjadahSpacing.xs),
          Wrap(
            spacing: EjadahSpacing.xxs,
            runSpacing: EjadahSpacing.xxs,
            children: [
              for (final block in TimeBlock.values)
                EjadahFilterChip(
                  label: _blockLabel(strings, block),
                  isSelected: draft.hasBlock(weekday, block),
                  onTap: () => controller.toggleBlock(weekday, block),
                ),
              for (final rule in custom)
                EjadahFilterChip(
                  label: _hours(rule),
                  isSelected: true,
                  // Tapping a custom chip removes it — the same gesture the
                  // presets use for the same meaning.
                  onTap: () => controller.removeRule(rule),
                ),
              EjadahFilterChip(
                label: strings.customHours,
                isSelected: false,
                onTap: () => _addCustom(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _addCustom(BuildContext context, WidgetRef ref) async {
    final start = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 17, minute: 0),
      helpText: context.strings.windowFrom,
    );
    if (start == null || !context.mounted) return;

    final end = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: (start.hour + 2) % 24, minute: start.minute),
      helpText: context.strings.windowTo,
    );
    if (end == null || !context.mounted) return;

    final startMinute = start.hour * 60 + start.minute;
    final endMinute = end.hour * 60 + end.minute;
    if (endMinute <= startMinute) {
      // Said rather than silently ignored: a window that ends before it starts
      // is a mistake worth naming.
      showEjadahToast(context, message: context.strings.windowTo);
      return;
    }

    ref
        .read(availabilityControllerProvider.notifier)
        .addCustom(weekday, startMinute, endMinute);
  }

  static String _hours(AvailabilityRule rule) =>
      '${_clock(rule.startMinute)}–${_clock(rule.endMinute)}';

  static String _clock(int minute) =>
      '${(minute ~/ 60).toString().padLeft(2, '0')}:'
      '${(minute % 60).toString().padLeft(2, '0')}';

  static String _blockLabel(EjadahStrings strings, TimeBlock block) =>
      switch (block) {
        TimeBlock.morning => strings.blockMorning,
        TimeBlock.afternoon => strings.blockAfternoon,
        TimeBlock.evening => strings.blockEvening,
      };
}

class _ExceptionRow extends ConsumerWidget {
  const _ExceptionRow({required this.exception});

  final AvailabilityException exception;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;

    return EjadahListRow(
      title: CairoTime.dayLabel(exception.startsAt),
      subtitle: exception.reason?.isNotEmpty ?? false
          ? exception.reason
          : (exception.isAvailable
                ? strings.openedLabel
                : strings.blockedLabel),
      trailing: EjadahIconButton(
        icon: EjadahIcons.close,
        semanticLabel: strings.removeWindow,
        onPressed: () => ref
            .read(availabilityControllerProvider.notifier)
            .removeException(exception.id),
      ),
    );
  }
}

class _AvailabilitySkeleton extends StatelessWidget {
  const _AvailabilitySkeleton();

  @override
  Widget build(BuildContext context) => EjadahPageBody(
    // Scrollable: a skeleton stands in for content that scrolls, and a fixed
    // column of blocks overflows on a short viewport — which paints Flutter's
    // striped overflow bar exactly where a loading state should look calm.
    child: ListView(
      children: [
        const SizedBox(height: EjadahSpacing.md),
        const Skeleton(width: 160, height: 28),
        const SizedBox(height: EjadahSpacing.lg),
        for (var i = 0; i < 5; i++)
          const Padding(
            padding: EdgeInsets.only(bottom: EjadahSpacing.sm),
            child: Skeleton(width: double.infinity, height: 84),
          ),
      ],
    ),
  );
}
