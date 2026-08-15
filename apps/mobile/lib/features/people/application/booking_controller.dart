import 'dart:async';

import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/people_repository.dart';

/// The eight steps of a booking.
///
/// Numbered because the design announces "step n of m" and because the flow is
/// a sequence a user can be part-way through, not a form with sections.
enum BookingStep {
  /// The slot grid. Picking places the hold, so the countdown starts here.
  pickSlot(1),
  duration(2),
  subject(3),

  /// At least ten characters, with the patient-data warning always visible.
  goal(4),

  /// Price and cancellation terms, before any money is discussed.
  review(5),

  /// The redirect sheet, which names the host the checkout runs on.
  payment(6),

  /// Success or "not completed" — never a blank return.
  returned(7),
  confirmed(8);

  const BookingStep(this.number);

  final int number;

  static const int totalSteps = 8;
}

/// How the external checkout came back.
enum PaymentReturn { pending, completed, notCompleted }

/// The whole booking flow, in one immutable value.
///
/// A wizard is genuinely one state moving forward rather than several unrelated
/// screens, and keeping it in one object is what makes "go back one step
/// without losing anything" true by construction.
class BookingFlowState {
  const BookingFlowState({
    required this.professional,
    required this.step,
    required this.weekStart,
    required this.durationMinutes,
    this.slots = const [],
    this.slotsLoading = true,
    this.slotsFailure,
    this.selectedSlot,
    this.hold,
    this.subject = '',
    this.goal = '',
    this.packageId,
    this.booking,
    this.isSubmitting = false,
    this.failure,
    this.slotTaken = false,
    this.holdExpired = false,
    this.paymentReturn = PaymentReturn.pending,
  });

  final Professional professional;
  final BookingStep step;

  /// Midnight UTC on the first day of the week being shown.
  final DateTime weekStart;
  final int durationMinutes;

  /// Every slot in the window, available or not — an unavailable time renders
  /// untappable rather than being hidden.
  final List<AvailabilitySlot> slots;
  final bool slotsLoading;
  final Failure? slotsFailure;
  final AvailabilitySlot? selectedSlot;

  /// The live hold. Its `expiresAt` drives the countdown.
  final BookingHold? hold;
  final String subject;
  final String goal;
  final int? packageId;
  final Booking? booking;
  final bool isSubmitting;
  final Failure? failure;

  /// Someone else took the slot between the grid loading and the tap. The grid
  /// refreshes itself and the screen says what happened.
  final bool slotTaken;

  /// The hold ran out. The screen explains it and confirms nothing was charged.
  final bool holdExpired;
  final PaymentReturn paymentReturn;

  bool get hasOpenSlots => slots.any((slot) => slot.isAvailable);

  /// The price this booking will cost, computed the same way the server does
  /// so the review step and the receipt agree.
  ///
  /// Displayed only; the server never reads a figure from here.
  int get quotedEgp {
    final package = packageId == null
        ? null
        : professional.packages
              .where((item) => item.id == packageId)
              .firstOrNull;
    if (package != null) return package.priceEgp;
    return (professional.hourlyRateEgp * durationMinutes / 60).round();
  }

  bool get isGoalLongEnough => goal.trim().length >= minimumGoalLength;

  /// The design's own floor: "help" is not a brief.
  static const int minimumGoalLength = 10;

  BookingFlowState copyWith({
    BookingStep? step,
    DateTime? weekStart,
    int? durationMinutes,
    List<AvailabilitySlot>? slots,
    bool? slotsLoading,
    Failure? slotsFailure,
    bool clearSlotsFailure = false,
    AvailabilitySlot? selectedSlot,
    bool clearSelectedSlot = false,
    BookingHold? hold,
    bool clearHold = false,
    String? subject,
    String? goal,
    int? packageId,
    Booking? booking,
    bool? isSubmitting,
    Failure? failure,
    bool clearFailure = false,
    bool? slotTaken,
    bool? holdExpired,
    PaymentReturn? paymentReturn,
  }) => BookingFlowState(
    professional: professional,
    step: step ?? this.step,
    weekStart: weekStart ?? this.weekStart,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    slots: slots ?? this.slots,
    slotsLoading: slotsLoading ?? this.slotsLoading,
    slotsFailure: clearSlotsFailure ? null : (slotsFailure ?? this.slotsFailure),
    selectedSlot: clearSelectedSlot ? null : (selectedSlot ?? this.selectedSlot),
    hold: clearHold ? null : (hold ?? this.hold),
    subject: subject ?? this.subject,
    goal: goal ?? this.goal,
    packageId: packageId ?? this.packageId,
    booking: booking ?? this.booking,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    failure: clearFailure ? null : (failure ?? this.failure),
    slotTaken: slotTaken ?? this.slotTaken,
    holdExpired: holdExpired ?? this.holdExpired,
    paymentReturn: paymentReturn ?? this.paymentReturn,
  );
}

