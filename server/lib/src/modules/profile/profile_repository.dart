import 'dart:convert';

import 'package:ejadah_models/ejadah_models.dart';
import 'package:postgres/postgres.dart';

import '../../db/database.dart';

/// The owner's own view of their profile.
///
/// Deliberately a separate type from [PublicProfile]: the public projection is
/// built by a different query that cannot reach these columns, so a private
/// field can never be leaked by forgetting to strip it. Adding a field here
/// does not add it to `/profile/public/{slug}`.
class OwnerProfile {
  const OwnerProfile({
    required this.userId,
    required this.slug,
    required this.isPublic,
    required this.displayName,
    required this.title,
    required this.clinic,
    required this.bio,
    required this.links,
    required this.publicViewCount,
    this.phone,
  });

  final String userId;

  /// Null until the user claims a handle. `/dr/{slug}` needs one.
  final String? slug;
  final bool isPublic;
  final LocalizedText displayName;
  final LocalizedText title;
  final LocalizedText clinic;
  final LocalizedText bio;
  final Map<String, String> links;

  /// Private to the owner, never public.
  final String? phone;

  /// How many times the public card was opened, in aggregate.
  ///
  /// A count and nothing else: `public_profile_views` stores no viewer
  /// identity, so there is no query that could name one.
  final int publicViewCount;

  Map<String, dynamic> toJson() => {
    'slug': slug,
    'is_public': isPublic,
    'display_name': displayName.toJson(),
    'title': title.toJson(),
    'clinic': clinic.toJson(),
    'bio': bio.toJson(),
    'links': links,
    'phone': phone,
    'public_view_count': publicViewCount,
  };
}

/// All database access for profiles, certificates and the CPD ledger.
///
/// The public reads at the top of this file are the growth and trust loops:
/// they take no user id, run for a signed-out visitor, and select an explicit
/// column list rather than `*` so a column added to `users` or `profiles`
/// tomorrow cannot silently become public.
class ProfileRepository {
  const ProfileRepository(this._database);

  final Database _database;

  // --- Public: `/dr/{slug}` -------------------------------------------------

  /// The public card for [slug], or null when there is no published profile.
  ///
  /// Requires `is_public` and a live account. A deleted account's card stops
  /// resolving immediately, even though the row survives its 30-day undo
  /// window.
  Future<PublicProfile?> findPublicProfile(String slug) async {
    final rows = await _query(
      '''
      SELECT u.id,
             u.public_slug,
             u.full_name_en,
             u.full_name_ar,
             p.title_en, p.title_ar,
             p.clinic_en, p.clinic_ar,
             p.bio_en, p.bio_ar,
             p.links
      FROM users u
      JOIN profiles p ON p.user_id = u.id
      WHERE u.public_slug = @slug
        AND u.deleted_at IS NULL
        AND p.is_public = true
      ''',
      {'slug': slug},
    );
    if (rows.isEmpty) return null;
    final row = rows.first;

    return PublicProfile(
      slug: row.str('public_slug'),
      displayName: LocalizedText(
        en: row.str('full_name_en'),
        ar: row.str('full_name_ar'),
      ),
      title: LocalizedText(en: row.str('title_en'), ar: row.str('title_ar')),
      clinic: LocalizedText(en: row.str('clinic_en'), ar: row.str('clinic_ar')),
      bio: LocalizedText(en: row.str('bio_en'), ar: row.str('bio_ar')),
      certificates: await _publicCertificates(row.str('id')),
      links: _readLinks(row['links']),
      // No avatar is ever published. Phase 1 ships no licensed portraits, and
      // the card renders initials — a broken image is never shown.
      avatarUrl: null,
    );
  }

  /// The verified, unrevoked certificates that may appear on a public card.
  ///
  /// The `evidence = 'verified'` filter is the product rule; the schema's
  /// `certificates_verified_are_ejadah_issued` constraint is what guarantees
  /// only an Ejadah course can reach that value in the first place.
  Future<List<Certificate>> _publicCertificates(String userId) async {
    final rows = await _query(
      '''
      SELECT id, title_en, title_ar, issuer_en, issuer_ar, issued_on,
             evidence, cpd_points, course_id, verification_code
      FROM certificates
      WHERE user_id = @user
        AND evidence = 'verified'
        AND revoked_at IS NULL
      ORDER BY issued_on DESC
      ''',
      {'user': userId},
    );
    // `document_key` is deliberately absent: it addresses a private object in
    // storage and has no business on a public page.
    return rows.map((row) => _toCertificate(row, includeDocument: false)).toList();
  }

