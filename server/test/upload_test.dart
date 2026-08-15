import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_server/src/config/config.dart';
import 'package:ejadah_server/src/http/api_error.dart';
import 'package:ejadah_server/src/http/middleware.dart';
import 'package:ejadah_server/src/modules/uploads/file_store.dart';
import 'package:ejadah_server/src/modules/uploads/upload_routes.dart';
import 'package:ejadah_server/src/observability/logger.dart';
import 'package:ejadah_server/src/services/token_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:test/test.dart';

import 'support/test_database.dart';

/// Uploads carry documents that identify a real person.
///
/// A tutor's qualification certificate is the most sensitive thing this product
/// stores about a professional, and a CV is the most sensitive thing it stores
/// about a student. Three rules protect them and each is pinned here, because
/// each is the kind that survives review and then quietly stops holding: the
/// bytes decide the type, reads are owner-only, and a key from the URL can
/// never reach outside the storage root.
void main() {
  late TestDatabase db;
  late Directory root;
  late AppConfig config;
  late LocalFileStore store;
  late Handler handler;
  late TokenService tokens;
  late String userA;
  late String userB;

  setUpAll(() async {
    db = await TestDatabase.open();
  });

  tearDownAll(() async {
    await db.close();
  });

  setUp(() async {
    await db.reset();
    root = Directory.systemTemp.createTempSync('ejadah_uploads_test');
    config = AppConfig.fromEnvironment({
      'EJADAH_ENV': 'test',
      'DATABASE_URL': 'postgres://unused/unused',
      'JWT_SECRET': 'test-secret-that-is-long-enough-for-tests',
      'STORAGE_ROOT': root.path,
    });
    store = LocalFileStore(config);
    tokens = TokenService(config);
    userA = await _createUser(db, 'a@ejadah.test');
    userB = await _createUser(db, 'b@ejadah.test');

    handler = const Pipeline()
        .addMiddleware(contextMiddleware(TokenService(config)))
        .addMiddleware(errorMiddleware(AppLogger('test', sink: _NullSink())))
        .addHandler(
          (Router()
                ..mount('/uploads', uploadRoutes(store, db.database).call))
              .call,
        );
  });

  tearDown(() {
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  group('what may be stored', () {
    test('a PNG is stored under a key naming its owner', () async {
      final stored = await store.put(
        userId: userA,
        purpose: UploadPurpose.document,
        bytes: _png,
      );

      expect(stored.contentType, 'image/png');
      expect(stored.key, startsWith('document/$userA/'));
      expect(stored.key, endsWith('.png'));
      expect(await store.read(stored.key), _png);
    });

    test('two uploads of the same bytes get different keys', () async {
      final first = await store.put(
        userId: userA,
        purpose: UploadPurpose.avatar,
        bytes: _png,
      );
      final second = await store.put(
        userId: userA,
        purpose: UploadPurpose.avatar,
        bytes: _png,
      );

      // Random, not sequential: knowing one key must say nothing about the
      // next one, or the owner check below is decoration.
      expect(first.key, isNot(second.key));
    });

    test('the bytes decide the type, not the request', () async {
      // A Windows executable. Anything that reads the declared content type
      // instead of the bytes stores this happily.
      final executable = Uint8List.fromList([0x4D, 0x5A, 0x90, 0x00, 0x03]);

      await expectLater(
        store.put(
          userId: userA,
          purpose: UploadPurpose.document,
          bytes: executable,
        ),
        throwsA(
          isA<ApiException>().having(
            (error) => error.code,
            'code',
            ApiErrorCode.validation,
          ),
        ),
      );
    });

    test('a PDF is not a photograph', () async {
      // Accepted as a certificate, refused as an avatar — the purpose narrows
      // the type, so a PDF cannot end up rendering as a face on a card.
      await store.put(
        userId: userA,
        purpose: UploadPurpose.document,
        bytes: _pdf,
      );

      await expectLater(
        store.put(
          userId: userA,
          purpose: UploadPurpose.avatar,
          bytes: _pdf,
        ),
        throwsA(isA<ApiException>()),
      );
    });

    test('an empty file is refused with a reason, not stored', () async {
      await expectLater(
        store.put(
          userId: userA,
          purpose: UploadPurpose.document,
          bytes: Uint8List(0),
        ),
        throwsA(
          isA<ApiException>().having(
            (error) => error.fields.keys.single,
            'field',
            'file',
          ),
        ),
      );
    });
  });

  group('who may read', () {
    test('the owner reads their own file', () async {
      final stored = await store.put(
        userId: userA,
        purpose: UploadPurpose.document,
        bytes: _pdf,
      );

      final response = await handler(
        Request(
          'GET',
          Uri.parse('http://x/uploads/${stored.key}'),
          headers: _auth(tokens, userA),
        ),
      );

      expect(response.statusCode, 200);
      expect(response.headers['content-type'], 'application/pdf');
      // Never rendered in this origin: an uploaded file is user content.
      expect(response.headers['content-disposition'], 'attachment');
      expect(await response.read().expand((chunk) => chunk).toList(), _pdf);
    });

    test("a stranger gets 404, not 403, for someone else's certificate",
        () async {
      final stored = await store.put(
        userId: userA,
        purpose: UploadPurpose.document,
        bytes: _pdf,
      );

      final response = await handler(
        Request(
          'GET',
          Uri.parse('http://x/uploads/${stored.key}'),
          headers: _auth(tokens, userB),
        ),
      );

      // 403 would confirm the key exists, which is the answer someone
      // enumerating keys is looking for.
      expect(response.statusCode, 404);
      expect(await response.readAsString(), isNot(contains(userA)));
    });

    test('a guest cannot read at all', () async {
      final stored = await store.put(
        userId: userA,
        purpose: UploadPurpose.document,
        bytes: _pdf,
      );

      final response = await handler(
        Request('GET', Uri.parse('http://x/uploads/${stored.key}')),
      );

      expect(response.statusCode, 401);
    });

    test('a guest cannot upload', () async {
      final response = await handler(
        Request(
          'POST',
          Uri.parse('http://x/uploads/document'),
          headers: {'content-type': 'application/json'},
          body: jsonEncode({'data': base64Encode(_pdf)}),
        ),
      );

      expect(response.statusCode, 401);
    });
  });

  group('the key cannot climb out', () {
    test('a traversing key reads nothing', () async {
      final secret = File('${root.path}/secret.txt')
        ..writeAsStringSync('not yours');
      addTearDown(() => secret.deleteSync());

      // Shaped to pass the owner check, so what stops it is the key check
      // itself rather than authorisation happening to fire first.
      expect(await store.read('document/$userA/../../secret.txt'), isNull);
    });

    test('an absolute key reads nothing', () async {
      expect(await store.read('/etc/hostname'), isNull);
    });

    test('a key with no owner segment belongs to nobody', () async {
      expect(FileStore.isOwnedBy('secret.txt', 'user-a'), isFalse);
      expect(FileStore.isOwnedBy('document/user-a/x.pdf', 'user-a'), isTrue);
      expect(FileStore.isOwnedBy('document/user-b/x.pdf', 'user-a'), isFalse);
    });
  });

  group('the route', () {
    test('stores and answers with the key', () async {
      final response = await handler(
        Request(
          'POST',
          Uri.parse('http://x/uploads/avatar'),
          headers: {'content-type': 'application/json', ..._auth(tokens, userA)},
          body: jsonEncode({'data': base64Encode(_png)}),
        ),
      );

      expect(response.statusCode, 201);
      final body =
          jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      expect(body['key'], startsWith('avatar/$userA/'));
      expect(body['content_type'], 'image/png');
      expect(body['size_bytes'], _png.length);
    });

    test('an unknown purpose is not found', () async {
      final response = await handler(
        Request(
          'POST',
          Uri.parse('http://x/uploads/anything'),
          headers: {'content-type': 'application/json', ..._auth(tokens, userA)},
          body: jsonEncode({'data': base64Encode(_png)}),
        ),
      );

      expect(response.statusCode, 404);
    });

    test('an oversized body is refused before it is decoded', () async {
      // Six megabytes of base64 against a 5 MB cap. The cap is checked on the
      // encoded length, so this never becomes six megabytes of Uint8List.
      final huge = 'A' * (7 * 1024 * 1024);
      final response = await handler(
        Request(
          'POST',
          Uri.parse('http://x/uploads/document'),
          headers: {'content-type': 'application/json', ..._auth(tokens, userA)},
          body: jsonEncode({'data': huge}),
        ),
      );

      expect(response.statusCode, 422);
      expect(root.listSync(recursive: true).whereType<File>(), isEmpty);
    });

    test('a body that is not base64 is refused with a reason', () async {
      final response = await handler(
        Request(
          'POST',
          Uri.parse('http://x/uploads/document'),
          headers: {'content-type': 'application/json', ..._auth(tokens, userA)},
          body: jsonEncode({'data': 'not base64 at all !!!'}),
        ),
      );

      expect(response.statusCode, 422);
    });
  });

}

Future<String> _createUser(TestDatabase db, String email) async {
  final result = await db.execute(
    "INSERT INTO users (email, password_hash, full_name_en, full_name_ar) "
    "VALUES (@email, 'x', 'A', 'أ') RETURNING id",
    {'email': email},
  );
  return result.first[0]! as String;
}

Map<String, String> _auth(TokenService tokens, String userId) => {
  'authorization': 'Bearer '
      '${tokens.issueAccessToken(userId: userId, role: UserRole.student)}',
};

/// The smallest valid PNG: an 8-byte signature is all `sniff` reads.
final Uint8List _png = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
]);

final Uint8List _pdf = Uint8List.fromList(
  utf8.encode('%PDF-1.4\n1 0 obj\n<<>>\nendobj\n'),
);

class _NullSink implements IOSink {
  @override
  void writeln([Object? object = '']) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
