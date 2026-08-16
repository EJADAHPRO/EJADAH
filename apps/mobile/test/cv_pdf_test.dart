import 'dart:typed_data';

import 'package:ejadah_mobile/features/profile/application/cv_pdf.dart';
import 'package:ejadah_mobile/features/profile/data/cv_repository.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:flutter_test/flutter_test.dart';

/// The exported CV.
///
/// This is the document a dentist attaches to a university application, so it
/// is the one artefact this product produces that a stranger reads on a
/// machine we know nothing about. Three rules carry it and all three are
/// invisible until they are broken on someone else's computer.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final language in AppLanguage.values) {
    group('in ${language.code}', () {
      test('the fonts are embedded, not referenced', () async {
        final bytes = await _build(language);
        final raw = String.fromCharCodes(bytes);

        // Both faces, subset into the file. A PDF that names a font it does
        // not carry renders Arabic as boxes on a reader that lacks it — and
        // the reader that matters is an admissions officer's.
        expect(raw, contains('Amiri'));
        expect(raw, contains('IBMPlexSansArabic'));
        // `FontFile2` is the embedded-TrueType stream. Its absence is exactly
        // the failure this test exists for: a document that looks right here
        // and wrong everywhere else.
        expect(raw, contains('FontFile2'));
      });

      test('it is A4', () async {
        final bytes = await _build(language);
        final raw = String.fromCharCodes(bytes);

        // A4 is 595.27559 × 841.88976 points. Not Letter: the readers are
        // Egyptian universities and European ones, and a CV that prints with
        // the wrong margins on their paper is a CV that looks careless.
        expect(raw, contains('MediaBox[0 0 595.27559 841.88976]'));
      });

      test('the patient-data warning does not print', () async {
        final bytes = await _build(language);
        final raw = String.fromCharCodes(bytes);

        // Guidance for the person writing the CV, not a statement about them.
        // On a document sent to a university it would read as a disclaimer
        // someone thought was necessary.
        expect(raw, isNot(contains('patient')));
        expect(raw, isNot(contains('المرضى')));
      });

      test('it renders without throwing on an empty CV', () async {
        // The export button is disabled for this, but a controller change
        // could reach it and an exception here is a crash on the one screen
        // where a user has just spent an hour.
        final bytes = await CvPdf.build(
          cv: const Cv(
            sections: [],
            patientDataWarning: _warning,
            kinds: ['summary'],
          ),
          name: _name,
          stage: 'General dentist',
          language: language,
          headingFor: (kind) => kind,
        );
        expect(bytes, isNotEmpty);
      });
    });
  }

  test('Arabic-Indic digits in the user’s own text come out Western', () async {
    final bytes = await CvPdf.build(
      cv: const Cv(
        sections: [
          CvSection(
            id: 's1',
            position: 1,
            kind: 'education',
            heading: 'التعليم',
            // Typed on an Arabic keyboard, as it would be.
            body: 'بكالوريوس طب الأسنان ٢٠١٨',
          ),
        ],
        patientDataWarning: _warning,
        kinds: ['education'],
      ),
      name: _name,
      stage: 'طبيب أسنان عام',
      language: AppLanguage.ar,
      headingFor: (kind) => kind,
    );

    // Figures sit beside Latin-context codes throughout this product; mixing
    // numeral systems down one document is what makes a CV look improvised.
    expect(bytes, isNotEmpty);
    expect(CvPdfDigits.toWestern('٢٠١٨'), '2018');
    expect(CvPdfDigits.toWestern('۲۰۱۸'), '2018');
    expect(CvPdfDigits.toWestern('BDS 2018'), 'BDS 2018');
  });

  test('the uploaded file is not inlined into the document', () async {
    final bytes = await CvPdf.build(
      cv: const Cv(
        sections: [
          CvSection(
            id: 'u1',
            position: 0,
            kind: 'uploaded',
            heading: '',
            body: 'cv/user-a/secret-token.pdf',
          ),
        ],
        patientDataWarning: _warning,
        kinds: ['summary'],
      ),
      name: _name,
      stage: 'General dentist',
      language: AppLanguage.en,
      headingFor: (kind) => kind,
    );

    // The storage key is an internal path. Printing it would put a private
    // identifier on a document sent to strangers.
    expect(String.fromCharCodes(bytes), isNot(contains('secret-token')));
  });
}

Future<Uint8List> _build(AppLanguage language) => CvPdf.build(
  cv: const Cv(
    sections: [
      CvSection(
        id: 's1',
        position: 1,
        kind: 'summary',
        heading: 'Summary',
        body: 'Consultant endodontist, Cairo.',
      ),
      CvSection(
        id: 's2',
        position: 2,
        kind: 'education',
        heading: '',
        body: 'BDS, Cairo University',
      ),
    ],
    patientDataWarning: _warning,
    kinds: ['summary', 'education'],
  ),
  name: _name,
  stage: language == AppLanguage.ar ? 'طبيب أسنان عام' : 'General dentist',
  language: language,
  headingFor: (kind) => kind == 'education' ? 'Education' : 'Summary',
);

const LocalizedText _name = LocalizedText(
  en: 'Dr. Mona Adel',
  ar: 'د. منى عادل',
);

const LocalizedText _warning = LocalizedText(
  en: "Please don't include patient names or identifying details.",
  ar: 'لا تُدرج أسماء المرضى أو بيانات تعريفية.',
);
