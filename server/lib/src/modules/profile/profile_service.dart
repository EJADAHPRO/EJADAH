import 'package:ejadah_models/ejadah_models.dart';

import '../../config/config.dart';
import '../../http/api_error.dart';
import 'profile_repository.dart';

/// The public card plus the link a visitor can share on.
class PublicProfileView {
  const PublicProfileView({required this.profile, required this.shareUrl});

  final PublicProfile profile;

  /// The canonical URL of this card, so a share sheet does not have to
  /// reconstruct it and get the host wrong.
  final String shareUrl;

  Map<String, dynamic> toJson() => {
    ...profile.toJson(),
    'share_url': shareUrl,
  };
}

/// The CPD ledger with its running total.
class CpdLedger {
  const CpdLedger({required this.entries, required this.totalPoints});

  final List<CpdEntry> entries;
  final int totalPoints;

  Map<String, dynamic> toJson() => {
    'items': entries.map((entry) => entry.toJson()).toList(),
    'total_points': totalPoints,
  };
}

/// Profile use-cases: the public card, public verification, certificates, the
/// CPD ledger and notification preferences.
///
/// Two of these methods are the product's only organic growth: [publicProfile]
/// and [verifyCertificate] take no user id, are never charged for, and must
/// keep working for a signed-out stranger.
class ProfileService {
  const ProfileService({required this.repository, required this.config});

  final ProfileRepository repository;
  final AppConfig config;

  /// A handle is lowercase letters, digits and single hyphens. It appears in a
  /// printed URL on a physical card, so it stays short and unambiguous.
  static final RegExp slugPattern = RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$');

  static const int slugMinLength = 3;
  static const int slugMaxLength = 40;
  static const int bioMaxLength = 400;

  /// Link keys the card renders. Anything else is dropped rather than stored,
  /// so the public payload cannot be used as arbitrary storage.
  static const Set<String> allowedLinkKeys = {
    'website',
    'linkedin',
    'instagram',
    'facebook',
    'x',
    'whatsapp',
  };

  // --- Public -----------------------------------------------------------

  /// The card at `/dr/{slug}`, for anyone, signed in or not.
  ///
  /// The view is counted in aggregate as a side effect. The counter failing
  /// must never cost a visitor the page, so it is best-effort.
  Future<PublicProfileView> publicProfile(String slug) async {
    final normalised = slug.trim().toLowerCase();
    final profile = await repository.findPublicProfile(normalised);
    if (profile == null) throw ApiException.notFound();

    try {
      await repository.recordPublicView(normalised);
    } on Object {
      // Analytics are never load-bearing for a page the growth loop depends on.
    }

    return PublicProfileView(
      profile: profile,
      shareUrl: publicUrlFor(profile.slug),
    );
  }

  String publicUrlFor(String slug) => '${config.publicBaseUrl}/dr/$slug';

  String verifyUrlFor(String code) => '${config.publicBaseUrl}/verify/$code';

