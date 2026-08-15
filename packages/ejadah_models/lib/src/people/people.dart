import '../common/localized_text.dart';
import '../common/value.dart';

/// The three marketplace doors.
///
/// One shared profile, availability and booking architecture serves all three —
/// building three unrelated booking systems is the failure mode this enum
/// exists to prevent (brief §47).
enum ServiceKind {
  tutoring('tutoring'),
  mentoring('mentoring'),
  consulting('consulting');

  const ServiceKind(this.wire);

  final String wire;

  static ServiceKind fromWire(String? value) => ServiceKind.values.firstWhere(
    (kind) => kind.wire == value,
    orElse: () => ServiceKind.tutoring,
  );
}

/// How a credential is evidenced.
///
/// Verified and stated must be visually and technically distinct — conflating
/// them is exactly the credibility problem the product exists to solve.
enum CredentialEvidence {
  /// Ejadah checked the document.
  verifiedByEjadah('verified'),

  /// The professional asserted it; Ejadah has not checked it.
  statedByProfessional('stated');

  const CredentialEvidence(this.wire);

  final String wire;

  static CredentialEvidence fromWire(String? value) => value == 'verified'
      ? CredentialEvidence.verifiedByEjadah
      : CredentialEvidence.statedByProfessional;
}

/// A qualification on a professional's profile.
class Qualification extends ValueObject {
  const Qualification({
    required this.id,
    required this.title,
    required this.issuer,
    required this.evidence,
    this.year,
  });

  final int id;
  final LocalizedText title;
  final LocalizedText issuer;
  final CredentialEvidence evidence;
  final int? year;

  factory Qualification.fromJson(Map<String, dynamic> json) => Qualification(
    id: jsonRequire<int>(json, 'id'),
    title: LocalizedText.fromJson(json['title'])!,
    issuer:
        LocalizedText.fromJson(json['issuer']) ?? const LocalizedText.same(''),
    evidence: CredentialEvidence.fromWire(json['evidence'] as String?),
    year: jsonInt(json['year']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title.toJson(),
    'issuer': issuer.toJson(),
    'evidence': evidence.wire,
    'year': year,
  };

  @override
  List<Object?> get props => [id, evidence, year];
}

/// A multi-session package offered by a professional.
class ServicePackage extends ValueObject {
  const ServicePackage({
    required this.id,
    required this.title,
    required this.sessionCount,
    required this.sessionMinutes,
    required this.priceEgp,
    required this.cadenceSentence,
  });

  final int id;
  final LocalizedText title;

  /// Sessions are modelled individually when booked — never as one vague
  /// "8 sessions" appointment (brief §53).
  final int sessionCount;
  final int sessionMinutes;

  /// Server-authoritative. The client displays it and never computes it.
  final int priceEgp;

  /// "One 60-minute session a week for eight weeks" — the plan states its own
  /// cadence so the booking flow never re-asks what the plan already answered.
  final LocalizedText cadenceSentence;

  factory ServicePackage.fromJson(Map<String, dynamic> json) => ServicePackage(
    id: jsonRequire<int>(json, 'id'),
    title: LocalizedText.fromJson(json['title'])!,
    sessionCount: jsonInt(json['session_count']) ?? 1,
    sessionMinutes: jsonInt(json['session_minutes']) ?? 60,
    priceEgp: jsonInt(json['price_egp']) ?? 0,
    cadenceSentence:
        LocalizedText.fromJson(json['cadence_sentence']) ??
        const LocalizedText.same(''),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title.toJson(),
    'session_count': sessionCount,
    'session_minutes': sessionMinutes,
    'price_egp': priceEgp,
    'cadence_sentence': cadenceSentence.toJson(),
  };

  @override
  List<Object?> get props => [id, sessionCount, sessionMinutes, priceEgp];
}

/// A tutor, mentor or consultant.
class Professional extends ValueObject {
  const Professional({
    required this.id,
    required this.slug,
    required this.kind,
    required this.displayName,
    required this.headline,
    required this.bio,
    required this.specialties,
    required this.languages,
    required this.hourlyRateEgp,
    required this.rating,
    required this.reviewCount,
    required this.qualifications,
    required this.packages,
    required this.offersFreeIntroCall,
    required this.isNewThisMonth,
    required this.cancellationPolicy,
    this.avatarUrl,
    this.journeyFrom,
    this.journeyTo,
    this.journeyYear,
  });

