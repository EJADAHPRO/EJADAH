import 'dart:io';

import 'package:ejadah_server/src/config/config.dart';
import 'package:ejadah_server/src/db/database.dart';
import 'package:ejadah_server/src/observability/logger.dart';
import 'package:postgres/postgres.dart';

/// Seeds the Learn catalogue.
///
///     dart run tool/seed_learn.dart
///
/// Development and test only. It grants a course entitlement to the demo
/// student without any money moving, which is exactly the thing that must never
/// happen in production, so it refuses to run there rather than trusting the
/// operator to remember — the same rule `tool/seed.dart` follows.
///
/// The content is authored, not generated: three courses, one per department,
/// written in both languages in the Ejadah voice. No course carries a price,
/// here or anywhere else — courses are in-app purchase only and the store is
/// the pricing authority (Apple §3.1.1), which is why the schema has no price
/// column to fill.
Future<void> main() async {
  final logger = AppLogger('seed-learn');
  final config = AppConfig.fromEnvironment();

  if (!config.environment.allowsDevelopmentAffordances) {
    stderr.writeln(
      'Refusing to seed: this grants a paid course without a store receipt '
      'and must never run outside development or test.',
    );
    exitCode = 1;
    return;
  }

  final database = await Database.connect(config.databaseUrl);

  try {
    for (final course in _courses) {
      final id = await _upsertCourse(database, course);
      await _seedLessons(database, id, course);
      await _seedHandouts(database, id, course, config.storageRoot);
      await _seedDeck(database, id, course);
      await _seedQuiz(database, id, course);
      stdout.writeln(
        '  ${course.slug} — ${course.lessons.length} lessons, '
        '${course.cards.length} cards, ${course.questions.length} questions',
      );
    }

    // So a fresh clone can open an owned course and a locked one side by side.
    final granted = await _grantDemoEntitlement(database, _courses.first.slug);
    stdout
      ..writeln('Seeded ${_courses.length} courses.')
      ..writeln(
        granted
            ? '  student@ejadah.test now owns "${_courses.first.slug}" '
                  '(source: dev, no payment).'
            : '  No demo student found — run tool/seed.dart first to own one.',
      )
      ..writeln(
        '  Handout files written under '
        '${Directory(config.storageRoot).absolute.path}',
      );

    logger.info('learn seed complete');
  } finally {
    await database.close();
  }
}

// ---------------------------------------------------------------------------
// Writing
// ---------------------------------------------------------------------------

Future<int> _upsertCourse(Database database, _Course course) async {
  final rows = await database.run(
    (session) => session.execute(
      Sql.named('''
      INSERT INTO courses (
        slug, title_en, title_ar, subtitle_en, subtitle_ar,
        description_en, description_ar, department, level_en, level_ar,
        cpd_points, instructor_name_en, instructor_name_ar,
        instructor_bio_en, instructor_bio_ar, iap_product_id, is_published
      ) VALUES (
        @slug, @title_en, @title_ar, @subtitle_en, @subtitle_ar,
        @description_en, @description_ar, @department::department,
        @level_en, @level_ar, @cpd_points, @instructor_name_en,
        @instructor_name_ar, @instructor_bio_en, @instructor_bio_ar,
        @iap_product_id, true
      )
      ON CONFLICT (slug) DO UPDATE SET
        title_en = EXCLUDED.title_en, title_ar = EXCLUDED.title_ar,
        subtitle_en = EXCLUDED.subtitle_en, subtitle_ar = EXCLUDED.subtitle_ar,
        description_en = EXCLUDED.description_en,
        description_ar = EXCLUDED.description_ar,
        department = EXCLUDED.department,
        level_en = EXCLUDED.level_en, level_ar = EXCLUDED.level_ar,
        cpd_points = EXCLUDED.cpd_points,
        instructor_name_en = EXCLUDED.instructor_name_en,
        instructor_name_ar = EXCLUDED.instructor_name_ar,
        instructor_bio_en = EXCLUDED.instructor_bio_en,
        instructor_bio_ar = EXCLUDED.instructor_bio_ar,
        iap_product_id = EXCLUDED.iap_product_id,
        updated_at = now()
      RETURNING id
      '''),
      parameters: {
        'slug': course.slug,
        'title_en': course.titleEn,
        'title_ar': course.titleAr,
        'subtitle_en': course.subtitleEn,
        'subtitle_ar': course.subtitleAr,
        'description_en': course.descriptionEn,
        'description_ar': course.descriptionAr,
        'department': course.department,
        'level_en': course.levelEn,
        'level_ar': course.levelAr,
        'cpd_points': course.cpdPoints,
        'instructor_name_en': course.instructorEn,
        'instructor_name_ar': course.instructorAr,
        'instructor_bio_en': course.instructorBioEn,
        'instructor_bio_ar': course.instructorBioAr,
        'iap_product_id': course.iapProductId,
      },
    ),
  );
  return (rows.first[0]! as num).toInt();
}

Future<void> _seedLessons(
  Database database,
  int courseId,
  _Course course,
) async {
  for (var i = 0; i < course.lessons.length; i++) {
    final lesson = course.lessons[i];
    await database.run(
      (session) => session.execute(
        Sql.named('''
        INSERT INTO lessons (
          course_id, position, title_en, title_ar, duration_seconds,
          is_free_preview
        ) VALUES (
          @course_id, @position, @title_en, @title_ar, @duration, @free
        )
        ON CONFLICT (course_id, position) DO UPDATE SET
          title_en = EXCLUDED.title_en, title_ar = EXCLUDED.title_ar,
          duration_seconds = EXCLUDED.duration_seconds,
          is_free_preview = EXCLUDED.is_free_preview
        '''),
        parameters: {
          'course_id': courseId,
          'position': i + 1,
          'title_en': lesson.titleEn,
          'title_ar': lesson.titleAr,
          'duration': lesson.seconds,
          // Lesson one is a free preview in every course. The server enforces
          // this regardless of the column; the column simply agrees.
          'free': i == 0,
        },
      ),
    );
  }
  // No video_url is seeded: there is no licensed media in the repository, and a
  // URL that 404s is worse than an honest absence.
}

