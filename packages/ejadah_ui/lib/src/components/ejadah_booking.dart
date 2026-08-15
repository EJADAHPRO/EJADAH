import 'dart:async';

import 'package:flutter/widgets.dart';

import '../foundation/bidi_text.dart';
import '../foundation/ejadah_icons.dart';
import '../foundation/ejadah_pressable.dart';
import '../foundation/gradient_budget.dart';
import '../theme/ejadah_theme.dart';
import '../tokens/ejadah_tokens.dart';

/// One bookable time in the slot grid.
///
/// The rule this component exists to enforce: **an unavailable slot is not
/// tappable.** Rendering every hour as a button and rejecting the taken ones on
/// tap teaches the user that the grid lies, and it is the single most common way
/// a booking flow becomes untrustworthy. Here, [isAvailable] removes the gesture
/// entirely and marks the tile unavailable to assistive technology, so a screen
/// reader and a thumb reach the same conclusion.
///
/// **Do not use when** the time is merely *unselected* — that is the default
/// state, not the unavailable one.
class SlotButton extends StatelessWidget {
  const SlotButton({
    required this.label,
    required this.isAvailable,
    required this.isSelected,
    required this.onTap,
    this.unavailableLabel,
    super.key,
  });

  /// The time, pre-formatted by the caller's localization in Western digits.
  /// Rendered as an LTR island so "7:00 pm" never reorders inside Arabic.
  final String label;

  /// False renders an inert tile: no gesture, no button semantics, no haptic.
  final bool isAvailable;
  final bool isSelected;

  /// Ignored entirely when [isAvailable] is false.
  final VoidCallback onTap;

  /// Announced with the time so the state is never colour-alone — e.g. "Taken".
  final String? unavailableLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.ejadah;

    final tile = AnimatedContainer(
      duration: tokens.motion(EjadahMotion.fast),
      curve: EjadahMotion.curve,
      // Sized to its own label, never stretched: a slot grid is a wrap of
      // chips, and a `Container` given an `alignment` would expand to fill the
      // row instead. The 44 minimum still applies in both dimensions.
      constraints: const BoxConstraints(
        minHeight: EjadahSizes.tapTargetMin,
        minWidth: EjadahSizes.tapTargetMin,
      ),
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: EjadahSpacing.sm,
        vertical: EjadahSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: switch ((isAvailable, isSelected)) {
          (false, _) => EjadahColors.inset,
          (true, true) => EjadahColors.tint(EjadahColors.orange),
          (true, false) => EjadahColors.card,
        },
        borderRadius: EjadahRadius.all(EjadahRadius.md),
        border: Border.all(
          color: isSelected && isAvailable
              ? EjadahColors.orange
              : EjadahColors.border,
          width: EjadahSizes.cardBorderWidth,
        ),
      ),
      child: Center(
        widthFactor: 1,
        heightFactor: 1,
        child: LtrIsland(
          child: Text(
            label,
            style: context.type.caption(
              color: switch ((isAvailable, isSelected)) {
                (false, _) => EjadahColors.labelMuted,
                (true, true) => EjadahColors.orangeText,
                (true, false) => EjadahColors.textPrimary,
              },
            ),
          ),
        ),
      ),
    );

    if (!isAvailable) {
      // Not a disabled button — not a button at all. There is nothing to tap
      // and nothing to explain away afterwards.
      return Semantics(
        label: unavailableLabel == null
            ? label
            : '$label · ${unavailableLabel!}',
        enabled: false,
        excludeSemantics: true,
        child: tile,
      );
    }

    return EjadahPressable(
      onTap: onTap,
      haptic: PressHaptic.selection,
      isButton: false,
      enforceMinimumTarget: false,
      semanticLabel: label,
      child: Semantics(selected: isSelected, child: tile),
    );
  }
}

/// The countdown on a live hold: "Held for you 14:32".
///
/// Visible from the moment the slot is picked, not from the review step — the
/// user is told a clock is running before they start typing, never after.
///
/// Two details are load-bearing. The digits render in an LTR island, because
/// "14:32" reversed to "32:14" in Arabic is a genuinely alarming thing to read
/// on a countdown. And the whole line is a live region, so a screen-reader user
/// hears the hold running out rather than discovering it at submit.
class HoldCountdown extends StatefulWidget {
  const HoldCountdown({
    required this.expiresAt,
    required this.labelBuilder,
    this.onExpired,
    super.key,
  });

  /// Server-controlled. The client displays this deadline; it never extends it.
  final DateTime expiresAt;

