import 'package:ejadah_models/ejadah_models.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../http/api_error.dart';
import '../../http/context.dart';
import '../../http/responses.dart';
import 'roadmap_service.dart';

/// `/api/v1/roadmap` — the funnel, generation, the gate, and what-if.
///
/// Every route here works for a guest except saving and scenarios: the whole
/// point of the design is that four answers are invested before any wall.
Router roadmapRoutes(RoadmapService service) {
  final router = Router();

  router.get('/draft', (Request request) async {
    final draft = await service.loadDraft(
      userId: request.ctx.userId,
      deviceToken: request.ctx.deviceToken,
    );
    return draft == null ? Json.noContent() : Json.ok(draft);
  });

  router.put('/draft', (Request request) async {
    final body = await readJsonBody(request);
    await service.saveDraft(
      userId: request.ctx.userId,
      deviceToken: request.ctx.deviceToken,
      answers: Map<String, dynamic>.from(
        (body['answers'] as Map?) ?? const <String, dynamic>{},
      ),
      lastStep: (body['last_step'] as num?)?.toInt() ?? 1,
    );
    return Json.noContent();
  });

  router.post('/generate', (Request request) async {
    final body = await readJsonBody(request);
    final answersJson = body['answers'];
    if (answersJson is! Map) {
      throw ApiException(
        ApiErrorCode.validation,
        details: 'Missing "answers".',
      );
    }

    final view = await service.generate(
      userId: request.ctx.userId,
      deviceToken: request.ctx.deviceToken,
      answers: RoadmapAnswers.fromJson(Map<String, dynamic>.from(answersJson)),
    );
    return Json.created(view.toJson());
  });

  router.get('/mine', (Request request) async {
    final roadmaps = await service.myRoadmaps(request.ctx.requireUser());
    return Json.ok({
      'items': roadmaps.map((roadmap) => roadmap.toJson()).toList(),
    });
  });

  router.get('/<id>', (Request request, String id) async {
    final view = await service.roadmap(
      parsePathUuid(id),
      userId: request.ctx.userId,
      deviceToken: request.ctx.deviceToken,
    );
    return Json.ok(view.toJson());
  });

  router.post('/<id>/save', (Request request, String id) async {
    final view = await service.save(
      parsePathUuid(id),
      request.ctx.requireUser(),
      // A guest who has just signed in still holds the device token that owns
      // the draft, so saving it is a claim rather than a cross-user write.
      deviceToken: request.ctx.deviceToken,
    );
    return Json.ok(view.toJson());
  });

  router.post('/<id>/what-if', (Request request, String id) async {
    final body = await readJsonBody(request);
    final view = await service.whatIf(
      parentId: parsePathUuid(id),
      preset: WhatIfPreset.fromWire(body['preset'] as String?),
      userId: request.ctx.requireUser(),
    );
    return Json.created(view.toJson());
  });

  router.patch('/<id>/stages/<position>', (
    Request request,
    String id,
    String position,
  ) async {
    final body = await readJsonBody(request);
    final view = await service.setStageComplete(
      roadmapId: parsePathUuid(id),
      // A path segment is user input. A bad one is a 400 the client can act on,
      // never a 500 that reads as our fault.
      position: parsePathInt(position, 'position'),
      isComplete: body['is_complete'] == true,
      userId: request.ctx.requireUser(),
    );
    return Json.ok(view.toJson());
  });

  return router;
}
