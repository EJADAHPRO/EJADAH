import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
// The booking components are not yet exported from the `ejadah_ui` barrel; the
// export is owned by whoever assembles that file. Importing the component
// directly keeps this screen working until it lands, and the only change then is
// deleting these two lines.
import 'package:flutter/material.dart';

import 'cairo_time.dart';

/// A week of bookable times, grouped by day.
///
/// Two rules the grid exists to keep:
///
/// * a taken hour is **rendered untappable**, never tappable-then-rejected —
///   [SlotButton] enforces that, and this grid never filters unavailable times
///   out, because a day with three of its four hours missing reads as a broken
///   calendar rather than a busy one;
/// * every time is Cairo time and the grid says so, once, at the top.
class SlotGrid extends StatelessWidget {
  const SlotGrid({
    required this.slots,
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final List<AvailabilitySlot> slots;
  final AvailabilitySlot? selected;
  final ValueChanged<AvailabilitySlot> onSelect;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final days = _byDay(slots);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.type.eyebrowText(strings.pickSlot),
          style: context.type.eyebrow(color: EjadahColors.labelMuted),
        ),
        const SizedBox(height: EjadahSpacing.xxs),
        // Said once, at the top, rather than repeated under every day.
        Text(
          strings.timezoneNote,
          style: context.type.micro(color: EjadahColors.labelMuted),
        ),
        const SizedBox(height: EjadahSpacing.sm),
        for (final day in days) ...[
          TimeText(
            CairoTime.longDayLabel(day.first.startsAt),
            style: context.type.bodyStrong(),
          ),
          const SizedBox(height: EjadahSpacing.xs),
          Wrap(
            spacing: EjadahSpacing.xs,
            runSpacing: EjadahSpacing.xs,
            children: [
              for (final slot in day)
                SlotButton(
                  label: CairoTime.time(slot.startsAt),
                  isAvailable: slot.isAvailable,
                  isSelected: selected?.startsAt == slot.startsAt,
                  onTap: () => onSelect(slot),
                ),
            ],
          ),
          const SizedBox(height: EjadahSpacing.md),
        ],
      ],
    );
  }

  /// Groups by Cairo day, preserving chronological order.
  static List<List<AvailabilitySlot>> _byDay(List<AvailabilitySlot> slots) {
    final days = <List<AvailabilitySlot>>[];
    for (final slot in slots) {
      if (days.isNotEmpty &&
          CairoTime.sameDay(days.last.first.startsAt, slot.startsAt)) {
        days.last.add(slot);
      } else {
        days.add([slot]);
      }
    }
    return days;
  }
}

/// The week the grid is showing, with a way out of an empty one.
///
/// "Try another week" is the action the empty state routes to, so a week with
/// nothing open is never a dead end.
class WeekNavigator extends StatelessWidget {
  const WeekNavigator({
    required this.weekStart,
    required this.canGoBack,
    required this.onPrevious,
    required this.onNext,
    super.key,
  });

  final DateTime weekStart;

  /// False on the current week: there is nothing to book in a week that has
  /// already gone, and the control explains that rather than doing nothing.
  final bool canGoBack;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Row(
      children: [
        EjadahIconButton(
          // Mirrors in Arabic: "earlier" sits on the reading-start side.
          icon: EjadahIcons.chevronBack,
          semanticLabel: strings.back,
          onPressed: canGoBack ? onPrevious : null,
          color: canGoBack ? EjadahColors.textPrimary : EjadahColors.labelMuted,
        ),
        Expanded(
          child: Center(
            child: TimeText(
              '${CairoTime.dayLabel(weekStart)} — '
              '${CairoTime.dayLabel(weekStart.add(const Duration(days: 6)))}',
              style: context.type.caption(),
            ),
          ),
        ),
        EjadahIconButton(
          icon: EjadahIcons.chevronForward,
          semanticLabel: strings.pickAnotherWeek,
          onPressed: onNext,
        ),
      ],
    );
  }
}

/// A skeleton in the shape of the slot grid.
class SlotGridSkeleton extends StatelessWidget {
  const SlotGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var day = 0; day < 3; day++) ...[
        const Skeleton(width: 160, height: 14),
        const SizedBox(height: EjadahSpacing.xs),
        Wrap(
          spacing: EjadahSpacing.xs,
          runSpacing: EjadahSpacing.xs,
          children: [
            for (var slot = 0; slot < 4; slot++)
              const Skeleton(width: 84, height: EjadahSizes.tapTargetMin),
          ],
        ),
        const SizedBox(height: EjadahSpacing.md),
      ],
    ],
  );
}
