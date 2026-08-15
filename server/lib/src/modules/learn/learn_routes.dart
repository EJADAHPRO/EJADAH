import 'package:ejadah_models/ejadah_models.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../http/api_error.dart';
import '../../http/context.dart';
import '../../http/responses.dart';
import 'learn_service.dart';

/// `/api/v1/learn` — the catalogue, playback, spacing and grading.
///
/// The catalogue is public: browsing courses signed out is deliberate, and the
/// gate is purchasing, not looking. Everything that touches a person's own
/// progress requires an account, and everything behind a purchase additionally
/// requires the entitlement — checked in the service, never inferred from the
/// fact that a client managed to call the route.
Router learnRoutes(LearnService service) {
  final router = Router();

  // --- Catalogue (public) ---------------------------------------------------

  router.get('/courses', (Request request) async {
    final department = request.url.queryParameters['department'];
    return Json.ok(
      await service.catalogue(
        department: department == null || department.isEmpty
            ? null
            : Department.fromWire(department),
        // A guest gets the catalogue; they simply never get `is_owned: true`.
        userId: request.ctx.userId,
      ),
    );
  });

  // Ownership restore. Declared before `/courses/<slug>` so "entitlements" is
  // never mistaken for a course slug.
  router.get('/entitlements', (Request request) async {
    return Json.ok(await service.restore(request.ctx.requireUser()));
  });

  router.get('/courses/<slug>', (Request request, String slug) async {
    final detail = await service.courseBySlug(slug, userId: request.ctx.userId);
    return Json.ok(detail.toJson());
  });

  router.get('/courses/<id>/lessons', (Request request, String id) async {
    final lessons = await service.lessons(
      parsePathInt(id, 'id'),
      userId: request.ctx.userId,
    );
    return Json.ok({
      'items': lessons.map((lesson) => lesson.toJson()).toList(),
      'total': lessons.length,
    });
  });

  router.get('/courses/<id>/handouts', (Request request, String id) async {
    final handouts = await service.handouts(
      userId: request.ctx.requireUser(),
      courseId: parsePathInt(id, 'id'),
    );
    return Json.ok({
      'items': handouts.map((handout) => handout.toJson()).toList(),
      'total': handouts.length,
    });
  });

  router.get('/handouts/<id>/file', (Request request, String id) async {
    return Json.ok(
      await service.handoutFile(
        userId: request.ctx.requireUser(),
        handoutId: parsePathInt(id, 'id'),
      ),
    );
  });

  // --- Purchase -------------------------------------------------------------

  router.post('/courses/<id>/entitlement', (Request request, String id) async {
    final body = await readJsonBody(request);
    final result = await service.grantEntitlement(
      userId: request.ctx.requireUser(),
      courseId: parsePathInt(id, 'id'),
      // Defaults to the store path: the development simulator has to be asked
      // for by name, so a misconfigured client cannot fall into it.
      source: (body['source'] as String?) ?? 'iap',
      receipt:
          (body['receipt'] ?? body['transaction_id'] ?? body['external_ref'])
              as String?,
    );
    return Json.created(result);
  });

  // --- Playback -------------------------------------------------------------

  router.put('/lessons/<id>/progress', (Request request, String id) async {
    final body = await readJsonBody(request);
    final position = body['position_seconds'];
    if (position is! num) {
      throw ApiException(
        ApiErrorCode.validation,
        details: 'position_seconds is required.',
      );
    }

    final lesson = await service.saveProgress(
      userId: request.ctx.requireUser(),
      lessonId: parsePathInt(id, 'id'),
      positionSeconds: position.toInt(),
    );
    return Json.ok(lesson.toJson());
  });

  router.post('/lessons/<id>/complete', (Request request, String id) async {
    final body = await readJsonBody(request);
    final result = await service.completeLesson(
      userId: request.ctx.requireUser(),
      lessonId: parsePathInt(id, 'id'),
      positionSeconds: (body['position_seconds'] as num?)?.toInt(),
    );
    return Json.ok(result);
  });

  // --- Flashcards -----------------------------------------------------------

  router.get('/decks/<id>/due', (Request request, String id) async {
    return Json.ok(
      await service.dueQueue(
        userId: request.ctx.requireUser(),
        deckId: parsePathInt(id, 'id'),
      ),
    );
  });

  router.post('/flashcards/<id>/review', (Request request, String id) async {
    final body = await readJsonBody(request);
    final outcome = body['outcome'];
    if (outcome != ReviewOutcome.again.wire &&
        outcome != ReviewOutcome.gotIt.wire) {
      throw ApiException(
        ApiErrorCode.validation,
        details: 'outcome must be "again" or "got_it".',
      );
    }

    final result = await service.review(
      userId: request.ctx.requireUser(),
      flashcardId: parsePathInt(id, 'id'),
      outcome: ReviewOutcome.fromWire(outcome as String),
      sessionStartedAt: DateTime.tryParse(
        (body['session_started_at'] as String?) ?? '',
      )?.toUtc(),
    );
    return Json.ok(result.toJson());
  });

  // --- Quizzes --------------------------------------------------------------

  router.get('/quizzes/<id>', (Request request, String id) async {
    return Json.ok(
      await service.quizForClient(
        userId: request.ctx.requireUser(),
        quizId: parsePathInt(id, 'id'),
      ),
    );
  });

  router.post('/quizzes/<id>/attempts', (Request request, String id) async {
    final body = await readJsonBody(request);
    final graded = await service.submitAttempt(
      userId: request.ctx.requireUser(),
      quizId: parsePathInt(id, 'id'),
      answers: _answersFrom(body['answers']),
    );
    return Json.created(graded.toJson());
  });

  return router;
}

/// Reads `[{"question_id": 1, "option_id": 4}, …]`.
///
/// A skipped question may be omitted or sent with a null option; both mean the
/// same thing to the grader, and neither is an error — a partly finished quiz
/// still deserves a score and its explanations.
Map<int, int?> _answersFrom(Object? raw) {
  if (raw is! List) {
    throw ApiException(
      ApiErrorCode.validation,
      details: 'answers must be a list of {question_id, option_id}.',
    );
  }

  final answers = <int, int?>{};
  for (final entry in raw) {
    if (entry is! Map) {
      throw ApiException(
        ApiErrorCode.validation,
        details: 'Each answer must be an object.',
      );
    }
    final questionId = entry['question_id'];
    if (questionId is! num) {
      throw ApiException(
        ApiErrorCode.validation,
        details: 'Each answer needs a question_id.',
      );
    }
    final optionId = entry['option_id'];
    answers[questionId.toInt()] = optionId is num ? optionId.toInt() : null;
  }
  return answers;
}