  /// Receives the formatted "mm:ss" and returns the localized sentence — e.g.
  /// `strings.holdCountdown`. Composed through a placeholder, never by
  /// concatenating a label and a number.
  final String Function(String remaining) labelBuilder;

  /// Fired once, when the hold runs out. The screen explains what happened and
  /// confirms nothing was charged.
  final VoidCallback? onExpired;

  @override
  State<HoldCountdown> createState() => _HoldCountdownState();
}

class _HoldCountdownState extends State<HoldCountdown> {
  Timer? _ticker;
  late Duration _remaining = _timeLeft();
  bool _notified = false;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void didUpdateWidget(HoldCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expiresAt != widget.expiresAt) {
      _notified = false;
      _tick();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Duration _timeLeft() {
    final left = widget.expiresAt.difference(DateTime.now().toUtc());
    return left.isNegative ? Duration.zero : left;
  }

  void _tick() {
    final left = _timeLeft();
    if (mounted) setState(() => _remaining = left);

    if (left == Duration.zero && !_notified) {
      _notified = true;
      _ticker?.cancel();
      widget.onExpired?.call();
    }
  }

  /// Western digits in both languages, zero-padded so the line does not jitter.
  static String _format(Duration remaining) {
    final minutes = remaining.inMinutes.toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// A marker passed through the localized sentence so the clock's position
  /// inside it can be found without the string table knowing anything about
  /// rendering. Never displayed.
  static const String _clockSlot = '\u0001';

  /// The sentence in the reading direction, with the clock as an LTR island.
  ///
  /// The Arabic sentence must run right-to-left while "14:32" must not: a
  /// countdown that reads "32:14" is not a cosmetic bug, it is a lie about how
  /// much time is left. Splitting the localized sentence at the placeholder is
  /// what lets both hold at once, without embedding Unicode control characters
  /// in the string tables — those would leak into search, sorting and
  /// analytics.
  Widget _line(BuildContext context, Color colour) {
    final style = context.type.caption(color: colour);
    final clock = _format(_remaining);
    final parts = widget.labelBuilder(_clockSlot).split(_clockSlot);

    if (parts.length != 2) {
      // A sentence without the placeholder is still rendered honestly, with the
      // clock appended as its own island rather than silently dropped.
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Text(widget.labelBuilder(clock), style: style)),
        ],
      );
    }

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: parts.first),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: LtrIsland(child: Text(clock, style: style)),
          ),
          TextSpan(text: parts.last),
        ],
      ),
      style: style,
    );
  }

  @override
  Widget build(BuildContext context) {
    // The last minute is the only point at which urgency is worth colouring,
    // and the words still carry the state on their own.
    final isUrgent = _remaining.inSeconds <= 60;
    final colour = isUrgent
        ? EjadahColors.dangerText
        : EjadahColors.textSecondary;

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: EjadahSpacing.sm,
          vertical: EjadahSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: EjadahColors.tint(
            isUrgent ? EjadahColors.danger : EjadahColors.amber,
            0.10,
          ),
          borderRadius: EjadahRadius.all(EjadahRadius.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // A clock face never mirrors.
            Icon(EjadahIcons.clock, size: EjadahIconSize.inline, color: colour),
            const SizedBox(width: EjadahSpacing.xs),
            Flexible(child: _line(context, colour)),
          ],
        ),
      ),
    );
  }
}

/// The step indicator across a multi-step flow.
///
/// Named `BookingStepper` rather than `Stepper` because Flutter already ships a
/// Material `Stepper` with entirely different behaviour, and a name collision in
/// a shared design-system barrel is a trap.
///
/// The dots are an ordered list to assistive technology and announce "step n of
/// m" — the design requires the position to be spoken, not merely drawn. The
/// current marker is the gradient's numbered-step-marker use and counts against
/// the screen's budget.
class BookingStepper extends StatelessWidget {
  const BookingStepper({
    required this.currentStep,
    required this.totalSteps,
    required this.semanticsLabel,
    super.key,
  });

  /// One-based.
  final int currentStep;
  final int totalSteps;

  /// The localized "Step {n} of {total}" sentence, already composed by the
  /// caller through its placeholder.
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.ejadah;

