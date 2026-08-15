import 'package:ejadah_models/ejadah_models.dart';

import '../../http/api_error.dart';
import 'booking_service.dart';
import 'people_repository.dart';

/// What stands behind the three doors.
///
/// The hub states its own supply rather than sending someone through a door
/// that turns out to be empty.
class PeopleHub {
  const PeopleHub({required this.counts});

  final Map<ServiceKind, int> counts;

  int get total => counts.values.fold(0, (sum, count) => sum + count);

  Map<String, dynamic> toJson() => {
    'doors': [
      for (final kind in ServiceKind.values)
        {'kind': kind.wire, 'count': counts[kind] ?? 0},
    ],
    'total': total,
  };
}

/// One marketplace list, with everything the screen needs to render all of its
/// states in a single round trip.
///
/// The facets travel with the results so the filter sheet never offers a filter
/// that matches nothing, and the rail travels with them so a cold-start roster
/// still has something to lead with.
class ProfessionalList {
  const ProfessionalList({
    required this.page,
    required this.facets,
    required this.newThisMonth,
  });

  final Paginated<Professional> page;
  final Map<String, List<String>> facets;

  /// Cold-start supply survival: someone approved this month, shown before they
  /// have a single review to sort by.
  final List<Professional> newThisMonth;

  Map<String, dynamic> toJson() => {
    ...page.toJson((professional) => professional.toJson()),
    'facets': facets,
    'new_this_month': newThisMonth.map((p) => p.toJson()).toList(),
  };
}

/// A professional's full profile.
///
/// Qualifications carry their own evidence, packages carry their own cadence
/// sentence, and the cancellation policy travels with the profile so the terms
/// are readable *before* anyone books rather than after they want out.
class ProfessionalProfile {
  const ProfessionalProfile({
    required this.professional,
    required this.reviews,
  });

  final Professional professional;
  final List<ProfessionalReview> reviews;

  Map<String, dynamic> toJson() => {
    ...professional.toJson(),
    'reviews': reviews.map((review) => review.toJson()).toList(),
  };
}

/// Discovery across the three marketplace doors.
///
/// Booking lives in [BookingService]; this service is everything before the
/// decision — who exists, what they charge, what they can prove, and what
/// happens if the student changes their mind.
class PeopleService {
  const PeopleService(this._repository, {DateTime Function()? clock})
    : _now = clock ?? DateTime.timestamp;

  final PeopleRepository _repository;
  final DateTime Function() _now;

  /// How many professionals each door leads to.
  Future<PeopleHub> hub() async =>
      PeopleHub(counts: await _repository.countsByKind());

  /// A filtered page of one door, plus its facets and its rail.
  Future<ProfessionalList> browse(ProfessionalQuery query) async {
    final page = await _repository.searchProfessionals(query);
    return ProfessionalList(
      page: page,
      facets: await _repository.professionalFacets(query.kind),
      // The rail is about supply, not about the current filter — narrowing it
      // to the filtered set would hide exactly the people it exists to surface.
      newThisMonth: await _repository.newThisMonth(query.kind),
    );
  }

  /// A profile by slug, or a real not-found state.
  ///
  /// The slug is what the shared link carries, so a link that no longer
  /// resolves lands on content-unavailable rather than a blank screen.
  Future<ProfessionalProfile> profile(String slug) async {
    final professional = await _repository.findProfessionalBySlug(slug);
    if (professional == null) throw ApiException.notFound();

    return ProfessionalProfile(
      professional: professional,
      reviews: await _repository.reviewsFor(professional.id),
    );
  }

  /// The "New this month" rail on its own, for the Home feed and the hub.
  Future<List<Professional>> newThisMonth(ServiceKind kind) =>
      _repository.newThisMonth(kind);

  /// Projects the **live** cancellation tier onto a booking.
  ///
  /// The stored `refunded_egp` is only written when a booking is cancelled, so
  /// an active booking would otherwise report a refund of zero — and the design
  /// requires the tier to be readable *before* the cancel button, not after it.
  /// Recomputing here from [BookingService.refundFor] means the figure the user
  /// is shown and the figure the cancellation pays out come from one function.
  ///
  /// A cancelled booking keeps its stored figure: that is what was actually
  /// refunded, and recomputing it against today's clock would rewrite history.
  Booking withLiveRefund(Booking booking) {
    if (booking.status.isCancelled) return booking;
    return _copyWithRefund(booking, BookingService.refundFor(booking, _now()));
  }

  List<Booking> withLiveRefunds(List<Booking> bookings) =>
      bookings.map(withLiveRefund).toList();

  /// [Booking] is a value object without a `copyWith`, and it lives in a
  /// package this module does not own, so the projection is written out here
  /// rather than by mutating the model.
  static Booking _copyWithRefund(Booking booking, int refundableEgp) => Booking(
    id: booking.id,
    professionalId: booking.professionalId,
    professionalName: booking.professionalName,
    kind: booking.kind,
    status: booking.status,
    sessions: booking.sessions,
    totalEgp: booking.totalEgp,
    refundableEgp: refundableEgp,
    subject: booking.subject,
    createdAt: booking.createdAt,
    hasReview: booking.hasReview,
    avatarUrl: booking.avatarUrl,
  );
}
