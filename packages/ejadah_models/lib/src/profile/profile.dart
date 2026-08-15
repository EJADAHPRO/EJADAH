import '../common/localized_text.dart';
import '../common/value.dart';
import '../people/people.dart';

/// A certificate on a user's profile.
///
/// Courses completed on Ejadah are **verified**. Certificates the user adds
/// themselves are displayed but explicitly **unverified**, and the distinction
/// is visible at a glance. Implying verification that has not occurred is the
/// one thing this model must make impossible.
class Certificate extends ValueObject {
  const Certificate({
    required this.id,
    required this.title,
    required this.issuer,
    required this.issuedOn,
    required this.evidence,
    required this.cpdPoints,
    this.verificationCode,
    this.courseId,
    this.documentUrl,
  });

  final String id;
  final LocalizedText title;
  final LocalizedText issuer;
  final DateTime issuedOn;
  final CredentialEvidence evidence;
  final int cpdPoints;

  /// Only Ejadah-issued certificates carry a public verification code.
  final String? verificationCode;
  final int? courseId;
  final String? documentUrl;

  bool get isEjadahIssued =>
      evidence == CredentialEvidence.verifiedByEjadah &&
      verificationCode != null;

  factory Certificate.fromJson(Map<String, dynamic> json) => Certificate(
    id: jsonRequire<String>(json, 'id'),
    title: LocalizedText.fromJson(json['title'])!,
    issuer:
        LocalizedText.fromJson(json['issuer']) ?? const LocalizedText.same(''),
    issuedOn: jsonDate(json['issued_on'])!,
    evidence: CredentialEvidence.fromWire(json['evidence'] as String?),
    cpdPoints: jsonInt(json['cpd_points']) ?? 0,
    verificationCode: json['verification_code'] as String?,
    courseId: jsonInt(json['course_id']),
    documentUrl: json['document_url'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title.toJson(),
    'issuer': issuer.toJson(),
    'issued_on': issuedOn.toIso8601String(),
    'evidence': evidence.wire,
    'cpd_points': cpdPoints,
    'verification_code': verificationCode,
    'course_id': courseId,
    'document_url': documentUrl,
  };

  @override
  List<Object?> get props => [id, evidence, verificationCode, cpdPoints];
}

/// The outcome of a public certificate check.
enum VerificationOutcome {
  verified('verified'),
  notFound('not_found'),
  revoked('revoked');

  const VerificationOutcome(this.wire);

  final String wire;

  static VerificationOutcome fromWire(String? value) => switch (value) {
    'verified' => VerificationOutcome.verified,
    'revoked' => VerificationOutcome.revoked,
    _ => VerificationOutcome.notFound,
  };
}

/// The public answer to `/verify/{code}`.
///
/// Requires no account and is never charged for. Exposes only what a third
/// party needs to trust the credential — never private account data.
class CertificateVerification extends ValueObject {
  const CertificateVerification({
    required this.outcome,
    this.holderName,
    this.title,
    this.issuedOn,
    this.cpdPoints,
    this.revokedOn,
  });

  final VerificationOutcome outcome;
  final LocalizedText? holderName;
  final LocalizedText? title;
  final DateTime? issuedOn;
  final int? cpdPoints;
  final DateTime? revokedOn;

  factory CertificateVerification.fromJson(Map<String, dynamic> json) =>
      CertificateVerification(
        outcome: VerificationOutcome.fromWire(json['outcome'] as String?),
        holderName: LocalizedText.fromJson(json['holder_name']),
        title: LocalizedText.fromJson(json['title']),
        issuedOn: jsonDate(json['issued_on']),
        cpdPoints: jsonInt(json['cpd_points']),
        revokedOn: jsonDate(json['revoked_on']),
      );

  Map<String, dynamic> toJson() => {
    'outcome': outcome.wire,
    if (holderName != null) 'holder_name': holderName!.toJson(),
    if (title != null) 'title': title!.toJson(),
    if (issuedOn != null) 'issued_on': issuedOn!.toIso8601String(),
    if (cpdPoints != null) 'cpd_points': cpdPoints,
    if (revokedOn != null) 'revoked_on': revokedOn!.toIso8601String(),
  };

  @override
  List<Object?> get props => [outcome, holderName, title, issuedOn];
}

/// The public NFC profile at `/dr/{slug}`.
///
/// Renders for signed-out visitors — it is the only organic growth loop in the
/// product, so it is never gated. Only fields intended to be public appear
/// here; view analytics are private and viewers are never named.
class PublicProfile extends ValueObject {
  const PublicProfile({
    required this.slug,
    required this.displayName,
    required this.title,
    required this.clinic,
    required this.bio,
    required this.certificates,
    required this.links,
    this.avatarUrl,
  });

  final String slug;
  final LocalizedText displayName;
  final LocalizedText title;
  final LocalizedText clinic;
  final LocalizedText bio;

  /// Only verified certificates appear publicly, and they are labelled as such.
  final List<Certificate> certificates;
  final Map<String, String> links;
  final String? avatarUrl;