    return Semantics(
      label: semanticsLabel,
      // Read as one unit: a screen reader announcing eight anonymous dots is
      // noise, and the position is what actually matters.
      container: true,
      child: ExcludeSemantics(
        child: Row(
          children: [
            for (var step = 1; step <= totalSteps; step++) ...[
              if (step > 1) const SizedBox(width: EjadahSpacing.xxs),
              Expanded(
                child: step == currentStep
                    ? BrandGradient(
                        use: GradientUse.stepMarker,
                        borderRadius: EjadahRadius.all(EjadahRadius.pill),
                        child: const SizedBox(height: 4),
                      )
                    : AnimatedContainer(
                        duration: tokens.motion(EjadahMotion.base),
                        curve: EjadahMotion.curve,
                        height: 4,
                        decoration: BoxDecoration(
                          color: step < currentStep
                              ? EjadahColors.orange
                              : EjadahColors.inset,
                          borderRadius: EjadahRadius.all(EjadahRadius.pill),
                        ),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One week in a multi-session plan.
class WeekStep {
  const WeekStep({
    required this.label,
    required this.isComplete,
    required this.statusLine,
  });

  /// "Week 3", composed by the caller's localization.
  final String label;

  /// Whether this week has all of its sessions placed.
  final bool isComplete;

  /// The server's own words about this week — e.g. which weeks could not be
  /// filled at the requested time. Written by the server rather than assembled
  /// on the client, so the report cannot drift from what actually happened.
  final String statusLine;
}

/// The week-by-week stepper for a multi-session plan.
///
/// A plan is filled one week at a time — week 1, tick, advance — because the
/// alternative ("how many hours do you want in total?") makes the student do
/// scheduling arithmetic the product is supposed to do for them. Asking an
/// aggregate-hours question here is a defect, not a shortcut.
///
/// Weeks already filled stay reachable: changing week 2 after reaching week 6
/// must not mean starting again.
class WeekStepper extends StatelessWidget {
  const WeekStepper({
    required this.weeks,
    required this.currentWeek,
    required this.onSelectWeek,
    required this.statusLabel,
    super.key,
  });

  final List<WeekStep> weeks;

  /// Zero-based index into [weeks].
  final int currentWeek;
  final ValueChanged<int> onSelectWeek;

  /// Localized description of the strip as a whole, for assistive technology.
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    final current = weeks.isEmpty
        ? null
        : weeks[currentWeek.clamp(0, weeks.length - 1)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: statusLabel,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var index = 0; index < weeks.length; index++) ...[
                  if (index > 0) const SizedBox(width: EjadahSpacing.xs),
                  _WeekPill(
                    week: weeks[index],
                    isCurrent: index == currentWeek,
                    onTap: () => onSelectWeek(index),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (current != null && current.statusLine.isNotEmpty) ...[
          const SizedBox(height: EjadahSpacing.xs),
          Semantics(
            liveRegion: true,
            child: Text(
              current.statusLine,
              style: context.type.small(color: EjadahColors.textSecondary),
            ),
          ),
        ],
      ],
    );
  }
}

class _WeekPill extends StatelessWidget {
  const _WeekPill({
    required this.week,
    required this.isCurrent,
    required this.onTap,
  });

  final WeekStep week;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // A filled week shows a tick, a current week shows the gradient, and every
    // other week shows its number: three visually distinct states, none of them
    // carried by colour alone.
    final Widget content = SizedBox(
      height: EjadahSizes.tapTargetMin,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: EjadahSpacing.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (week.isComplete) ...[
              Icon(
                EjadahIcons.check,
                size: EjadahIconSize.inline,
                color: isCurrent
                    ? EjadahColors.onDark
                    : EjadahColors.successText,
              ),
              const SizedBox(width: EjadahSpacing.xxs),
            ],
            Text(
              week.label,
              style: context.type.caption(
                color: isCurrent
                    ? EjadahColors.onDark
                    : week.isComplete
                    ? EjadahColors.successText
                    : EjadahColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );

    return EjadahPressable(
      onTap: onTap,
      haptic: PressHaptic.selection,
      isButton: false,
      enforceMinimumTarget: false,
      semanticLabel: week.label,
      child: Semantics(
        selected: isCurrent,
        child: isCurrent
            ? ClipRRect(
                borderRadius: EjadahRadius.all(EjadahRadius.pill),
                child: BrandGradient(
                  use: GradientUse.stepMarker,
                  child: content,
                ),
              )
            : DecoratedBox(
                decoration: BoxDecoration(
                  color: week.isComplete
                      ? EjadahColors.tint(EjadahColors.success)
                      : EjadahColors.card,
                  borderRadius: EjadahRadius.all(EjadahRadius.pill),
                  border: Border.all(
                    color: week.isComplete
                        ? EjadahColors.success
                        : EjadahColors.border,
                    width: EjadahSizes.cardBorderWidth,
                  ),
                ),
                child: content,
              ),
      ),
    );
  }
}