  /// Counts one view of [slug], in aggregate only.
  ///
  /// One row per slug per day holding a count. No viewer identity is recorded
  /// anywhere, so the owner cannot be shown who looked even by a future
  /// feature — the data does not exist.
  Future<void> recordPublicView(String slug) => _execute(
    '''
    INSERT INTO public_profile_views (slug, viewed_on, view_count)
    VALUES (@slug, CURRENT_DATE, 1)
    ON CONFLICT (slug, viewed_on)
    DO UPDATE SET view_count = public_profile_views.view_count + 1
    ''',
    {'slug': slug},
  );

  // --- Public: `/verify/{code}` ---------------------------------------------

  /// Looks up a certificate by its public verification code.
  ///
  /// Three outcomes and nothing between them. A revoked certificate returns
  /// [VerificationOutcome.revoked] carrying only the revocation date: the
  /// certificate body is withheld, because printing it beside a "revoked"
  /// label is exactly the confusion a checker must not be left with.
  Future<CertificateVerification> verifyCertificate(String code) async {
    final rows = await _query(
      '''
      SELECT c.title_en, c.title_ar, c.issued_on, c.cpd_points, c.revoked_at,
             u.full_name_en, u.full_name_ar
      FROM certificates c
      JOIN users u ON u.id = c.user_id
      WHERE c.verification_code = @code
      ''',
      {'code': code},
    );
    if (rows.isEmpty) {
      return const CertificateVerification(
        outcome: VerificationOutcome.notFound,
      );
    }

    final row = rows.first;
    final revokedOn = row.dateOrNull('revoked_at');
    if (revokedOn != null) {
      return CertificateVerification(
        outcome: VerificationOutcome.revoked,
        revokedOn: revokedOn,
      );
    }

    return CertificateVerification(
      outcome: VerificationOutcome.verified,
      holderName: LocalizedText(
        en: row.str('full_name_en'),
        ar: row.str('full_name_ar'),
      ),
      title: LocalizedText(en: row.str('title_en'), ar: row.str('title_ar')),
      issuedOn: row.dateAt('issued_on'),
      cpdPoints: row.intAt('cpd_points'),
    );
  }

  // --- The owner's own profile ----------------------------------------------

