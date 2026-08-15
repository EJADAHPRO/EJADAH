import 'package:ejadah_models/ejadah_models.dart';
import 'package:flutter/widgets.dart';

import 'tokens.g.dart';

/// The twelve type sizes. There is nothing else in the scale.
abstract final class EjadahTypeSize {
  static const double micro = RawTokens.sizeMicro;
  static const double caption = RawTokens.sizeCaption;
  static const double small = RawTokens.sizeSmall;
  static const double body = RawTokens.sizeBody;
  static const double bodyLg = RawTokens.sizeBodyLg;
  static const double h6 = RawTokens.sizeH6;
  static const double h5 = RawTokens.sizeH5;
  static const double h4 = RawTokens.sizeH4;
  static const double h3 = RawTokens.sizeH3;
  static const double h2 = RawTokens.sizeH2;
  static const double h1 = RawTokens.sizeH1;
  static const double display = RawTokens.sizeDisplay;
}

/// How tightly a block of text is set.
enum TextDensity {
  /// Headings.
  tight,

  /// Sub-headings and dense labels.
  snug,

  /// Running copy.
  body,
}

/// The Ejadah type system, resolved per language.
///
/// Arabic is not English with a different font. It sets on raised line-heights
/// (1.25→1.45 tight, 1.45→1.65 snug, 1.70→1.85 body), always at zero letter
/// spacing, never uppercased, and long headings shrink 12% above 28 characters.
/// Those rules are applied here, centrally, rather than being remembered at each
/// call site.
///
/// Playfair Display carries no Arabic glyphs, so Amiri is the Arabic display
/// face — rendering Playfair in Arabic produces tofu, not a fallback.
class EjadahTypography {
  const EjadahTypography(this.language);

  final AppLanguage language;

  bool get _isArabic => language == AppLanguage.ar;

  String get displayFamily =>
      _isArabic ? RawTokens.fontDisplayAr : RawTokens.fontDisplayEn;

  String get bodyFamily =>
      _isArabic ? RawTokens.fontBodyAr : RawTokens.fontBodyEn;

  double lineHeightFor(TextDensity density) => switch (density) {
    TextDensity.tight =>
      _isArabic ? RawTokens.lineHeightTightAr : RawTokens.lineHeightTightEn,
    TextDensity.snug =>
      _isArabic ? RawTokens.lineHeightSnugAr : RawTokens.lineHeightSnugEn,
    TextDensity.body =>
      _isArabic ? RawTokens.lineHeightBodyAr : RawTokens.lineHeightBodyEn,
  };

  /// Arabic never carries tracking. English eyebrows carry 0.08em.
  double letterSpacingFor(double fontSize, {bool isEyebrow = false}) {
    if (_isArabic) return RawTokens.letterSpacingAr;
    return isEyebrow ? RawTokens.letterSpacingEyebrowEn * fontSize : 0;
  }

  /// The Arabic long-heading rule.
  ///
  /// Arabic renders wider than English at the same point size, so a heading
  /// that fits in English can wrap to three lines in Arabic. Above 28
  /// characters the size drops 12%. English is returned unchanged.
  double headingSizeFor(double fontSize, String text) {
    if (!_isArabic) return fontSize;
    if (text.characters.length <= RawTokens.arHeadingThresholdChars) {
      return fontSize;
    }
    return fontSize * (1 - RawTokens.arHeadingReducePct);
  }

  /// Arabic is never uppercased — the script has no case, and the transform
  /// silently mangles mixed Latin runs inside Arabic strings.
  String eyebrowText(String text) => _isArabic ? text : text.toUpperCase();

  // --- Display (Playfair / Amiri) ------------------------------------------

  TextStyle display({String text = '', Color? color}) => _display(
    EjadahTypeSize.display,
    text,
    color,
    RawTokens.weightDisplayBlack,
  );

  TextStyle h1({String text = '', Color? color}) =>
      _display(EjadahTypeSize.h1, text, color, RawTokens.weightDisplayBold);

  TextStyle h2({String text = '', Color? color}) =>
      _display(EjadahTypeSize.h2, text, color, RawTokens.weightDisplayBold);

  TextStyle h3({String text = '', Color? color}) =>
      _display(EjadahTypeSize.h3, text, color, RawTokens.weightDisplayBold);