  final int id;
  final String slug;
  final ServiceKind kind;
  final LocalizedText displayName;
  final LocalizedText headline;
  final LocalizedText bio;
  final List<String> specialties;
  final List<String> languages;

  /// Server-authoritative price. Rendered as an LTR-isolated island.
  final int hourlyRateEgp;
  final double? rating;
  final int reviewCount;
  final List<Qualification> qualifications;
  final List<ServicePackage> packages;

  /// 15 minutes, where the professional enables it.
  final bool offersFreeIntroCall;

  /// Drives the "New this month" rail — cold-start supply survival.
  final bool isNewThisMonth;
  final LocalizedText cancellationPolicy;
  final String? avatarUrl;

  /// A mentor is someone who made the move; their card leads with the journey
  /// ("Cairo → London, 2021"), not with a rating.
  final String? journeyFrom;
  final String? journeyTo;
  final int? journeyYear;

  bool get hasJourney => journeyFrom != null && journeyTo != null;

  /// New professionals show a "New" badge rather than an empty star row.
  bool get showsNewBadge => reviewCount == 0;

  factory Professional.fromJson(Map<String, dynamic> json) => Professional(
    id: jsonRequire<int>(json, 'id'),
    slug: jsonRequire<String>(json, 'slug'),
    kind: ServiceKind.fromWire(json['kind'] as String?),
    displayName: LocalizedText.fromJson(json['display_name'])!,
    headline:
        LocalizedText.fromJson(json['headline']) ??
        const LocalizedText.same(''),
    bio: LocalizedText.fromJson(json['bio']) ?? const LocalizedText.same(''),
    specialties: (json['specialties'] as List<dynamic>? ?? const [])
        .map((s) => s.toString())
        .toList(),
    languages: (json['languages'] as List<dynamic>? ?? const [])
        .map((l) => l.toString())
        .toList(),
    hourlyRateEgp: jsonInt(json['hourly_rate_egp']) ?? 0,
    rating: jsonDouble(json['rating']),
    reviewCount: jsonInt(json['review_count']) ?? 0,
    qualifications: (json['qualifications'] as List<dynamic>? ?? const [])
        .map((q) => Qualification.fromJson(Map<String, dynamic>.from(q as Map)))
        .toList(),
    packages: (json['packages'] as List<dynamic>? ?? const [])
        .map(
          (p) => ServicePackage.fromJson(Map<String, dynamic>.from(p as Map)),
        )
        .toList(),
    offersFreeIntroCall: jsonBool(json['offers_free_intro_call']) ?? false,
    isNewThisMonth: jsonBool(json['is_new_this_month']) ?? false,
    cancellationPolicy:
        LocalizedText.fromJson(json['cancellation_policy']) ??
        const LocalizedText.same(''),
    avatarUrl: json['avatar_url'] as String?,
    journeyFrom: json['journey_from'] as String?,
    journeyTo: json['journey_to'] as String?,
    journeyYear: jsonInt(json['journey_year']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'slug': slug,
    'kind': kind.wire,
    'display_name': displayName.toJson(),
    'headline': headline.toJson(),
    'bio': bio.toJson(),
    'specialties': specialties,
    'languages': languages,
    'hourly_rate_egp': hourlyRateEgp,
    'rating': rating,
    'review_count': reviewCount,
    'qualifications': qualifications.map((q) => q.toJson()).toList(),
    'packages': packages.map((p) => p.toJson()).toList(),
    'offers_free_intro_call': offersFreeIntroCall,
    'is_new_this_month': isNewThisMonth,
    'cancellation_policy': cancellationPolicy.toJson(),
    'avatar_url': avatarUrl,
    'journey_from': journeyFrom,
    'journey_to': journeyTo,
    'journey_year': journeyYear,
  };

  @override
  List<Object?> get props => [id, kind, hourlyRateEgp, rating, reviewCount];
}

/// A bookable slot.
///
/// Availability is computed on the server from the professional's schedule
/// rules, exceptions, live holds and existing bookings. The client never
/// invents times (brief §49).
class AvailabilitySlot extends ValueObject {
  const AvailabilitySlot({
    required this.startsAt,
    required this.endsAt,
    required this.isAvailable,
  });

