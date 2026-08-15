import 'dart:convert';
import 'dart:io';

import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_server/src/http/api_error.dart';
import 'package:ejadah_server/src/http/middleware.dart';
import 'package:ejadah_server/src/modules/people/booking_service.dart';
import 'package:ejadah_server/src/modules/people/people_repository.dart';
import 'package:ejadah_server/src/modules/people/people_routes.dart';
import 'package:ejadah_server/src/modules/people/people_service.dart';
import 'package:ejadah_server/src/modules/people/tutor_application_service.dart';
import 'package:ejadah_server/src/observability/logger.dart';
import 'package:ejadah_server/src/services/payments/payment_provider.dart';
import 'package:ejadah_server/src/services/token_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:test/test.dart';

import 'support/test_database.dart';

/// The People HTTP surface.
///
/// Driven through the real pipeline — context, error envelope, router — rather
/// than by calling services directly, because the things most likely to be
/// wrong here are HTTP-shaped: route ordering, the guest/auth split, and
/// whether the refund tier actually reaches the client *before* the cancel
/// button rather than after it.
void main() {
  late TestDatabase db;
  late TokenService tokens;
  late Handler handler;
  late PeopleService people;

  late String studentId;
  late String studentToken;
  late int mentorId;
  late int tutorId;

  setUpAll(() async {
    db = await TestDatabase.open();
  });

  tearDownAll(() async {
    await db.close();
  });

  setUp(() async {
    await db.reset();

    final repository = PeopleRepository(db.database);
    final logger = AppLogger('test', sink: _silent);
    people = PeopleService(repository);
    final booking = BookingService(
      database: db.database,
      repository: repository,
      payments: DevPaymentProvider(config: db.config, logger: logger),
      config: db.config,
      logger: logger,
    );

    tokens = TokenService(db.config);
    handler = const Pipeline()
        .addMiddleware(contextMiddleware(tokens))
        .addMiddleware(errorMiddleware(logger))
        .addHandler(
          (Router()..mount(
                '/people',
                peopleRoutes(
                  people,
                  booking,
                  TutorApplicationService(db.database, db.config),
                ).call,
              ))
              .call,
        );

    studentId = await _createUser(db, 'student@ejadah.test', 'Khaled Fathy');
    studentToken = tokens.issueAccessToken(
      userId: studentId,
      role: UserRole.student,
    );

    mentorId = await _createProfessional(
      db,
      slug: 'dr-mona-adel',
      kind: 'mentoring',
      nameEn: 'Dr. Mona Adel',
      rateEgp: 800,
      specialties: ['Endodontics'],
      languages: ['ar', 'en'],
      journeyTo: 'London',
      offersFreeIntroCall: true,
    );
    tutorId = await _createProfessional(
      db,
      slug: 'dr-hana-selim',
      kind: 'tutoring',
      nameEn: 'Dr. Hana Selim',
      rateEgp: 400,
      specialties: ['Prosthodontics'],
      languages: ['ar'],
    );
    // Approved but not this month, so "New this month" is a real distinction
    // rather than "everyone".
    await db.execute(
      "UPDATE professionals SET created_at = now() - interval '90 days' "
      'WHERE id = @id',
      {'id': tutorId},
    );
    await _seedAvailability(db, mentorId);
  });

  group('the hub', () {
    test('states how many people stand behind each door', () async {
      final body = await _json(handler, 'GET', '/people/');

      final doors = (body['doors'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      expect(_countFor(doors, 'mentoring'), 1);
      expect(_countFor(doors, 'tutoring'), 1);
      // An empty door is reported as zero rather than omitted: the hub must be
      // able to say "nobody yet" instead of hiding the door.
      expect(_countFor(doors, 'consulting'), 0);
      expect(body['total'], 2);
    });
  });

  group('the lists', () {
    test('a door returns only its own kind, to a guest', () async {
      final body = await _json(handler, 'GET', '/people/mentoring');

      final items = (body['items'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      expect(items, hasLength(1));
      expect(items.single['slug'], 'dr-mona-adel');
      expect(items.single['kind'], 'mentoring');
      // Browsing is open. Booking is the gate, not looking.
      expect(body['total'], 1);
    });

    test('an unapproved professional is never listed', () async {
      await _createProfessional(
        db,
        slug: 'dr-pending',
        kind: 'mentoring',
        nameEn: 'Dr. Pending',
        rateEgp: 900,
        isApproved: false,
      );

      final body = await _json(handler, 'GET', '/people/mentoring');
      expect(body['total'], 1);
    });

    test('filters narrow the list and are combined with AND', () async {
      Future<int> total(String query) async =>
          (await _json(handler, 'GET', '/people/mentoring?$query'))['total']
              as int;

      expect(await total('specialty=Endodontics'), 1);
      expect(await total('specialty=Orthodontics'), 0);
      expect(await total('destination=London'), 1);
      expect(await total('destination=Toronto'), 0);
      expect(await total('language=en'), 1);
      expect(await total('max_rate_egp=500'), 0);
      expect(await total('max_rate_egp=800'), 1);
      expect(await total('free_intro_call=true'), 1);
      // Both must hold: a mentor to London who does not teach orthodontics is
      // not a match for someone who asked for both.
      expect(await total('destination=London&specialty=Orthodontics'), 0);
    });

    test('facets offer only values the door actually contains', () async {
      final body = await _json(handler, 'GET', '/people/mentoring');
      final facets = body['facets'] as Map<String, dynamic>;

      expect(facets['specialties'], ['Endodontics']);
      expect(facets['destinations'], ['London']);
      // The tutoring door's specialty must not leak into the mentoring sheet.
      expect(facets['specialties'], isNot(contains('Prosthodontics')));
    });

    test('the rail carries this month\'s approvals only', () async {
      final mentoring = await _json(handler, 'GET', '/people/mentoring');
      final tutoring = await _json(handler, 'GET', '/people/tutoring');

      expect(mentoring['new_this_month'], hasLength(1));
      // Approved ninety days ago: real, listed, but not new.
      expect(tutoring['new_this_month'], isEmpty);
      expect((tutoring['items'] as List<dynamic>), hasLength(1));
    });

    test(
      'an unknown door is not-found, never a silent tutoring list',
      () async {
        final response = await _send(handler, 'GET', '/people/nonsense');
        expect(response.statusCode, 404);
      },
    );
  });

  group('the profile', () {
    test('carries qualifications, packages, policy and reviews', () async {
      await _seedQualifications(db, mentorId);
      await _seedPackage(db, mentorId);

      final body = await _json(handler, 'GET', '/people/profile/dr-mona-adel');

      final qualifications = (body['qualifications'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      expect(qualifications, hasLength(2));
      // Verified and stated are different facts and stay different on the wire.
      expect(qualifications.first['evidence'], 'verified');
      expect(qualifications.last['evidence'], 'stated');

      final packages = (body['packages'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      expect(packages.single['session_count'], 8);
      expect(packages.single['price_egp'], 5600);
      // The plan states its own cadence, so the flow never re-asks it.
      expect(
        (packages.single['cadence_sentence'] as Map)['en'],
        'One 60-minute session a week for eight weeks.',
      );

      // Readable before anyone books, not after they want out.
      expect(
        (body['cancellation_policy'] as Map)['en'],
        contains('Full refund up to 24 hours'),
      );
      expect(body['reviews'], isEmpty);
      expect(body['review_count'], 0);
      // No licensed photograph exists for anyone in this release; the client
      // falls back to initials rather than a broken image.
      expect(body['avatar_url'], isNull);
    });

    test('a profile that no longer resolves is a real not-found', () async {
      final response = await _send(handler, 'GET', '/people/profile/nobody');
      expect(response.statusCode, 404);

      final body =
          jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      final message = (body['error'] as Map)['message'] as Map;
      expect(message['en'], ApiErrorCopy.contentUnavailable.en);
      expect(message['ar'], ApiErrorCopy.contentUnavailable.ar);
    });
  });

  group('availability', () {
    test('returns unavailable slots as unavailable, not as absent', () async {
      final from = _nextWeekday(10);
      final to = from.add(const Duration(days: 1));

      // Take one slot off the calendar the way a booking would.
      await db.execute(
        '''
        INSERT INTO slot_reservations (professional_id, period, kind, expires_at,
                                       held_by_user_id)
        VALUES (@id, tstzrange(@from, @to, '[)'), 'hold', now() + interval '15 minutes',
                @user)
        ''',
        {
          'id': mentorId,
          'from': from,
          'to': from.add(const Duration(hours: 1)),
          'user': studentId,
        },
      );

      final body = await _json(
        handler,
        'GET',
        '/people/$mentorId/availability'
            '?from=${Uri.encodeComponent(from.toIso8601String())}'
            '&to=${Uri.encodeComponent(to.toIso8601String())}',
      );

      final items = (body['items'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      expect(items, isNotEmpty);

      final held = items.firstWhere(
        (slot) => DateTime.parse(slot['starts_at'] as String) == from,
      );
      // Present and marked false, so the grid renders it untappable rather than
      // tappable-then-rejected.
      expect(held['is_available'], isFalse);
      expect(items.any((slot) => slot['is_available'] == true), isTrue);
    });

    test('a window that ends before it starts is rejected', () async {
      final from = _nextWeekday(10);
      final response = await _send(
        handler,
        'GET',
        '/people/$mentorId/availability'
            '?from=${Uri.encodeComponent(from.toIso8601String())}'
            '&to=${Uri.encodeComponent(from.toIso8601String())}',
      );
      expect(response.statusCode, 422);
    });
  });

  group('holds and bookings', () {
    test('holding requires an account; browsing does not', () async {
      final start = _nextWeekday(10);

      final anonymous = await _send(
        handler,
        'POST',
        '/people/holds',
        body: {
          'professional_id': mentorId,
          'starts_at': start.toIso8601String(),
          'duration_minutes': 60,
        },
      );
      expect(anonymous.statusCode, 401);

      // The same request with a session succeeds — the gate is the account, not
      // the endpoint.
      final held = await _send(
        handler,
        'POST',
        '/people/holds',
        token: studentToken,
        body: {
          'professional_id': mentorId,
          'starts_at': start.toIso8601String(),
          'duration_minutes': 60,
        },
      );
      expect(held.statusCode, 201);
    });

    test('a race returns 409 with the approved slot-taken copy', () async {
      final start = _nextWeekday(10);
      final rival = await _createUser(db, 'rival@ejadah.test', 'Rival Student');
      final rivalToken = tokens.issueAccessToken(
        userId: rival,
        role: UserRole.student,
      );

      final first = await _send(
        handler,
        'POST',
        '/people/holds',
        token: studentToken,
        body: {
          'professional_id': mentorId,
          'starts_at': start.toIso8601String(),
        },
      );
      expect(first.statusCode, 201);

      final second = await _send(
        handler,
        'POST',
        '/people/holds',
        token: rivalToken,
        body: {
          'professional_id': mentorId,
          'starts_at': start.toIso8601String(),
        },
      );

      expect(second.statusCode, 409);
      final message =
          ((jsonDecode(await second.readAsString())
                      as Map<String, dynamic>)['error']
                  as Map)['message']
              as Map;
      // The loser reads the product's own words in their own language, never a
      // constraint name.
      expect(message['en'], ApiErrorCopy.slotTaken.en);
      expect(message['ar'], ApiErrorCopy.slotTaken.ar);
    });

    test('releasing a hold puts the time back on the calendar', () async {
      final start = _nextWeekday(10);
      final hold = await _json(
        handler,
        'POST',
        '/people/holds',
        token: studentToken,
        body: {
          'professional_id': mentorId,
          'starts_at': start.toIso8601String(),
        },
      );

      final released = await _send(
        handler,
        'DELETE',
        '/people/holds/${hold['id']}',
        token: studentToken,
      );
      expect(released.statusCode, 204);

      final again = await _send(
        handler,
        'POST',
        '/people/holds',
        token: studentToken,
        body: {
          'professional_id': mentorId,
          'starts_at': start.toIso8601String(),
        },
      );
      expect(again.statusCode, 201);
    });

    test('a goal shorter than a sentence is rejected by field', () async {
      final start = _nextWeekday(10);
      final hold = await _json(
        handler,
        'POST',
        '/people/holds',
        token: studentToken,
        body: {
          'professional_id': mentorId,
          'starts_at': start.toIso8601String(),
        },
      );

      final response = await _send(
        handler,
        'POST',
        '/people/bookings',
        token: studentToken,
        body: {'hold_id': hold['id'], 'subject': 'Endodontics', 'goal': 'help'},
      );

      expect(response.statusCode, 422);
      final error =
          (jsonDecode(await response.readAsString())
                  as Map<String, dynamic>)['error']
              as Map;
      // Named field, approved copy, so the message can sit under the field and
      // be announced rather than shown as a page-level failure.
      expect((error['fields'] as Map).containsKey('goal'), isTrue);
    });

    test('the price on the confirmation comes from the server', () async {
      final booking = await _confirmBooking(
        handler,
        token: studentToken,
        professionalId: mentorId,
        startsAt: _nextWeekday(10),
        // A price in the request body is not merely rejected — it is never read.
        extra: {'total_egp': 1},
      );

      expect(booking['total_egp'], 800);
      expect((booking['sessions'] as List<dynamic>), hasLength(1));
    });
  });

  group('the refund tier is readable before the cancel button', () {
    test('an active booking projects its live tier, not zero', () async {
      // Three days out: comfortably inside the full-refund tier.
      final booking = await _confirmBooking(
        handler,
        token: studentToken,
        professionalId: mentorId,
        startsAt: _nextWeekday(10),
      );

      // The stored column is still null — nothing has been refunded.
      final stored = await db.execute(
        'SELECT refunded_egp FROM bookings WHERE id = @id',
        {'id': booking['id']},
      );
      expect(stored.first[0], isNull);

      final list = await _json(
        handler,
        'GET',
        '/people/bookings',
        token: studentToken,
      );
      final row = (list['items'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .single;

      // Projected from the same function the cancellation will use, so the
      // figure shown and the figure paid cannot disagree.
      expect(row['refundable_egp'], 800);
      expect(row['total_egp'], 800);
      expect(booking['refundable_egp'], 800);
    });

    test(
      'a booking inside the half-refund tier says so before the button',
      () async {
        final soon = DateTime.timestamp().add(const Duration(hours: 6));
        final booking = await _confirmBooking(
          handler,
          token: studentToken,
          professionalId: mentorId,
          startsAt: soon,
        );

        final list = await _json(
          handler,
          'GET',
          '/people/bookings',
          token: studentToken,
        );
        final row = (list['items'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .single;

        // Between two and twenty-four hours out: half. Stated now, not discovered
        // after the confirmation sheet.
        expect(row['refundable_egp'], 400);
        expect(booking['refundable_egp'], 400);
      },
    );

    test('cancelling names the exact refund and keeps it afterwards', () async {
      final booking = await _confirmBooking(
        handler,
        token: studentToken,
        professionalId: mentorId,
        startsAt: _nextWeekday(10),
      );

      final cancelled = await _json(
        handler,
        'POST',
        '/people/bookings/${booking['id']}/cancel',
        token: studentToken,
      );

      expect(cancelled['refunded_egp'], 800);
      expect(cancelled['total_egp'], 800);
      expect(
        (cancelled['booking'] as Map)['status'],
        BookingStatus.cancelledByStudent.wire,
      );

      // History is not rewritten against today's clock: the cancelled row keeps
      // what was actually refunded.
      final list = await _json(
        handler,
        'GET',
        '/people/bookings',
        token: studentToken,
      );
      final row = (list['items'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .single;
      expect(row['refundable_egp'], 800);
    });

    test('someone else\'s booking cannot be cancelled', () async {
      final booking = await _confirmBooking(
        handler,
        token: studentToken,
        professionalId: mentorId,
        startsAt: _nextWeekday(10),
      );

      final intruder = await _createUser(db, 'other@ejadah.test', 'Other');
      final response = await _send(
        handler,
        'POST',
        '/people/bookings/${booking['id']}/cancel',
        token: tokens.issueAccessToken(
          userId: intruder,
          role: UserRole.student,
        ),
      );
      expect(response.statusCode, 403);
    });

    test('my bookings requires an account', () async {
      final response = await _send(handler, 'GET', '/people/bookings');
      expect(response.statusCode, 401);
    });
  });

  group('route ordering', () {
    test('literal paths are not swallowed by the door pattern', () async {
      // `/people/bookings` must reach the bookings handler, not be read as a
      // door named "bookings" — the whole reason literals are registered first.
      final response = await _send(handler, 'GET', '/people/bookings');
      expect(response.statusCode, 401);
      expect(response.statusCode, isNot(404));
    });

    test('"profile" is never parsed as a professional id', () async {
      final response = await _send(
        handler,
        'GET',
        '/people/profile/dr-mona-adel',
      );
      expect(response.statusCode, 200);
    });
  });
}

// --- Driving the handler ----------------------------------------------------

Future<Response> _send(
  Handler handler,
  String method,
  String path, {
  String? token,
  Object? body,
}) async => handler(
  Request(
    method,
    Uri.parse('http://localhost$path'),
    headers: {
      'content-type': 'application/json',
      if (token != null) 'authorization': 'Bearer $token',
    },
    body: body == null ? null : jsonEncode(body),
  ),
);

Future<Map<String, dynamic>> _json(
  Handler handler,
  String method,
  String path, {
  String? token,
  Object? body,
}) async {
  final response = await _send(handler, method, path, token: token, body: body);
  final text = await response.readAsString();
  expect(
    response.statusCode,
    inInclusiveRange(200, 299),
    reason: '$method $path returned ${response.statusCode}: $text',
  );
  return jsonDecode(text) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> _confirmBooking(
  Handler handler, {
  required String token,
  required int professionalId,
  required DateTime startsAt,
  Map<String, Object?> extra = const {},
}) async {
  final hold = await _json(
    handler,
    'POST',
    '/people/holds',
    token: token,
    body: {
      'professional_id': professionalId,
      'starts_at': startsAt.toIso8601String(),
      'duration_minutes': 60,
    },
  );

  return _json(
    handler,
    'POST',
    '/people/bookings',
    token: token,
    body: {
      'hold_id': hold['id'],
      'subject': 'Endodontics',
      'goal': 'A molar retreatment I want a second opinion on.',
      ...extra,
    },
  );
}

// --- Fixtures ---------------------------------------------------------------

int _countFor(List<Map<String, dynamic>> doors, String kind) =>
    doors.firstWhere((door) => door['kind'] == kind)['count'] as int;

/// The next occurrence of a weekday inside the seeded availability window.
///
/// Pinned to a whole hour so it lines up with the slot grid rather than landing
/// mid-slot, and always at least a day out so the "not in the past" guard is
/// never what is being tested.
DateTime _nextWeekday(int hour) {
  var day = DateTime.timestamp().add(const Duration(days: 3));
  // Sunday is 0 in the booking calendar; the fixture opens Sunday to Thursday.
  while (day.weekday % 7 > 4) {
    day = day.add(const Duration(days: 1));
  }
  return DateTime.utc(day.year, day.month, day.day, hour);
}

Future<String> _createUser(TestDatabase db, String email, String name) async {
  final result = await db.execute(
    '''
    INSERT INTO users (email, password_hash, full_name_en, full_name_ar)
    VALUES (@email, 'x', @name, @name)
    RETURNING id
    ''',
    {'email': email, 'name': name},
  );
  return result.first[0]! as String;
}

Future<int> _createProfessional(
  TestDatabase db, {
  required String slug,
  required String kind,
  required String nameEn,
  required int rateEgp,
  List<String> specialties = const [],
  List<String> languages = const [],
  String? journeyTo,
  bool offersFreeIntroCall = false,
  bool isApproved = true,
}) async {
  final result = await db.execute(
    '''
    INSERT INTO professionals (
      slug, kind, display_name_en, display_name_ar, headline_en, headline_ar,
      specialties, languages, hourly_rate_egp, offers_free_intro_call,
      journey_from, journey_to, journey_year,
      cancellation_policy_en, cancellation_policy_ar, is_approved
    ) VALUES (
      @slug, @kind::service_kind, @name_en, @name_ar, '', '',
      @specialties, @languages, @rate, @intro,
      @journey_from, @journey_to, @journey_year,
      'Full refund up to 24 hours before. Half within 24 hours. Nothing within 2 hours.',
      'استرداد كامل قبل 24 ساعة. نصف المبلغ خلال 24 ساعة. لا استرداد خلال ساعتين.',
      @approved
    )
    RETURNING id
    ''',
    {
      'slug': slug,
      'kind': kind,
      'name_en': nameEn,
      'name_ar': 'د. تجريبي',
      'specialties': specialties,
      'languages': languages,
      'rate': rateEgp,
      'intro': offersFreeIntroCall,
      'journey_from': journeyTo == null ? null : 'Cairo',
      'journey_to': journeyTo,
      'journey_year': journeyTo == null ? null : 2021,
      'approved': isApproved,
    },
  );
  return (result.first[0]! as num).toInt();
}

/// Sunday to Thursday, 10:00–18:00 UTC.
Future<void> _seedAvailability(TestDatabase db, int professionalId) =>
    db.execute(
      '''
      INSERT INTO availability_rules (professional_id, weekday, start_minute, end_minute)
      SELECT @id, weekday, 0, 1440 FROM generate_series(0, 6) AS weekday
      ''',
      {'id': professionalId},
    );

Future<void> _seedQualifications(TestDatabase db, int professionalId) =>
    db.execute(
      '''
      INSERT INTO professional_qualifications (
        professional_id, position, title_en, title_ar, issuer_en, issuer_ar,
        evidence, year
      ) VALUES
        (@id, 1, 'ORE Part 1 and 2', 'ORE الجزء الأول والثاني',
         'General Dental Council', 'المجلس العام لطب الأسنان', 'verified', 2021),
        (@id, 2, 'MSc Endodontology', 'ماجستير علاج الجذور',
         'King''s College London', 'كينجز كوليدج لندن', 'stated', 2023)
      ''',
      {'id': professionalId},
    );

Future<void> _seedPackage(TestDatabase db, int professionalId) => db.execute(
  '''
  INSERT INTO professional_packages (
    professional_id, title_en, title_ar, session_count, session_minutes,
    price_egp, cadence_sentence_en, cadence_sentence_ar
  ) VALUES (
    @id, 'ORE Part 1 plan', 'خطة ORE الجزء الأول', 8, 60, 5600,
    'One 60-minute session a week for eight weeks.',
    'جلسة واحدة 60 دقيقة أسبوعيًا لمدة ثمانية أسابيع.'
  )
  ''',
  {'id': professionalId},
);

/// Keeps the suite's output to test results rather than server log lines.
final IOSink _silent = _NullSink();

class _NullSink implements IOSink {
  @override
  void writeln([Object? object = '']) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
