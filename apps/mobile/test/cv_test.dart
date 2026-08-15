import 'dart:typed_data';

import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_mobile/features/profile/data/cv_repository.dart';
import 'package:ejadah_mobile/features/profile/presentation/cv_screen.dart';
import 'package:ejadah_mobile/features/uploads/file_field.dart';
import 'package:ejadah_mobile/features/uploads/upload_repository.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The CV builder (PR-07).
///
/// Upload-first, and the patient-data warning always on screen. The second is
/// not a nicety: a CV is a document clinicians paste case notes into, and a
/// patient's name reaching this server is a data-protection incident.
void main() {
  testWidgets('the patient-data warning is visible without any interaction', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(_FakeRepository(cv: _cv())));
    await tester.pumpAndSettle();

    // Always on screen, never behind a tap, and never only after a failed
    // save.
    expect(find.text(_warning.ar), findsOneWidget);
  });

  testWidgets('the warning is repeated where the typing actually happens', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(_FakeRepository(cv: _cv())));
    await tester.pumpAndSettle();

    await tester.tap(find.text('أضف قسمًا'));
    await tester.pumpAndSettle();

    // The editor is its own route — the CV screen behind it is gone from the
    // tree — so the warning has to be here too. A reminder on a screen nobody
    // is looking at is not a reminder.
    expect(find.byType(EjadahInput), findsNWidgets(2));
    expect(find.text(_warning.ar), findsOneWidget);
  });

  testWidgets('the upload comes first, before anything that takes typing', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(_FakeRepository(cv: _cv())));
    await tester.pumpAndSettle();

    final upload = tester.getTopLeft(find.text('ملفك'));
    final sections = tester.getTopLeft(find.text('الأقسام'));
    expect(upload.dy, lessThan(sections.dy));
  });

  testWidgets('an uploaded file records its key against the CV', (
    tester,
  ) async {
    final repository = _FakeRepository(cv: _cv());
    await tester.pumpWidget(_harness(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('اختر ملفًا'));
    await tester.pumpAndSettle();

    expect(repository.uploadedKey, 'cv/u/abc.pdf');
  });

  testWidgets('the editor offers only the kinds the server accepts', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        _FakeRepository(cv: _cv(kinds: const ['summary', 'skills'])),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('أضف قسمًا'));
    await tester.pumpAndSettle();

    // A chip that would produce a 404 is a chip that should not be offered.
    expect(find.text('نبذة'), findsOneWidget);
    expect(find.text('المهارات'), findsOneWidget);
    expect(find.text('التعليم'), findsNothing);
  });

  testWidgets('a section saves with an empty body — every one is optional', (
    tester,
  ) async {
    final repository = _FakeRepository(cv: _cv(kinds: const ['summary']));
    await tester.pumpWidget(_harness(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('أضف قسمًا'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    // A builder that refuses to save until six boxes are full is one people
    // abandon at box two.
    expect(repository.savedKind, 'summary');
    expect(repository.savedBody, '');
  });

  testWidgets('an existing section can be removed', (tester) async {
    final repository = _FakeRepository(
      cv: _cv(
        sections: [
          const CvSection(
            id: 's1',
            position: 1,
            kind: 'summary',
            heading: 'Summary',
            body: 'Consultant endodontist.',
          ),
        ],
      ),
    );
    await tester.pumpWidget(_harness(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(EjadahIconButton).first);
    await tester.pumpAndSettle();

    expect(repository.deletedId, 's1');
  });

  testWidgets('an empty CV says what to do rather than showing a blank', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(_FakeRepository(cv: _cv())));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'لا شيء هنا بعد. ارفع سيرة ذاتية، أو أضف قسمًا — أيهما أسهل.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('a failure states what happened and offers a retry', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(_FakeRepository(failure: const NetworkFailure())),
    );
    await tester.pumpAndSettle();

    expect(find.byType(EjadahErrorState), findsOneWidget);
  });
}

Widget _harness(CvRepository repository) => ProviderScope(
  overrides: [
    cvRepositoryProvider.overrideWithValue(repository),
    uploadRepositoryProvider.overrideWithValue(_FakeUploads()),
    filePickerProvider.overrideWithValue(
      (purpose) async =>
          PickedFile(name: 'cv.pdf', bytes: Uint8List.fromList([0x25, 0x50])),
    ),
  ],
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: const Locale('ar'),
    supportedLocales: ejadahSupportedLocales,
    localizationsDelegates: EjadahStrings.localizationsDelegates,
    theme: buildEjadahTheme(
      language: AppLanguage.ar,
      windowClass: EjadahWindowClass.compact,
      reduceMotion: true,
    ),
    home: const Directionality(
      textDirection: TextDirection.rtl,
      child: CvScreen(),
    ),
  ),
);

const LocalizedText _warning = LocalizedText(
  en: "Please don't include patient names or identifying details.",
  ar: 'لا تُدرج أسماء المرضى أو بيانات تعريفية.',
);

Cv _cv({
  List<CvSection> sections = const [],
  List<String> kinds = const [
    'summary',
    'education',
    'experience',
    'skills',
    'publications',
    'other',
  ],
}) => Cv(sections: sections, patientDataWarning: _warning, kinds: kinds);

class _FakeRepository implements CvRepository {
  _FakeRepository({this.cv, this.failure});

  final Cv? cv;
  final Failure? failure;

  String? uploadedKey;
  String? savedKind;
  String? savedBody;
  String? deletedId;

  @override
  Future<Cv> load() async {
    if (failure != null) throw failure!;
    return cv!;
  }

  @override
  Future<CvSection> setUploadedFile(String storageKey) async {
    uploadedKey = storageKey;
    return CvSection(
      id: 'u1',
      position: 0,
      kind: 'uploaded',
      heading: '',
      body: storageKey,
    );
  }

  @override
  Future<void> removeUploadedFile() async {
    uploadedKey = null;
  }

  @override
  Future<CvSection> saveSection({
    required String kind,
    required String heading,
    required String body,
    int? position,
  }) async {
    savedKind = kind;
    savedBody = body;
    return CvSection(
      id: 's-new',
      position: position ?? 1,
      kind: kind,
      heading: heading,
      body: body,
    );
  }

  @override
  Future<void> deleteSection(String id) async {
    deletedId = id;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUploads implements UploadRepository {
  @override
  Future<StoredFile> upload({
    required UploadPurpose purpose,
    required Uint8List bytes,
  }) async => const StoredFile(
    key: 'cv/u/abc.pdf',
    contentType: 'application/pdf',
    sizeBytes: 2,
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
