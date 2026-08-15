import 'package:ejadah_models/ejadah_models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../tokens/ejadah_tokens.dart';
import '../tokens/ejadah_typography.dart';

/// The Ejadah design system, carried through the widget tree.
///
/// Reached as `context.ejadah`. Material 3 may power widget internals, but every
/// visual value comes from here — the product must not ship default-Material
/// aesthetics arranged to look like Ejadah.
@immutable
class EjadahTokens extends ThemeExtension<EjadahTokens> {
  const EjadahTokens({
    required this.language,
    required this.typography,
    required this.windowClass,
    required this.reduceMotion,
  });

  final AppLanguage language;
  @override
  Object get type => EjadahTokens;

  /// The resolved type system for this language.
  final EjadahTypography typography;
  final EjadahWindowClass windowClass;

  /// Mirrors the platform's reduce-motion setting. Read through
  /// [EjadahMotion.durationFor] rather than branched on per animation.
  final bool reduceMotion;

  TextDirection get textDirection =>
      language.isRtl ? TextDirection.rtl : TextDirection.ltr;

  LinearGradient get gradient => EjadahGradient.of(textDirection);

  /// The page gutter at this width.
  double get gutter => windowClass.gutter;

  Duration motion(Duration requested) =>
      EjadahMotion.durationFor(requested, reduceMotion: reduceMotion);

  @override
  EjadahTokens copyWith({
    AppLanguage? language,
    EjadahTypography? typography,
    EjadahWindowClass? windowClass,
    bool? reduceMotion,
  }) => EjadahTokens(
    language: language ?? this.language,
    typography: typography ?? this.typography,
    windowClass: windowClass ?? this.windowClass,
    reduceMotion: reduceMotion ?? this.reduceMotion,
  );

  /// The tokens are discrete design decisions, not interpolable values: a
  /// half-way language or breakpoint is meaningless, so this snaps.
  @override
  EjadahTokens lerp(covariant EjadahTokens? other, double t) =>
      t < 0.5 ? this : (other ?? this);
}

extension EjadahThemeAccess on BuildContext {
  /// The Ejadah design system for this subtree.
  EjadahTokens get ejadah => Theme.of(this).extension<EjadahTokens>()!;

  /// Shorthand for the resolved type system.
  EjadahTypography get type => ejadah.typography;
}

/// Builds the app theme for a language and window size.
///
/// Material's own colour and text themes are populated so that any Material
/// internals a component leans on already look like Ejadah, rather than needing
/// to be overridden individually.
ThemeData buildEjadahTheme({
  required AppLanguage language,
  required EjadahWindowClass windowClass,
  bool reduceMotion = false,
}) {
  final type = EjadahTypography(language);

  final scheme = ColorScheme.fromSeed(
    seedColor: EjadahColors.orange,
    surface: EjadahColors.background,
    primary: EjadahColors.orange,
    onPrimary: EjadahColors.onDark,
    secondary: EjadahColors.gold,
    error: EjadahColors.danger,
    onSurface: EjadahColors.textPrimary,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: EjadahColors.background,
    fontFamily: type.bodyFamily,
    splashFactory: NoSplash.splashFactory,
    // Swipe-back on every pushed route, on every platform.
    //
    // Android's default (`ZoomPageTransitionsBuilder`) has no drag-to-dismiss
    // at all, so on the phones most of this product's users hold, the only way
    // out of a screen was the system back button or the app bar's arrow. An
    // interior screen you cannot swipe out of is the single most-felt piece of
    // friction in a deep app, and this is a marketplace with a lot of interior
    // screens.
    //
    // Cupertino's builder honours [Directionality], so in Arabic the gesture
    // starts at the right edge — the side the language reads back towards.
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        for (final platform in TargetPlatform.values)
          platform: const CupertinoPageTransitionsBuilder(),
      },
    ),
    // Ejadah acknowledges a press by scaling the control and firing a haptic;
    // a Material ink ripple is a different design language.
    highlightColor: Colors.transparent,
    textTheme:
        TextTheme(
          displayLarge: type.display(),
          headlineLarge: type.h1(),
          headlineMedium: type.h2(),
          headlineSmall: type.h3(),
          titleLarge: type.h4(),
          titleMedium: type.h5(),
          titleSmall: type.h6(),
          bodyLarge: type.bodyLarge(),
          bodyMedium: type.bodyText(),
          bodySmall: type.small(),
          labelLarge: type.button(),
          labelMedium: type.caption(),
          labelSmall: type.micro(),
        ).apply(
          bodyColor: EjadahColors.textPrimary,
          displayColor: EjadahColors.textPrimary,
        ),
    dividerTheme: const DividerThemeData(
      color: EjadahColors.border,
      thickness: 1,
      space: 1,
    ),
    extensions: [
      EjadahTokens(
        language: language,
        typography: type,
        windowClass: windowClass,
        reduceMotion: reduceMotion,
      ),
    ],
  );
}
