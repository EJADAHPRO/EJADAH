
import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Reached transitively through `ejadah_core`, which already depends on it for
// `LocalStore`. Declaring it directly in the app's pubspec is the tidy fix and
// belongs to whoever owns that file.
// ignore: depend_on_referenced_packages

import '../../../app/providers.dart';

/// How a marketplace list is ordered. Mirrors the server enum.
enum ProfessionalSort {
  recommended('recommended'),
  priceAsc('price_asc'),
  priceDesc('price_desc'),
  ratingDesc('rating_desc'),
  newest('newest');

  const ProfessionalSort(this.wire);

  final String wire;

  static ProfessionalSort fromWire(String? value) =>
      ProfessionalSort.values.firstWhere(
        (sort) => sort.wire == value,
        orElse: () => ProfessionalSort.recommended,
      );
}

/// The filters one door offers.
///
/// The set is the same across the three doors; only `destinations` differs in
/// whether it is ever populated, because only a mentor has a move to match on.
class ProfessionalQuery {
  const ProfessionalQuery({
    required this.kind,
    this.specialties = const [],
    this.languages = const [],
    this.destinations = const [],
    this.maxRateEgp,
    this.freeIntroCallOnly = false,
    this.sort = ProfessionalSort.recommended,
    this.page = 1,
  });

  final ServiceKind kind;
  final List<String> specialties;
  final List<String> languages;
  final List<String> destinations;
  final int? maxRateEgp;
  final bool freeIntroCallOnly;
  final ProfessionalSort sort;
  final int page;

  int get activeFilterCount =>
      specialties.length +
      languages.length +
      destinations.length +
      (maxRateEgp == null ? 0 : 1) +
      (freeIntroCallOnly ? 1 : 0);

  bool get hasActiveFilters => activeFilterCount > 0;

  ProfessionalQuery copyWith({
    List<String>? specialties,
    List<String>? languages,
    List<String>? destinations,
    int? maxRateEgp,
    bool clearMaxRate = false,
    bool? freeIntroCallOnly,
    ProfessionalSort? sort,
    int? page,
  }) => ProfessionalQuery(
    kind: kind,
    specialties: specialties ?? this.specialties,
    languages: languages ?? this.languages,
    destinations: destinations ?? this.destinations,
    maxRateEgp: clearMaxRate ? null : (maxRateEgp ?? this.maxRateEgp),
    freeIntroCallOnly: freeIntroCallOnly ?? this.freeIntroCallOnly,
    sort: sort ?? this.sort,
    page: page ?? this.page,
  );

  Map<String, String> toQueryParameters() => {
    if (specialties.isNotEmpty) 'specialty': specialties.join(','),
    if (languages.isNotEmpty) 'language': languages.join(','),
    if (destinations.isNotEmpty) 'destination': destinations.join(','),
    if (maxRateEgp != null) 'max_rate_egp': '$maxRateEgp',
    if (freeIntroCallOnly) 'free_intro_call': 'true',
    'sort': sort.wire,
    'page': '$page',
  };

  /// Only the filters are persisted — not the page, because coming back to
  /// page four of a list you last saw a week ago is disorienting.
  Map<String, dynamic> toJson() => {
    'specialties': specialties,
    'languages': languages,
    'destinations': destinations,
    'max_rate_egp': maxRateEgp,
    'free_intro_call': freeIntroCallOnly,
    'sort': sort.wire,
  };

  factory ProfessionalQuery.fromJson(
    ServiceKind kind,
    Map<String, dynamic> json,
  ) => ProfessionalQuery(
    kind: kind,
    specialties: _strings(json['specialties']),
    languages: _strings(json['languages']),
    destinations: _strings(json['destinations']),
    maxRateEgp: (json['max_rate_egp'] as num?)?.toInt(),
    freeIntroCallOnly: json['free_intro_call'] == true,
    sort: ProfessionalSort.fromWire(json['sort'] as String?),
  );

