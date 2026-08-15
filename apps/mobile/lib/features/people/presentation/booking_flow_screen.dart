import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
// The booking components are not yet exported from the `ejadah_ui` barrel; the
// export is owned by whoever assembles that file. The only change when it lands
// is deleting these two lines.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../application/booking_controller.dart';
import 'payment_returned_screen.dart';
import 'widgets/cairo_time.dart';
import 'widgets/slot_grid.dart';

/// PE-04..PE-07 — the eight-step booking flow.
///
/// The hold is placed the moment a slot is picked and the countdown is visible
/// from that same moment, on every subsequent step. Two things follow from
/// that, and both are designed rather than incidental:
///
/// * losing the race is a normal outcome. The grid refreshes itself, the screen
///   says "someone booked that time a moment ago", and nothing the user typed
///   is thrown away;
/// * the hold running out is explained in words that confirm nothing was
///   charged, and the flow returns to the grid rather than failing at submit.
///
/// The session itself is paid **externally**, on ejadah.international. That is
/// the opposite rule from courses, which are in-app purchase only, and the
/// inconsistency is legal rather than accidental.
class BookingFlowScreen extends ConsumerStatefulWidget {
  const BookingFlowScreen({
    required this.professional,
    this.packageId,
    super.key,
  });

  final Professional professional;
  final int? packageId;

  @override
  ConsumerState<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends ConsumerState<BookingFlowScreen> {
  final TextEditingController _subject = TextEditingController();
  final TextEditingController _goal = TextEditingController();

  late final BookingFlowArgs _args = BookingFlowArgs(
    professional: widget.professional,
    packageId: widget.packageId,
  );

  @override
  void initState() {
    super.initState();
    // `EjadahInput` deliberately exposes no `onChanged` — validation runs on
    // blur, not per keystroke. The controller still has to know what has been
    // typed, so the text fields report through their own controllers rather
    // than through a keystroke callback the design does not want.
    _subject.addListener(() => _controller.setSubject(_subject.text));
    _goal.addListener(() => _controller.setGoal(_goal.text));
  }

  @override
  void dispose() {
    _subject.dispose();
    _goal.dispose();
    super.dispose();
  }

  BookingFlowController get _controller =>
      ref.read(bookingFlowControllerProvider(_args).notifier);

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final state = ref.watch(bookingFlowControllerProvider(_args));

    // Race and expiry are announced as they happen rather than discovered at
    // submit. Both leave every answer the user has given intact.
    ref.listen(bookingFlowControllerProvider(_args), (previous, next) {
      if (next.slotTaken && previous?.slotTaken != true) {
        showEjadahToast(context, message: strings.slotTakenBody);
      }
      if (next.holdExpired && previous?.holdExpired != true) {
        showEjadahToast(context, message: strings.holdExpiredBody);
      }
    });

    return GradientBudget(
      screenName: 'booking-flow',
      child: Scaffold(
        appBar: EjadahAppBar(
          title: strings.bookNow,
          backLabel: strings.back,
          onBack: () async {
            // Walking away puts the time back on the calendar immediately
            // rather than leaving it dead until the hold expires.
            await _controller.abandon();
            if (context.mounted) Navigator.of(context).pop();
          },
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: EjadahPageBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: EjadahSpacing.sm),
                BookingStepper(
                  currentStep: state.step.number,
                  totalSteps: BookingStep.totalSteps,
                  semanticsLabel: strings.stepOfSteps(
                    state.step.number,
                    BookingStep.totalSteps,
                  ),
                ),
                const SizedBox(height: EjadahSpacing.xs),
                Text(
                  strings.stepOfSteps(
                    state.step.number,
                    BookingStep.totalSteps,
                  ),
                  style: context.type.micro(color: EjadahColors.labelMuted),
                ),
                // Visible on every step from the pick onwards, so the clock is
                // never running out of sight.
                if (state.hold != null) ...[
                  const SizedBox(height: EjadahSpacing.sm),
                  HoldCountdown(
                    expiresAt: state.hold!.expiresAt,
                    labelBuilder: strings.holdCountdown,
                    onExpired: _controller.onHoldExpired,
                  ),
                ],
                if (state.holdExpired) ...[
                  const SizedBox(height: EjadahSpacing.sm),
                  InlineAlert(
                    title: strings.holdExpiredTitle,
                    message: strings.holdExpiredBody,
                  ),
                ],
                if (state.slotTaken) ...[
                  const SizedBox(height: EjadahSpacing.sm),
                  InlineAlert(
                    title: strings.slotTakenTitle,
                    message: strings.slotTakenBody,
                  ),
                ],
                const SizedBox(height: EjadahSpacing.md),
                Expanded(child: _StepBody(args: _args, state: state,
                    subject: _subject, goal: _goal)),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _StickyBar(
          args: _args,
          state: state,
          onConfirm: _confirm,
          onPay: _openCheckout,
        ),
      ),
    );
  }

