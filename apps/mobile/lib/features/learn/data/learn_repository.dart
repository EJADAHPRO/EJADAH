import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import 'learn_models.dart';

final learnRepositoryProvider = Provider<LearnRepository>(
  (ref) => LearnRepository(ref.watch(apiClientProvider)),
);

/// Everything the Learn tab reads and writes.
///
/// Two things never happen here, and both are deliberate:
///
/// * **No course price is fetched or held.** Courses are in-app purchase only
///   and the store is the pricing authority — the client asks the store what a
///   course costs, never this API.
/// * **No answer is graded on the device.** The quiz paper arrives without its
///   key, and the score comes back from the server.
class LearnRepository {
  const LearnRepository(this._client);

  final ApiClient _client;

  // --- Catalogue ------------------------------------------------------------

  Future<Catalogue> catalogue({Department? department}) => _client.get(
    '/learn/courses',
    query: {if (department != null) 'department': department.wire},
    parse: Catalogue.fromJson,
  );

  Future<CourseDetail> course(String slug) =>
      _client.get('/learn/courses/$slug', parse: CourseDetail.fromJson);

  Future<List<Lesson>> lessons(int courseId) => _client.get(
    '/learn/courses/$courseId/lessons',
    parse: (json) => (json['items'] as List<dynamic>)
        .map((item) => Lesson.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList(),
  );

  // --- Playback -------------------------------------------------------------

  /// Stores the playback position, called about every five seconds.
  ///
  /// The position lives on the server so it survives a reinstall, which local
  /// state alone cannot deliver.
  Future<Lesson> saveProgress(int lessonId, int positionSeconds) => _client.put(
    '/learn/lessons/$lessonId/progress',
    body: {'position_seconds': positionSeconds},
    parse: Lesson.fromJson,
  );

  Future<LessonCompletion> completeLesson(
    int lessonId, {
    int? positionSeconds,
  }) => _client.post(
    '/learn/lessons/$lessonId/complete',
    body: {if (positionSeconds != null) 'position_seconds': positionSeconds},
    parse: LessonCompletion.fromJson,
  );

  // --- Handouts -------------------------------------------------------------

  Future<List<Handout>> handouts(int courseId) => _client.get(
    '/learn/courses/$courseId/handouts',
    parse: (json) => (json['items'] as List<dynamic>)
        .map((item) => Handout.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList(),
  );

  /// Fetches a handout's bytes. Returns the byte count the server delivered.
  Future<int> fetchHandout(int handoutId) => _client.get(
    '/learn/handouts/$handoutId/file',
    parse: (json) => (json['bytes'] as num?)?.toInt() ?? 0,
  );

  // --- Purchase -------------------------------------------------------------

  /// Records ownership after the store reports a completed purchase.
  ///
  /// [receipt] is the store transaction identifier. The server verifies it;
  /// the client asserting ownership is never enough, which is why this returns
  /// the server's own view of the course rather than a boolean.
  Future<Course> purchase(
    int courseId, {
    required String source,
    String? receipt,
  }) => _client.post(
    '/learn/courses/$courseId/entitlement',
    body: {'source': source, if (receipt != null) 'receipt': receipt},
    parse: (json) =>
        Course.fromJson(Map<String, dynamic>.from(json['course'] as Map)),
  );

  /// "Restore purchases". Entitlements are server-side, so restoring on a new
  /// device is a read.
  Future<List<Course>> restorePurchases() => _client.get(
    '/learn/entitlements',
    parse: (json) => (json['items'] as List<dynamic>)
        .map((item) => Course.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList(),
  );

  // --- Flashcards -----------------------------------------------------------

  Future<DueQueue> dueCards(int deckId) =>
      _client.get('/learn/decks/$deckId/due', parse: DueQueue.fromJson);

  Future<ReviewResult> review(
    int flashcardId,
    ReviewOutcome outcome, {
    DateTime? sessionStartedAt,
  }) => _client.post(
    '/learn/flashcards/$flashcardId/review',
    body: {
      'outcome': outcome.wire,
      if (sessionStartedAt != null)
        'session_started_at': sessionStartedAt.toUtc().toIso8601String(),
    },
    parse: ReviewResult.fromJson,
  );

  // --- Quiz -----------------------------------------------------------------

  Future<QuizPaper> quiz(int quizId) =>
      _client.get('/learn/quizzes/$quizId', parse: QuizPaper.fromJson);

  /// Submits every answer at once and receives the grade.
  ///
  /// A question the user skipped is sent with a null option rather than being
  /// omitted, so the payload is a complete record of the attempt.
  Future<GradedAttempt> submitAttempt(int quizId, Map<int, int?> answers) =>
      _client.post(
        '/learn/quizzes/$quizId/attempts',
        body: {
          'answers': [
            for (final entry in answers.entries)
              {'question_id': entry.key, 'option_id': entry.value},
          ],
        },
        parse: GradedAttempt.fromJson,
      );
}
