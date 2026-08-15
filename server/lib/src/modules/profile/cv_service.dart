import 'package:ejadah_models/ejadah_models.dart';
import 'package:postgres/postgres.dart';

import '../../db/database.dart';
import '../../http/api_error.dart';

/// One block of a CV.
///
/// Free text rather than a schema of jobs and dates, because a dental CV in
/// Egypt is not the same shape as one in Germany and forcing either into the
/// other's fields loses the parts that matter.
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

  /// `uploaded` marks the one section that holds a file rather than text.
  final String kind;
  final String heading;
  final String body;

  bool get isUpload => kind == CvService.uploadedKind;

  Map<String, dynamic> toJson() => {
    'id': id,
    'position': position,
    'kind': kind,
    'heading': heading,
    'body': body,
  };
}

/// The CV, and the file it may have started as.
///
/// **Upload-first.** Most people already have a CV; asking them to retype it
/// into a form is how a feature goes unused. The uploaded file is the primary
/// path and the sections are what someone builds *afterwards*, or instead.
class CvService {
  const CvService(this._database);

  final Database _database;

  /// The section kind that holds an uploaded file's key in its body.
  static const String uploadedKind = 'uploaded';

  /// Sections that exist because the flow names them. Anything else is refused
  /// rather than stored, so this table cannot become arbitrary storage.
  static const Set<String> kinds = {
    uploadedKind,
    'summary',
    'education',
    'experience',
    'skills',
    'publications',
    'other',
  };

  static const int headingMaxLength = 120;
  static const int bodyMaxLength = 4000;

  /// The warning that is always on screen, and is not only decoration: a CV is
  /// a document dentists paste case notes into, and a patient's name reaching
  /// this server is a data-protection incident rather than an untidy field.
  static const LocalizedText patientDataWarning = LocalizedText(
    en: "Please don't include patient names or identifying details.",
    ar: 'لا تُدرج أسماء المرضى أو بيانات تعريفية.',
  );

  Future<List<CvSection>> sections(String userId) async {
    final rows = await _query(
      'SELECT * FROM cv_sections WHERE user_id = @user_id ORDER BY position',
      {'user_id': userId},
    );
    return rows.map(_toSection).toList();
  }

  /// Records an uploaded CV as the first section.
  ///
  /// Replaces rather than appends: someone has one CV file, and two would leave
  /// a reader guessing which is current.
  Future<CvSection> setUploadedFile({
    required String userId,
    required String storageKey,
  }) => _database.runTx((tx) async {
    await tx.execute(
      Sql.named(
        'DELETE FROM cv_sections WHERE user_id = @user_id AND kind = @kind',
      ),
      parameters: {'user_id': userId, 'kind': uploadedKind},
    );

    // Position 0 so the upload sits above anything typed. The other sections
    // are 1-based, which leaves this slot free without renumbering them.
    final inserted = await tx.execute(
      Sql.named(
        'INSERT INTO cv_sections (user_id, position, kind, heading, body) '
        "VALUES (@user_id, 0, @kind, '', @body) RETURNING *",
      ),
      parameters: {
        'user_id': userId,
        'kind': uploadedKind,
        'body': storageKey,
      },
    );
    return _toSection(inserted.first.toColumnMap());
  });

  Future<void> removeUploadedFile(String userId) async {
    await _execute(
      'DELETE FROM cv_sections WHERE user_id = @user_id AND kind = @kind',
      {'user_id': userId, 'kind': uploadedKind},
    );
  }

