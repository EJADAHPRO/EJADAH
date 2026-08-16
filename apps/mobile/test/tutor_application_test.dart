import 'dart:typed_data';

import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_mobile/features/people/data/tutor_application_repository.dart';
import 'package:ejadah_mobile/features/people/presentation/become_tutor_screen.dart';
import 'package:ejadah_mobile/features/people/presentation/tutor_application_screen.dart';
import 'package:ejadah_mobile/features/uploads/file_field.dart';
import 'package:ejadah_mobile/features/uploads/upload_repository.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// The supply side's way in.
///
/// The marketplace has no product without tutors, and the flow names two rules
/// that decide whether anyone finishes this form: every step is draft-saved,
/// and a blocked submit names **every** missing item. Both are the kind that
/// pass a visual review while being quietly broken, so both are asserted here.
void main() {
  testWidgets('the pitch states the split from the server, not from copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const BecomeTutorScreen(),
        _FakeRepository(snapshot: _snapshot()),
      ),
    );
    await tester.pumpAndSettle();

    // 70 comes from `professional_share_percent`. A number written into the
    // string table would keep saying 70 the day the ledger changed.
    expect(find.textContaining('70'), findsOneWidget);
    expect(find.textContaining('30'), findsOneWidget);
  });

  testWidgets('leaving a step saves it', (tester) async {
    final repository = _FakeRepository(snapshot: _snapshot());
    await tester.pumpWidget(
      _harness(const TutorApplicationScreen(), repository),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Dr. Mona Adel');
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();

    // Saved on leaving the step, not held until submit: a six-step form on a
    // phone that only writes at the end is a form that loses step 4.
    expect(repository.saved, hasLength(1));
    expect(repository.saved.single.step, ApplicationStep.basics);
    expect(repository.saved.single.answers['display_name_en'], 'Dr. Mona Adel');
  });

  testWidgets('going back also saves, and does not lose the answer', (
    tester,
  ) async {
    final repository = _FakeRepository(
      snapshot: _snapshot(
        application: _application(lastStep: 2, payload: const {}),
      ),
    );
    await tester.pumpWidget(
      _harness(const TutorApplicationScreen(), repository),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'BDS Cairo');
    await tester.tap(find.text('رجوع'));
    await tester.pumpAndSettle();

    // Which direction someone moves has nothing to do with whether their
    // answer is worth keeping.
    expect(repository.saved, hasLength(1));
    expect(repository.saved.single.step, ApplicationStep.qualifications);
    expect(repository.saved.single.answers['items'], ['BDS Cairo']);
  });

  testWidgets('a draft resumes at the step it reached', (tester) async {
    await tester.pumpWidget(
      _harness(
        const TutorApplicationScreen(),
        _FakeRepository(
          snapshot: _snapshot(
            application: _application(
              lastStep: 4,
              payload: const {
                'rate': {'hourly_rate_egp': 800},
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Step 4, with what was typed there still in the field. Resuming at step 1
    // would make the saving pointless.
    expect(find.text('سعرك'), findsOneWidget);
    expect(find.text('800'), findsOneWidget);
  });

  testWidgets('the review step names every missing item, not the first', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const TutorApplicationScreen(),
        _FakeRepository(
          snapshot: _snapshot(
            application: _application(lastStep: 6, payload: const {}),
            missing: _threeMissing,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Walk to the review screen.
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();

    for (final item in _threeMissing) {
      expect(find.text(item.label.ar), findsOneWidget);
    }
  });

  testWidgets('submit is disabled with the reason while anything is missing', (
    tester,
  ) async {
    final repository = _FakeRepository(
      snapshot: _snapshot(
        application: _application(lastStep: 6, payload: const {}),
        missing: _threeMissing,
      ),
    );
    await tester.pumpWidget(
      _harness(const TutorApplicationScreen(), repository),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();

    // The reason is on screen *before* the tap, above the button — not only
    // discovered by prodding a control that looks broken.
    expect(find.text('أضف ما هو مذكور أعلاه أولًا.'), findsOneWidget);

    await tester.tap(find.text('أرسل للمراجعة'));
    await tester.pumpAndSettle();

    // Nothing was sent, and the tap repeated the reason rather than doing
    // nothing at all.
    expect(repository.submitted, isFalse);
    expect(find.text('أضف ما هو مذكور أعلاه أولًا.'), findsNWidgets(2));
  });

  testWidgets('with nothing missing, submit sends', (tester) async {
    final repository = _FakeRepository(
      snapshot: _snapshot(
        application: _application(lastStep: 6, payload: const {}),
      ),
    );
    await tester.pumpWidget(
      _routedHarness(const TutorApplicationScreen(), repository),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();

    expect(find.text('كل ما طلبناه موجود.'), findsOneWidget);

    await tester.tap(find.text('أرسل للمراجعة'));
    await tester.pumpAndSettle();

    expect(repository.submitted, isTrue);
  });

  testWidgets('an application under review is shown, not editable', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const TutorApplicationScreen(),
        _FakeRepository(
          snapshot: _snapshot(
            application: _application(
              lastStep: 1,
              payload: const {
                'basics': {'display_name_en': 'Dr. Mona Adel'},
              },
              status: ProfessionalStatus.underReview,
              isEditable: false,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The reason the fields are dead is stated, rather than left to be
    // discovered by tapping them.
    expect(find.text('قيد المراجعة'), findsOneWidget);
    final field = tester.widget<TextField>(find.byType(TextField).first);
    expect(field.enabled, isFalse);
  });

  testWidgets('a refused upload does not read as attached', (tester) async {
    await tester.pumpWidget(
      _harness(
        const TutorApplicationScreen(),
        _FakeRepository(
          snapshot: _snapshot(
            application: _application(lastStep: 2, payload: const {}),
          ),
        ),
        uploader: _RefusingUploads(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('اختر ملفًا'));
    await tester.pumpAndSettle();

    // Still asking for a file, with the reason shown. Showing "chosen" here
    // would let someone submit believing a certificate was attached.
    expect(find.text('اختر ملفًا'), findsOneWidget);
    expect(find.text('استبدال'), findsNothing);
    expect(find.text(_refusal.ar), findsOneWidget);
  });
}

Widget _harness(
  Widget screen,
  TutorApplicationRepository repository, {
  UploadRepository? uploader,
}) => ProviderScope(
  overrides: [
    tutorApplicationRepositoryProvider.overrideWithValue(repository),
    if (uploader != null) uploadRepositoryProvider.overrideWithValue(uploader),
    // A widget test cannot open a file browser; this stands in for one so the
    // upload, the refusal and the "chosen" affordance stay under test.
    filePickerProvider.overrideWithValue(
      (purpose) async =>
          PickedFile(name: 'bds.pdf', bytes: Uint8List.fromList([0x25, 0x50])),
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
    home: Directionality(textDirection: TextDirection.rtl, child: screen),
  ),
);

/// The same harness with a router underneath it, for the flows that navigate.
Widget _routedHarness(
  Widget screen,
  TutorApplicationRepository repository,
) => ProviderScope(
  overrides: [
    tutorApplicationRepositoryProvider.overrideWithValue(repository),
    filePickerProvider.overrideWithValue(
      (purpose) async =>
          PickedFile(name: 'bds.pdf', bytes: Uint8List.fromList([0x25, 0x50])),
    ),
  ],
  child: MaterialApp.router(
    debugShowCheckedModeBanner: false,
    locale: const Locale('ar'),
    supportedLocales: ejadahSupportedLocales,
    localizationsDelegates: EjadahStrings.localizationsDelegates,
    theme: buildEjadahTheme(
      language: AppLanguage.ar,
      windowClass: EjadahWindowClass.compact,
      reduceMotion: true,
    ),
    routerConfig: GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              Directionality(textDirection: TextDirection.rtl, child: screen),
        ),
        GoRoute(
          path: '/teach/status',
          builder: (context, state) => const Scaffold(body: Text('status')),
        ),
      ],
    ),
  ),
);

TutorApplicationSnapshot _snapshot({
  TutorApplication? application,
  List<MissingItem> missing = const [],
}) => TutorApplicationSnapshot(
  professionalSharePercent: 70,
  minimumWeeklyHours: 5,
  missing: missing,
  application: application,
);

TutorApplication _application({
  required int lastStep,
  required Map<String, dynamic> payload,
  ProfessionalStatus status = ProfessionalStatus.draft,
  bool isEditable = true,
}) => TutorApplication(
  status: status,
  lastStep: lastStep,
  payload: payload,
  isEditable: isEditable,
);

const List<MissingItem> _threeMissing = [
  MissingItem(
    key: 'basics.display_name_ar',
    step: ApplicationStep.basics,
    field: 'display_name_ar',
    label: LocalizedText(en: 'Your name in Arabic', ar: 'اسمك بالعربية'),
  ),
  MissingItem(
    key: 'qualifications.document_key',
    step: ApplicationStep.qualifications,
    field: 'document_key',
    label: LocalizedText(
      en: 'A document proving one of them',
      ar: 'مستند يثبت أحدها',
    ),
  ),
  MissingItem(
    key: 'media.avatar_key',
    step: ApplicationStep.media,
    field: 'avatar_key',
    label: LocalizedText(en: 'A photograph', ar: 'صورة شخصية'),
  ),
];

const LocalizedText _refusal = LocalizedText(
  en: 'That file type is not accepted. Use a PDF or a photograph.',
  ar: 'صيغة الملف غير مقبولة. استخدم ملف PDF أو صورة.',
);

class _SavedStep {
  const _SavedStep(this.step, this.answers);

  final ApplicationStep step;
  final Map<String, dynamic> answers;
}

class _FakeRepository implements TutorApplicationRepository {
  _FakeRepository({required TutorApplicationSnapshot snapshot})
    : _current = snapshot;

  final TutorApplicationSnapshot _current;
  final List<_SavedStep> saved = [];
  bool submitted = false;

  @override
  Future<TutorApplicationSnapshot> snapshot() async => _current;

  @override
  Future<TutorApplication> saveStep({
    required ApplicationStep step,
    required Map<String, dynamic> answers,
  }) async {
    saved.add(_SavedStep(step, answers));
    return _current.application ??
        _application(lastStep: step.position, payload: {step.wire: answers});
  }

  @override
  Future<TutorApplication> submit() async {
    submitted = true;
    return _application(
      lastStep: 6,
      payload: const {},
      status: ProfessionalStatus.underReview,
      isEditable: false,
    );
  }

  @override
  Future<Playbook> playbook() async => const Playbook({});

  @override
  Future<Playbook> completePlaybookItem(String item) async =>
      const Playbook({});

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Refuses every upload, the way the server refuses an unaccepted type.
class _RefusingUploads implements UploadRepository {
  @override
  Future<StoredFile> upload({
    required UploadPurpose purpose,
    required Uint8List bytes,
  }) async => throw const ValidationFailure(message: _refusal);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
