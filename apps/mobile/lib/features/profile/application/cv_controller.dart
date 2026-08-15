import 'package:ejadah_core/ejadah_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/cv_repository.dart';

final cvControllerProvider = AsyncNotifierProvider<CvController, Cv>(
  CvController.new,
);

/// The CV builder.
class CvController extends AsyncNotifier<Cv> {
  @override
  Future<Cv> build() => ref.read(cvRepositoryProvider).load();

  CvRepository get _repository => ref.read(cvRepositoryProvider);

  Future<void> refresh() async {
    state = await AsyncValue.guard(_repository.load);
  }

  Future<Failure?> setUploadedFile(String storageKey) =>
      _write(() => _repository.setUploadedFile(storageKey));

  Future<Failure?> removeUploadedFile() =>
      _write(_repository.removeUploadedFile);

  Future<Failure?> saveSection({
    required String kind,
    required String heading,
    required String body,
  }) => _write(
    () => _repository.saveSection(kind: kind, heading: heading, body: body),
  );

  Future<Failure?> deleteSection(String id) =>
      _write(() => _repository.deleteSection(id));

  /// Runs a write and re-reads.
  ///
  /// Returns the failure rather than throwing so the screen can show the
  /// server's own message — which for a CV is usually the length rule, and is
  /// the sentence that tells someone what to change.
  ///
  /// Deliberately not optimistic. The rest of this app updates hopefully, but a
  /// CV section that appears and then vanishes when the write fails looks like
  /// lost work, and lost work is the one thing a document editor may not do.
  Future<Failure?> _write(Future<void> Function() action) async {
    try {
      await action();
      state = AsyncData(await _repository.load());
      return null;
    } on Failure catch (failure) {
      await refresh();
      return failure;
    }
  }
}