Future<void> _seedHandouts(
  Database database,
  int courseId,
  _Course course,
  String storageRoot,
) async {
  // Handouts carry no user data, so replacing them wholesale is safe and keeps
  // a re-run from stacking duplicates.
  await database.run(
    (session) => session.execute(
      Sql.named('DELETE FROM handouts WHERE course_id = @course_id'),
      parameters: {'course_id': courseId},
    ),
  );

  final directory = Directory('$storageRoot/handouts')
    ..createSync(recursive: true);

  for (final handout in course.handouts) {
    final key = 'handouts/${course.slug}-${handout.fileStem}.pdf';
    final file = File('${directory.parent.path}/$key');
    final bytes = _placeholderPdf(handout.titleEn, course.titleEn);
    file.writeAsBytesSync(bytes);

    await database.run(
      (session) => session.execute(
        Sql.named('''
        INSERT INTO handouts (course_id, title_en, title_ar, storage_key, bytes)
        VALUES (@course_id, @title_en, @title_ar, @key, @bytes)
        '''),
        parameters: {
          'course_id': courseId,
          'title_en': handout.titleEn,
          'title_ar': handout.titleAr,
          'key': key,
          'bytes': bytes.length,
        },
      ),
    );
  }
}

Future<void> _seedDeck(Database database, int courseId, _Course course) async {
  if (course.cards.isEmpty) return;

  // Decks are left alone once they exist: deleting one cascades into
  // flashcard_states and would throw away a tester's review history.
  final existing = await database.run(
    (session) => session.execute(
      Sql.named('SELECT id FROM flashcard_decks WHERE course_id = @course_id'),
      parameters: {'course_id': courseId},
    ),
  );
  if (existing.isNotEmpty) return;

  final rows = await database.run(
    (session) => session.execute(
      Sql.named('''
      INSERT INTO flashcard_decks (course_id, title_en, title_ar)
      VALUES (@course_id, @title_en, @title_ar)
      RETURNING id
      '''),
      parameters: {
        'course_id': courseId,
        'title_en': course.deckTitleEn,
        'title_ar': course.deckTitleAr,
      },
    ),
  );
  final deckId = (rows.first[0]! as num).toInt();

  for (var i = 0; i < course.cards.length; i++) {
    final card = course.cards[i];
    await database.run(
      (session) => session.execute(
        Sql.named('''
        INSERT INTO flashcards (
          deck_id, position, front_en, front_ar, back_en, back_ar
        ) VALUES (@deck_id, @position, @front_en, @front_ar, @back_en, @back_ar)
        '''),
        parameters: {
          'deck_id': deckId,
          'position': i + 1,
          'front_en': card.frontEn,
          'front_ar': card.frontAr,
          'back_en': card.backEn,
          'back_ar': card.backAr,
        },
      ),
    );
  }
}

Future<void> _seedQuiz(Database database, int courseId, _Course course) async {
  if (course.questions.isEmpty) return;

  final existing = await database.run(
    (session) => session.execute(
      Sql.named('SELECT id FROM quizzes WHERE course_id = @course_id'),
      parameters: {'course_id': courseId},
    ),
  );
  if (existing.isNotEmpty) return;

  final rows = await database.run(
    (session) => session.execute(
      Sql.named('''
      INSERT INTO quizzes (course_id, title_en, title_ar, pass_mark)
      VALUES (@course_id, @title_en, @title_ar, 60)
      RETURNING id
      '''),
      parameters: {
        'course_id': courseId,
        'title_en': course.quizTitleEn,
        'title_ar': course.quizTitleAr,
      },
    ),
  );
  final quizId = (rows.first[0]! as num).toInt();

  for (var q = 0; q < course.questions.length; q++) {
    final question = course.questions[q];
    final questionRows = await database.run(
      (session) => session.execute(
        Sql.named('''
        INSERT INTO quiz_questions (
          quiz_id, position, prompt_en, prompt_ar, explanation_en,
          explanation_ar
        ) VALUES (
          @quiz_id, @position, @prompt_en, @prompt_ar, @explanation_en,
          @explanation_ar
        )
        RETURNING id
        '''),
        parameters: {
          'quiz_id': quizId,
          'position': q + 1,
          'prompt_en': question.promptEn,
          'prompt_ar': question.promptAr,
          'explanation_en': question.explanationEn,
          'explanation_ar': question.explanationAr,
        },
      ),
    );
    final questionId = (questionRows.first[0]! as num).toInt();

    for (var o = 0; o < question.options.length; o++) {
      final option = question.options[o];
      await database.run(
        (session) => session.execute(
          Sql.named('''
          INSERT INTO quiz_options (
            question_id, position, label_en, label_ar, is_correct
          ) VALUES (@question_id, @position, @label_en, @label_ar, @correct)
          '''),
          parameters: {
            'question_id': questionId,
            'position': o + 1,
            'label_en': option.labelEn,
            'label_ar': option.labelAr,
            'correct': o == question.correctIndex,
          },
        ),
      );
    }
  }
}

/// Gives the demo student one owned course, so both the owned and the locked
/// states are reachable on a fresh clone.
Future<bool> _grantDemoEntitlement(Database database, String slug) async {
  final rows = await database.run(
    (session) => session.execute(
      Sql.named('''
      INSERT INTO entitlements (user_id, course_id, source, external_ref)
      SELECT u.id, c.id, 'dev', 'dev:' || u.id || ':' || c.id
      FROM users u, courses c
      WHERE u.email = 'student@ejadah.test' AND c.slug = @slug
      ON CONFLICT (user_id, course_id) DO NOTHING
      RETURNING user_id
      '''),
      parameters: {'slug': slug},
    ),
  );

  await database.run(
    (session) => session.execute(
      Sql.named('''
      INSERT INTO enrollments (user_id, course_id)
      SELECT u.id, c.id FROM users u, courses c
      WHERE u.email = 'student@ejadah.test' AND c.slug = @slug
      ON CONFLICT DO NOTHING
      '''),
      parameters: {'slug': slug},
    ),
  );

  if (rows.isNotEmpty) return true;

  // Already granted by an earlier run still counts as owned.
  final owned = await database.run(
    (session) => session.execute(
      Sql.named('''
      SELECT 1 FROM entitlements e
      JOIN users u ON u.id = e.user_id
      JOIN courses c ON c.id = e.course_id
      WHERE u.email = 'student@ejadah.test' AND c.slug = @slug
      '''),
      parameters: {'slug': slug},
    ),
  );
  return owned.isNotEmpty;
}

