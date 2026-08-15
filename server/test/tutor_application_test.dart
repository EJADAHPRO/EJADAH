import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_server/src/http/api_error.dart';
import 'package:ejadah_server/src/modules/people/tutor_application_service.dart';
import 'package:test/test.dart';

import 'support/test_database.dart';

/// The supply side's way in.
///
/// Two rules from the flow carry this feature, and both are the kind that
/// quietly stop being true: every step is draft-saved, and submit names **every**
/// missing item at once. A six-step form on a phone that loses step 4, or that
/// sends someone back one omission at a time, is a form nobody finishes — and
/// with no tutors the marketplace is a directory of empty rooms.
void main() {
  late TestDatabase db;
  late TutorApplicationService service;
  late String userId;

  setUpAll(() async {
    db = await TestDatabase.open();
  });

  tearDownAll(() async {
    await db.close();
  });

  setUp(() async {
    await db.reset();
    service = TutorApplicationService(db.database, db.config);
    userId = await _createUser(db, 'mona@ejadah.test');
  });

  group('the draft', () {
    test('each step is saved on its own', () async {
      await service.saveStep(
        userId: userId,
        step: ApplicationStep.basics,
        answers: {'display_name_en': 'Dr. Mona Adel'},
      );
      await service.saveStep(
        userId: userId,
        step: ApplicationStep.rate,
        answers: {'hourly_rate_egp': 800},
      );

      final saved = await service.find(userId);
      // Step 4's answers did not overwrite step 1's: the payload is merged,
      // because a client that sends only the step it is on must not blank the
      // five it is not.
      expect(saved!.payload['basics']['display_name_en'], 'Dr. Mona Adel');
      expect(saved.payload['rate']['hourly_rate_egp'], 800);
    });

    test(
      'revisiting an earlier step does not lose the furthest reached',
      () async {
        await service.saveStep(
          userId: userId,
          step: ApplicationStep.availability,
          answers: const {'rules': []},
        );
        expect((await service.find(userId))!.lastStep, 5);

        await service.saveStep(
          userId: userId,
          step: ApplicationStep.basics,
          answers: {'headline': 'Endodontist'},
        );

        // Going back to fix step 1 must not send the user through 2–5 again.
        expect((await service.find(userId))!.lastStep, 5);
      },
    );

    test('an application under review is not editable', () async {
      await _completeApplication(service, userId);
      await service.submit(userId);

      await expectLater(
        service.saveStep(
          userId: userId,
          step: ApplicationStep.rate,
          answers: {'hourly_rate_egp': 2000},
        ),
        throwsA(isA<ApiException>()),
      );
    });

    test('a rejected application is editable again', () async {
      await _completeApplication(service, userId);
      await service.submit(userId);
      await db.execute(
        "UPDATE tutor_applications SET status = 'rejected', "
        "rejection_reason = 'Certificate unreadable' WHERE user_id = @u",
        {'u': userId},
      );

      final reopened = await service.find(userId);
      expect(reopened!.isEditable, isTrue);
      expect(reopened.rejectionReason, 'Certificate unreadable');

      // And the answers are still there to correct rather than retype.
      expect(reopened.payload['basics']['display_name_en'], isNotNull);
    });
  });

  group('submit', () {
    test('an empty application names every missing item at once', () async {
      await service.saveStep(
        userId: userId,
        step: ApplicationStep.basics,
        answers: const {},
      );

      try {
        await service.submit(userId);
        fail('an empty application must not submit');
      } on ApiException catch (error) {
        expect(error.code, ApiErrorCode.validation);
        // Nine required items across the six steps — all of them, not the
        // first one found.
        expect(error.fields, hasLength(9));
        expect(error.fields.keys, contains('basics.display_name_ar'));
        expect(error.fields.keys, contains('rate.hourly_rate_egp'));
        expect(error.fields.keys, contains('media.avatar_key'));
        // Qualifications and subjects both answer `items`. Keyed by the bare
        // field name they would collapse into one entry and a required item
        // would go unnamed — in the one list whose whole job is completeness.
        expect(error.fields.keys, contains('qualifications.items'));
        expect(error.fields.keys, contains('subjects.items'));
        // Each one is named in both languages, so the screen can list them.
        expect(error.fields['media.avatar_key']!.en, 'A photograph');
        expect(error.fields['media.avatar_key']!.ar, isNotEmpty);
      }
    });

    test('one missing item is still named', () async {
      await _completeApplication(service, userId);
      await service.saveStep(
        userId: userId,
        step: ApplicationStep.media,
        answers: const {},
      );

      try {
        await service.submit(userId);
        fail('a missing photograph must not submit');
      } on ApiException catch (error) {
        expect(error.fields, hasLength(1));
        expect(error.fields.keys.single, 'media.avatar_key');
      }
    });

    test(
      'too little availability is a missing item, not a silent pass',
      () async {
        await _completeApplication(service, userId);
        await service.saveStep(
          userId: userId,
          step: ApplicationStep.availability,
          answers: const {
            'rules': [
              {'weekday': 1, 'starts_at': '18:00', 'ends_at': '20:00'},
            ],
          },
        );

        // Two hours a week: bookable once, then invisible — which reads to a
        // student as an inactive marketplace.
        final missing = service.missingItems(
          (await service.find(userId))!.payload,
        );
        expect(missing.map((item) => item.field), contains('rules'));
        expect(
          missing.firstWhere((item) => item.field == 'rules').label.en,
          contains('${TutorApplicationService.minimumWeeklyHours}'),
        );
      },
    );

    test('a complete application submits and goes under review', () async {
      await _completeApplication(service, userId);
      expect(
        service.missingItems((await service.find(userId))!.payload),
        isEmpty,
      );

      final submitted = await service.submit(userId);
      expect(submitted.status, ProfessionalStatus.underReview);
      expect(submitted.submittedAt, isNotNull);
      expect(submitted.isEditable, isFalse);
    });

    test('submitting twice is refused', () async {
      await _completeApplication(service, userId);
      await service.submit(userId);
      await expectLater(service.submit(userId), throwsA(isA<ApiException>()));
    });
  });

  group('the playbook', () {
    test('starts as three unchecked actions', () async {
      final playbook = await service.playbook(userId);
      expect(playbook, hasLength(3));
      expect(playbook.values.every((done) => !done), isTrue);
    });

    test('completing one is idempotent and leaves the others alone', () async {
      await service.completePlaybookItem(
        userId: userId,
        item: 'set_availability',
      );
      final again = await service.completePlaybookItem(
        userId: userId,
        item: 'set_availability',
      );

      expect(again['set_availability'], isTrue);
      expect(again['complete_profile'], isFalse);
      expect(again['share_card'], isFalse);
    });

    test(
      'an unknown item is not found rather than silently recorded',
      () async {
        await expectLater(
          service.completePlaybookItem(userId: userId, item: 'invented'),
          throwsA(isA<ApiException>()),
        );
      },
    );
  });

  test('the split shown on the pitch is the one the ledger uses', () {
    // Computed from config rather than written into copy, so the public number
    // and the earnings rows cannot drift apart.
    expect(service.professionalSharePercent, 70);
    expect(
      service.professionalSharePercent,
      100 - db.config.platformFeePercent,
    );
  });
}

