import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';

/// The owner's own card, including the fields the public page never carries.
class MyProfileCard {
  const MyProfileCard({
    required this.slug,
    required this.isPublic,
    required this.displayName,
    required this.title,
    required this.clinic,
    required this.bio,
    required this.links,
    required this.publicViewCount,
    this.phone,
    this.shareUrl,
  });

  final String? slug;
  final bool isPublic;
  final LocalizedText displayName;
  final LocalizedText title;
  final LocalizedText clinic;
  final LocalizedText bio;
  final Map<String, String> links;

  /// Aggregate only. The product never names a viewer, so there is nothing
  /// else here to show.
  final int publicViewCount;
  final String? phone;

  /// The canonical `/dr/{slug}` URL, absent until a handle is claimed.
  final String? shareUrl;

  bool get isPublished => isPublic && slug != null;

  factory MyProfileCard.fromJson(Map<String, dynamic> json) => MyProfileCard(
    slug: json['slug'] as String?,
    isPublic: json['is_public'] as bool? ?? false,
    displayName:
        LocalizedText.fromJson(json['display_name']) ??
        const LocalizedText.same(''),
    title:
        LocalizedText.fromJson(json['title']) ?? const LocalizedText.same(''),
    clinic:
        LocalizedText.fromJson(json['clinic']) ?? const LocalizedText.same(''),
    bio: LocalizedText.fromJson(json['bio']) ?? const LocalizedText.same(''),
    links: (json['links'] as Map<dynamic, dynamic>? ?? const {}).map(
      (key, value) => MapEntry(key.toString(), value.toString()),
    ),
    publicViewCount: (json['public_view_count'] as num?)?.toInt() ?? 0,
    phone: json['phone'] as String?,
    shareUrl: json['share_url'] as String?,
  );
}

/// A public card plus the link to share it on.
class PublicProfileView {
  const PublicProfileView({required this.profile, required this.shareUrl});

  final PublicProfile profile;
  final String shareUrl;

  factory PublicProfileView.fromJson(Map<String, dynamic> json) =>
      PublicProfileView(
        profile: PublicProfile.fromJson(json),
        shareUrl: json['share_url'] as String? ?? '',
      );
}

/// The CPD ledger and its running total.
class CpdLedger {
  const CpdLedger({required this.entries, required this.totalPoints});

  final List<CpdEntry> entries;
  final int totalPoints;

  factory CpdLedger.fromJson(Map<String, dynamic> json) => CpdLedger(
    entries: (json['items'] as List<dynamic>? ?? const [])
        .map((e) => CpdEntry.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    totalPoints: (json['total_points'] as num?)?.toInt() ?? 0,
  );
}

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(apiClientProvider)),
);

/// Everything the Profile tab reads and writes.
///
/// The first two methods carry no credentials by design: `/dr/{slug}` and
/// `/verify/{code}` are the growth and trust loops, and a signed-out visitor
/// must be able to complete both.
class ProfileRepository {
  const ProfileRepository(this._client);

  final ApiClient _client;

  Future<PublicProfileView> publicProfile(String slug) => _client.get(
    '/profile/public/$slug',
    parse: PublicProfileView.fromJson,
  );

  Future<CertificateVerification> verifyCertificate(String code) => _client.get(
    '/profile/verify/$code',
    parse: CertificateVerification.fromJson,
  );

  Future<MyProfileCard> myCard() =>
      _client.get('/profile/me', parse: MyProfileCard.fromJson);

  Future<MyProfileCard> saveCard({
    String? slug,
    required bool isPublic,
    required LocalizedText title,
    required LocalizedText clinic,
    required LocalizedText bio,
    required Map<String, String> links,
    String? phone,
  }) => _client.put(
    '/profile/me',
    body: {
      if (slug != null && slug.isNotEmpty) 'slug': slug,
      'is_public': isPublic,
      'title': title.toJson(),
      'clinic': clinic.toJson(),
      'bio': bio.toJson(),
      'links': links,
      'phone': phone,
    },
    parse: MyProfileCard.fromJson,
  );

  Future<List<Certificate>> certificates() => _client.get(
    '/profile/certificates',
    parse: (json) => (json['items'] as List<dynamic>? ?? const [])
        .map((c) => Certificate.fromJson(Map<String, dynamic>.from(c as Map)))
        .toList(),
  );

  /// Adds a certificate the user states themselves.
  ///
  /// There is no evidence parameter and no code parameter: a user-added
  /// certificate is always stated, and the server and the schema both enforce
  /// it. Nothing the client sends can make one look verified.
  Future<Certificate> addStatedCertificate({
    required LocalizedText title,
    required LocalizedText issuer,
    required DateTime issuedOn,
    int cpdPoints = 0,
  }) => _client.post(
    '/profile/certificates',
    body: {
      'title': title.toJson(),
      'issuer': issuer.toJson(),
      'issued_on': issuedOn.toIso8601String(),
      'cpd_points': cpdPoints,
    },
    parse: Certificate.fromJson,
  );

  Future<void> deleteCertificate(String id) =>
      _client.delete('/profile/certificates/$id');

  Future<CpdLedger> cpdLedger() =>
      _client.get('/profile/cpd', parse: CpdLedger.fromJson);

  Future<NotificationPreferences> notificationPreferences() => _client.get(
    '/profile/notifications/preferences',
    parse: NotificationPreferences.fromJson,
  );

  Future<NotificationPreferences> saveNotificationPreferences(
    NotificationPreferences preferences,
  ) => _client.put(
    '/profile/notifications/preferences',
    body: preferences.toJson(),
    parse: NotificationPreferences.fromJson,
  );

  /// Starts the 30-day deletion window.
  ///
  /// The server already implements this as a soft delete with an undo window
  /// and keeps tax invoices; the client only asks for it.
  Future<void> deleteAccount() => _client.delete('/auth/me');
}
