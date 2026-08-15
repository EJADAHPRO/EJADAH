import 'dart:convert';
import 'dart:typed_data';

import 'package:ejadah_core/ejadah_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';

/// What a file is being uploaded for.
///
/// Mirrors the server's enum, and narrows what is accepted: a photograph slot
/// that took a PDF would render as a broken avatar on every card in the
/// marketplace.
enum UploadPurpose {
  avatar('avatar', ['jpg', 'jpeg', 'png']),
  document('document', ['pdf', 'jpg', 'jpeg', 'png']),
  cv('cv', ['pdf']);

  const UploadPurpose(this.wire, this.extensions);

  final String wire;

  /// What the picker offers. The server still decides from the bytes — this is
  /// a courtesy so the file browser does not show files that will be refused.
  final List<String> extensions;
}

/// A file the server has accepted and stored.
class StoredFile {
  const StoredFile({
    required this.key,
    required this.contentType,
    required this.sizeBytes,
  });

  /// What the application records. Never a URL — the file is read back through
  /// an owner-checked route, not from a public path.
  final String key;
  final String contentType;
  final int sizeBytes;

  static StoredFile fromJson(Map<String, dynamic> json) => StoredFile(
    key: json['key'] as String,
    contentType: json['content_type'] as String,
    sizeBytes: (json['size_bytes'] as num).toInt(),
  );
}

/// Sending a file to the server.
class UploadRepository {
  const UploadRepository(this._client);

  final ApiClient _client;

  /// The most a file may be, matching the server's cap.
  ///
  /// Checked here as well so an oversized photograph is refused with a readable
  /// message on a Cairo mobile connection rather than after a long upload that
  /// ends in a 422.
  /// Five megabytes, the figure `CONTENT.md` states — and the limit the copy
  /// promises has to be the limit that is enforced.
  static const int maxBytes = 5 * 1024 * 1024;

  Future<StoredFile> upload({
    required UploadPurpose purpose,
    required Uint8List bytes,
  }) => _client.post(
    '/uploads/${purpose.wire}',
    body: {'data': base64Encode(bytes)},
    parse: StoredFile.fromJson,
  );
}

final uploadRepositoryProvider = Provider<UploadRepository>(
  (ref) => UploadRepository(ref.watch(apiClientProvider)),
);