  final DateTime startsAt;
  final DateTime endsAt;

  /// Unavailable slots render untappable rather than tappable-then-rejected.
  final bool isAvailable;

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) =>
      AvailabilitySlot(
        startsAt: jsonDate(json['starts_at'])!,
        endsAt: jsonDate(json['ends_at'])!,
        isAvailable: jsonBool(json['is_available']) ?? false,
      );

  Map<String, dynamic> toJson() => {
    'starts_at': startsAt.toIso8601String(),
    'ends_at': endsAt.toIso8601String(),
    'is_available': isAvailable,
  };

  @override
  List<Object?> get props => [startsAt, endsAt, isAvailable];
}

/// A temporary reservation created the moment a slot is picked.
///
/// The countdown is visible from that moment. Duration is server-controlled and
/// expiry is enforced by a background job, not by the client.
class BookingHold extends ValueObject {
  const BookingHold({
    required this.id,
    required this.professionalId,
    required this.startsAt,
    required this.endsAt,
    required this.expiresAt,
  });

  final String id;
  final int professionalId;
  final DateTime startsAt;
  final DateTime endsAt;
  final DateTime expiresAt;

  Duration remaining(DateTime now) {
    final left = expiresAt.difference(now);
    return left.isNegative ? Duration.zero : left;
  }

  bool isExpired(DateTime now) => !expiresAt.isAfter(now);

  factory BookingHold.fromJson(Map<String, dynamic> json) => BookingHold(
    id: jsonRequire<String>(json, 'id'),
    professionalId: jsonInt(json['professional_id']) ?? 0,
    startsAt: jsonDate(json['starts_at'])!,
    endsAt: jsonDate(json['ends_at'])!,
    expiresAt: jsonDate(json['expires_at'])!,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'professional_id': professionalId,
    'starts_at': startsAt.toIso8601String(),
    'ends_at': endsAt.toIso8601String(),
    'expires_at': expiresAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [id, startsAt, endsAt, expiresAt];
}

enum BookingStatus {
  /// Created, awaiting the external checkout to return.
  pendingPayment('pending_payment'),
  confirmed('confirmed'),
  completed('completed'),
  cancelledByStudent('cancelled_by_student'),
  cancelledByProfessional('cancelled_by_professional'),
  paymentFailed('payment_failed');

  const BookingStatus(this.wire);

  final String wire;

  static BookingStatus fromWire(String? value) =>
      BookingStatus.values.firstWhere(
        (status) => status.wire == value,
        orElse: () => BookingStatus.pendingPayment,
      );

  bool get isCancelled =>
      this == BookingStatus.cancelledByStudent ||
      this == BookingStatus.cancelledByProfessional;

  bool get isActive =>
      this == BookingStatus.confirmed || this == BookingStatus.pendingPayment;
}

/// One scheduled session within a booking. Every session has its own real time.
class BookingSession extends ValueObject {
  const BookingSession({
    required this.id,
    required this.position,
    required this.startsAt,
    required this.endsAt,
    required this.isAttended,
  });

  final String id;
  final int position;
  final DateTime startsAt;
  final DateTime endsAt;
  final bool isAttended;

  factory BookingSession.fromJson(Map<String, dynamic> json) => BookingSession(
    id: jsonRequire<String>(json, 'id'),
    position: jsonInt(json['position']) ?? 1,
    startsAt: jsonDate(json['starts_at'])!,
    endsAt: jsonDate(json['ends_at'])!,
    isAttended: jsonBool(json['is_attended']) ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'position': position,
    'starts_at': startsAt.toIso8601String(),
    'ends_at': endsAt.toIso8601String(),
    'is_attended': isAttended,
  };

