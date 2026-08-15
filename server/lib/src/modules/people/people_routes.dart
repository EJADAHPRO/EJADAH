import 'package:ejadah_models/ejadah_models.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../http/api_error.dart';
import '../../http/context.dart';
import '../../http/responses.dart';
import 'booking_service.dart';
import 'people_repository.dart';
import 'people_service.dart';

/// `/api/v1/people` — the three marketplace doors and the booking flow.
///
/// Browsing every door, every profile, every price and every cancellation
/// policy is open to guests by design: booking is one of the five gates, but
/// deciding whether to book is not. The gate lands on `POST /holds`, which is
/// the first request that costs anyone anything.
///
/// Route order is load-bearing. `GET /<kind>` matches any single segment, so
/// every literal path — `/bookings`, `/holds`, `/profile/...` — is registered
/// ahead of it, and `/profile/<slug>` ahead of `/<id>/availability` so that
/// "profile" is never parsed as a professional id.
Router peopleRoutes(PeopleService service, BookingService booking) {
  final router = Router();

  // --- Hub ------------------------------------------------------------------

  router.get('/', (Request request) async {
    // The hub states how many people stand behind each door, so a door never
    // leads somewhere empty without saying so first.
    return Json.ok((await service.hub()).toJson());
  });

  // --- Bookings (auth) ------------------------------------------------------

  router.get('/bookings', (Request request) async {
    final bookings = await booking.myBookings(request.ctx.requireUser());
    return Json.ok({
      // Every row carries the refund it would pay out *right now* — the tier is
      // shown before the cancel button, never discovered after it.
      'items': service
          .withLiveRefunds(bookings)
          .map((item) => item.toJson())
          .toList(),
    });
  });

  router.post('/bookings', (Request request) async {
    final userId = request.ctx.requireUser();
    final body = await readJsonBody(request);

    final goal = (body['goal'] as String? ?? '').trim();
    if (goal.length < _minimumGoalLength) {
      throw ApiException.validation({'goal': _goalTooShort});
    }

    final confirmed = await booking.confirmBooking(
      userId: userId,
      holdId: _requireString(body, 'hold_id'),
      // A multi-session plan sends the rest of its held slots here. They are
      // confirmed in the same transaction, so a plan is all of its sessions or
      // none of them.
      additionalHoldIds:
          (body['additional_hold_ids'] as List<dynamic>? ?? const [])
              .map((value) => value.toString())
              .toList(),
      subject: (body['subject'] as String? ?? '').trim(),
      goal: goal,
      // A package id is looked up server-side; the price it implies is never
      // read from the request.
      packageId: (body['package_id'] as num?)?.toInt(),
    );

    return Json.created(service.withLiveRefund(confirmed).toJson());
  });

  router.post('/bookings/<id>/cancel', (Request request, String id) async {
    final cancelled = await booking.cancelBooking(
      userId: request.ctx.requireUser(),
      bookingId: id,
      // Only the professional's own dashboard may claim a professional
      // cancellation, which always refunds in full. A student cannot ask for it.
      cancelledByProfessional: false,
    );

    return Json.ok({
      'booking': cancelled.toJson(),
      // Stated explicitly as well as on the booking, because the confirmation
      // the user agreed to named this exact figure.
      'refunded_egp': cancelled.refundableEgp,
      'total_egp': cancelled.totalEgp,
    });
  });

  // --- Holds (auth) ---------------------------------------------------------

  router.post('/holds', (Request request) async {
    final userId = request.ctx.requireUser();
    final body = await readJsonBody(request);

    // A hold is placed the moment a slot is picked, so the countdown is visible
    // from that moment rather than from the review step.
    //
    // A race here surfaces as 409 with the approved "someone booked that time a
    // moment ago" copy: the exclusion constraint decides, not the client.
    final hold = await booking.holdSlot(
      userId: userId,
      professionalId: _requireInt(body, 'professional_id'),
      startsAt: _requireDate(body, 'starts_at'),
      durationMinutes: (body['duration_minutes'] as num?)?.toInt() ?? 60,
    );

    return Json.created(hold.toJson());
  });

  router.delete('/holds/<id>', (Request request, String id) async {
    await booking.releaseHold(userId: request.ctx.requireUser(), holdId: id);
    // The slot goes straight back on the calendar for everyone else.
    return Json.noContent();
  });

  // --- Profiles and availability (public) -----------------------------------

  router.get('/profile/<slug>', (Request request, String slug) async {
    return Json.ok((await service.profile(slug)).toJson());
  });

  router.get('/<id>/availability', (Request request, String id) async {
    final params = request.url.queryParameters;
    final from = _parseDate(params['from']) ?? DateTime.timestamp();
    // A week is the window the slot grid and the week stepper both work in.
    final to = _parseDate(params['to']) ?? from.add(const Duration(days: 7));

    if (!to.isAfter(from)) {
      throw ApiException(
        ApiErrorCode.validation,
        details: 'The availability window must end after it starts.',
      );
    }

    final slots = await booking.availability(
      professionalId: _parseId(id),
      from: from,
      to: to,
      slotMinutes: (int.tryParse(params['slot_minutes'] ?? '') ?? 60).clamp(
        15,
        240,
      ),
    );

    return Json.ok({
      'from': from.toIso8601String(),
      'to': to.toIso8601String(),
      // Unavailable slots are returned as unavailable rather than omitted, so
      // the grid renders them untappable instead of tappable-then-rejected.
      'items': slots.map((slot) => slot.toJson()).toList(),
    });
  });

  // --- The doors (public browse) --------------------------------------------
  //
  // Registered last: this pattern matches any single segment and would
  // otherwise swallow `/bookings` and `/holds`.

  router.get('/<kind>', (Request request, String kind) async {
    final list = await service.browse(_queryFrom(request, kind));
    return Json.ok(list.toJson());
  });

  return router;
}