  /// Adds or replaces a typed section.
  ///
  /// Every section is optional. The flow says so, and a CV builder that refuses
  /// to save until six boxes are full is a CV builder people abandon at box
  /// two.
  Future<CvSection> saveSection({
    required String userId,
    required String kind,
    required String heading,
    required String body,
    int? position,
  }) async {
    if (!kinds.contains(kind) || kind == uploadedKind) {
      throw ApiException.notFound();
    }

    final fields = <String, LocalizedText>{};
    if (heading.trim().length > headingMaxLength) {
      fields['heading'] = _headingTooLong;
    }
    if (body.trim().length > bodyMaxLength) {
      fields['body'] = _bodyTooLong;
    }
    if (fields.isNotEmpty) throw ApiException.validation(fields);

    final rows = await _query(
      '''
      INSERT INTO cv_sections (user_id, position, kind, heading, body)
      VALUES (
        @user_id,
        COALESCE(
          @position,
          -- Appended after whatever exists. Position 0 belongs to the upload.
          (SELECT COALESCE(MAX(position), 0) + 1 FROM cv_sections
           WHERE user_id = @user_id)
        ),
        @kind, @heading, @body
      )
      ON CONFLICT (user_id, position) DO UPDATE SET
        kind = @kind, heading = @heading, body = @body
      RETURNING *
      ''',
      {
        'user_id': userId,
        'position': position,
        'kind': kind,
        'heading': heading.trim(),
        'body': body.trim(),
      },
    );
    return _toSection(rows.first);
  }

  /// Deletes one section.
  ///
  /// Scoped by user id in the WHERE clause rather than checked first: an
  /// ownership check that happens in a separate statement is an ownership check
  /// that can be raced.
  Future<void> deleteSection({
    required String userId,
    required String sectionId,
  }) async {
    final rows = await _query(
      'DELETE FROM cv_sections WHERE id = @id AND user_id = @user_id '
      'RETURNING id',
      {'id': sectionId, 'user_id': userId},
    );
    // Not-found rather than forbidden for someone else's section: a 403 would
    // confirm it exists.
    if (rows.isEmpty) throw ApiException.notFound();
  }

  /// Reorders the typed sections.
  ///
  /// Takes the whole list rather than a move instruction, so the result cannot
  /// depend on what the client believed the previous order was.
  Future<List<CvSection>> reorder({
    required String userId,
    required List<String> sectionIds,
  }) => _database.runTx((tx) async {
    // Out of the way first: `UNIQUE (user_id, position)` fires mid-loop
    // otherwise, because a shuffle passes through positions that are still
    // occupied. Negative positions cannot collide with the ones being written.
    for (var i = 0; i < sectionIds.length; i++) {
      await tx.execute(
        Sql.named(
          'UPDATE cv_sections SET position = @position '
          'WHERE id = @id AND user_id = @user_id AND kind <> @uploaded',
        ),
        parameters: {
          'position': -(i + 1),
          'id': sectionIds[i],
          'user_id': userId,
          'uploaded': uploadedKind,
        },
      );
    }
    for (var i = 0; i < sectionIds.length; i++) {
      await tx.execute(
        Sql.named(
          'UPDATE cv_sections SET position = @position '
          'WHERE id = @id AND user_id = @user_id AND kind <> @uploaded',
        ),
        parameters: {
          'position': i + 1,
          'id': sectionIds[i],
          'user_id': userId,
          'uploaded': uploadedKind,
        },
      );
    }

    final rows = await tx.execute(
      Sql.named(
        'SELECT * FROM cv_sections WHERE user_id = @user_id ORDER BY position',
      ),
      parameters: {'user_id': userId},
    );
    return rows.map((row) => _toSection(row.toColumnMap())).toList();
  });

  CvSection _toSection(Map<String, dynamic> row) => CvSection(
    id: row.str('id'),
    position: row.intAt('position'),
    kind: row.str('kind'),
    heading: row.str('heading'),
    body: row.str('body'),
  );

  Future<List<Map<String, dynamic>>> _query(
    String sql,
    Map<String, Object?> parameters,
  ) async {
    final result = await _database.run(
      (session) => session.execute(Sql.named(sql), parameters: parameters),
    );
    return result.map((row) => row.toColumnMap()).toList();
  }

  Future<void> _execute(String sql, Map<String, Object?> parameters) async {
    await _query(sql, parameters);
  }

  static const LocalizedText _headingTooLong = LocalizedText(
    en: 'That heading is too long. Keep it under 120 characters.',
    ar: 'هذا العنوان طويل. اجعله أقل من 120 حرفًا.',
  );

  static const LocalizedText _bodyTooLong = LocalizedText(
    en: 'That section is too long. Keep it under 4,000 characters.',
    ar: 'هذا القسم طويل. اجعله أقل من 4,000 حرف.',
  );
}