  @override
  List<Object?> get props => [id, position, startsAt, endsAt, isAttended];
}

/// A booking record — one or many sessions bought together.
class Booking extends ValueObject {
  const Booking({
    required this.id,
    required this.professionalId,
    required this.professionalName,
    required this.kind,
    required this.status,
    required this.sessions,
    required this.totalEgp,
    required this.refundableEgp,
    required this.subject,
    required this.createdAt,
    required this.hasReview,
    this.avatarUrl,
  });

  final String id;
  final int professionalId;
  final LocalizedText professionalName;
  final ServiceKind kind;
  final BookingStatus status;
  final List<BookingSession> sessions;

  /// Server-calculated. A price arriving from the client is never trusted.
  final int totalEgp;

  /// What the user would get back if they cancelled right now. Shown BEFORE the
  /// cancel button, and again in the confirm sheet with the exact figure.
  final int refundableEgp;
  final String subject;
  final DateTime createdAt;
  final bool hasReview;
  final String? avatarUrl;

  DateTime? get firstSessionStart =>
      sessions.isEmpty ? null : sessions.first.startsAt;

  bool get isMultiSession => sessions.length > 1;

  bool get canReview =>
      !hasReview &&
      status == BookingStatus.completed &&
      sessions.any((session) => session.isAttended);

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    id: jsonRequire<String>(json, 'id'),
    professionalId: jsonInt(json['professional_id']) ?? 0,
    professionalName: LocalizedText.fromJson(json['professional_name'])!,
    kind: ServiceKind.fromWire(json['kind'] as String?),
    status: BookingStatus.fromWire(json['status'] as String?),
    sessions: (json['sessions'] as List<dynamic>? ?? const [])
        .map(
          (s) => BookingSession.fromJson(Map<String, dynamic>.from(s as Map)),
        )
        .toList(),
    totalEgp: jsonInt(json['total_egp']) ?? 0,
    refundableEgp: jsonInt(json['refundable_egp']) ?? 0,
    subject: (json['subject'] ?? '') as String,
    createdAt: jsonDate(json['created_at'])!,
    hasReview: jsonBool(json['has_review']) ?? false,
    avatarUrl: json['avatar_url'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'professional_id': professionalId,
    'professional_name': professionalName.toJson(),
    'kind': kind.wire,
    'status': status.wire,
    'sessions': sessions.map((session) => session.toJson()).toList(),
    'total_egp': totalEgp,
    'refundable_egp': refundableEgp,
    'subject': subject,
    'created_at': createdAt.toIso8601String(),
    'has_review': hasReview,
    'avatar_url': avatarUrl,
  };

  @override
  List<Object?> get props => [id, status, sessions, totalEgp, refundableEgp];
}

/// An itemised earnings row for the supply side: gross − fee = net.
///
/// The 70/30 split is shown in application step 1 and itemised in every
/// estimate — a tutor should never be surprised by the deal.
class EarningRow extends ValueObject {
  const EarningRow({
    required this.bookingId,
    required this.occurredAt,
    required this.description,
    required this.grossEgp,
    required this.platformFeeEgp,
  });

  final String bookingId;
  final DateTime occurredAt;
  final LocalizedText description;
  final int grossEgp;
  final int platformFeeEgp;

  int get netEgp => grossEgp - platformFeeEgp;

  factory EarningRow.fromJson(Map<String, dynamic> json) => EarningRow(
    bookingId: jsonRequire<String>(json, 'booking_id'),
    occurredAt: jsonDate(json['occurred_at'])!,
    description:
        LocalizedText.fromJson(json['description']) ??
        const LocalizedText.same(''),
    grossEgp: jsonInt(json['gross_egp']) ?? 0,
    platformFeeEgp: jsonInt(json['platform_fee_egp']) ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'booking_id': bookingId,
    'occurred_at': occurredAt.toIso8601String(),
    'description': description.toJson(),
    'gross_egp': grossEgp,
    'platform_fee_egp': platformFeeEgp,
  };

  @override
  List<Object?> get props => [bookingId, grossEgp, platformFeeEgp];
}