  static List<String> _strings(Object? value) => value is List
      ? value.map((item) => item.toString()).toList()
      : const <String>[];
}

/// One door's page of results, with everything its states need.
class ProfessionalListPage {
  const ProfessionalListPage({
    required this.page,
    required this.facets,
    required this.newThisMonth,
  });

  final Paginated<Professional> page;

  /// Only values this door actually contains, so the sheet never offers a
  /// filter that matches nothing.
  final Map<String, List<String>> facets;

  /// The rail. Independent of the current filter — narrowing it would hide the
  /// people it exists to surface.
  final List<Professional> newThisMonth;

  factory ProfessionalListPage.fromJson(Map<String, dynamic> json) =>
      ProfessionalListPage(
        page: Paginated.fromJson(json, Professional.fromJson),
        facets: (json['facets'] as Map<String, dynamic>? ?? const {}).map(
          (key, value) => MapEntry(
            key,
            (value as List<dynamic>).map((v) => v.toString()).toList(),
          ),
        ),
        newThisMonth: (json['new_this_month'] as List<dynamic>? ?? const [])
            .map(
              (item) =>
                  Professional.fromJson(Map<String, dynamic>.from(item as Map)),
            )
            .toList(),
      );
}

/// A review on a profile.
class ProfessionalReview {
  const ProfessionalReview({
    required this.id,
    required this.rating,
    required this.body,
    required this.authorName,
    required this.createdAt,
  });

  final String id;
  final int rating;
  final String body;
  final LocalizedText authorName;
  final DateTime createdAt;

  factory ProfessionalReview.fromJson(Map<String, dynamic> json) =>
      ProfessionalReview(
        id: json['id'] as String,
        rating: (json['rating'] as num?)?.toInt() ?? 0,
        body: (json['body'] ?? '') as String,
        authorName:
            LocalizedText.fromJson(json['author_name']) ??
            const LocalizedText.same(''),
        createdAt:
            DateTime.tryParse(json['created_at'] as String? ?? '')?.toUtc() ??
            DateTime.now().toUtc(),
      );
}

/// A professional plus their reviews.
class ProfessionalProfile {
  const ProfessionalProfile({required this.professional, required this.reviews});

  final Professional professional;
  final List<ProfessionalReview> reviews;

  factory ProfessionalProfile.fromJson(Map<String, dynamic> json) =>
      ProfessionalProfile(
        professional: Professional.fromJson(json),
        reviews: (json['reviews'] as List<dynamic>? ?? const [])
            .map(
              (item) => ProfessionalReview.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList(),
      );
}

/// How many professionals stand behind each door.
class PeopleHubCounts {
  const PeopleHubCounts(this.counts);

  final Map<ServiceKind, int> counts;

  int forKind(ServiceKind kind) => counts[kind] ?? 0;

  factory PeopleHubCounts.fromJson(Map<String, dynamic> json) {
    final counts = <ServiceKind, int>{};
    for (final door in json['doors'] as List<dynamic>? ?? const []) {
      final map = Map<String, dynamic>.from(door as Map);
      counts[ServiceKind.fromWire(map['kind'] as String?)] =
          (map['count'] as num?)?.toInt() ?? 0;
    }
    return PeopleHubCounts(counts);
  }
}

/// What a cancellation actually paid back.
class CancellationOutcome {
  const CancellationOutcome({
    required this.booking,
    required this.refundedEgp,
    required this.totalEgp,
  });

  final Booking booking;

  /// The exact figure. Named in the confirmation the user agreed to, and named
  /// again here so the two can be compared rather than trusted.
  final int refundedEgp;
  final int totalEgp;

