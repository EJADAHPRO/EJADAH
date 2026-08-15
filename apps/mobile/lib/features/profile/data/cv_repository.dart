import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';

/// One block of the CV.
class CvSection {
  const CvSection({
    required this.id,
    required this.position,
    required this.kind,
    required this.heading,
    required this.body,
  });

  final String id;
  final int position;
  final String kind;
  final String heading;
  final String body;

  /// The one section that holds a file key rather than text.
  bool get isUpload => kind == 'uploaded';

  static CvSection fromJson(Map<String, dynamic> json) => CvSection(
    id: json['id'] as String,
    position: (json['position'] as num).toInt(),
    kind: json['kind'] as String,
    heading: json['heading'] as String? ?? '',
    body: json['body'] as String? ?? '',
  );
}

/// The CV, and the warning that is always shown with it.
class Cv {
  const Cv({
    required this.sections,
    required this.patientDataWarning,
    required this.kinds,
  });

  final List<CvSection> sections;

  /// From the server, not from the app's copy — so a redesign that only touches
  /// the client cannot drop the one warning this screen must always show.
  final LocalizedText patientDataWarning;

  /// The section kinds the server will accept. Offering one it would refuse is
  /// a dropdown that produces an error.
  final List<String> kinds;

  CvSection? get uploaded =>
      sections.where((section) => section.isUpload).firstOrNull;

  List<CvSection> get typed =>
      sections.where((section) => !section.isUpload).toList();

  static Cv fromJson(Map<String, dynamic> json) => Cv(
    sections: (json['items'] as List<dynamic>)
        .map(
          (item) => CvSection.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(),
    patientDataWarning:
        LocalizedText.fromJson(json['patient_data_warning']) ??
        const LocalizedText.same(''),
    kinds: (json['kinds'] as List<dynamic>)
        .map((kind) => kind.toString())
        .where((kind) => kind != 'uploaded')
        .toList(),
  );
}

class CvRepository {
  const CvRepository(this._client);

  final ApiClient _client;

  Future<Cv> load() => _client.get('/profile/cv', parse: Cv.fromJson);

  Future<CvSection> setUploadedFile(String storageKey) => _client.put(
    '/profile/cv/upload',
    body: {'storage_key': storageKey},
    parse: CvSection.fromJson,
  );

  Future<void> removeUploadedFile() => _client.delete('/profile/cv/upload');

  Future<CvSection> saveSection({
    required String kind,
    required String heading,
    required String body,
    int? position,
  }) => _client.post(
    '/profile/cv/sections',
    body: {
      'kind': kind,
      'heading': heading,
      'body': body,
      if (position != null) 'position': position,
    },
    parse: CvSection.fromJson,
  );

  Future<void> deleteSection(String id) =>
      _client.delete('/profile/cv/sections/$id');
}

final cvRepositoryProvider = Provider<CvRepository>(
  (ref) => CvRepository(ref.watch(apiClientProvider)),
);