/// A real, openable one-page PDF.
///
/// The handouts feature is about a file that downloads and opens, so seeding a
/// zero-byte placeholder would leave the screen untestable. This is the
/// smallest valid PDF that renders a title.
List<int> _placeholderPdf(String title, String courseTitle) {
  String escape(String value) => value
      .replaceAll(r'\', r'\\')
      .replaceAll('(', r'\(')
      .replaceAll(')', r'\)');

  final content =
      'BT /F1 16 Tf 56 760 Td (${escape(title)}) Tj '
      'ET BT /F1 11 Tf 56 736 Td (${escape(courseTitle)}) Tj '
      'ET BT /F1 10 Tf 56 712 Td '
      '(Development placeholder. Not teaching material.) Tj ET';

  final objects = <String>[
    '<< /Type /Catalog /Pages 2 0 R >>',
    '<< /Type /Pages /Kids [3 0 R] /Count 1 >>',
    '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] '
        '/Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>',
    '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>',
    '<< /Length ${content.length} >>\nstream\n$content\nendstream',
  ];

  final buffer = StringBuffer('%PDF-1.4\n');
  final offsets = <int>[];
  for (var i = 0; i < objects.length; i++) {
    offsets.add(buffer.length);
    buffer.write('${i + 1} 0 obj\n${objects[i]}\nendobj\n');
  }

  final xrefOffset = buffer.length;
  buffer.write('xref\n0 ${objects.length + 1}\n0000000000 65535 f \n');
  for (final offset in offsets) {
    buffer.write('${offset.toString().padLeft(10, '0')} 00000 n \n');
  }
  buffer.write(
    'trailer\n<< /Size ${objects.length + 1} /Root 1 0 R >>\n'
    'startxref\n$xrefOffset\n%%EOF\n',
  );

  return buffer.toString().codeUnits;
}

// ---------------------------------------------------------------------------
// The content
// ---------------------------------------------------------------------------

class _Course {
  const _Course({
    required this.slug,
    required this.department,
    required this.titleEn,
    required this.titleAr,
    required this.subtitleEn,
    required this.subtitleAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.levelEn,
    required this.levelAr,
    required this.cpdPoints,
    required this.instructorEn,
    required this.instructorAr,
    required this.instructorBioEn,
    required this.instructorBioAr,
    required this.iapProductId,
    required this.lessons,
    required this.handouts,
    required this.deckTitleEn,
    required this.deckTitleAr,
    required this.cards,
    required this.quizTitleEn,
    required this.quizTitleAr,
    required this.questions,
  });

  final String slug;
  final String department;
  final String titleEn;
  final String titleAr;
  final String subtitleEn;
  final String subtitleAr;
  final String descriptionEn;
  final String descriptionAr;
  final String levelEn;
  final String levelAr;
  final int cpdPoints;
  final String instructorEn;
  final String instructorAr;
  final String instructorBioEn;
  final String instructorBioAr;
  final String iapProductId;
  final List<_Lesson> lessons;
  final List<_Handout> handouts;
  final String deckTitleEn;
  final String deckTitleAr;
  final List<_Card> cards;
  final String quizTitleEn;
  final String quizTitleAr;
  final List<_Question> questions;
}

class _Lesson {
  const _Lesson(this.titleEn, this.titleAr, this.seconds);

  final String titleEn;
  final String titleAr;
  final int seconds;
}

class _Handout {
  const _Handout(this.titleEn, this.titleAr, this.fileStem);

  final String titleEn;
  final String titleAr;
  final String fileStem;
}

class _Card {
  const _Card(this.frontEn, this.frontAr, this.backEn, this.backAr);

  final String frontEn;
  final String frontAr;
  final String backEn;
  final String backAr;
}

class _Question {
  const _Question({
    required this.promptEn,
    required this.promptAr,
    required this.explanationEn,
    required this.explanationAr,
    required this.options,
    required this.correctIndex,
  });

  final String promptEn;
  final String promptAr;
  final String explanationEn;
  final String explanationAr;
  final List<_Option> options;
  final int correctIndex;
}

class _Option {
  const _Option(this.labelEn, this.labelAr);

  final String labelEn;
  final String labelAr;
}

const List<_Course> _courses = [
  // --- Orthodontics ---------------------------------------------------------
  _Course(
    slug: 'aligner-case-selection',
    department: 'orthodontics',
    titleEn: 'Clear aligner case selection and staging',
    titleAr: 'اختيار الحالات والتدريج في المصففات الشفافة',
    subtitleEn:
        'Which cases aligners finish well, which need attachments, and which '
        'belong in fixed appliances.',
    subtitleAr:
        'أي الحالات تنهيها المصففات جيدًا، وأيها يحتاج ملحقات، وأيها يبقى '
        'للأجهزة الثابتة.',
    descriptionEn:
        'Six recorded lessons on reading a case before you accept it. The '
        'course works through records, tooth movements aligners predict '
        'reliably, attachment design, staging, and the refinement scan. It '
        'takes a position on when to refer, and says why.',
    descriptionAr:
        'ستة دروس مسجلة عن قراءة الحالة قبل قبولها. تتناول الدورة السجلات '
        'والحركات التي تتنبأ بها المصففات بدقة، وتصميم الملحقات، والتدريج، '
        'ومسح التحسين. وتحدد موقفًا واضحًا من التحويل ومتى يكون الأنسب.',
    levelEn: 'Intermediate',
    levelAr: 'متوسط',
    cpdPoints: 6,
    instructorEn: 'Dr. Yasmin Farouk',
    instructorAr: 'د. ياسمين فاروق',
    instructorBioEn:
        'Orthodontist in Cairo since 2012. Treats about 120 aligner cases a '
        'year and teaches case selection to postgraduate students.',
    instructorBioAr:
        'أخصائية تقويم في القاهرة منذ 2012. تعالج نحو 120 حالة مصففات سنويًا '
        'وتُدرّس اختيار الحالات لطلاب الدراسات العليا.',
    iapProductId: 'international.ejadah.course.aligner_case_selection',
    lessons: [
      _Lesson(
        'What aligners move well, and what they do not',
        'ما تحركه المصففات جيدًا وما لا تحركه',
        712,
      ),
      _Lesson(
        'Reading the records before you quote a case',
        'قراءة السجلات قبل تسعير الحالة',
        946,
      ),
      _Lesson(
        'Attachments: where they earn their place',
        'الملحقات: أين تستحق وجودها',
        1088,
      ),
      _Lesson(
        'Staging rotations, extrusions and root torque',
        'تدريج الدوران والبثق وعزم الجذر',
        874,
      ),
      _Lesson(
        'The refinement scan without restarting the case',
        'مسح التحسين دون إعادة بدء الحالة',
        781,
      ),
      _Lesson(
        'When to refer, and how to say it to the patient',
        'متى تُحوّل الحالة وكيف تشرح ذلك للمريض',
        623,
      ),
    ],
    handouts: [
      _Handout(
        'Case selection checklist',
        'قائمة فحص اختيار الحالة',
        'case-selection-checklist',
      ),
      _Handout(
        'Attachment placement reference',
        'مرجع وضع الملحقات',
        'attachment-reference',
      ),
    ],
    deckTitleEn: 'Aligner case selection — the numbers',
    deckTitleAr: 'اختيار حالات المصففات — الأرقام',
    cards: [
      _Card(
        'Which single movement is least predictable with aligners?',
        'ما الحركة الأقل قابلية للتنبؤ بالمصففات؟',
        'Root torque on upper incisors. Plan it with attachments and expect '
            'refinement.',
        'عزم جذور القواطع العلوية. خطّط له بالملحقات وتوقّع مرحلة تحسين.',
      ),
      _Card(
        'How much rotation of a lower premolar is realistic per stage?',
        'كم مقدار دوران الضاحك السفلي الواقعي في كل مرحلة؟',
        'About 2 degrees per aligner, with an optimised attachment.',
        'نحو درجتين لكل مصفف، مع ملحق محسّن.',
      ),
      _Card(
        'What is the usual limit for non-extraction arch expansion?',
        'ما الحد المعتاد لتوسيع القوس دون خلع؟',
        'Around 4mm across the arch, and only where the bone supports it.',
        'نحو 4 مم عبر القوس، وفقط حيث يسمح العظم بذلك.',
      ),
      _Card(
        'When is interproximal reduction preferred over expansion?',
        'متى يُفضّل البرد بين الأسنان على التوسيع؟',
        'When crowding is under 6mm and the gingival biotype is thin.',
        'عند تزاحم أقل من 6 مم ونمط لثوي رقيق.',
      ),
      _Card(
        'What does a mid-treatment scan actually check?',
        'ماذا يفحص مسح منتصف العلاج فعليًا؟',
        'Tracking. If the aligner is not seating fully, staging failed, not '
            'the patient.',
        'مدى المتابعة. إن لم يجلس المصفف بالكامل فالخلل في التدريج لا في '
            'المريض.',
      ),
      _Card(
        'How many hours a day must an aligner be worn?',
        'كم ساعة يوميًا يجب ارتداء المصفف؟',
        '22 hours. Below 20, tracking loss shows within three aligners.',
        '22 ساعة. تحت 20 ساعة يظهر فقد المتابعة خلال ثلاثة مصففات.',
      ),
      _Card(
        'Which case type should go to fixed appliances?',
        'أي نوع من الحالات يذهب للأجهزة الثابتة؟',
        'Skeletal Class III needing significant root movement, and impacted '
            'canines.',
        'الفئة الثالثة الهيكلية التي تحتاج حركة جذرية كبيرة، والأنياب المنطمرة.',
      ),
      _Card(
        'What is the first thing to check when a case stops tracking?',
        'ما أول ما تفحصه عند توقف متابعة الحالة؟',
        'Attachment integrity, then wear time, then the staging file. In that '
            'order.',
        'سلامة الملحقات، ثم مدة الارتداء، ثم ملف التدريج. بهذا الترتيب.',
      ),
    ],
    quizTitleEn: 'Aligner case selection',
    quizTitleAr: 'اختيار حالات المصففات',
    questions: [
      _Question(
        promptEn:
            'A patient has 5mm of lower anterior crowding and a thin gingival '
            'biotype. What is the more defensible plan?',
        promptAr:
            'مريض لديه تزاحم أمامي سفلي 5 مم ونمط لثوي رقيق. ما الخطة الأكثر '
            'دفاعًا عنها؟',
        explanationEn:
            'Under 6mm of crowding with a thin biotype, interproximal '
            'reduction keeps the roots inside the alveolar housing. Expansion '
            'here risks recession that the aligner cannot undo.',
        explanationAr:
            'مع تزاحم أقل من 6 مم ونمط رقيق، يبقي البرد بين الأسنان الجذور '
            'داخل العظم السنخي. التوسيع هنا يخاطر بانحسار لا تعالجه المصففات.',
        options: [
          _Option(
            'Interproximal reduction, staged across the anterior segment',
            'برد بين الأسنان مُدرّج عبر القطاع الأمامي',
          ),
          _Option(
            'Arch expansion of 5mm to create the space',
            'توسيع القوس بمقدار 5 مم لإيجاد المساحة',
          ),
          _Option(
            'Extract a lower incisor and close the space',
            'خلع قاطع سفلي وإغلاق المساحة',
          ),
          _Option(
            'Accept the crowding and treat the upper arch only',
            'قبول التزاحم وعلاج القوس العلوي فقط',
          ),
        ],
        correctIndex: 0,
      ),
      _Question(
        promptEn:
            'Three aligners into treatment, the upper right canine shows a '
            'visible gap at the incisal edge. What do you check first?',
        promptAr:
            'بعد ثلاثة مصففات يظهر فراغ عند الحافة القاطعة للناب العلوي '
            'الأيمن. ما أول ما تفحصه؟',
        explanationEn:
            'A lost or worn attachment is the most common and the fastest to '
            'confirm. Wear time and the staging file come next, in that '
            'order — changing the plan before checking the attachment usually '
            'rebuilds a case that was never wrong.',
        explanationAr:
            'الملحق المفقود أو المتآكل هو الأكثر شيوعًا والأسرع في التحقق. ثم '
            'مدة الارتداء ثم ملف التدريج بهذا الترتيب — تغيير الخطة قبل فحص '
            'الملحق يعيد بناء حالة لم تكن خاطئة أصلًا.',
        options: [
          _Option('The attachment on that canine', 'الملحق على ذلك الناب'),
          _Option('The patient\'s wear time', 'مدة ارتداء المريض'),
          _Option(
            'The staging of the next ten aligners',
            'تدريج المصففات العشرة التالية',
          ),
          _Option('The bite registration', 'تسجيل العضة'),
        ],
        correctIndex: 0,
      ),
      _Question(
        promptEn:
            'Which movement should you expect to need refinement for, even in '
            'a well-planned case?',
        promptAr:
            'أي حركة يُتوقع أن تحتاج مرحلة تحسين حتى في حالة مخططة جيدًا؟',
        explanationEn:
            'Root torque on upper incisors is the least predictable movement '
            'in aligner therapy. Planning refinement into the case from the '
            'start is honest with the patient and with the fee.',
        explanationAr:
            'عزم جذور القواطع العلوية هو أقل الحركات قابلية للتنبؤ في علاج '
            'المصففات. تضمين مرحلة التحسين في الخطة من البداية أمانة مع '
            'المريض ومع الأتعاب.',
        options: [
          _Option('Root torque on upper incisors', 'عزم جذور القواطع العلوية'),
          _Option('Tipping of lower premolars', 'إمالة الضواحك السفلية'),
          _Option('Minor anterior alignment', 'التصفيف الأمامي البسيط'),
          _Option('Closing a 1mm diastema', 'إغلاق فُرجة 1 مم'),
        ],
        correctIndex: 0,
      ),
      _Question(
        promptEn:
            'A patient reports wearing the aligners about 18 hours a day. What '
            'does that predict?',
        promptAr:
            'يذكر المريض أنه يرتدي المصففات نحو 18 ساعة يوميًا. بماذا ينبئ '
            'ذلك؟',
        explanationEn:
            'The protocol is 22 hours. Below 20, tracking loss typically shows '
            'within three aligners, so the conversation belongs at this visit '
            'rather than at the next scan.',
        explanationAr:
            'البروتوكول 22 ساعة. تحت 20 ساعة يظهر فقد المتابعة عادة خلال '
            'ثلاثة مصففات، لذا يجب أن تكون المحادثة في هذه الزيارة لا في '
            'المسح التالي.',
        options: [
          _Option(
            'Tracking loss within about three aligners',
            'فقد المتابعة خلال نحو ثلاثة مصففات',
          ),
          _Option(
            'No measurable effect on the outcome',
            'لا أثر ملموس على النتيجة',
          ),
          _Option(
            'Faster movement from longer rest periods',
            'حركة أسرع بسبب فترات الراحة',
          ),
          _Option(
            'A need to shorten each aligner stage',
            'الحاجة لتقصير مدة كل مصفف',
          ),
        ],
        correctIndex: 0,
      ),
      _Question(
        promptEn:
            'Which finding most clearly belongs in fixed appliances rather '
            'than aligners?',
        promptAr: 'أي نتيجة تنتمي بوضوح للأجهزة الثابتة بدل المصففات؟',
        explanationEn:
            'An impacted canine needs traction that aligners cannot deliver. '
            'Saying so at the consultation is better practice — and better '
            'business — than restarting the case six months in.',
        explanationAr:
            'الناب المنطمر يحتاج شدًا لا توفره المصففات. قول ذلك في الاستشارة '
            'ممارسة أفضل — وعمل أفضل — من إعادة بدء الحالة بعد ستة أشهر.',
        options: [
          _Option('An impacted upper canine', 'ناب علوي منطمر'),
          _Option('3mm of upper crowding', 'تزاحم علوي 3 مم'),
          _Option('A single rotated premolar', 'ضاحك واحد مدور'),
          _Option('A 2mm midline shift', 'انزياح خط الوسط 2 مم'),
        ],
        correctIndex: 0,
      ),
    ],
  ),

  // --- Digital --------------------------------------------------------------
  _Course(
    slug: 'intraoral-scanning',
    department: 'digital',
    titleEn: 'Intraoral scanning the lab can actually use',
    titleAr: 'المسح داخل الفم بجودة يقبلها المعمل',
    subtitleEn:
        'Scan strategy, soft-tissue control, and the five errors that cause '
        'most remakes.',
    subtitleAr:
        'استراتيجية المسح، والتحكم بالأنسجة الرخوة، والأخطاء الخمسة وراء أغلب '
        'حالات إعادة العمل.',
    descriptionEn:
        'Five recorded lessons filmed on a working scanner. The course covers '
        'the scan path, retraction, margin capture, bite registration and what '
        'to send the lab so the case is not returned. Every claim is what the '
        'instructor does in her own clinic.',
    descriptionAr:
        'خمسة دروس مسجلة على ماسح أثناء العمل. تغطي الدورة مسار المسح، '
        'والإبعاد، والتقاط الحدود، وتسجيل العضة، وما تُرسله للمعمل حتى لا '
        'تُعاد الحالة. كل ما يُذكر هو ما يفعله المحاضر في عيادته.',
    levelEn: 'Foundation',
    levelAr: 'تمهيدي',
    cpdPoints: 4,
    instructorEn: 'Dr. Karim Nabil',
    instructorAr: 'د. كريم نبيل',
    instructorBioEn:
        'Restorative dentist. Moved his practice to a fully digital workflow '
        'in 2019 and has scanned about 3,000 units since.',
    instructorBioAr:
        'طبيب أسنان ترميمي. نقل عيادته إلى سير عمل رقمي كامل عام 2019 ومسح '
        'نحو 3,000 وحدة منذ ذلك الحين.',
    iapProductId: 'international.ejadah.course.intraoral_scanning',
    lessons: [
      _Lesson(
        'The scan path, and why order matters',
        'مسار المسح ولماذا يهم الترتيب',
        684,
      ),
      _Lesson(
        'Soft-tissue control: retraction that holds',
        'التحكم بالأنسجة الرخوة: إبعاد يثبت',
        912,
      ),
      _Lesson(
        'Capturing a margin the lab can read',
        'التقاط حد يستطيع المعمل قراءته',
        1035,
      ),
      _Lesson(
        'Bite registration and the articulation check',
        'تسجيل العضة وفحص الإطباق',
        756,
      ),
      _Lesson(
        'What to send the lab, and in what format',
        'ماذا ترسل للمعمل وبأي صيغة',
        598,
      ),
    ],
    handouts: [
      _Handout('Scan path diagrams', 'مخططات مسار المسح', 'scan-path'),
      _Handout(
        'Lab prescription template',
        'نموذج وصفة المعمل',
        'lab-prescription',
      ),
    ],
    deckTitleEn: 'Scanning essentials',
    deckTitleAr: 'أساسيات المسح',
    cards: [
      _Card(
        'What is the standard scan order for a full arch?',
        'ما ترتيب المسح القياسي للقوس الكامل؟',
        'Occlusal first, then lingual, then buccal — one continuous pass.',
        'الإطباقي أولًا، ثم اللساني، ثم الشدقي — مسحة واحدة متصلة.',
      ),
      _Card(
        'Why does the scanner lose tracking mid-arch?',
        'لماذا يفقد الماسح التتبع في منتصف القوس؟',
        'Too fast over a featureless surface. Slow down at the edentulous '
            'span.',
        'السرعة الزائدة فوق سطح بلا معالم. أبطئ عند المنطقة الخالية من الأسنان.',
      ),
      _Card(
        'How long should retraction cord stay before a margin scan?',
        'كم تبقى خيوط الإبعاد قبل مسح الحد؟',
        'Four minutes is enough for most cases. Scan immediately after removal.',
        'أربع دقائق تكفي لأغلب الحالات. امسح فور الإزالة.',
      ),
      _Card(
        'What does the lab need besides the scan file?',
        'ماذا يحتاج المعمل غير ملف المسح؟',
        'Shade with a reference tab, the bite scan, and the opposing arch.',
        'اللون مع عينة مرجعية، ومسح العضة، والقوس المقابل.',
      ),
      _Card(
        'When is a scan not appropriate?',
        'متى لا يكون المسح مناسبًا؟',
        'Subgingival margins deeper than 1mm that cannot be exposed.',
        'حدود تحت لثوية أعمق من 1 مم يتعذر كشفها.',
      ),
      _Card(
        'What is the most common cause of a returned case?',
        'ما أشيع سبب لإعادة الحالة من المعمل؟',
        'An unreadable margin, not file format. Blood and saliva, almost '
            'always.',
        'حد غير مقروء، لا صيغة الملف. الدم واللعاب في الغالب.',
      ),
    ],
    quizTitleEn: 'Scanning for a case the lab accepts',
    quizTitleAr: 'المسح لحالة يقبلها المعمل',
    questions: [
      _Question(
        promptEn:
            'A full-arch scan keeps losing tracking across an edentulous span. '
            'What is the correction?',
        promptAr:
            'يفقد مسح القوس الكامل التتبع عبر منطقة خالية من الأسنان. ما '
            'التصحيح؟',
        explanationEn:
            'The scanner stitches on surface features. A featureless ridge '
            'needs a slower pass, not a restart — restarting loses the arch '
            'you already had.',
        explanationAr:
            'يعتمد الماسح على معالم السطح في الدمج. الحافة بلا معالم تحتاج '
            'مسحة أبطأ لا إعادة بدء — فالإعادة تفقدك القوس الذي أنجزته.',
        options: [
          _Option('Slow the pass across the ridge', 'أبطئ المسح فوق الحافة'),
          _Option('Restart the scan from the midline', 'أعد المسح من خط الوسط'),
          _Option('Increase the room lighting', 'زد إضاءة الغرفة'),
          _Option('Switch to a smaller scanner tip', 'بدّل إلى رأس ماسح أصغر'),
        ],
        correctIndex: 0,
      ),
      _Question(
        promptEn:
            'A crown comes back from the lab with an open margin. Which cause '
            'is most likely?',
        promptAr: 'يعود تاج من المعمل بحد مفتوح. ما السبب الأرجح؟',
        explanationEn:
            'Blood or saliva at the margin at the moment of capture is by far '
            'the most common cause. File format problems announce themselves '
            'before the case is milled.',
        explanationAr:
            'وجود دم أو لعاب عند الحد لحظة الالتقاط هو السبب الأشيع بفارق '
            'كبير. مشاكل صيغة الملف تظهر قبل تصنيع الحالة.',
        options: [
          _Option(
            'Fluid at the margin during capture',
            'سائل عند الحد أثناء الالتقاط',
          ),
          _Option('The export file format', 'صيغة ملف التصدير'),
          _Option('The scanner calibration date', 'تاريخ معايرة الماسح'),
          _Option('The shade selection', 'اختيار اللون'),
        ],
        correctIndex: 0,
      ),
      _Question(
        promptEn: 'What must accompany the scan in the lab prescription?',
        promptAr: 'ما الذي يجب أن يرافق المسح في وصفة المعمل؟',
        explanationEn:
            'The opposing arch and the bite scan let the lab articulate the '
            'case. Without them the technician is guessing at the occlusion, '
            'and the adjustment lands in your chair.',
        explanationAr:
            'القوس المقابل ومسح العضة يتيحان للمعمل ضبط الإطباق. بدونهما '
            'يخمّن الفني الإطباق، ويقع التعديل على كرسيك.',
        options: [
          _Option(
            'The opposing arch and the bite scan',
            'القوس المقابل ومسح العضة',
          ),
          _Option('A photograph of the patient', 'صورة فوتوغرافية للمريض'),
          _Option('The previous radiograph', 'الأشعة السابقة'),
          _Option('The scanner serial number', 'الرقم التسلسلي للماسح'),
        ],
        correctIndex: 0,
      ),
      _Question(
        promptEn:
            'When should a case go to a conventional impression instead of a '
            'scan?',
        promptAr: 'متى تذهب الحالة لطبعة تقليدية بدل المسح؟',
        explanationEn:
            'A subgingival margin deeper than about 1mm that cannot be exposed '
            'is not visible to the camera. Light cannot go where it cannot '
            'reach, and no software setting changes that.',
        explanationAr:
            'الحد تحت اللثوي بعمق يتجاوز 1 مم تقريبًا ويتعذر كشفه لا تراه '
            'الكاميرا. الضوء لا يصل حيث لا يصل، ولا يغيّر ذلك أي إعداد برمجي.',
        options: [
          _Option(
            'A deep subgingival margin that cannot be exposed',
            'حد تحت لثوي عميق يتعذر كشفه',
          ),
          _Option('Any full-arch case', 'أي حالة قوس كامل'),
          _Option('A single posterior crown', 'تاج خلفي مفرد'),
          _Option(
            'A patient with a strong gag reflex',
            'مريض بمنعكس بلعومي قوي',
          ),
        ],
        correctIndex: 0,
      ),
    ],
  ),

  // --- Business and paradental ----------------------------------------------
  _Course(
    slug: 'clinic-numbers',
    department: 'business_paradental',
    titleEn: 'The four numbers a clinic owner checks weekly',
    titleAr: 'أربعة أرقام يراجعها صاحب العيادة كل أسبوع',
    subtitleEn:
        'Chair utilisation, case acceptance, cost per hour and collection — '
        'what each one is telling you.',
    subtitleAr:
        'استغلال الكرسي، وقبول الخطط، والتكلفة بالساعة، والتحصيل — ماذا يقول '
        'كل رقم منها.',
    descriptionEn:
        'Four recorded lessons for a dentist who owns or runs a clinic. The '
        'course builds one weekly sheet, defines each number precisely, and '
        'shows what to change when a number moves. Figures are in EGP and come '
        'from real Cairo practices with permission.',
    descriptionAr:
        'أربعة دروس مسجلة لطبيب يملك عيادة أو يديرها. تبني الدورة كشفًا '
        'أسبوعيًا واحدًا، وتُعرّف كل رقم بدقة، وتوضح ما تغيّره حين يتحرك رقم. '
        'الأرقام بالجنيه المصري ومن عيادات قاهرية حقيقية بإذن أصحابها.',
    levelEn: 'Foundation',
    levelAr: 'تمهيدي',
    cpdPoints: 3,
    instructorEn: 'Dr. Hala Mostafa',
    instructorAr: 'د. هالة مصطفى',
    instructorBioEn:
        'Runs two clinics in Cairo and Giza. Has published her own operating '
        'figures since 2020 so the numbers in this course can be checked.',
    instructorBioAr:
        'تدير عيادتين في القاهرة والجيزة. تنشر أرقام التشغيل الخاصة بها منذ '
        '2020 حتى يمكن التحقق من أرقام هذه الدورة.',
    iapProductId: 'international.ejadah.course.clinic_numbers',
    lessons: [
      _Lesson(
        'Chair utilisation: the number most clinics measure wrong',
        'استغلال الكرسي: الرقم الذي تقيسه أغلب العيادات خطأ',
        738,
      ),
      _Lesson(
        'Case acceptance, and what a low rate is really saying',
        'قبول الخطط، وماذا يعني المعدل المنخفض فعليًا',
        864,
      ),
      _Lesson(
        'Cost per chair hour, built from your own invoices',
        'تكلفة ساعة الكرسي محسوبة من فواتيرك',
        1002,
      ),
      _Lesson(
        'Collection: the gap between billed and banked',
        'التحصيل: الفارق بين ما فُوتر وما وصل',
        689,
      ),
    ],
    handouts: [
      _Handout('Weekly numbers sheet', 'كشف الأرقام الأسبوعي', 'weekly-sheet'),
      _Handout(
        'Cost per hour worksheet',
        'ورقة حساب تكلفة الساعة',
        'cost-per-hour',
      ),
    ],
    deckTitleEn: 'Clinic numbers — definitions',
    deckTitleAr: 'أرقام العيادة — التعريفات',
    cards: [
      _Card(
        'How is chair utilisation defined here?',
        'كيف يُعرّف استغلال الكرسي هنا؟',
        'Booked clinical hours divided by hours the chair was staffed and open.',
        'الساعات السريرية المحجوزة مقسومة على ساعات تشغيل الكرسي بطاقم كامل.',
      ),
      _Card(
        'Why exclude no-shows from booked hours?',
        'لماذا تُستبعد حالات عدم الحضور من الساعات المحجوزة؟',
        'They cost the same as an empty chair. Counting them hides the problem.',
        'تكلفتها كتكلفة كرسي فارغ. احتسابها يخفي المشكلة.',
      ),
      _Card(
        'What does case acceptance measure?',
        'ماذا يقيس معدل قبول الخطط؟',
        'Treatment plans started within 30 days, over plans presented.',
        'الخطط التي بدأت خلال 30 يومًا على الخطط المعروضة.',
      ),
      _Card(
        'A case acceptance rate of 30% usually points at what?',
        'معدل قبول 30% يشير عادة إلى ماذا؟',
        'The consultation, not the price. Patients decline what they did not '
            'understand.',
        'الاستشارة لا السعر. يرفض المرضى ما لم يفهموه.',
      ),
      _Card(
        'What belongs in cost per chair hour?',
        'ماذا يدخل في تكلفة ساعة الكرسي؟',
        'Rent, salaries, consumables, equipment amortisation and utilities.',
        'الإيجار والرواتب والمستهلكات وإهلاك الأجهزة والمرافق.',
      ),
      _Card(
        'What is a healthy gap between billed and collected?',
        'ما الفارق الصحي بين ما فُوتر وما حُصّل؟',
        'Under 5% after 60 days. Above 10%, the front desk process is the '
            'issue.',
        'أقل من 5% بعد 60 يومًا. فوق 10% تكون المشكلة في إجراءات الاستقبال.',
      ),
    ],
    quizTitleEn: 'Reading your clinic numbers',
    quizTitleAr: 'قراءة أرقام عيادتك',
    questions: [
      _Question(
        promptEn:
            'Your chair utilisation reads 92%, but the clinic is not '
            'profitable. What is the most likely explanation?',
        promptAr:
            'استغلال الكرسي 92% لكن العيادة غير مربحة. ما التفسير الأرجح؟',
        explanationEn:
            'High utilisation with low profit almost always means the hourly '
            'rate sits below cost per chair hour. The chair is busy losing '
            'money, which no amount of extra booking fixes.',
        explanationAr:
            'الاستغلال المرتفع مع ربح منخفض يعني غالبًا أن سعر الساعة أقل من '
            'تكلفة ساعة الكرسي. الكرسي مشغول بخسارة المال، ولا يصلح ذلك بمزيد '
            'من الحجوزات.',
        options: [
          _Option(
            'The hourly rate is below cost per chair hour',
            'سعر الساعة أقل من تكلفة ساعة الكرسي',
          ),
          _Option('Too few new patients', 'عدد قليل من المرضى الجدد'),
          _Option(
            'The clinic needs longer opening hours',
            'العيادة تحتاج ساعات عمل أطول',
          ),
          _Option('Case acceptance is too high', 'معدل قبول الخطط مرتفع جدًا'),
        ],
        correctIndex: 0,
      ),
      _Question(
        promptEn:
            'Case acceptance has fallen from 62% to 34% over one quarter, with '
            'no price change. Where do you look first?',
        promptAr:
            'انخفض قبول الخطط من 62% إلى 34% خلال ربع سنة دون تغيير الأسعار. '
            'أين تبحث أولًا؟',
        explanationEn:
            'A drop with prices unchanged points at the consultation: who is '
            'presenting, how long it takes, and whether the patient leaves '
            'understanding the plan. Discounting a plan nobody understood does '
            'not raise acceptance.',
        explanationAr:
            'الانخفاض دون تغيير الأسعار يشير إلى الاستشارة: من يعرضها، وكم '
            'تستغرق، وهل يغادر المريض فاهمًا للخطة. تخفيض خطة لم يفهمها أحد لا '
            'يرفع القبول.',
        options: [
          _Option('The consultation itself', 'الاستشارة نفسها'),
          _Option('The competitor down the street', 'المنافس في الشارع نفسه'),
          _Option('The clinic\'s social media', 'حسابات العيادة على التواصل'),
          _Option('The equipment list', 'قائمة الأجهزة'),
        ],
        correctIndex: 0,
      ),
      _Question(
        promptEn: 'Which of these belongs inside cost per chair hour?',
        promptAr: 'أي مما يلي يدخل ضمن تكلفة ساعة الكرسي؟',
        explanationEn:
            'Equipment amortisation is a real hourly cost even in a month when '
            'nothing is bought. Leaving it out is the most common reason a '
            'clinic believes it is more profitable than it is.',
        explanationAr:
            'إهلاك الأجهزة تكلفة ساعية حقيقية حتى في شهر لا شراء فيه. إغفاله '
            'هو أشيع سبب لاعتقاد العيادة أنها أكثر ربحية مما هي عليه.',
        options: [
          _Option('Equipment amortisation', 'إهلاك الأجهزة'),
          _Option('The owner\'s personal car', 'سيارة المالك الشخصية'),
          _Option('Lab fees for a specific case', 'أتعاب المعمل لحالة بعينها'),
          _Option('One-off marketing campaigns', 'حملات تسويق لمرة واحدة'),
        ],
        correctIndex: 0,
      ),
      _Question(
        promptEn:
            '14% of what you billed 60 days ago is still uncollected. What '
            'does that indicate?',
        promptAr:
            '14% مما فوترته قبل 60 يومًا لم يُحصّل بعد. على ماذا يدل ذلك؟',
        explanationEn:
            'Above 10% after 60 days, the problem is process rather than '
            'patients: when payment is asked for, by whom, and what happens on '
            'the day the instalment is missed.',
        explanationAr:
            'فوق 10% بعد 60 يومًا تكون المشكلة في الإجراءات لا في المرضى: متى '
            'يُطلب الدفع، ومن يطلبه، وماذا يحدث يوم يتأخر القسط.',
        options: [
          _Option('A front-desk process problem', 'مشكلة في إجراءات الاستقبال'),
          _Option('Prices that are too high', 'أسعار مرتفعة جدًا'),
          _Option('Normal seasonal variation', 'تغيّر موسمي طبيعي'),
          _Option('Too many instalment plans', 'كثرة خطط التقسيط'),
        ],
        correctIndex: 0,
      ),
    ],
  ),
];