  factory CancellationOutcome.fromJson(Map<String, dynamic> json) =>
      CancellationOutcome(
        booking: Booking.fromJson(
          Map<String, dynamic>.from(json['booking'] as Map),
        ),
        refundedEgp: (json['refunded_egp'] as num?)?.toInt() ?? 0,
        totalEgp: (json['total_egp'] as num?)?.toInt() ?? 0,
      );
}

final peopleRepositoryProvider = Provider<PeopleRepository>(
  (ref) => PeopleRepository(ref.watch(apiClientProvider)),
);

/// Everything the People tab reads and writes.
///
/// Filtering and paging happen server-side; the roster is never downloaded to
/// be filtered on the phone. Prices, availability and refunds all arrive
/// computed — the client renders authority it did not invent.
class PeopleRepository {
  PeopleRepository(this._client, {LocalStore? store})
    : _store = store ?? LocalStore();

  final ApiClient _client;
  final LocalStore _store;

  Future<PeopleHubCounts> hub() =>
      _client.get('/people/', parse: PeopleHubCounts.fromJson);

  Future<ProfessionalListPage> browse(ProfessionalQuery query) => _client.get(
    '/people/${query.kind.wire}',
    query: query.toQueryParameters(),
    parse: ProfessionalListPage.fromJson,
  );

  Future<ProfessionalProfile> profile(String slug) => _client.get(
    '/people/profile/$slug',
    parse: ProfessionalProfile.fromJson,
  );

  /// Slots for a window, including the unavailable ones.
  ///
  /// Unavailable times arrive marked rather than omitted, so the grid can
  /// render them untappable instead of leaving a hole where an hour should be.
  Future<List<AvailabilitySlot>> availability({
    required int professionalId,
    required DateTime from,
    required DateTime to,
  }) => _client.get(
    '/people/$professionalId/availability',
    query: {
      'from': from.toUtc().toIso8601String(),
      'to': to.toUtc().toIso8601String(),
    },
    parse: (json) => (json['items'] as List<dynamic>)
        .map(
          (item) =>
              AvailabilitySlot.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(),
  );

  /// Places a hold. Throws [ConflictFailure] when someone else got there first.
  Future<BookingHold> hold({
    required int professionalId,
    required DateTime startsAt,
    required int durationMinutes,
  }) => _client.post(
    '/people/holds',
    body: {
      'professional_id': professionalId,
      'starts_at': startsAt.toUtc().toIso8601String(),
      'duration_minutes': durationMinutes,
    },
    parse: BookingHold.fromJson,
  );

  Future<void> releaseHold(String holdId) =>
      _client.delete('/people/holds/$holdId');

  /// Confirms against a live hold.
  ///
  /// No price is sent: the server computes it from the professional's own rate
  /// or the package it looked up, and a figure from here would not be read.
  Future<Booking> confirm({
    required String holdId,
    required String subject,
    required String goal,
    int? packageId,
  }) => _client.post(
    '/people/bookings',
    body: {
      'hold_id': holdId,
      'subject': subject,
      'goal': goal,
      if (packageId != null) 'package_id': packageId,
    },
    parse: Booking.fromJson,
  );

  Future<List<Booking>> myBookings() => _client.get(
    '/people/bookings',
    parse: (json) => (json['items'] as List<dynamic>)
        .map((item) => Booking.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList(),
  );

  Future<CancellationOutcome> cancel(String bookingId) => _client.post(
    '/people/bookings/$bookingId/cancel',
    parse: CancellationOutcome.fromJson,
  );

  // --- Persisted filters ----------------------------------------------------
  //
  // Filters persist across launches, per door: re-applying them by hand every
  // time is friction the design explicitly removes. They go through
  // `LocalStore` like every other persisted preference, so there is one place
  // that knows what this app keeps on the device.

  Future<ProfessionalQuery?> storedFilters(ServiceKind kind) async {
    final stored = await _store.peopleFilters(kind.wire);
    if (stored == null) return null;
    return ProfessionalQuery.fromJson(kind, stored);
  }

  Future<void> saveFilters(ProfessionalQuery query) =>
      _store.savePeopleFilters(query.kind.wire, query.toJson());

  Future<void> clearFilters(ServiceKind kind) =>
      _store.clearPeopleFilters(kind.wire);
}
