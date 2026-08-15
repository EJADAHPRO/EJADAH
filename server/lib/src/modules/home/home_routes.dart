import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../http/context.dart';
import '../../http/responses.dart';
import '../auth/auth_service.dart';
import 'home_service.dart';

/// `/api/v1/home` — the feed.
///
/// One request assembles the whole feed, because seven parallel requests from a
/// cold start on a mid-range Android phone is the thing the design is trying to
/// avoid.
Router homeRoutes(HomeService service, AuthService auth) {
  final router = Router();

  router.get('/', (Request request) async {
    final user = await auth.currentUser(request.ctx.requireUser());
    final feed = await service.feed(user);
    return Json.ok(feed.toJson());
  });

  return router;
}
