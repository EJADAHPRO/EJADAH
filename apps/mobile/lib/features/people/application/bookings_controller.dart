import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/people_repository.dart';

/// The three tabs of My bookings.
enum BookingTab { upcoming, past, cancelled }

/// What My bookings is showing.
sealed class BookingsState {
  const BookingsState();
}

class BookingsLoading extends BookingsState {
  const BookingsLoading();
}

class BookingsReady extends BookingsState {
  const BookingsReady(this.bookings);

  final List<Booking> bookings;

  /// Confirmed or awaiting payment, and still ahead of us.
  ///
  /// Soonest first: the next session is the one the user opened this screen for.
  List<Booking> get upcoming =>
      _sorted(_inTab(BookingTab.upcoming), ascending: true);

  /// Newest first: recent history is what gets reviewed and re-booked.
  List<Booking> get past => _sorted(_inTab(BookingTab.past), ascending: false);

  List<Booking> get cancelled =>
      _sorted(_inTab(BookingTab.cancelled), ascending: false);

  List<Booking> forTab(BookingTab tab) => switch (tab) {
    BookingTab.upcoming => upcoming,
    BookingTab.past => past,
    BookingTab.cancelled => cancelled,
  };

  List<Booking> _inTab(BookingTab tab) {
    final now = DateTime.now().toUtc();
    return bookings.where((booking) {
      if (booking.status.isCancelled) return tab == BookingTab.cancelled;
      final start = booking.firstSessionStart;
      final isAhead = start != null && start.isAfter(now);
      return tab == (isAhead ? BookingTab.upcoming : BookingTab.past);
    }).toList();
  }

  static List<Booking> _sorted(
    List<Booking> items, {
    required bool ascending,
  }) {
    final sorted = items.toList()
      ..sort((a, b) {
        final left = a.firstSessionStart ?? a.createdAt;
        final right = b.firstSessionStart ?? b.createdAt;
        return ascending ? left.compareTo(right) : right.compareTo(left);
      });
    return sorted;
  }
}

class BookingsFailed extends BookingsState {
  const BookingsFailed(this.failure);

  final Failure failure;
}

final bookingsControllerProvider =
    NotifierProvider<BookingsController, BookingsState>(
      BookingsController.new,
    );

/// Owns My bookings.
///
/// Every row already carries the refund it would pay out right now, projected
/// by the server — the cancel sheet quotes that figure rather than computing a
/// second, possibly different one on the phone.
class BookingsController extends Notifier<BookingsState> {
  @override
  BookingsState build() {
    Future.microtask(load);
    return const BookingsLoading();
  }

  Future<void> load() async {
    state = const BookingsLoading();
    try {
      state = BookingsReady(
        await ref.read(peopleRepositoryProvider).myBookings(),
      );
    } on Failure catch (failure) {
      state = BookingsFailed(failure);
    }
  }

  /// Cancels a booking and reports exactly what was refunded.
  ///
  /// The figure comes back from the server rather than being assumed to match
  /// what the sheet said, so a disagreement is visible instead of silent.
  Future<CancellationOutcome> cancel(Booking booking) async {
    final outcome = await ref
        .read(peopleRepositoryProvider)
        .cancel(booking.id);
    await load();
    return outcome;
  }

  Future<void> retry() => load();
}
