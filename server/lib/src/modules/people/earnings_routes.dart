import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../http/api_error.dart';
import '../../http/context.dart';
import '../../http/responses.dart';
import 'earnings_service.dart';

/// `/api/v1/earnings` — the tutor's ledger.
///
/// Its own mount rather than a corner of `/people`, because everything here is
/// about the signed-in professional's own money and none of it is a marketplace
/// read. There is no route that takes a professional id: the only ledger anyone
/// can reach through this is their own, resolved from the token.
Router earningsRoutes(EarningsService service) {
  final router = Router();

  router.get('/', (Request request) async {
    final professionalId = await _requireProfessional(request, service);

    final summary = await service.summary(professionalId);
    final payouts = await service.payouts(professionalId);

    return Json.ok({
      'summary': summary.toJson(),
      // Every row carries gross, fee and net. A screen that shows only the
      // share is a screen a tutor cannot check.
      'items': (await service.rows(
        professionalId,
      )).map((row) => row.toJson()).toList(),
      'payouts': payouts.map((payout) => payout.toJson()).toList(),
      'minimum_payout_egp': EarningsService.minimumPayoutEgp,
      'platform_fee_percent': service.platformFeePercent,
      // Why the button is disabled, computed server-side and sent whether or
      // not it is disabled — so the screen never has to invent a reason and
      // never shows a dead control with nothing beside it.
      'payout_blocked_reason': service
          .blockedReason(summary: summary, payouts: payouts)
          ?.toJson(),
    });
  });

  router.post('/payouts', (Request request) async {
    final professionalId = await _requireProfessional(request, service);
    // The amount is the available balance, never a figure from the request.
    return Json.created((await service.requestPayout(professionalId)).toJson());
  });

  return router;
}

/// The signed-in user's professional id.
///
/// Not-found rather than forbidden for a student: there is no ledger to be
/// refused access to, and 403 would imply one exists.
Future<int> _requireProfessional(
  Request request,
  EarningsService service,
) async {
  final professionalId = await service.professionalIdFor(
    request.ctx.requireUser(),
  );
  if (professionalId == null) throw ApiException.notFound();
  return professionalId;
}