  Future<void> _confirm() async {
    final booking = await _controller.confirm();
    if (!mounted || booking == null) return;
    // The design's own haptic for a booking that landed.
    await _openCheckout();
  }

  /// The redirect sheet, then the external checkout.
  ///
  /// The sheet names the host by name before anything opens, so nobody is
  /// surprised about where their card details are going.
  Future<void> _openCheckout() async {
    final state = ref.read(bookingFlowControllerProvider(_args));
    final booking = state.booking;
    if (booking == null) return;

    final proceed = await showEjadahSheet<bool>(
      context: context,
      builder: (context) => _RedirectSheet(amountEgp: booking.totalEgp),
    );
    if (proceed != true || !mounted) return;

    // Sessions are human services and are paid on the website — never through
    // in-app purchase. That split is law, not architecture.
    final uri = Uri.https(checkoutHost, '/checkout/${booking.id}');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;

    final succeeded = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PaymentReturnedScreen(booking: booking),
      ),
    );
    if (!mounted) return;
    _controller.completePayment(succeeded: succeeded ?? false);
  }
}

/// The host the redirect sheet names and the checkout runs on.
///
/// Matches the approved copy — "Completed securely on ejadah.international".
/// When the payment provider starts returning a real checkout URL through the
/// API, this constant is what it replaces.
const String checkoutHost = 'ejadah.international';

/// The body of the current step.
class _StepBody extends ConsumerWidget {
  const _StepBody({
    required this.args,
    required this.state,
    required this.subject,
    required this.goal,
  });

  final BookingFlowArgs args;
  final BookingFlowState state;
  final TextEditingController subject;
  final TextEditingController goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (state.step) {
      BookingStep.pickSlot => _PickSlotStep(args: args, state: state),
      BookingStep.duration => _DurationStep(args: args, state: state),
      BookingStep.subject => _TextStep(
        label: context.strings.subjectsLabel,
        hint: context.strings.notesPlaceholder,
        controller: subject,
      ),
      BookingStep.goal => _GoalStep(state: state, controller: goal),
      BookingStep.review => _ReviewStep(state: state),
      BookingStep.payment ||
      BookingStep.returned ||
      BookingStep.confirmed => _ConfirmedStep(state: state),
    };
  }
}

/// Step 1 — the grid. Picking places the hold.
class _PickSlotStep extends ConsumerWidget {
  const _PickSlotStep({required this.args, required this.state});

  final BookingFlowArgs args;
  final BookingFlowState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final controller = ref.read(bookingFlowControllerProvider(args).notifier);
    final thisWeek = DateTime.now().toUtc();

    return ListView(
      key: const PageStorageKey('booking-slots'),
      children: [
        WeekNavigator(
          weekStart: state.weekStart,
          canGoBack: state.weekStart.isAfter(thisWeek),
          onPrevious: () => controller.showWeek(-1),
          onNext: () => controller.showWeek(1),
        ),
        const SizedBox(height: EjadahSpacing.md),
        if (state.slotsLoading)
          const SlotGridSkeleton()
        else if (state.slotsFailure != null)
          EjadahErrorState(
            title: FailureCopy.errorTitle(context),
            body: state.slotsFailure!.message(context),
            retryLabel: strings.retry,
            onRetry: controller.loadSlots,
          )
        else if (!state.hasOpenSlots)
          // Empty routes to action: the next week is one tap away.
          EjadahEmptyState(
            title: strings.noSlots,
            body: strings.pickAnotherWeek,
            actionLabel: strings.pickAnotherWeek,
            onAction: () => controller.showWeek(1),
          )
        else
          SlotGrid(
            slots: state.slots,
            selected: state.selectedSlot,
            onSelect: controller.pickSlot,
          ),
      ],
    );
  }
}

/// Step 2 — how long. Changing it re-places the hold at the new length.
class _DurationStep extends ConsumerWidget {
  const _DurationStep({required this.args, required this.state});

  final BookingFlowArgs args;
  final BookingFlowState state;

  static const List<int> _options = [30, 60, 90, 120];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final controller = ref.read(bookingFlowControllerProvider(args).notifier);

