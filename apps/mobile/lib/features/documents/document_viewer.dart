import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

/// Shows a document to the user.
///
/// One seam for the two features that produce one: a course handout, fetched
/// and read; and a CV, generated and handed over. Both open the platform's own
/// viewer, where the user can already print, save or send — which is why the
/// app itself never writes a file. Downloads is cut, and the version of this
/// that keeps a copy on the device is the version that would need a storage
/// screen, a delete action and an undo behind it.
///
/// Behind a provider because a widget test cannot open a viewer: the tests
/// override it and assert on the bytes that were handed over, which is the
/// part that can actually be wrong.
typedef DocumentViewer =
    Future<void> Function({required Uint8List bytes, required String name});

final documentViewerProvider = Provider<DocumentViewer>(
  (ref) => _openWithPlatform,
);

Future<void> _openWithPlatform({
  required Uint8List bytes,
  required String name,
}) => Printing.layoutPdf(
  onLayout: (_) async => bytes,
  name: name,
);
