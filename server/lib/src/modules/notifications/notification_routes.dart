import 'package:ejadah_models/ejadah_models.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../http/context.dart';
import '../../http/responses.dart';
import 'notification_scheduler.dart';

/// `/api/v1/notifications` — the notification centre and its switches.
///
/// The centre is the system of record, not the OS tray: a user who declined
/// push permission, or who was offline when a reminder went out, still finds
/// every notification here. Nothing on this surface is public — a notification
/// names a user's saved programmes and booked sessions.
Router notificationRoutes(NotificationScheduler scheduler) {
  final router = Router();

  router.get('/', (Request request) async {
    final userId = request.ctx.requireUser();
    final items = await scheduler.centre(userId);
    return Json.ok({
      'items': items.map((item) => item.toJson()).toList(),
      'unread': await scheduler.unreadCount(userId),
    });
  });

  router.post('/read', (Request request) async {
    await scheduler.markAllRead(request.ctx.requireUser());
    return Json.noContent();
  });

  router.get('/preferences', (Request request) async {
    final preferences = await scheduler.preferences(request.ctx.requireUser());
    return Json.ok(preferences.toJson());
  });

  // The three switches. There is deliberately no marketing category to switch
  // off, so this is the whole surface.
  router.put('/preferences', (Request request) async {
    final userId = request.ctx.requireUser();
    final body = await readJsonBody(request);
    final current = await scheduler.preferences(userId);

    // Absent keys keep their current value, so a client that knows about two
    // switches cannot silently reset a third it has never heard of.
    final updated = await scheduler.updatePreferences(
      userId,
      NotificationPreferences(
        deadlineAlerts:
            jsonBool(body['deadline_alerts']) ?? current.deadlineAlerts,
        sessionReminders:
            jsonBool(body['session_reminders']) ?? current.sessionReminders,
        studyNudges: jsonBool(body['study_nudges']) ?? current.studyNudges,
      ),
    );
    return Json.ok(updated.toJson());
  });

  return router;
}
