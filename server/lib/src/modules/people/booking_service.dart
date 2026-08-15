import 'package:ejadah_models/ejadah_models.dart';
import 'package:postgres/postgres.dart';

import '../../config/config.dart';
import '../../db/database.dart';
import '../../http/api_error.dart';
import '../../observability/logger.dart';
import '../../services/payments/payment_provider.dart';
import 'people_repository.dart';

/// Booking.
///
/// The concurrency guarantee lives here and in the `slot_reservations`
/// exclusion constraint, and nowhere else. Two callers racing for the same slot
/// cannot both succeed: PostgreSQL rejects the second write, and the API turns
/// that into the "someone booked that time a moment ago" state with a refreshed
/// slot list. The client is never trusted to prevent a double booking — it
/// cannot see the other caller.
class BookingService {
  BookingService({
    required Database database,
    required PeopleRepository repository,
    required PaymentProvider payments,
    required AppConfig config,
    required AppLogger logger,
    DateTime Function()? clock,
  }) : _database = database,
       _repository = repository,
       _payments = payments,
       _config = config,
       _logger = logger,
       _now = clock ?? (() => DateTime.now().toUtc());

  final Database _database;
  final PeopleRepository _repository;
  final PaymentProvider _payments;
  final AppConfig _config;
  final AppLogger _logger;
  final DateTime Function() _now;

  /// Places a hold the moment a slot is picked.
  ///
  /// The countdown is visible from that moment, and the duration is server
  /// controlled. Expiry is enforced by a background job *and* re-checked inside
  /// every booking transaction, so a slot is never wrongly occupied between
  /// ticks.
  Future<BookingHold> holdSlot({
    required String userId,
    required int professionalId,
    required DateTime startsAt,
    required int durationMinutes,
  }) async {
    final endsAt = startsAt.add(Duration(minutes: durationMinutes));
    await _assertBookable(professionalId, startsAt, endsAt);

    return _database.runTx((tx) async {
      await _releaseExpiredHolds(professionalId, tx);

      try {
        final id = await _repository.insertReservation(
          professionalId: professionalId,
          startsAt: startsAt,
          endsAt: endsAt,
          kind: 'hold',
          heldByUserId: userId,
          expiresAt: _now().add(_config.bookingHoldDuration),
          session: tx,
        );

        return BookingHold(
          id: id,
          professionalId: professionalId,
          startsAt: startsAt,
          endsAt: endsAt,
          expiresAt: _now().add(_config.bookingHoldDuration),
        );
      } on ServerException catch (error) {
        // 23P01 exclusion_violation: the constraint refused an overlap. Someone
        // else holds or has booked this slot.
        if (error.code == '23P01') {
          throw ApiException.conflict(message: ApiErrorCopy.slotTaken);
        }
        rethrow;
      }
    });
  }

