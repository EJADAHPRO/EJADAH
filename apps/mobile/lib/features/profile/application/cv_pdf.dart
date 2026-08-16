import 'dart:typed_data';

import 'package:ejadah_models/ejadah_models.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/cv_repository.dart';

/// The CV, as an A4 PDF.
///
/// This is the document a dentist attaches to an application, so three things
/// are non-negotiable and each is easy to get wrong:
///
/// * **The fonts are embedded.** Amiri for headings, IBM Plex Sans Arabic for
///   body — the same two faces the app renders. A PDF that relies on the
///   reader's system fonts renders Arabic as boxes on a machine that lacks
///   them, and the one machine that matters is a stranger's.
/// * **Western numerals, in both languages.** The rule the whole product
///   follows: dates and figures sit beside Latin-context codes, and mixing
///   numeral systems is what makes a document look improvised.
/// * **The patient-data warning does not print.** It is guidance for the person
///   writing the CV, not a statement about them. On a document sent to a
///   university it would read as a disclaimer someone thought was necessary.
class CvPdf {
  const CvPdf._();

  /// Builds the document.
  ///
  /// [name] and [stage] come from the account rather than the CV, because they
  /// are the two things the flow says are not optional and the CV's own
  /// sections are all optional.
  static Future<Uint8List> build({
    required Cv cv,
    required LocalizedText name,
    required String stage,
    required AppLanguage language,
    required String Function(String kind) headingFor,
    DateTime? generatedOn,
  }) async {
    final heading = pw.Font.ttf(
      await rootBundle.load('packages/ejadah_ui/assets/fonts/Amiri-Bold.ttf'),
    );
    final body = pw.Font.ttf(
      await rootBundle.load(
        'packages/ejadah_ui/assets/fonts/IBMPlexSansArabic-Regular.ttf',
      ),
    );
    final bodyBold = pw.Font.ttf(
      await rootBundle.load(
        'packages/ejadah_ui/assets/fonts/IBMPlexSansArabic-SemiBold.ttf',
      ),
    );

    final isArabic = language == AppLanguage.ar;
    final document = pw.Document(
      title: name.resolve(language),
      author: name.resolve(language),
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        // The page mirrors with the language, so an Arabic CV reads from the
        // right the way its reader does.
        textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        theme: pw.ThemeData.withFont(base: body, bold: bodyBold),
        margin: const pw.EdgeInsets.fromLTRB(48, 56, 48, 56),
        footer: (context) => pw.Container(
          alignment: isArabic
              ? pw.Alignment.centerLeft
              : pw.Alignment.centerRight,
          child: pw.Text(
            // Western digits, deliberately, in both languages.
            _western('${context.pageNumber} / ${context.pagesCount}'),
            style: pw.TextStyle(font: body, fontSize: 9, color: PdfColors.grey),
            // A page number is a Latin-context figure and stays LTR even on an
            // Arabic page.
            textDirection: pw.TextDirection.ltr,
          ),
        ),
        build: (context) => [
          _header(
            name: name.resolve(language),
            stage: stage,
            heading: heading,
            body: body,
          ),
          pw.SizedBox(height: 20),
          // The uploaded file is not inlined: it is a separate document the
          // reader already has, and pasting a filename into a CV would be
          // noise. Only what was typed is rendered here.
          for (final section in cv.typed) ...[
            _section(
              title: section.heading.trim().isEmpty
                  ? headingFor(section.kind)
                  : section.heading,
              text: section.body,
              heading: heading,
              body: body,
            ),
            pw.SizedBox(height: 16),
          ],
        ],
      ),
    );

    return document.save();
  }

  static pw.Widget _header({
    required String name,
    required String stage,
    required pw.Font heading,
    required pw.Font body,
  }) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(name, style: pw.TextStyle(font: heading, fontSize: 24)),
      pw.SizedBox(height: 4),
      pw.Text(
        stage,
        style: pw.TextStyle(font: body, fontSize: 11, color: PdfColors.grey700),
      ),
      pw.SizedBox(height: 12),
      pw.Divider(color: PdfColors.grey400, thickness: 0.6),
    ],
  );

  static pw.Widget _section({
    required String title,
    required String text,
    required pw.Font heading,
    required pw.Font body,
  }) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(title, style: pw.TextStyle(font: heading, fontSize: 13)),
      if (text.trim().isNotEmpty) ...[
        pw.SizedBox(height: 4),
        pw.Text(
          _western(text),
          style: pw.TextStyle(font: body, fontSize: 10.5, lineSpacing: 3),
        ),
      ],
    ],
  );

  static String _western(String value) => CvPdfDigits.toWestern(value);
}

/// The numeral rule the document follows.
///
/// Its own class so it can be asserted directly. Reading digits back out of a
/// compressed PDF stream is not a test anyone should have to write, and a rule
/// this small should not be provable only through a rendered artefact.
abstract final class CvPdfDigits {
  /// Replaces Arabic-Indic digits with Western ones, leaving everything else
  /// untouched.
  ///
  /// Applied to the user's own text as well as ours: someone who typed a date
  /// with an Arabic keyboard should still get a document whose figures match
  /// the rest of it. Both ranges are covered — Arabic-Indic (U+0660) and the
  /// Eastern Arabic-Indic forms (U+06F0) an Urdu or Persian keyboard produces.
  static String toWestern(String value) {
    const arabicZero = 0x0660;
    const extendedZero = 0x06F0;
    return String.fromCharCodes([
      for (final unit in value.runes)
        if (unit >= arabicZero && unit <= arabicZero + 9)
          0x30 + (unit - arabicZero)
        else if (unit >= extendedZero && unit <= extendedZero + 9)
          0x30 + (unit - extendedZero)
        else
          unit,
    ]);
  }
}
