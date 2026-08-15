// GENERATED FILE — DO NOT EDIT BY HAND.
//
// Source: handoff-flutter/03-design-system/DESIGN_TOKENS.json
// Regenerate: dart run tool/generate_tokens.dart
//
// Every visual constant in the Ejadah design system resolves to
// a value in this file. A raw colour, radius, duration or size
// written anywhere else in the codebase is a defect.

import 'dart:ui';

/// The canonical Ejadah design tokens.
abstract final class RawTokens {
  // --- Colour ---
  static const Color brandRed = Color(0xFFFF2D32);
  static const Color brandOrange = Color(0xFFFF6B1A);
  static const Color brandAmber = Color(0xFFFFAA18);
  static const Color brandGold = Color(0xFFFFC62E);
  static const Color surfaceOffWhite = Color(0xFFFFF9EF);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfacePaleGray = Color(0xFFF5F2EC);
  static const Color surfaceBorderGray = Color(0xFFE7E2DA);
  static const Color surfaceCharcoal = Color(0xFF1B1B1B);
  static const Color surfaceDeep = Color(0xFF121212);
  static const Color surfaceEspresso = Color(0xFF24201D);
  static const Color textPrimary = Color(0xFF1B1B1B);
  static const Color textSecondary = Color(0xFF716D67);
  static const Color textLabelMuted = Color(0xFF6B6862);
  static const Color textLabelStrong = Color(0xFF5A5751);
  static const Color textOrangeText = Color(0xFFC2450F);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textOnDarkMuted = Color(0xB8FFFFFF);
  static const Color textOnDarkFaint = Color(0x8CFFFFFF);
  static const Color semanticSuccess = Color(0xFF2D9B68);
  static const Color semanticInfo = Color(0xFF496FA8);
  static const Color semanticDanger = Color(0xFFFF2D32);
  static const Color semanticWarningText = Color(0xFF8A5C00);
  static const Color semanticSuccessText = Color(0xFF1B6B47);
  static const Color semanticDangerText = Color(0xFFC41419);

  /// Never use. fails AA (2.84-3.28:1); false pass in legacy docs — never reintroduce
  static const Color bannedMutedLabel = Color(0xFF8E8A83);

  // --- Brand gradient ---
  static const List<Color> gradientStops = <Color>[
    Color(0xFFFF2D32),
    Color(0xFFFF6B1A),
    Color(0xFFFFC62E),
  ];
  static const List<double> gradientPositions = <double>[0.0, 0.5, 1.0];
  static const double gradientAngleLtr = 135;
  static const double gradientAngleRtl = 225;
  static const int gradientMaxPerScreen = 6;
  static const List<String> gradientPermittedUses = <String>[
    'primaryButton',
    'logoTile',
    'stepMarker',
    'headingEmphasisPhrase',
    'closingCtaBand',
    'activeTabIndicator',
  ];

  // --- Typography ---
  static const String fontDisplayEn = 'Playfair Display';
  static const String fontBodyEn = 'Inter';
  static const String fontDisplayAr = 'Amiri';
  static const String fontBodyAr = 'IBM Plex Sans Arabic';
  static const double sizeMicro = 11.0;
  static const double sizeCaption = 12.0;
  static const double sizeSmall = 13.0;
  static const double sizeBody = 14.0;
  static const double sizeBodyLg = 16.0;
  static const double sizeH6 = 18.0;
  static const double sizeH5 = 20.0;
  static const double sizeH4 = 22.0;
  static const double sizeH3 = 24.0;
  static const double sizeH2 = 28.0;
  static const double sizeH1 = 32.0;
  static const double sizeDisplay = 36.0;
  static const double lineHeightTightEn = 1.25;
  static const double lineHeightTightAr = 1.45;
  static const double lineHeightSnugEn = 1.45;
  static const double lineHeightSnugAr = 1.65;
  static const double lineHeightBodyEn = 1.7;
  static const double lineHeightBodyAr = 1.85;
  static const double letterSpacingEyebrowEn = 0.08;
  static const double letterSpacingAr = 0.0;
  static const int weightDisplayBold = 700;
  static const int weightDisplayBlack = 800;
  static const int weightRegular = 400;
  static const int weightMedium = 500;
  static const int weightSemibold = 600;
  static const int weightBold = 700;
  static const int weightExtrabold = 800;

  /// Arabic headings shrink by this fraction above
  /// [arHeadingThresholdChars] characters.
  static const double arHeadingReducePct = 0.12;
  static const int arHeadingThresholdChars = 28;

  // --- Spacing scale ---
  static const List<double> space = <double>[
    4.0,
    8.0,
    12.0,
    16.0,
    20.0,
    24.0,
    32.0,
    40.0,
    48.0,
    64.0,
  ];

  // --- Radius ---
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusXxl = 24.0;
  static const double radiusPill = 999.0;

  // --- Opacity ---
  static const double opacityDisabled = 0.5;
  static const double opacityComingSoon = 0.6;
  static const double opacityBlurLocked = 0.55;

  // --- Motion ---
  static const int durationMsFast = 150;
  static const int durationMsBase = 200;
  static const int durationMsSlow = 300;
  static const double pressScale = 0.97;
  static const int staggerListMs = 40;

  // --- Breakpoints ---
  static const double breakpointCompact = 0.0;
  static const double breakpointMedium = 600.0;
  static const double breakpointExpanded = 1024.0;

  // --- Icon sizes ---
  static const double iconSizeInline = 16.0;
  static const double iconSizeNav = 21.0;
  static const double iconSizeFeature = 24.0;

  // --- Component sizing ---
  static const double buttonHeightPrimary = 52.0;
  static const double buttonHeightSecondary = 48.0;
  static const double buttonHeightCompact = 40.0;
  static const double inputHeight = 48.0;
  static const double chipMinHeight = 36.0;
  static const double tapTargetMin = 44.0;
  static const double bottomNavHeight = 72.0;
  static const double cardBorderWidth = 1.5;
  static const double phoneContentMaxWidth = 480.0;

  // --- Z order ---
  static const int zContent = 0;
  static const int zStickyBar = 30;
  static const int zSheet = 40;
  static const int zDialog = 50;
  static const int zToast = 60;
}