    return ListView(
      children: [
        SectionHeader(title: strings.durationLabel),
        const SizedBox(height: EjadahSpacing.xs),
        Wrap(
          spacing: EjadahSpacing.xs,
          runSpacing: EjadahSpacing.xs,
          children: [
            for (final minutes in _options)
              EjadahFilterChip(
                // Western digits in both languages, as one LTR run.
                label: '$minutes',
                isSelected: state.durationMinutes == minutes,
                onTap: () => controller.setDuration(minutes),
              ),
          ],
        ),
        const SizedBox(height: EjadahSpacing.md),
        Row(
          children: [
            Text(strings.sessionFee, style: context.type.bodyText()),
            const Spacer(),
            CurrencyText(
              amount: state.quotedEgp,
              currency: 'EGP',
              style: context.type.bodyStrong(),
            ),
          ],
        ),
      ],
    );
  }
}

/// Step 3 — the subject.
class _TextStep extends StatelessWidget {
  const _TextStep({
    required this.label,
    required this.hint,
    required this.controller,
  });

  final String label;
  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => ListView(
    children: [
      EjadahInput(
        label: label,
        hint: hint,
        controller: controller,
        maxLines: 3,
        // The subject is optional: the goal carries the brief, and demanding
        // two free-text fields before a booking is friction with no payoff.
      ),
    ],
  );
}

/// Step 4 — the goal.
///
/// Ten characters minimum, and the patient-data warning is **permanently**
/// visible rather than appearing after a mistake: by the time a name has been
/// typed into a free-text box that reaches another person, the warning is late.
class _GoalStep extends StatefulWidget {
  const _GoalStep({required this.state, required this.controller});

  final BookingFlowState state;
  final TextEditingController controller;

  @override
  State<_GoalStep> createState() => _GoalStepState();
}

class _GoalStepState extends State<_GoalStep> {
  final FocusNode _focus = FocusNode();
  bool _touched = false;