/// Identifies one booking flow: whose calendar, and which package if any.
class BookingFlowArgs {
  const BookingFlowArgs({required this.professional, this.packageId});

  final Professional professional;

  /// Set when the student chose a package on the profile. The plan already
  /// answered the cadence question, so the flow never re-asks it.
  final int? packageId;

  @override
  bool operator ==(Object other) =>
      other is BookingFlowArgs &&
      other.professional.id == professional.id &&
      other.packageId == packageId;

  @override
  int get hashCode => Object.hash(professional.id, packageId);
}

final bookingFlowControllerProvider = NotifierProvider.family<
  BookingFlowController,
  BookingFlowState,
  BookingFlowArgs
>(BookingFlowController.new);

/// Drives one booking from the first slot tap to the confirmation.
///
/// Three rules live here rather than in the widgets:
///
/// * the hold is placed the instant a slot is picked, so the countdown is
///   honest about when the clock started;
/// * a lost race is a normal outcome, not an error — the grid refreshes and the
///   flow stays exactly where it was;
/// * abandoning the flow releases the hold, so the slot goes back for everyone
///   else rather than sitting dead until it expires.
class BookingFlowController
    extends FamilyNotifier<BookingFlowState, BookingFlowArgs> {
  @override
  BookingFlowState build(BookingFlowArgs arg) {
    final package = arg.packageId == null
        ? null
        : arg.professional.packages
              .where((item) => item.id == arg.packageId)
              .firstOrNull;

    ref.onDispose(_releaseHoldQuietly);

    Future.microtask(loadSlots);
    return BookingFlowState(
      professional: arg.professional,
      step: BookingStep.pickSlot,
      weekStart: _startOfWeek(DateTime.now().toUtc()),
      durationMinutes: package?.sessionMinutes ?? 60,
      packageId: arg.packageId,
    );
  }

  /// The booking calendar starts on Sunday in both languages.
  static DateTime _startOfWeek(DateTime day) {
    final midnight = DateTime.utc(day.year, day.month, day.day);
    return midnight.subtract(Duration(days: midnight.weekday % 7));
  }

  // --- Slots ----------------------------------------------------------------

  Future<void> loadSlots() async {
    state = state.copyWith(slotsLoading: true, clearSlotsFailure: true);
    try {
      final slots = await ref
          .read(peopleRepositoryProvider)
          .availability(
            professionalId: state.professional.id,
            from: state.weekStart,
            to: state.weekStart.add(const Duration(days: 7)),
          );
      state = state.copyWith(slots: slots, slotsLoading: false);
    } on Failure catch (failure) {
      state = state.copyWith(slotsLoading: false, slotsFailure: failure);
    }
  }

  /// Moves the grid a week at a time. The empty week offers exactly this.
  Future<void> showWeek(int offsetWeeks) async {
    final target = state.weekStart.add(Duration(days: 7 * offsetWeeks));
    final thisWeek = _startOfWeek(DateTime.now().toUtc());
    // There is nothing to book in a week that has already gone.
    if (target.isBefore(thisWeek)) return;

    state = state.copyWith(weekStart: target, slots: const []);
    await loadSlots();
  }

  /// Picks a slot and places the hold in the same gesture.
  ///
  /// A hold that only appeared at the review step would mean the countdown
  /// started long before the user was told about it.
  Future<void> pickSlot(AvailabilitySlot slot) async {
    if (!slot.isAvailable || state.isSubmitting) return;

    // Swapping slots releases the previous hold first, so a user browsing times
    // does not silently occupy three of them.
    await _releaseHoldQuietly();

    state = state.copyWith(
      isSubmitting: true,
      slotTaken: false,
      holdExpired: false,
      clearFailure: true,
    );

    try {
      final hold = await ref
          .read(peopleRepositoryProvider)
          .hold(
            professionalId: state.professional.id,
            startsAt: slot.startsAt,
            durationMinutes: state.durationMinutes,
          );
      state = state.copyWith(
        selectedSlot: slot,
        hold: hold,
        isSubmitting: false,
      );
    } on ConflictFailure {
      // Someone got there first. The error envelope carries no slot list, so
      // the grid refetches — which is also the only way to be sure it is now
      // showing the truth rather than a patched-up guess.
      state = state.copyWith(
        isSubmitting: false,
        slotTaken: true,
        clearSelectedSlot: true,
        clearHold: true,
      );
      await loadSlots();
    } on Failure catch (failure) {
      state = state.copyWith(isSubmitting: false, failure: failure);
    }
  }

  /// Changes the session length, re-placing the hold at the new duration.
  ///
  /// The longer slot may collide with the next appointment, which surfaces as
  /// the same friendly race state rather than as a silent no-op.
  Future<void> setDuration(int minutes) async {
    if (minutes == state.durationMinutes) return;
    final slot = state.selectedSlot;

    state = state.copyWith(durationMinutes: minutes);
    if (slot == null) return;

    await _releaseHoldQuietly();
    state = state.copyWith(clearHold: true);
    await pickSlot(slot);
  }

  // --- The form -------------------------------------------------------------

  void setSubject(String value) => state = state.copyWith(subject: value);

  void setGoal(String value) => state = state.copyWith(goal: value);

  // --- Navigation -----------------------------------------------------------

  void goTo(BookingStep step) => state = state.copyWith(step: step);

  void next() {
    final index = BookingStep.values.indexOf(state.step);
    if (index < BookingStep.values.length - 1) {
      state = state.copyWith(step: BookingStep.values[index + 1]);
    }
  }

  void back() {
    final index = BookingStep.values.indexOf(state.step);
    if (index > 0) state = state.copyWith(step: BookingStep.values[index - 1]);
  }

  /// The hold ran out while the user was typing.
  ///
  /// Everything they wrote survives; only the time is gone, and the flow
  /// returns to the grid rather than failing at submit.
  void onHoldExpired() {
    state = state.copyWith(
      holdExpired: true,
      clearHold: true,
      clearSelectedSlot: true,
      step: BookingStep.pickSlot,
    );
    unawaited(loadSlots());
  }

  void dismissSlotTaken() => state = state.copyWith(slotTaken: false);

  void dismissHoldExpired() => state = state.copyWith(holdExpired: false);

  // --- Confirmation ---------------------------------------------------------

  /// Confirms the booking against the live hold.
  ///
  /// Returns the booking, or null when it could not be created — the state
  /// carries which of the designed failures happened.
  Future<Booking?> confirm() async {
    final hold = state.hold;
    if (hold == null || !state.isGoalLongEnough) return null;

    state = state.copyWith(isSubmitting: true, clearFailure: true);
    try {
      final booking = await ref
          .read(peopleRepositoryProvider)
          .confirm(
            holdId: hold.id,
            subject: state.subject.trim(),
            goal: state.goal.trim(),
            packageId: state.packageId,
          );
      state = state.copyWith(
        booking: booking,
        isSubmitting: false,
        clearHold: true,
        step: BookingStep.payment,
      );
      return booking;
    } on ConflictFailure catch (failure) {
      // The hold died between the countdown reaching zero and this request.
      state = state.copyWith(
        isSubmitting: false,
        holdExpired: true,
        clearHold: true,
        clearSelectedSlot: true,
        step: BookingStep.pickSlot,
        failure: failure,
      );
      await loadSlots();
      return null;
    } on Failure catch (failure) {
      state = state.copyWith(isSubmitting: false, failure: failure);
      return null;
    }
  }

  /// Records how the external checkout came back.
  void completePayment({required bool succeeded}) => state = state.copyWith(
    paymentReturn: succeeded
        ? PaymentReturn.completed
        : PaymentReturn.notCompleted,
    step: succeeded ? BookingStep.confirmed : BookingStep.returned,
  );

  /// Releases the hold without surfacing a failure.
  ///
  /// Called when the user walks away. If it fails the server expires the hold
  /// on its own schedule, so there is nothing here worth interrupting someone
  /// mid-exit to tell them.
  Future<void> _releaseHoldQuietly() async {
    final hold = state.hold;
    if (hold == null) return;
    try {
      await ref.read(peopleRepositoryProvider).releaseHold(hold.id);
    } on Failure {
      // Deliberately swallowed: expiry is enforced server-side regardless.
    }
  }

  /// Abandons the flow, putting the time back on the calendar immediately.
  Future<void> abandon() => _releaseHoldQuietly();
}