  Future<OwnerProfile?> findOwnerProfile(String userId) async {
    final rows = await _query(
      '''
      SELECT u.id, u.public_slug, u.full_name_en, u.full_name_ar,
             p.title_en, p.title_ar, p.clinic_en, p.clinic_ar,
             p.bio_en, p.bio_ar, p.phone, p.links, p.is_public
      FROM users u
      LEFT JOIN profiles p ON p.user_id = u.id
      WHERE u.id = @user AND u.deleted_at IS NULL
      ''',
      {'user': userId},
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    final slug = row.strOrNull('public_slug');

    return OwnerProfile(
      userId: row.str('id'),
      slug: slug,
      isPublic: row.boolOrNull('is_public') ?? false,
      displayName: LocalizedText(
        en: row.str('full_name_en'),
        ar: row.str('full_name_ar'),
      ),
      title: LocalizedText(
        en: row.strOrNull('title_en') ?? '',
        ar: row.strOrNull('title_ar') ?? '',
      ),
      clinic: LocalizedText(
        en: row.strOrNull('clinic_en') ?? '',
        ar: row.strOrNull('clinic_ar') ?? '',
      ),
      bio: LocalizedText(
        en: row.strOrNull('bio_en') ?? '',
        ar: row.strOrNull('bio_ar') ?? '',
      ),
      links: _readLinks(row['links']),
      phone: row.strOrNull('phone'),
      publicViewCount: slug == null ? 0 : await publicViewCount(slug),
    );
  }

  /// The aggregate view count for a slug. There is no per-viewer breakdown to
  /// return, by design.
  Future<int> publicViewCount(String slug) async {
    final rows = await _query(
      '''
      SELECT coalesce(sum(view_count), 0)::int AS total
      FROM public_profile_views
      WHERE slug = @slug
      ''',
      {'slug': slug},
    );
    return rows.first.intAt('total');
  }

  /// Creates or updates the card. Runs in one transaction because the slug
  /// lives on `users` and everything else on `profiles`.
  Future<void> saveOwnerProfile({
    required String userId,
    required String? slug,
    required bool isPublic,
    required LocalizedText title,
    required LocalizedText clinic,
    required LocalizedText bio,
    required Map<String, String> links,
    String? phone,
  }) => _database.runTx((tx) async {
    if (slug != null) {
      await tx.execute(
        Sql.named('UPDATE users SET public_slug = @slug, updated_at = now() '
            'WHERE id = @user'),
        parameters: {'slug': slug, 'user': userId},
      );
    }
    await tx.execute(
      Sql.named('''
        INSERT INTO profiles (
          user_id, title_en, title_ar, clinic_en, clinic_ar,
          bio_en, bio_ar, phone, links, is_public, updated_at
        ) VALUES (
          @user, @title_en, @title_ar, @clinic_en, @clinic_ar,
          @bio_en, @bio_ar, @phone, @links::jsonb, @is_public, now()
        )
        ON CONFLICT (user_id) DO UPDATE SET
          title_en = EXCLUDED.title_en,
          title_ar = EXCLUDED.title_ar,
          clinic_en = EXCLUDED.clinic_en,
          clinic_ar = EXCLUDED.clinic_ar,
          bio_en = EXCLUDED.bio_en,
          bio_ar = EXCLUDED.bio_ar,
          phone = EXCLUDED.phone,
          links = EXCLUDED.links,
          is_public = EXCLUDED.is_public,
          updated_at = now()
      '''),
      parameters: {
        'user': userId,
        'title_en': title.en,
        'title_ar': title.ar,
        'clinic_en': clinic.en,
        'clinic_ar': clinic.ar,
        'bio_en': bio.en,
        'bio_ar': bio.ar,
        'phone': phone,
        'links': jsonEncode(links),
        'is_public': isPublic,
      },
    );
  });

  /// True when [slug] is taken by someone other than [userId].
  Future<bool> slugTaken(String slug, {required String userId}) async {
    final rows = await _query(
      '''
      SELECT 1 FROM users
      WHERE public_slug = @slug AND id <> @user AND deleted_at IS NULL
      ''',
      {'slug': slug, 'user': userId},
    );
    return rows.isNotEmpty;
  }

  // --- Certificates ---------------------------------------------------------

  /// Every certificate the owner holds, verified and stated alike.
  Future<List<Certificate>> certificates(String userId) async {
    final rows = await _query(
      '''
      SELECT id, title_en, title_ar, issuer_en, issuer_ar, issued_on,
             evidence, cpd_points, course_id, verification_code, document_key,
             revoked_at
      FROM certificates
      WHERE user_id = @user
      ORDER BY issued_on DESC, created_at DESC
      ''',
      {'user': userId},
    );
    return rows.map((row) => _toCertificate(row)).toList();
  }

  /// Adds a certificate the user states themselves.
  ///
  /// `evidence` is hard-coded to `stated` and no verification code is written.
  /// Even if this method were called with intent to forge one, the schema's
  /// `certificates_only_verified_have_codes` check would reject the row.
  Future<Certificate> addStatedCertificate({
    required String userId,
    required LocalizedText title,
    required LocalizedText issuer,
    required DateTime issuedOn,
    int cpdPoints = 0,
    String? documentKey,
  }) async {
    final rows = await _query(
      '''
      INSERT INTO certificates (
        user_id, title_en, title_ar, issuer_en, issuer_ar, issued_on,
        evidence, cpd_points, document_key
      ) VALUES (
        @user, @title_en, @title_ar, @issuer_en, @issuer_ar, @issued_on,
        'stated', @cpd_points, @document_key
      )
      RETURNING id, title_en, title_ar, issuer_en, issuer_ar, issued_on,
                evidence, cpd_points, course_id, verification_code,
                document_key, revoked_at
      ''',
      {
        'user': userId,
        'title_en': title.en,
        'title_ar': title.ar,
        'issuer_en': issuer.en,
        'issuer_ar': issuer.ar,
        'issued_on': issuedOn,
        'cpd_points': cpdPoints,
        'document_key': documentKey,
      },
    );
    return _toCertificate(rows.first);
  }

  Future<void> deleteCertificate({
    required String userId,
    required String certificateId,
  }) => _execute(
    // Scoped by user id: an id guessed from someone else's public card
    // deletes nothing.
    'DELETE FROM certificates WHERE id = @id AND user_id = @user',
    {'id': certificateId, 'user': userId},
  );

  // --- CPD ledger -----------------------------------------------------------

  Future<List<CpdEntry>> cpdEntries(String userId) async {
    final rows = await _query(
      '''
      SELECT id, title_en, title_ar, points, earned_on, evidence, certificate_id
      FROM cpd_entries
      WHERE user_id = @user
      ORDER BY earned_on DESC, created_at DESC
      ''',
      {'user': userId},
    );
    return rows
        .map(
          (row) => CpdEntry(
            id: row.str('id'),
            title: LocalizedText(
              en: row.str('title_en'),
              ar: row.str('title_ar'),
            ),
            points: row.intAt('points'),
            earnedOn: row.dateAt('earned_on'),
            evidence: CredentialEvidence.fromWire(row.str('evidence')),
            certificateId: row.strOrNull('certificate_id'),
          ),
        )
        .toList();
  }

  // --- Notification preferences ---------------------------------------------

  /// The three categories. A missing row means the defaults, which are all on.
  Future<NotificationPreferences> notificationPreferences(
    String userId,
  ) async {
    final rows = await _query(
      '''
      SELECT deadline_alerts, session_reminders, study_nudges
      FROM notification_preferences
      WHERE user_id = @user
      ''',
      {'user': userId},
    );
    if (rows.isEmpty) return const NotificationPreferences.allEnabled();
    final row = rows.first;
    return NotificationPreferences(
      deadlineAlerts: row.boolAt('deadline_alerts'),
      sessionReminders: row.boolAt('session_reminders'),
      studyNudges: row.boolAt('study_nudges'),
    );
  }

  Future<void> saveNotificationPreferences(
    String userId,
    NotificationPreferences preferences,
  ) => _execute(
    '''
    INSERT INTO notification_preferences (
      user_id, deadline_alerts, session_reminders, study_nudges, updated_at
    ) VALUES (@user, @deadline, @session, @study, now())
    ON CONFLICT (user_id) DO UPDATE SET
      deadline_alerts = EXCLUDED.deadline_alerts,
      session_reminders = EXCLUDED.session_reminders,
      study_nudges = EXCLUDED.study_nudges,
      updated_at = now()
    ''',
    {
      'user': userId,
      'deadline': preferences.deadlineAlerts,
      'session': preferences.sessionReminders,
      'study': preferences.studyNudges,
    },
  );

  // --- Mapping --------------------------------------------------------------

  Certificate _toCertificate(
    Map<String, dynamic> row, {
    bool includeDocument = true,
  }) => Certificate(
    id: row.str('id'),
    title: LocalizedText(en: row.str('title_en'), ar: row.str('title_ar')),
    issuer: LocalizedText(en: row.str('issuer_en'), ar: row.str('issuer_ar')),
    issuedOn: row.dateAt('issued_on'),
    evidence: CredentialEvidence.fromWire(row.str('evidence')),
    cpdPoints: row.intAt('cpd_points'),
    verificationCode: row.strOrNull('verification_code'),
    courseId: row.intOrNull('course_id'),
    documentUrl: includeDocument ? row.strOrNull('document_key') : null,
  );

  static Map<String, String> _readLinks(Object? value) {
    if (value is Map) {
      return value.map((key, v) => MapEntry(key.toString(), v.toString()));
    }
    if (value is String && value.trim().isNotEmpty) {
      final decoded = jsonDecode(value);
      if (decoded is Map) {
        return decoded.map((key, v) => MapEntry(key.toString(), v.toString()));
      }
    }
    return const {};
  }

  Future<List<Map<String, dynamic>>> _query(
    String sql,
    Map<String, Object?> parameters,
  ) async {
    final result = await _database.run(
      (session) => session.execute(Sql.named(sql), parameters: parameters),
    );
    return result.map((row) => row.toColumnMap()).toList();
  }

  Future<void> _execute(String sql, Map<String, Object?> parameters) async {
    await _query(sql, parameters);
  }
}