  @override
  void initState() {
    super.initState();
    // Validate on blur, not on every keystroke — correcting someone mid-word is
    // hostile.
    _focus.addListener(() {
      if (!_focus.hasFocus && mounted) setState(() => _touched = true);
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final showError = _touched && !widget.state.isGoalLongEnough;

    return ListView(
      children: [
        EjadahInput(
          label: strings.goalLabel,
          hint: strings.notesPlaceholder,
          controller: widget.controller,
          focusNode: _focus,
          maxLines: 4,
          errorText: showError ? strings.goalTooShort : null,
        ),
        const SizedBox(height: EjadahSpacing.sm),
        // Always on screen, in every state of this step.
        InlineAlert(
          message: strings.patientDataWarning,
          tone: AlertTone.warning,
        ),
      ],
    );
  }
}

/// Step 5 — review. Price and cancellation terms, before any money moves.
class _ReviewStep extends StatelessWidget {
  const _ReviewStep({required this.state});

  final BookingFlowState state;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final slot = state.selectedSlot;

    return ListView(
      children: [
        Text(strings.reviewBookingTitle, style: context.type.h5()),
        const SizedBox(height: EjadahSpacing.md),
        EjadahCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _Row(
                label: strings.viewProfile,
                value: Text(
                  state.professional.displayName(context),
                  style: context.type.bodyStrong(),
                ),
              ),
              if (slot != null)
                _Row(
                  label: strings.cairoTime,
                  value: TimeText(CairoTime.stamp(slot.startsAt)),
                ),
              _Row(
                label: strings.durationLabel,
                value: LtrIsland(
                  child: Text(
                    '${state.durationMinutes}',
                    style: context.type.tabular(),
                  ),
                ),
              ),
              _Row(
                label: strings.sessionFee,
                value: CurrencyText(
                  amount: state.quotedEgp,
                  currency: 'EGP',
                  style: context.type.bodyStrong(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: EjadahSpacing.md),
        SectionHeader(title: strings.cancelTermsLabel),
        const SizedBox(height: EjadahSpacing.xs),
        // The terms are on screen before the payment button, not behind it.
        Text(
          state.professional.cancellationPolicy(context),
          style: context.type.small(color: EjadahColors.textSecondary),
        ),
        const SizedBox(height: EjadahSpacing.md),
        Text(
          strings.payNoteExternal,
          style: context.type.small(color: EjadahColors.labelMuted),
        ),
      ],
    );
  }
}

/// Steps 6–8 — the booking exists; the checkout is the remaining act.
class _ConfirmedStep extends StatelessWidget {
  const _ConfirmedStep({required this.state});

  final BookingFlowState state;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final booking = state.booking;

    return ListView(
      children: [
        Text(
          state.paymentReturn == PaymentReturn.completed
              ? strings.bookingConfirmed
              : strings.reviewBookingTitle,
          style: context.type.h5(),
        ),
        const SizedBox(height: EjadahSpacing.xs),
        Text(
          state.paymentReturn == PaymentReturn.completed
              ? strings.bookedBody
              : strings.payNote,
          style: context.type.bodyText(color: EjadahColors.textSecondary),
        ),
        if (booking != null) ...[
          const SizedBox(height: EjadahSpacing.md),
          EjadahCard(
            child: _Row(
              label: strings.sessionFee,
              value: CurrencyText(
                amount: booking.totalEgp,
                currency: 'EGP',
                style: context.type.bodyStrong(),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: EjadahSpacing.xxs),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: context.type.small(color: EjadahColors.textSecondary),
          ),
        ),
        const SizedBox(width: EjadahSpacing.sm),
        value,
      ],
    ),
  );
}

/// The sticky bar: one main action, and a reason whenever it is disabled.
class _StickyBar extends ConsumerWidget {
  const _StickyBar({
    required this.args,
    required this.state,
    required this.onConfirm,
    required this.onPay,
  });

  final BookingFlowArgs args;
  final BookingFlowState state;
  final Future<void> Function() onConfirm;
  final Future<void> Function() onPay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final controller = ref.read(bookingFlowControllerProvider(args).notifier);

    // A disabled control explains itself on tap rather than doing nothing —
    // one of the two most-felt accessibility rules in the product.
    final (label, onPressed, reason) = switch (state.step) {
      BookingStep.pickSlot => (
        strings.continueAction,
        state.hold == null ? null : controller.next,
        strings.pickSlotFirst,
      ),
      BookingStep.duration ||
      BookingStep.subject => (
        strings.continueAction,
        controller.next,
        null,
      ),
      BookingStep.goal => (
        strings.continueAction,
        state.isGoalLongEnough ? controller.next : null,
        // The disabled reason names what is missing, not the field.
        strings.goalTooShort,
      ),
      BookingStep.review => (strings.payExternally, onConfirm, null),
      BookingStep.payment ||
      BookingStep.returned => (strings.tryPayAgain, onPay, null),
      BookingStep.confirmed => (
        strings.seeBookings,
        () => Navigator.of(context).pop(),
        null,
      ),
    };

    return Container(
      decoration: const BoxDecoration(
        color: EjadahColors.background,
        border: Border(top: BorderSide(color: EjadahColors.border)),
        boxShadow: EjadahElevation.stickyTop,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(EjadahSpacing.md),
          child: EjadahPrimaryButton(
            label: label,
            isLoading: state.isSubmitting,
            onPressed: onPressed == null ? null : () => onPressed(),
            disabledReason: reason,
            onDisabledTap: (message) =>
                showEjadahToast(context, message: message),
          ),
        ),
      ),
    );
  }
}

/// PE-06 — the redirect sheet.
///
/// Names the host before anything opens. The app never handles card details,
/// and the sheet says so rather than leaving the user to infer it from a
/// browser chrome they have not seen yet.
class _RedirectSheet extends StatelessWidget {
  const _RedirectSheet({required this.amountEgp});

  final int amountEgp;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(strings.reviewBookingTitle, style: context.type.h5()),
        const SizedBox(height: EjadahSpacing.xs),
        Text(
          strings.payNoteExternal,
          style: context.type.bodyText(color: EjadahColors.textSecondary),
        ),
        const SizedBox(height: EjadahSpacing.sm),
        Text(
          strings.payNote,
          style: context.type.small(color: EjadahColors.labelMuted),
        ),
        const SizedBox(height: EjadahSpacing.md),
        Row(
          children: [
            Text(strings.sessionFee, style: context.type.bodyText()),
            const Spacer(),
            CurrencyText(
              amount: amountEgp,
              currency: 'EGP',
              style: context.type.bodyStrong(),
            ),
          ],
        ),
        const SizedBox(height: EjadahSpacing.md),
        EjadahPrimaryButton(
          label: strings.payExternally,
          onPressed: () => Navigator.of(context).pop(true),
        ),
        const SizedBox(height: EjadahSpacing.xs),
        EjadahGhostButton(
          label: strings.cancel,
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }
}