  /// The answer to `/verify/{code}`.
  ///
  /// Always a 200 with an outcome, never a 404: "no certificate with that
  /// code" is an answer the checker asked for, not a failure of the request.
  Future<CertificateVerification> verifyCertificate(String code) {
    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      return Future.value(
        const CertificateVerification(outcome: VerificationOutcome.notFound),
      );
    }
    return repository.verifyCertificate(trimmed);
  }

  // --- The owner's own card -------------------------------------------------

  Future<OwnerProfile> ownerProfile(String userId) async {
    final profile = await repository.findOwnerProfile(userId);
    if (profile == null) throw ApiException.notFound();
    return profile;
  }

  /// Saves the card. Validation lives here rather than in the route so the
  /// same rules apply to the seed tool and to any future caller.
  Future<OwnerProfile> saveOwnerProfile({
    required String userId,
    String? slug,
    required bool isPublic,
    required LocalizedText title,
    required LocalizedText clinic,
    required LocalizedText bio,
    Map<String, String> links = const {},
    String? phone,
  }) async {
    final fields = <String, LocalizedText>{};

    String? normalisedSlug;
    if (slug != null && slug.trim().isNotEmpty) {
      normalisedSlug = slug.trim().toLowerCase();
      if (normalisedSlug.length < slugMinLength ||
          normalisedSlug.length > slugMaxLength ||
          !slugPattern.hasMatch(normalisedSlug)) {
        fields['slug'] = const LocalizedText(
          en: 'Use $slugMinLength–$slugMaxLength lowercase letters, numbers '
              'and hyphens.',
          ar: 'استخدم حروفًا إنجليزية صغيرة وأرقامًا وشرطات فقط.',
        );
      } else if (await repository.slugTaken(normalisedSlug, userId: userId)) {
        fields['slug'] = const LocalizedText(
          en: 'That handle is taken. Try another.',
          ar: 'هذا المُعرّف مستخدم. جرّب غيره.',
        );
      }
    }

    if (isPublic && normalisedSlug == null) {
      final existing = await repository.findOwnerProfile(userId);
      if (existing?.slug == null) {
        fields['slug'] = const LocalizedText(
          en: 'Choose a handle before publishing your card.',
          ar: 'اختر مُعرّفًا قبل نشر بطاقتك.',
        );
      }
    }

    if (bio.en.length > bioMaxLength || bio.ar.length > bioMaxLength) {
      fields['bio'] = const LocalizedText(
        en: 'Keep the bio under $bioMaxLength characters.',
        ar: 'اجعل النبذة أقل من $bioMaxLength حرفًا.',
      );
    }

    final cleanLinks = <String, String>{};
    for (final entry in links.entries) {
      final key = entry.key.trim().toLowerCase();
      final value = entry.value.trim();
      if (value.isEmpty) continue;
      if (!allowedLinkKeys.contains(key)) continue;
      if (!isHttpsUrl(value)) {
        fields['links.$key'] = const LocalizedText(
          en: 'Links must start with https://',
          ar: 'يجب أن تبدأ الروابط بـ https://',
        );
        continue;
      }
      cleanLinks[key] = value;
    }

    if (fields.isNotEmpty) throw ApiException.validation(fields);

    await repository.saveOwnerProfile(
      userId: userId,
      slug: normalisedSlug,
      isPublic: isPublic,
      title: title,
      clinic: clinic,
      bio: bio,
      links: cleanLinks,
      phone: phone,
    );
    return ownerProfile(userId);
  }

  /// An https URL and nothing else.
  ///
  /// http:// is rejected rather than upgraded: a card printed with a plaintext
  /// link is a downgrade a stranger cannot see.
  static bool isHttpsUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        uri.isAbsolute &&
        uri.scheme == 'https' &&
        uri.host.isNotEmpty;
  }

  // --- Certificates ---------------------------------------------------------

  Future<List<Certificate>> certificates(String userId) =>
      repository.certificates(userId);

  /// Adds a certificate the user states themselves.
  ///
  /// Always `stated`, never with a code. The caller cannot ask for anything
  /// else — there is no parameter for it — and the schema refuses the row even
  /// if this method were changed.
  Future<Certificate> addStatedCertificate({
    required String userId,
    required LocalizedText title,
    required LocalizedText issuer,
    required DateTime issuedOn,
    int cpdPoints = 0,
    String? documentKey,
    DateTime? now,
  }) async {
    final fields = <String, LocalizedText>{};
    if (title.en.trim().isEmpty && title.ar.trim().isEmpty) {
      fields['title'] = const LocalizedText(
        en: 'Give the certificate a name.',
        ar: 'اكتب اسم الشهادة.',
      );
    }
    final today = (now ?? DateTime.now().toUtc());
    if (issuedOn.isAfter(today)) {
      fields['issued_on'] = const LocalizedText(
        en: 'The issue date cannot be in the future.',
        ar: 'لا يمكن أن يكون تاريخ الإصدار في المستقبل.',
      );
    }
    if (cpdPoints < 0) {
      fields['cpd_points'] = const LocalizedText(
        en: 'CPD points cannot be negative.',
        ar: 'لا يمكن أن تكون النقاط سالبة.',
      );
    }
    if (fields.isNotEmpty) throw ApiException.validation(fields);

    final resolvedTitle = title.en.trim().isEmpty
        ? LocalizedText(en: title.ar, ar: title.ar)
        : (title.ar.trim().isEmpty
              ? LocalizedText(en: title.en, ar: title.en)
              : title);

    return repository.addStatedCertificate(
      userId: userId,
      title: resolvedTitle,
      issuer: issuer,
      issuedOn: issuedOn,
      cpdPoints: cpdPoints,
      documentKey: documentKey,
    );
  }

  Future<void> deleteCertificate({
    required String userId,
    required String certificateId,
  }) => repository.deleteCertificate(
    userId: userId,
    certificateId: certificateId,
  );

  // --- CPD ------------------------------------------------------------------

  Future<CpdLedger> cpdLedger(String userId) async {
    final entries = await repository.cpdEntries(userId);
    return CpdLedger(
      entries: entries,
      totalPoints: entries.fold(0, (sum, entry) => sum + entry.points),
    );
  }

  // --- Notification preferences ---------------------------------------------

  Future<NotificationPreferences> notificationPreferences(String userId) =>
      repository.notificationPreferences(userId);

  Future<NotificationPreferences> saveNotificationPreferences(
    String userId,
    NotificationPreferences preferences,
  ) async {
    await repository.saveNotificationPreferences(userId, preferences);
    return preferences;
  }
}