  TextStyle h4({String text = '', Color? color}) =>
      _display(EjadahTypeSize.h4, text, color, RawTokens.weightDisplayBold);

  // --- UI and body (Inter / IBM Plex Sans Arabic) --------------------------

  TextStyle h5({Color? color}) =>
      _body(EjadahTypeSize.h5, RawTokens.weightBold, TextDensity.snug, color);

  TextStyle h6({Color? color}) => _body(
    EjadahTypeSize.h6,
    RawTokens.weightSemibold,
    TextDensity.snug,
    color,
  );

  TextStyle bodyLarge({Color? color}) => _body(
    EjadahTypeSize.bodyLg,
    RawTokens.weightRegular,
    TextDensity.body,
    color,
  );

  TextStyle bodyText({Color? color}) => _body(
    EjadahTypeSize.body,
    RawTokens.weightRegular,
    TextDensity.body,
    color,
  );

  TextStyle bodyStrong({Color? color}) => _body(
    EjadahTypeSize.body,
    RawTokens.weightSemibold,
    TextDensity.snug,
    color,
  );

  TextStyle small({Color? color}) => _body(
    EjadahTypeSize.small,
    RawTokens.weightRegular,
    TextDensity.snug,
    color,
  );

  TextStyle caption({Color? color}) => _body(
    EjadahTypeSize.caption,
    RawTokens.weightMedium,
    TextDensity.snug,
    color,
  );

  TextStyle micro({Color? color}) => _body(
    EjadahTypeSize.micro,
    RawTokens.weightMedium,
    TextDensity.snug,
    color,
  );

  /// Section eyebrows. English carries tracking; Arabic never does.
  TextStyle eyebrow({Color? color}) => TextStyle(
    fontFamily: bodyFamily,
    fontSize: EjadahTypeSize.caption,
    fontWeight: _weight(RawTokens.weightBold),
    height: lineHeightFor(TextDensity.snug),
    letterSpacing: letterSpacingFor(EjadahTypeSize.caption, isEyebrow: true),
    color: color,
  );

  /// Button labels: 13–14, bold, in the body family.
  TextStyle button({Color? color}) => TextStyle(
    fontFamily: bodyFamily,
    fontSize: EjadahTypeSize.body,
    fontWeight: _weight(RawTokens.weightBold),
    height: lineHeightFor(TextDensity.tight),
    letterSpacing: letterSpacingFor(EjadahTypeSize.body),
    color: color,
  );

  /// Figures that align in a column — earnings rows, comparison tables.
  ///
  /// Always Latin-set with tabular figures, in both languages, because the
  /// product uses Western numerals throughout.
  TextStyle tabular({double? fontSize, Color? color}) => TextStyle(
    fontFamily: RawTokens.fontBodyEn,
    fontSize: fontSize ?? EjadahTypeSize.body,
    fontWeight: _weight(RawTokens.weightSemibold),
    height: lineHeightFor(TextDensity.snug),
    letterSpacing: 0,
    fontFeatures: const [FontFeature.tabularFigures()],
    color: color,
  );

  TextStyle _display(double size, String text, Color? color, int weight) =>
      TextStyle(
        fontFamily: displayFamily,
        fontSize: headingSizeFor(size, text),
        // Amiri ships at 700 and only 700 — the brand guide specifies that
        // weight. Asking for 800 in Arabic would get a synthesised face rather
        // than the one the type pairing was chosen for, so the request is
        // clamped to what actually exists.
        fontWeight: _weight(_isArabic && weight > 700 ? 700 : weight),
        height: lineHeightFor(TextDensity.tight),
        letterSpacing: letterSpacingFor(size),
        color: color,
      );

  TextStyle _body(double size, int weight, TextDensity density, Color? color) =>
      TextStyle(
        fontFamily: bodyFamily,
        fontSize: size,
        fontWeight: _weight(weight),
        height: lineHeightFor(density),
        letterSpacing: letterSpacingFor(size),
        color: color,
      );

  static FontWeight _weight(int value) => switch (value) {
    400 => FontWeight.w400,
    500 => FontWeight.w500,
    600 => FontWeight.w600,
    700 => FontWeight.w700,
    800 => FontWeight.w800,
    _ => FontWeight.w400,
  };
}