  /// Confirms a booking against a live hold.
  ///
  /// All-or-nothing: the booking, its sessions, the reservation conversion, the
  /// payment record and the professional's earnings row either all commit or
  /// none of them do.
  /// Confirms one or more held slots as a single booking.
  ///
  /// A multi-session plan is one booking with one `booking_sessions` row per
  /// real time — never a single vague appointment standing in for eight. All of
  /// it happens in one transaction: an eight-session plan where the seventh
  /// slot was taken while the student was filling the sixth must leave nothing
  /// behind, not seven confirmed sessions and a hole.
  Future<Booking> confirmBooking({
    required String userId,
    required String holdId,
    required String subject,
    required String goal,
    int? packageId,
    List<String> additionalHoldIds = const [],
  }) async {
    return _database.runTx((tx) async {
      // Sorted so two concurrent plans sharing slots lock them in the same
      // order and deadlock instead of neither finishing.
      final holdIds = <String>{holdId, ...additionalHoldIds}.toList()..sort();

      final holds = <ReservationRecord>[];
      for (final id in holdIds) {
        // Locks the reservation row for the length of the transaction, so a
        // concurrent confirmation of the same hold waits rather than racing.
        final hold = await _repository.lockReservation(id, session: tx);

        if (hold == null || hold.status != 'active' || hold.kind != 'hold') {
          throw ApiException.conflict(message: ApiErrorCopy.holdExpired);
        }
        if (hold.heldByUserId != userId) {
          throw ApiException.authorization();
        }
        if (hold.expiresAt != null && !hold.expiresAt!.isAfter(_now())) {
          // The hold ran out. The copy confirms nothing was charged.
          await _repository.releaseReservation(id, session: tx);
          throw ApiException.conflict(message: ApiErrorCopy.holdExpired);
        }
        holds.add(hold);
      }

      // Every session in a plan is with the same professional; a plan spanning
      // two of them is not a thing the product offers, and silently booking it
      // would produce one price for two people's time.
      final professionalId = holds.first.professionalId;
      if (holds.any((hold) => hold.professionalId != professionalId)) {
        throw ApiException.conflict();
      }

      // Chronological, so position 1 is the first session the student attends
      // rather than the first one they happened to pick.
      holds.sort((a, b) => a.startsAt.compareTo(b.startsAt));

      final professional = await _repository.findProfessional(
        professionalId,
        session: tx,
      );
      if (professional == null) throw ApiException.notFound();

      // The price is computed here, from the professional's own rate or a
      // package the server looked up. A price arriving from the client is never
      // trusted, and is never even read.
      final pricing = await _priceFor(
        professional: professional,
        packageId: packageId,
        sessions: holds,
        session: tx,
      );

      final bookingId = await _repository.insertBooking(
        userId: userId,
        professionalId: professionalId,
        packageId: packageId,
        kind: professional.kind,
        totalEgp: pricing.totalEgp,
        platformFeeEgp: pricing.platformFeeEgp,
        subject: subject,
        goal: goal,
        session: tx,
      );

      // One row per scheduled session — never a single vague appointment for a
      // multi-session package.
      for (var index = 0; index < holds.length; index++) {
        final hold = holds[index];
        final sessionId = await _repository.insertBookingSession(
          bookingId: bookingId,
          position: index + 1,
          startsAt: hold.startsAt,
          endsAt: hold.endsAt,
          session: tx,
        );

        // The hold becomes the session's reservation in place, so the slot is
        // never briefly free between releasing a hold and inserting a booking.
        await _repository.convertHoldToSession(
          reservationId: hold.id,
          bookingId: bookingId,
          bookingSessionId: sessionId,
          session: tx,
        );
      }

      await _repository.insertPayment(
        userId: userId,
        bookingId: bookingId,
        provider: _payments.name,
        amountEgp: pricing.totalEgp,
        session: tx,
      );

      // The professional's side of the same money, in the same transaction. A
      // confirmed session that never reached the ledger is a tutor who worked
      // for nothing and has no row to point at.
      await _repository.insertEarning(
        professionalId: professionalId,
        bookingId: bookingId,
        grossEgp: pricing.totalEgp,
        platformFeeEgp: pricing.platformFeeEgp,
        session: tx,
      );

      _logger.info('booking created', {
        'booking': bookingId,
        'professional': professionalId,
        'sessions': holds.length,
        // The goal is free text the student wrote and may contain clinical
        // detail; it is never logged and never sent to analytics.
      });

      return (await _repository.findBooking(bookingId, session: tx))!;
    });
  }

  /// Releases a hold the user abandoned.
  Future<void> releaseHold({required String userId, required String holdId}) =>
      _database.runTx((tx) async {
        final hold = await _repository.lockReservation(holdId, session: tx);
        if (hold == null) return;
        if (hold.heldByUserId != userId) throw ApiException.authorization();
        await _repository.releaseReservation(holdId, session: tx);
      });

  /// Bookable slots for a day, computed from the professional's own schedule.
  ///
  /// Rules, exceptions, live holds and confirmed sessions are all accounted
  /// for here. The client never invents a time, and an unavailable slot is
  /// returned as unavailable so it can render untappable rather than
  /// tappable-then-rejected.
  Future<List<AvailabilitySlot>> availability({
    required int professionalId,
    required DateTime from,
    required DateTime to,
    int slotMinutes = 60,
  }) => _repository.availableSlots(
    professionalId: professionalId,
    from: from,
    to: to,
    slotMinutes: slotMinutes,
    now: _now(),
  );

  Future<List<Booking>> myBookings(String userId) =>
      _repository.bookingsForUser(userId);

  /// Opens a checkout for a booking the caller owns.
  ///
  /// The provider decides the URL. Constructing one from a base host and a
  /// booking id happens to work against the simulator and would silently
  /// become a broken redirect the day a real provider lands, so the client is
  /// never given the pieces to assemble it itself.
  ///
  /// The amount comes from the stored booking, not from the request: this is
  /// the second place a client could otherwise name its own price.
  Future<CheckoutSession> checkoutFor({
    required String userId,
    required String bookingId,
  }) async {
    final booking = await _repository.findBooking(bookingId);
    if (booking == null) throw ApiException.notFound();
    if (!await _repository.ownsBooking(userId: userId, bookingId: bookingId)) {
      // Not-found rather than forbidden, so an id cannot be probed.
      throw ApiException.notFound();
    }
    if (booking.status != BookingStatus.pendingPayment) {
      // Paying twice for the same session is not a state to leave reachable.
      throw ApiException.conflict();
    }

    return _payments.createCheckout(
      bookingId: bookingId,
      amountEgp: booking.totalEgp,
      returnUrl: '${_config.publicBaseUrl}/bookings/$bookingId',
    );
  }

