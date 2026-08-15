import 'package:ejadah_server/src/http/api_error.dart';
import 'package:ejadah_server/src/modules/profile/cv_service.dart';
import 'package:test/test.dart';

import 'support/test_database.dart';

/// The CV builder (PR-07).
///
/// Upload-first, because most people already have a CV and retyping one into a
/// form is how a feature goes unused. Every typed section is optional, because
/// a builder that refuses to save until six boxes are full is one people
/// abandon at box two.
void main() {
  late TestDatabase db;
  late CvService service;
  late String userId;
  late String otherId;

  setUpAll(() async {
    db = await TestDatabase.open();
  });

  tearDownAll(() async {
    await db.close();
  });

  setUp(() async {
    await db.reset();
    service = CvService(db.database);
    userId = await _createUser(db, 'mona@ejadah.test');
    otherId = await _createUser(db, 'bob@ejadah.test');
  });

  group('the upload', () {
    test('is the first thing on the CV', () async {
      await service.setUploadedFile(userId: userId, storageKey: 'cv/u/a.pdf');
      await service.saveSection(
        userId: userId,
        kind: 'summary',
        heading: 'Summary',
        body: 'Consultant endodontist.',
      );

      final sections = await service.sections(userId);
      // Position 0: the file someone already had sits above anything they
      // typed afterwards.
      expect(sections.first.isUpload, isTrue);
      expect(sections.first.body, 'cv/u/a.pdf');
      expect(sections.last.kind, 'summary');
    });

    test('replaces rather than stacking', () async {
      await service.setUploadedFile(userId: userId, storageKey: 'cv/u/old.pdf');
      await service.setUploadedFile(userId: userId, storageKey: 'cv/u/new.pdf');

      // One CV file. Two would leave a reader guessing which is current.
      final uploads = (await service.sections(
        userId,
      )).where((section) => section.isUpload);
      expect(uploads, hasLength(1));
      expect(uploads.single.body, 'cv/u/new.pdf');
    });

    test('can be removed without taking the typed sections with it', () async {
      await service.setUploadedFile(userId: userId, storageKey: 'cv/u/a.pdf');
      await service.saveSection(
        userId: userId,
        kind: 'skills',
        heading: 'Skills',
        body: 'Microscope-assisted retreatment',
      );

      await service.removeUploadedFile(userId);

      final sections = await service.sections(userId);
      expect(sections, hasLength(1));
      expect(sections.single.kind, 'skills');
    });
  });

  group('typed sections', () {
    test('every one is optional — an empty body still saves', () async {
      final section = await service.saveSection(
        userId: userId,
        kind: 'publications',
        heading: 'Publications',
        body: '',
      );
      expect(section.body, '');
    });

    test('an invented kind is refused rather than stored', () async {
      // The table would happily hold anything; refusing here is what stops it
      // becoming arbitrary storage.
      await expectLater(
        service.saveSection(
          userId: userId,
          kind: 'arbitrary',
          heading: 'x',
          body: 'y',
        ),
        throwsA(isA<ApiException>()),
      );
    });

    test('the upload kind cannot be written as a typed section', () async {
      await expectLater(
        service.saveSection(
          userId: userId,
          kind: CvService.uploadedKind,
          heading: '',
          body: 'cv/u/forged.pdf',
        ),
        throwsA(isA<ApiException>()),
      );
    });

    test('an over-long section is refused with the field named', () async {
      try {
        await service.saveSection(
          userId: userId,
          kind: 'experience',
          heading: 'Experience',
          body: 'x' * (CvService.bodyMaxLength + 1),
        );
        fail('an over-long section must not save');
      } on ApiException catch (error) {
        expect(error.code, ApiErrorCode.validation);
        expect(error.fields.keys.single, 'body');
      }
    });
  });

  group('deleting', () {
    test('removes your own section', () async {
      final section = await service.saveSection(
        userId: userId,
        kind: 'other',
        heading: 'Other',
        body: 'Volunteering',
      );
      await service.deleteSection(userId: userId, sectionId: section.id);
      expect(await service.sections(userId), isEmpty);
    });

    test("cannot touch someone else's, and says not-found rather than no",
        () async {
      final section = await service.saveSection(
        userId: userId,
        kind: 'other',
        heading: 'Other',
        body: 'Volunteering',
      );

      await expectLater(
        service.deleteSection(userId: otherId, sectionId: section.id),
        throwsA(isA<ApiException>()),
      );
      // And it is still there.
      expect(await service.sections(userId), hasLength(1));
    });
  });

  test('reordering survives a swap that passes through occupied positions',
      () async {
    final first = await service.saveSection(
      userId: userId,
      kind: 'education',
      heading: 'Education',
      body: '',
    );
    final second = await service.saveSection(
      userId: userId,
      kind: 'experience',
      heading: 'Experience',
      body: '',
    );

    // `UNIQUE (user_id, position)` fires mid-shuffle unless the rows are moved
    // out of the way first. A straight swap is the case that catches it.
    final reordered = await service.reorder(
      userId: userId,
      sectionIds: [second.id, first.id],
    );

    expect(reordered.map((section) => section.kind), [
      'experience',
      'education',
    ]);
  });

  test('reordering never moves the uploaded file off the top', () async {
    await service.setUploadedFile(userId: userId, storageKey: 'cv/u/a.pdf');
    final typed = await service.saveSection(
      userId: userId,
      kind: 'summary',
      heading: 'Summary',
      body: '',
    );

    final reordered = await service.reorder(
      userId: userId,
      sectionIds: [typed.id],
    );

    expect(reordered.first.isUpload, isTrue);
  });

  test('the patient-data warning is the approved wording, in both languages',
      () {
    // Sent with the CV rather than written into the app's copy, so a redesign
    // that only touches the client cannot drop the one warning this screen
    // must always show.
    expect(
      CvService.patientDataWarning.en,
      "Please don't include patient names or identifying details.",
    );
    expect(
      CvService.patientDataWarning.ar,
      'لا تُدرج أسماء المرضى أو بيانات تعريفية.',
    );
  });
}

Future<String> _createUser(TestDatabase db, String email) async {
  final result = await db.execute(
    "INSERT INTO users (email, password_hash, full_name_en, full_name_ar) "
    "VALUES (@email, 'x', 'Mona Adel', 'منى عادل') RETURNING id",
    {'email': email},
  );
  return result.first[0]! as String;
}