  factory PublicProfile.fromJson(Map<String, dynamic> json) => PublicProfile(
    slug: jsonRequire<String>(json, 'slug'),
    displayName: LocalizedText.fromJson(json['display_name'])!,
    title:
        LocalizedText.fromJson(json['title']) ?? const LocalizedText.same(''),
    clinic:
        LocalizedText.fromJson(json['clinic']) ?? const LocalizedText.same(''),
    bio: LocalizedText.fromJson(json['bio']) ?? const LocalizedText.same(''),
    certificates: (json['certificates'] as List<dynamic>? ?? const [])
        .map((c) => Certificate.fromJson(Map<String, dynamic>.from(c as Map)))
        .toList(),
    links: (json['links'] as Map<dynamic, dynamic>? ?? const {}).map(
      (key, value) => MapEntry(key.toString(), value.toString()),
    ),
    avatarUrl: json['avatar_url'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'slug': slug,
    'display_name': displayName.toJson(),
    'title': title.toJson(),
    'clinic': clinic.toJson(),
    'bio': bio.toJson(),
    'certificates': certificates.map((c) => c.toJson()).toList(),
    'links': links,
    'avatar_url': avatarUrl,
  };

  @override
  List<Object?> get props => [slug, displayName, certificates];
}

/// One CPD ledger entry.
class CpdEntry extends ValueObject {
  const CpdEntry({
    required this.id,
    required this.title,
    required this.points,
    required this.earnedOn,
    required this.evidence,
    this.certificateId,
  });

  final String id;
  final LocalizedText title;
  final int points;
  final DateTime earnedOn;
  final CredentialEvidence evidence;
  final String? certificateId;

  factory CpdEntry.fromJson(Map<String, dynamic> json) => CpdEntry(
    id: jsonRequire<String>(json, 'id'),
    title: LocalizedText.fromJson(json['title'])!,
    points: jsonInt(json['points']) ?? 0,
    earnedOn: jsonDate(json['earned_on'])!,
    evidence: CredentialEvidence.fromWire(json['evidence'] as String?),
    certificateId: json['certificate_id'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title.toJson(),
    'points': points,
    'earned_on': earnedOn.toIso8601String(),
    'evidence': evidence.wire,
    'certificate_id': certificateId,
  };

  @override
  List<Object?> get props => [id, points, earnedOn, evidence];
}

/// The three notification categories. There is no marketing category, by
/// design, and each can be switched off separately.
class NotificationPreferences extends ValueObject {
  const NotificationPreferences({
    required this.deadlineAlerts,
    required this.sessionReminders,
    required this.studyNudges,
  });

  const NotificationPreferences.allEnabled()
    : deadlineAlerts = true,
      sessionReminders = true,
      studyNudges = true;

  final bool deadlineAlerts;
  final bool sessionReminders;
  final bool studyNudges;

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      NotificationPreferences(
        deadlineAlerts: jsonBool(json['deadline_alerts']) ?? true,
        sessionReminders: jsonBool(json['session_reminders']) ?? true,
        studyNudges: jsonBool(json['study_nudges']) ?? true,
      );

  Map<String, dynamic> toJson() => {
    'deadline_alerts': deadlineAlerts,
    'session_reminders': sessionReminders,
    'study_nudges': studyNudges,
  };

  NotificationPreferences copyWith({
    bool? deadlineAlerts,
    bool? sessionReminders,
    bool? studyNudges,
  }) => NotificationPreferences(
    deadlineAlerts: deadlineAlerts ?? this.deadlineAlerts,
    sessionReminders: sessionReminders ?? this.sessionReminders,
    studyNudges: studyNudges ?? this.studyNudges,
  );

  @override
  List<Object?> get props => [deadlineAlerts, sessionReminders, studyNudges];
}

/// The category a delivered notification belongs to.
enum NotificationCategory {
  deadline('deadline'),
  session('session'),
  study('study');

  const NotificationCategory(this.wire);

  final String wire;

  static NotificationCategory fromWire(String? value) => switch (value) {
    'session' => NotificationCategory.session,
    'study' => NotificationCategory.study,
    _ => NotificationCategory.deadline,
  };
}

/// A row in the notification centre.
class AppNotification extends ValueObject {
  const AppNotification({
    required this.id,
    required this.category,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    this.deepLink,
  });

  final String id;
  final NotificationCategory category;
  final LocalizedText title;
  final LocalizedText body;
  final DateTime createdAt;
  final bool isRead;
  final String? deepLink;

  factory AppNotification.fromJson(
    Map<String, dynamic> json,
  ) => AppNotification(
    id: jsonRequire<String>(json, 'id'),
    category: NotificationCategory.fromWire(json['category'] as String?),
    title: LocalizedText.fromJson(json['title'])!,
    body: LocalizedText.fromJson(json['body']) ?? const LocalizedText.same(''),
    createdAt: jsonDate(json['created_at'])!,
    isRead: jsonBool(json['is_read']) ?? false,
    deepLink: json['deep_link'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category.wire,
    'title': title.toJson(),
    'body': body.toJson(),
    'created_at': createdAt.toIso8601String(),
    'is_read': isRead,
    'deep_link': deepLink,
  };

  @override
  List<Object?> get props => [id, category, isRead, createdAt];
}
