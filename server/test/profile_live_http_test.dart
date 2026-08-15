import 'dart:convert';
import 'dart:io';

import 'package:ejadah_server/src/http/middleware.dart';
import 'package:ejadah_server/src/modules/profile/profile_repository.dart';
import 'package:ejadah_server/src/modules/profile/cv_service.dart';
import 'package:ejadah_server/src/modules/profile/profile_routes.dart';
import 'package:ejadah_server/src/modules/profile/profile_service.dart';
import 'package:ejadah_server/src/observability/logger.dart';
import 'package:ejadah_server/src/services/token_service.dart';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:test/test.dart';

import 'support/test_database.dart';

/// The public routes over a real socket.
///
/// `profile_public_test.dart` calls the handler in-process. This suite binds an
/// actual HTTP server and makes real requests with no Authorization header,
/// because "works signed out" is a claim about the wire, not about a Dart
/// function: a middleware that rejected an absent header, or a route mounted
/// behind an auth guard, would pass an in-process test and still break the
/// growth loop in production.
void main() {
  late TestDatabase db;
  late HttpServer server;
  late String origin;

  setUpAll(() async {
    db = await TestDatabase.open();
    await db.reset();
    await _seed(db);

    final service = ProfileService(
      repository: ProfileRepository(db.database),
      config: db.config,
    );
    final router = Router()
      ..mount('/api/v1/profile', profileRoutes(service, CvService(db.database)).call);

    final handler = const Pipeline()
        .addMiddleware(contextMiddleware(TokenService(db.config)))
        .addMiddleware(securityHeadersMiddleware())
        .addMiddleware(errorMiddleware(AppLogger('test', sink: _silent)))
        .addHandler(router.call);

    // Port 0: the OS picks a free one, so the suite cannot collide with a
    // development server already running.
    server = await shelf_io.serve(handler, InternetAddress.loopbackIPv4, 0);
    origin = 'http://${server.address.host}:${server.port}';
  });

  tearDownAll(() async {
    await server.close(force: true);
    await db.close();
  });

  test('a signed-out visitor can open a public card over HTTP', () async {
    final response = await http.get(
      Uri.parse('$origin/api/v1/profile/public/yasmine'),
    );

    expect(response.statusCode, 200);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    expect((body['display_name'] as Map)['ar'], 'د. ياسمين حسن');
    expect((body['certificates'] as List), hasLength(1));
    expect(response.body, isNot(contains('yasmine@ejadah.test')));
  });

  test('a signed-out visitor can verify a certificate over HTTP', () async {
    final response = await http.get(
      Uri.parse('$origin/api/v1/profile/verify/EJ-LIVE-1'),
    );

    expect(response.statusCode, 200);
    expect(jsonDecode(response.body)['outcome'], 'verified');
  });

  test('an unknown handle returns the not-found envelope, not a blank page',
      () async {
    final response = await http.get(
      Uri.parse('$origin/api/v1/profile/public/nobody'),
    );

    expect(response.statusCode, 404);
    final error = (jsonDecode(response.body) as Map)['error'] as Map;
    expect(error['code'], 'not_found');
    // Bilingual copy, so the 404 screen reads as Ejadah in either language.
    expect((error['message'] as Map)['ar'], isNotEmpty);
  });

  test('the owner routes still require an account', () async {
    final response = await http.get(Uri.parse('$origin/api/v1/profile/me'));
    expect(response.statusCode, 401);
  });
}

Future<void> _seed(TestDatabase db) async {
  final users = await db.execute(
    '''
    INSERT INTO users (email, password_hash, full_name_en, full_name_ar,
                       public_slug)
    VALUES ('yasmine@ejadah.test', 'x', 'Dr Yasmine Hassan', 'د. ياسمين حسن',
            'yasmine')
    RETURNING id
    ''',
  );
  final userId = users.first.toColumnMap()['id'].toString();

  await db.execute(
    '''
    INSERT INTO profiles (user_id, title_en, title_ar, clinic_en, clinic_ar,
                          is_public)
    VALUES (@user, 'Endodontist', 'أخصائية علاج جذور',
            'Nile Dental Studio', 'نايل دنتال ستوديو', true)
    ''',
    {'user': userId},
  );
  await db.execute(
    '''
    INSERT INTO courses (id, slug, title_en, title_ar, department,
                         iap_product_id)
    VALUES (1, 'rotary-endo', 'Rotary endodontics', 'المعالجة اللبية الدوّارة',
            'orthodontics', 'com.ejadah.rotary')
    ON CONFLICT (id) DO NOTHING
    ''',
  );
  await db.execute(
    '''
    INSERT INTO certificates (user_id, title_en, title_ar, issuer_en, issuer_ar,
                              issued_on, evidence, cpd_points, course_id,
                              verification_code)
    VALUES (@user, 'Rotary endodontics', 'المعالجة اللبية الدوّارة',
            'Ejadah', 'إجادة', DATE '2026-05-12', 'verified', 8, 1,
            'EJ-LIVE-1')
    ''',
    {'user': userId},
  );
}

final IOSink _silent = _NullSink();

class _NullSink implements IOSink {
  @override
  void writeln([Object? object = '']) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