/// The goal a student writes for the session.
///
/// Ten characters is the design's own floor: "help" is not a brief, and the
/// session is far more useful when the tutor knows what is coming.
const int _minimumGoalLength = 10;

/// Verbatim from `handoff-flutter/06-content/CONTENT.md` § form validation.
const LocalizedText _goalTooShort = LocalizedText(
  en:
      'Write a line or two about what you need — '
      'it makes the session far more useful.',
  ar: 'اكتب سطرًا أو سطرين عمّا تحتاجه',
);

ProfessionalQuery _queryFrom(Request request, String kind) {
  final params = request.url.queryParameters;
  return ProfessionalQuery(
    kind: _parseKind(kind),
    specialties: _stringList(params['specialty']),
    languages: _stringList(params['language']),
    // Only ever populated for mentoring: a mentor is someone who made the move,
    // and matching on that move is the whole point of the door.
    destinations: _stringList(params['destination']),
    maxRateEgp: int.tryParse(params['max_rate_egp'] ?? ''),
    freeIntroCallOnly: params['free_intro_call'] == 'true',
    newThisMonthOnly: params['new_this_month'] == 'true',
    sort: ProfessionalSort.fromWire(params['sort']),
    page: (int.tryParse(params['page'] ?? '') ?? 1).clamp(1, 1000),
    // Twelve is the designed page size; the cap stops a caller asking for the
    // whole roster in one request.
    pageSize: (int.tryParse(params['page_size'] ?? '') ?? 12).clamp(1, 50),
  );
}

/// An unknown door is a real not-found, not a silent fall back to tutoring.
///
/// `ServiceKind.fromWire` defaults to tutoring, which is right for reading a
/// stored row and wrong for a URL: `/people/nonsense` must not quietly render
/// the tutoring list.
ServiceKind _parseKind(String value) {
  for (final kind in ServiceKind.values) {
    if (kind.wire == value) return kind;
  }
  throw ApiException.notFound();
}

int _parseId(String value) {
  final id = int.tryParse(value);
  if (id == null) throw ApiException.notFound();
  return id;
}

String _requireString(Map<String, dynamic> body, String key) {
  final value = body[key];
  if (value is String && value.isNotEmpty) return value;
  throw ApiException(
    ApiErrorCode.validation,
    details: '$key is required and must be a string.',
  );
}

int _requireInt(Map<String, dynamic> body, String key) {
  final value = body[key];
  if (value is num) return value.toInt();
  throw ApiException(
    ApiErrorCode.validation,
    details: '$key is required and must be a number.',
  );
}

DateTime _requireDate(Map<String, dynamic> body, String key) {
  final parsed = _parseDate(body[key]?.toString());
  if (parsed == null) {
    throw ApiException(
      ApiErrorCode.validation,
      details: '$key is required and must be an ISO-8601 timestamp.',
    );
  }
  return parsed;
}

DateTime? _parseDate(String? value) {
  if (value == null || value.isEmpty) return null;
  return DateTime.tryParse(value)?.toUtc();
}

List<String> _stringList(String? value) => value == null || value.isEmpty
    ? const []
    : value.split(',').map((v) => v.trim()).where((v) => v.isNotEmpty).toList();
