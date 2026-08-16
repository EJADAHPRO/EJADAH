import 'package:ejadah_models/ejadah_models.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../http/api_error.dart';
import '../../http/context.dart';
import '../../http/responses.dart';
import 'availability_service.dart';
import 'earnings_service.dart';

/// `/api/v1/availability` — the tutor's own calendar (PE-14).
///
/// Like `/earnings`, no route takes a professional id: the only calendar
/// reachable through this is the caller's own, resolved from the token.
///
/// The one thing worth reading closely is how a clash comes back. Removing time
/// somebody has booked is refused with **409 and the sessions listed** — not a
/// bare "no", and never a silent success. A tutor blocking a week for travel
/// has to be told which students they would be standing up, by name and by
/// time, because the alternative is that the students find out by turning up.
Router availabilityRoutes(
  AvailabilityService service,
  EarningsService professionals,
) {
  final router = Router();

  router.get('/', (Request request) async {
    final id = await _requireProfessional(request, professionals);
    final rules = await service.rules(id);

    return Json.ok({
      'rules': rules.map((rule) => rule.toJson()).toList(),
      'exceptions': (await service.exceptions(
        id,
        from: DateTime.now().toUtc(),
      )).map((exception) => exception.toJson()).toList(),
      // Sent rather than computed twice: the hint under the grid and the check
      // the application ran have to be the same number.
      'weekly_minutes': service.weeklyMinutes(rules),
      'minimum_weekly_hours': AvailabilityService.minimumWeeklyHours,
    });
  });

  router.put('/rules', (Request request) async {
    final id = await _requireProfessional(request, professionals);
    final body = await readJsonBody(request);

    final replacement = (body['rules'] as List<dynamic>? ?? const [])
        .map((raw) {
          final rule = Map<String, dynamic>.from(raw as Map);
          return AvailabilityRule(
            id: 0,
            weekday: (rule['weekday'] as num?)?.toInt() ?? -1,
            startMinute: (rule['start_minute'] as num?)?.toInt() ?? -1,
            endMinute: (rule['end_minute'] as num?)?.toInt() ?? -1,
          );
        })
        .toList();

    try {
      final saved = await service.saveRules(
        professionalId: id,
        replacement: replacement,
      );
      return Json.ok({'rules': saved.map((rule) => rule.toJson()).toList()});
    } on AvailabilityClash catch (clash) {
      throw _clashException(clash);
    }
  });

  router.post('/blocks', (Request request) async {
    final id = await _requireProfessional(request, professionals);
    final body = await readJsonBody(request);

    try {
      final blocked = await service.block(
        professionalId: id,
        startsAt: _requireTime(body, 'starts_at'),
        endsAt: _requireTime(body, 'ends_at'),
        reason: (body['reason'] as String?)?.trim(),
      );
      return Json.created(blocked.toJson());
    } on AvailabilityClash catch (clash) {
      throw _clashException(clash);
    }
  });

  router.post('/openings', (Request request) async {
    final id = await _requireProfessional(request, professionals);
    final body = await readJsonBody(request);
    return Json.created(
      (await service.open(
        professionalId: id,
        startsAt: _requireTime(body, 'starts_at'),
        endsAt: _requireTime(body, 'ends_at'),
      )).toJson(),
    );
  });

  router.delete('/exceptions/<id>', (Request request, String id) async {
    await service.removeException(
      professionalId: await _requireProfessional(request, professionals),
      exceptionId: parsePathInt(id, 'id'),
    );
    return Json.noContent();
  });

  return router;
}

/// A clash, as the wire sees it.
///
/// 409 with the sessions in `details`-adjacent form: the client renders them as
/// a list the tutor can read and act on. The message says what happened; the
/// list says to whom.
ApiException _clashException(AvailabilityClash clash) => ApiException(
  ApiErrorCode.conflict,
  message: _clashMessage,
  fields: {
    for (final session in clash.sessions)
      // Keyed by session start so two sessions with the same student stay two
      // entries. Keyed by booking id they would collapse, and a multi-session
      // plan is exactly the case where that happens.
      session.startsAt.toIso8601String(): LocalizedText(
        en: '${session.studentName.en} — ${session.subject}',
        ar: '${session.studentName.ar} — ${session.subject}',
      ),
  },
  details: '${clash.sessions.length} confirmed sessions in the period.',
);

const LocalizedText _clashMessage = LocalizedText(
  en:
      'You have confirmed sessions in that time. Cancel them first if you '
      'need to — the students are refunded and told.',
  ar:
      'لديك جلسات مؤكدة في هذا الوقت. ألغِها أولًا إن كنت مضطرًا — '
      'ويُعاد المبلغ إلى الطلاب مع إشعارهم.',
);

DateTime _requireTime(Map<String, dynamic> body, String field) {
  final parsed = DateTime.tryParse(body[field] as String? ?? '');
  if (parsed == null) {
    throw ApiException.validation({
      field: const LocalizedText(
        en: 'That is not a valid time.',
        ar: 'هذا ليس وقتًا صالحًا.',
      ),
    });
  }
  return parsed.toUtc();
}

Future<int> _requireProfessional(
  Request request,
  EarningsService professionals,
) async {
  final id = await professionals.professionalIdFor(request.ctx.requireUser());
  // Not-found rather than forbidden for a student: there is no calendar to be
  // refused access to, and 403 would imply one exists.
  if (id == null) throw ApiException.notFound();
  return id;
}
