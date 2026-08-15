import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:ejadah_models/ejadah_models.dart';

import '../../config/config.dart';
import '../../http/api_error.dart';

/// What a user is uploading, and what that permits.
///
/// The purpose is not decoration: a profile photograph and a qualification
/// certificate have different accepted types and different reasons to exist, and
/// a single "any file" endpoint would let a photograph slot accept a PDF nobody
/// will ever render.
enum UploadPurpose {
  /// A profile photograph. Images only — a PDF here would render as a broken
  /// avatar on every card in the marketplace.
  avatar('avatar', {MediaType.jpeg, MediaType.png, MediaType.webp}),

  /// A certificate or transcript proving a qualification. PDFs and photographs
  /// of paper both, because most Egyptian certificates exist as paper first.
  document('document', {
    MediaType.pdf,
    MediaType.jpeg,
    MediaType.png,
    MediaType.webp,
  }),

  /// An uploaded CV, for the CV builder's upload-first path.
  cv('cv', {MediaType.pdf});

  const UploadPurpose(this.wire, this.accepted);

  final String wire;
  final Set<MediaType> accepted;

  static UploadPurpose? fromWire(String? value) {
    for (final purpose in values) {
      if (purpose.wire == value) return purpose;
    }
    return null;
  }
}

/// A file type this server will store, identified by its bytes.
enum MediaType {
  jpeg('image/jpeg', 'jpg'),
  png('image/png', 'png'),
  webp('image/webp', 'webp'),
  pdf('application/pdf', 'pdf');

  const MediaType(this.mime, this.extension);

  final String mime;
  final String extension;

  /// Identifies a file by its leading bytes rather than by what the client
  /// says it is.
  ///
  /// A declared content type is a claim by whoever is uploading. Storing an
  /// executable because the request called it `image/png` is how an upload
  /// endpoint becomes a file-drop, so the claim is never the answer here — it
  /// is not even read.
  static MediaType? sniff(Uint8List bytes) {
    bool startsWith(List<int> magic) {
      if (bytes.length < magic.length) return false;
      for (var i = 0; i < magic.length; i++) {
        if (bytes[i] != magic[i]) return false;
      }
      return true;
    }

    if (startsWith([0xFF, 0xD8, 0xFF])) return MediaType.jpeg;
    if (startsWith([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])) {
      return MediaType.png;
    }
    if (startsWith([0x25, 0x50, 0x44, 0x46])) return MediaType.pdf;
    // RIFF....WEBP — the size field sits between the two markers.
    if (startsWith([0x52, 0x49, 0x46, 0x46]) &&
        bytes.length >= 12 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return MediaType.webp;
    }
    return null;
  }
}

/// A stored file's identity.
class StoredFile {
  const StoredFile({
    required this.key,
    required this.contentType,
    required this.sizeBytes,
  });

  /// `document/<userId>/<random>.pdf`. Random rather than sequential, so
  /// knowing one key tells you nothing about anyone else's.
  final String key;
  final String contentType;
  final int sizeBytes;

  Map<String, dynamic> toJson() => {
    'key': key,
    'content_type': contentType,
    'size_bytes': sizeBytes,
  };
}

/// Where uploaded files live.
///
/// An interface with one implementation today, for the same reason the payment
/// provider is one: the day this moves to object storage, the routes and the
/// two features that upload should not change.
abstract class FileStore {
  /// Stores [bytes] and returns the key to record.
  ///
  /// Throws [ApiException] with [ApiErrorCode.validation] when the bytes are
  /// not a type [purpose] accepts, or are larger than [maxBytes].
  Future<StoredFile> put({
    required String userId,
    required UploadPurpose purpose,
    required Uint8List bytes,
  });

  /// Reads a file back, or null when the key names nothing.
  Future<List<int>?> read(String key);

  /// The type a stored key holds, inferred from its extension.
  String? contentTypeOf(String key);

  /// The most any single upload may be.
  ///
  /// Eight megabytes covers a phone photograph of a certificate and a scanned
  /// PDF; it is small enough that a hostile client cannot fill the disk with
  /// one request.
  static const int maxBytes = 8 * 1024 * 1024;

  /// Whether [key] belongs to [userId].
  ///
  /// The owner is in the key, so a read can be authorised without a database
  /// round trip and cannot be desynchronised from one. A qualification
  /// certificate is a private document: reading one must never be a matter of
  /// guessing a URL.
  static bool isOwnedBy(String key, String userId) {
    final parts = key.split('/');
    return parts.length >= 3 && parts[1] == userId;
  }
}

class LocalFileStore implements FileStore {
  LocalFileStore(this._config);

  final AppConfig _config;

  static final Random _random = Random.secure();

  @override
  Future<StoredFile> put({
    required String userId,
    required UploadPurpose purpose,
    required Uint8List bytes,
  }) async {
    if (bytes.isEmpty) {
      throw ApiException.validation({'file': _emptyFile});
    }
    if (bytes.length > FileStore.maxBytes) {
      throw ApiException.validation({'file': _tooLarge});
    }

    final type = MediaType.sniff(bytes);
    if (type == null || !purpose.accepted.contains(type)) {
      throw ApiException.validation({
        'file': purpose == UploadPurpose.avatar ? _notAnImage : _notAccepted,
      });
    }

    final key = '${purpose.wire}/$userId/${_token()}.${type.extension}';
    final file = File(_pathFor(key));
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);

    return StoredFile(
      key: key,
      contentType: type.mime,
      sizeBytes: bytes.length,
    );
  }

  @override
  Future<List<int>?> read(String key) async {
    if (!_isSafeKey(key)) return null;
    final file = File(_pathFor(key));
    if (!file.existsSync()) return null;
    return file.readAsBytes();
  }

  @override
  String? contentTypeOf(String key) {
    final extension = key.split('.').last;
    for (final type in MediaType.values) {
      if (type.extension == extension) return type.mime;
    }
    return null;
  }

  String _pathFor(String key) => '${_config.storageRoot}/uploads/$key';

  /// Refuses anything that could climb out of the storage root.
  ///
  /// Keys are generated here, never supplied — but reads take one from the URL,
  /// and `..` in a path is the oldest way to turn a file server into a copy of
  /// `/etc`.
  static bool _isSafeKey(String key) =>
      !key.contains('..') &&
      !key.startsWith('/') &&
      !key.contains(r'\') &&
      RegExp(r'^[A-Za-z0-9._/-]+$').hasMatch(key);

  static String _token() {
    const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(
      24,
      (_) => alphabet[_random.nextInt(alphabet.length)],
    ).join();
  }

  static const LocalizedText _emptyFile = LocalizedText(
    en: 'That file is empty.',
    ar: 'هذا الملف فارغ.',
  );

  static const LocalizedText _tooLarge = LocalizedText(
    en: 'That file is larger than 8 MB. Try a smaller one.',
    ar: 'حجم الملف أكبر من 8 ميجابايت. جرّب ملفًا أصغر.',
  );

  static const LocalizedText _notAnImage = LocalizedText(
    en: 'That is not a photograph. Use a JPG, PNG or WebP image.',
    ar: 'هذه ليست صورة. استخدم صورة بصيغة JPG أو PNG أو WebP.',
  );

  static const LocalizedText _notAccepted = LocalizedText(
    en: 'That file type is not accepted. Use a PDF or a photograph.',
    ar: 'صيغة الملف غير مقبولة. استخدم ملف PDF أو صورة.',
  );
}