  /// Records that a checkout did not complete.
  ///
  /// The booking stays `payment_failed` rather than being cancelled: cancelling
  /// would run the refund path over money that never moved. The slot stays held
  /// by its session reservation so a retry does not have to win it back, and
  /// the hold-expiry job releases it if the retry never comes.
  Future<Booking> markPaymentFailed({
    required String userId,
    required String bookingId,
  }) async {
    if (!await _repository.ownsBooking(userId: userId, bookingId: bookingId)) {
      throw ApiException.notFound();
    }
    await _repository.setBookingStatus(
      bookingId: bookingId,
      status: BookingStatus.paymentFailed,
    );
    return (await _repository.findBooking(bookingId))!;
  }

  /// Cancels a booking, refunding by the stated tier.
  ///
  /// The refund is computed before the confirmation is shown and again here, so
  /// the figure the user agreed to is the figure they get. A professional's
  /// cancellation always refunds in full.
  Future<Booking> cancelBooking({
    required String userId,
    required String bookingId,
    required bool cancelledByProfessional,
  }) => _database.runTx((tx) async {
    final booking = await _repository.findBooking(bookingId, session: tx);
    if (booking == null) throw ApiException.notFound();
    if (!cancelledByProfessional &&
        !await _repository.ownsBooking(
          userId: userId,
          bookingId: bookingId,
          session: tx,
        )) {
      throw ApiException.authorization();
    }

    final refund = cancelledByProfessional
        ? booking.totalEgp
        : refundFor(booking, _now());

    await _repository.cancelBooking(
      bookingId: bookingId,
      cancelledByProfessional: cancelledByProfessional,
      refundedEgp: refund,
      session: tx,
    );
    // The slots go back on the calendar.
    await _repository.releaseReservationsForBooking(bookingId, session: tx);

    // And the ledger row goes with them. Reversed, not deleted: a tutor asking
    // why an amount vanished deserves a row that says what happened to it.
    await _repository.reverseEarning(bookingId: bookingId, session: tx);

    if (refund > 0) {
      await _payments.refund(bookingId: bookingId, amountEgp: refund);
    }

    return (await _repository.findBooking(bookingId, session: tx))!;
  });

  /// The cancellation tiers.
  ///
  /// Shown before the cancel button and again in the confirmation, with the
  /// exact figure — cancel-then-surprise is the failure these exist to prevent.
  static int refundFor(Booking booking, DateTime now) {
    final start = booking.firstSessionStart;
    if (start == null) return booking.totalEgp;

    final hoursUntil = start.difference(now).inHours;
    if (hoursUntil >= 24) return booking.totalEgp;
    if (hoursUntil >= 2) return (booking.totalEgp * 0.5).round();
    return 0;
  }

  Future<void> _assertBookable(
    int professionalId,
    DateTime startsAt,
    DateTime endsAt,
  ) async {
    if (!startsAt.isAfter(_now())) {
      throw ApiException(
        ApiErrorCode.validation,
        details: 'A slot in the past cannot be held.',
      );
    }
    if (!endsAt.isAfter(startsAt)) {
      throw ApiException(
        ApiErrorCode.validation,
        details: 'A slot must end after it starts.',
      );
    }
    final professional = await _repository.findProfessional(professionalId);
    if (professional == null || !professional.isApproved) {
      throw ApiException.notFound();
    }
  }

  /// Expired holds are released lazily at the start of any booking attempt, so
  /// correctness never depends on the background job having run recently.
  Future<void> _releaseExpiredHolds(int professionalId, Session tx) =>
      _repository.releaseExpiredHolds(
        professionalId: professionalId,
        now: _now(),
        session: tx,
      );

  Future<({int totalEgp, int platformFeeEgp})> _priceFor({
    required ProfessionalRecord professional,
    required int? packageId,
    required List<ReservationRecord> sessions,
    required Session session,
  }) async {
    if (packageId != null) {
      final package = await _repository.findPackage(
        packageId,
        session: session,
      );
      if (package == null || package.professionalId != professional.id) {
        throw ApiException.notFound();
      }
      // A package price covers the package, however many sessions it holds —
      // that is what buying a package means.
      return (
        totalEgp: package.priceEgp,
        platformFeeEgp: _feeOn(package.priceEgp),
      );
    }

    // Without a package, every session is charged at the hourly rate for its
    // own length. Integer arithmetic so a price is exact rather than a rounded
    // float, and rounded per session so the total is the sum of what each line
    // says rather than a figure that disagrees with its own breakdown.
    var total = 0;
    for (final slot in sessions) {
      final minutes = slot.endsAt.difference(slot.startsAt).inMinutes;
      total += (professional.hourlyRateEgp * minutes / 60).round();
    }
    return (totalEgp: total, platformFeeEgp: _feeOn(total));
  }

  /// The 70/30 split, applied server-side.
  int _feeOn(int amountEgp) =>
      (amountEgp * _config.platformFeePercent / 100).round();
}