Future<String> _createUser(TestDatabase db, String email) async {
  final result = await db.execute(
    '''
    INSERT INTO users (email, password_hash, full_name_en, full_name_ar)
    VALUES (@email, 'x', 'Mona Adel', 'منى عادل')
    RETURNING id
    ''',
    {'email': email},
  );
  return result.first[0]! as String;
}

/// Fills all six steps with answers that pass.
Future<void> _completeApplication(
  TutorApplicationService service,
  String userId,
) async {
  await service.saveStep(
    userId: userId,
    step: ApplicationStep.basics,
    answers: {
      'display_name_en': 'Dr. Mona Adel',
      'display_name_ar': 'د. منى عادل',
      'headline': 'Consultant endodontist',
    },
  );
  await service.saveStep(
    userId: userId,
    step: ApplicationStep.qualifications,
    answers: const {
      'items': ['BDS Cairo University'],
      'document_key': 'uploads/bds.pdf',
    },
  );
  await service.saveStep(
    userId: userId,
    step: ApplicationStep.subjects,
    answers: const {
      'items': ['Endodontics'],
    },
  );
  await service.saveStep(
    userId: userId,
    step: ApplicationStep.rate,
    answers: const {'hourly_rate_egp': 800},
  );
  await service.saveStep(
    userId: userId,
    step: ApplicationStep.availability,
    answers: const {
      'rules': [
        {'weekday': 1, 'starts_at': '17:00', 'ends_at': '20:00'},
        {'weekday': 3, 'starts_at': '17:00', 'ends_at': '20:00'},
      ],
    },
  );
  await service.saveStep(
    userId: userId,
    step: ApplicationStep.media,
    answers: const {'avatar_key': 'uploads/mona.jpg'},
  );
}
