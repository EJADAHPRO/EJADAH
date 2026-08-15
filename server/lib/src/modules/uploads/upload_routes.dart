import 'dart:convert';
import 'dart:typed_data';

import 'package:ejadah_models/ejadah_models.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:postgres/postgres.dart';

import '../../db/database.dart';
import '../../http/api_error.dart';
import '../../http/context.dart';
import '../../http/responses.dart';
import 'file_store.dart';

/// `/api/v1/uploads` — the one way a file enters this system.
///
/// Two features need it: a tutor application's certificate and photograph, and
/// the CV builder's upload-first path. Both handle documents that identify a
/// real person, so three rules hold here and are not negotiable per caller:
///
/// * **authenticated, always.** There is no anonymous upload;
/// * **the bytes decide the type**, never the declared content type — see
///   `_MediaType.sniff`;
/// * **reads are owner-only.** A qualification certificate is private; the
///   owner is carried in the key so a read cannot be authorised by guessing a
///   URL.
///
/// Nothing about a file's *contents* is ever logged. The size and the type are;
/// the bytes and the original filename are not.
Router uploadRoutes(FileStore store, Database database) {
  final router = Router();

  router.post('/<purpose>', (Request request, String purpose) async {
    final userId = request.ctx.requireUser();

    final resolved = UploadPurpose.fromWire(purpose);
    if (resolved == null) throw ApiException.notFound();

    final body = await readJsonBody(request);
    final encoded = body['data'];
    if (encoded is! String || encoded.isEmpty) {
      throw ApiException.validation({'file': _missingFile});
    }

    // Checked before decoding: base64 runs about 4/3 the size of its payload,
    // so a request well past the cap is refused without ever materialising it
    // in memory.
    if (encoded.length > (FileStore.maxBytes * 4 ~/ 3) + 1024) {
      throw ApiException.validation({'file': _tooLarge});
    }

    final Uint8List bytes;
    try {
      bytes = base64Decode(encoded);
    } on FormatException {
      throw ApiException.validation({'file': _notReadable});
    }

    final stored = await store.put(
      userId: userId,
      purpose: resolved,
      bytes: bytes,
    );

    // Recorded as well as written. A file that exists only on disk is a file
    // nothing can list, audit or clean up — and the schema has had a table
    // waiting for it since `006_profile_platform.sql`.
    //
    // The mime type is the one the bytes proved, never the one the request
    // claimed, and the original filename is not stored: it routinely carries a
    // person's name and nothing here needs it.
    await database.run(
      (session) => session.execute(
        Sql.named(
          'INSERT INTO stored_files (owner_id, storage_key, mime_type, bytes) '
          'VALUES (@owner_id, @key, @mime, @bytes)',
        ),
        parameters: {
          'owner_id': userId,
          'key': stored.key,
          'mime': stored.contentType,
          'bytes': stored.sizeBytes,
        },
      ),
    );

    return Json.created(stored.toJson());
  });

  router.get('/<key|.*>', (Request request, String key) async {
    final userId = request.ctx.requireUser();

    // Not-found rather than forbidden for someone else's file: a 403 confirms
    // the key exists, which is itself the answer an attacker enumerating keys
    // is looking for.
    if (!FileStore.isOwnedBy(key, userId)) throw ApiException.notFound();

    final bytes = await store.read(key);
    if (bytes == null) throw ApiException.notFound();

    return Response.ok(
      bytes,
      headers: {
        'content-type': store.contentTypeOf(key) ?? 'application/octet-stream',
        // Never rendered inline: an uploaded file is user content, and a
        // browser that decides to execute it does so in this origin.
        'content-disposition': 'attachment',
        'x-content-type-options': 'nosniff',
        'cache-control': 'private, no-store',
      },
    );
  });

  return router;
}

const LocalizedText _missingFile = LocalizedText(
  en: 'Choose a file first.',
  ar: 'اختر ملفًا أولًا.',
);

const LocalizedText _tooLarge = LocalizedText(
  en: 'That file is larger than 5 MB. Try a smaller one.',
  ar: 'حجم الملف أكبر من 5 ميجابايت. جرّب ملفًا أصغر.',
);

const LocalizedText _notReadable = LocalizedText(
  en: "That file could not be read. Try choosing it again.",
  ar: 'تعذّرت قراءة هذا الملف. جرّب اختياره مرة أخرى.',
);
