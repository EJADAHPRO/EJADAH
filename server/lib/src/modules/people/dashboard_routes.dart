import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../http/api_error.dart';
import '../../http/context.dart';
import '../../http/responses.dart';
import 'dashboard_service.dart';
import 'earnings_service.dart';

/// `/api/v1/dashboard` — the tutor's working day (PE-13).
///
/// The shape of the response is the shape of the screen, in the order a tutor
/// actually wants it: today, then money, then what is holding money up, then
/// the rest of the week. Assembled server-side so the client makes one request
/// on a Cairo mobile connection rather than five.
Router dashboardRoutes(
  DashboardService service,
  EarningsService earnings,
) {
  final router = Router();

  router.get('/', (Request request) async {
    final id = await _requireProfessional(request, earnings);
    final now = DateTime.now().toUtc();
    final (dayStart, dayEnd) = DashboardService.cairoDay(now);

    final summary = await earnings.summary(id);

    return Json.ok({
      ...await service.profile(id),
      'today': (await service.sessions(
        professionalId: id,
        from: dayStart,
        to: dayEnd,
      )).map((session) => session.toJson()).toList(),
      // Money as two figures and the rule behind them — never a chart. A tutor
      // with six sessions a month has nothing to plot.
      'earnings': {
        'available_egp': summary.availableEgp,
        'pending_egp': summary.pendingEgp,
        'requested_egp': summary.requestedEgp,
      },
      'unmarked': (await service.unmarked(
        professionalId: id,
        now: now,
      )).map((session) => session.toJson()).toList(),
      // Tomorrow to the end of the seventh day — "the rest of the week"
      // counted forward from today rather than to Saturday, because a Friday
      // that shows two days is a screen that looks broken.
      'week': (await service.sessions(
        professionalId: id,
        from: dayEnd,
        to: dayEnd.add(const Duration(days: 6)),
      )).map((session) => session.toJson()).toList(),
      'auto_complete_after_days': DashboardService.autoCompleteAfterDays,
    });
  });

  router.post('/sessions/<id>/mark', (Request request, String id) async {
    return Json.ok(
      (await service.mark(
        professionalId: await _requireProfessional(request, earnings),
        sessionId: id,
      )).toJson(),
    );
  });

  router.put('/visibility', (Request request) async {
    final body = await readJsonBody(request);
    return Json.ok({
      'is_hidden': await service.setHidden(
        professionalId: await _requireProfessional(request, earnings),
        hidden: body['is_hidden'] == true,
      ),
    });
  });

  router.put('/meeting-url', (Request request) async {
    final body = await readJsonBody(request);
    return Json.ok({
      'meeting_url': await service.setMeetingUrl(
        professionalId: await _requireProfessional(request, earnings),
        url: body['meeting_url'] as String?,
      ),
    });
  });

  return router;
}

Future<int> _requireProfessional(
  Request request,
  EarningsService earnings,
) async {
  final id = await earnings.professionalIdFor(request.ctx.requireUser());
  // Not-found rather than forbidden for a student: there is no dashboard to be
  // refused access to, and 403 would imply one exists.
  if (id == null) throw ApiException.notFound();
  return id;
}
