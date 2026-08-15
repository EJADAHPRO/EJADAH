import 'package:ejadah_models/ejadah_models.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../http/api_error.dart';
import '../../http/context.dart';
import '../../http/responses.dart';
import 'profile_service.dart';

/// `/api/v1/profile` — the public card, public verification, certificates,
/// the CPD ledger and settings.
///
/// The first two routes take **no authentication at all**. `/dr/{slug}` and
/// `/verify/{code}` are the product's growth and trust loops; a stranger who
/// scans a card or checks a credential has no account and must not need one.
/// Everything below them is the owner's own private data and calls
/// `requireUser()`.
Router profileRoutes(ProfileService service) {
  final router = Router();

  // --- Public ---------------------------------------------------------------

  /// The public card. Returns only fields intended to be public and only
  /// verified certificates; the view is counted in aggregate, never by viewer.
  router.get('/public/<slug>', (Request request, String slug) async {
    final view = await service.publicProfile(slug);
    return Json.ok(view.toJson());
  });

  /// Public certificate verification. Always a 200 carrying one of three
  /// outcomes — verified, not_found, revoked — because "no certificate with
  /// that code" is the answer, not a failed request.
  router.get('/verify/<code>', (Request request, String code) async {
    final outcome = await service.verifyCertificate(code);
    return Json.ok({
      ...outcome.toJson(),
      if (outcome.outcome == VerificationOutcome.verified)
        'share_url': service.verifyUrlFor(code.trim()),
    });
  });

  // --- The owner's own card -------------------------------------------------

  router.get('/me', (Request request) async {
    final profile = await service.ownerProfile(request.ctx.requireUser());
    return Json.ok({
      ...profile.toJson(),
      if (profile.slug != null) 'share_url': service.publicUrlFor(profile.slug!),
    });
  });

  router.put('/me', (Request request) async {
    final userId = request.ctx.requireUser();
    final body = await readJsonBody(request);
    final profile = await service.saveOwnerProfile(
      userId: userId,
      slug: body['slug'] as String?,
      isPublic: body['is_public'] as bool? ?? false,
      title: _localized(body['title']),
      clinic: _localized(body['clinic']),
      bio: _localized(body['bio']),
      links: _links(body['links']),
      phone: (body['phone'] as String?)?.trim(),
    );
    return Json.ok({
      ...profile.toJson(),
      if (profile.slug != null) 'share_url': service.publicUrlFor(profile.slug!),
    });
  });

  // --- Certificates ---------------------------------------------------------

  router.get('/certificates', (Request request) async {
    final items = await service.certificates(request.ctx.requireUser());
    return Json.ok({'items': items.map((c) => c.toJson()).toList()});
  });

  /// Adds a certificate the user states themselves.
  ///
  /// There is no route that mints a verification code. Codes belong to
  /// Ejadah-issued certificates, which are created by course completion, and
  /// the schema refuses any other combination.
  router.post('/certificates', (Request request) async {
    final userId = request.ctx.requireUser();
    final body = await readJsonBody(request);
    final certificate = await service.addStatedCertificate(
      userId: userId,
      title: _localized(body['title']),
      issuer: _localized(body['issuer']),
      issuedOn: _date(body['issued_on']),
      cpdPoints: (body['cpd_points'] as num?)?.toInt() ?? 0,
      documentKey: body['document_key'] as String?,
    );
    return Json.created(certificate.toJson());
  });

  router.delete('/certificates/<id>', (Request request, String id) async {
    await service.deleteCertificate(
      userId: request.ctx.requireUser(),
      certificateId: id,
    );
    return Json.noContent();
  });

  // --- CPD ------------------------------------------------------------------

  router.get('/cpd', (Request request) async {
    final ledger = await service.cpdLedger(request.ctx.requireUser());
    return Json.ok(ledger.toJson());
  });

  // --- Settings -------------------------------------------------------------

  /// The three notification categories. There is deliberately no marketing
  /// category, so there is no fourth key to send.
  router.get('/notifications/preferences', (Request request) async {
    final preferences = await service.notificationPreferences(
      request.ctx.requireUser(),
    );
    return Json.ok(preferences.toJson());
  });

  router.put('/notifications/preferences', (Request request) async {
    final body = await readJsonBody(request);
    final preferences = await service.saveNotificationPreferences(
      request.ctx.requireUser(),
      NotificationPreferences.fromJson(body),
    );
    return Json.ok(preferences.toJson());
  });

  return router;
}

LocalizedText _localized(Object? value) =>
    LocalizedText.fromJson(value) ?? const LocalizedText.same('');

Map<String, String> _links(Object? value) {
  if (value is! Map) return const {};
  return value.map((key, v) => MapEntry(key.toString(), v.toString()));
}

DateTime _date(Object? value) {
  final parsed = value == null ? null : DateTime.tryParse(value.toString());
  if (parsed == null) {
    throw ApiException.validation({
      'issued_on': const LocalizedText(
        en: 'Give the date the certificate was issued.',
        ar: 'اكتب تاريخ إصدار الشهادة.',
      ),
    });
  }
  return DateTime.utc(parsed.year, parsed.month, parsed.day);
}
