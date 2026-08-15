import 'package:flutter/widgets.dart';

import 'tokens.g.dart';

/// Ejadah's colour roles.
///
/// Two of these are load-bearing corrections that older design material got
/// wrong, and both are contrast failures if reintroduced:
///
/// * [brandOrange] is for **fills and icons only** — it measures 2.35:1 on the
///   cream surface and fails AA as text. Orange copy uses [orangeText].
/// * [labelMuted] replaces `#8E8A83`, which measured 2.84–3.28:1 and passed
///   only in a mistaken legacy table. That value is exposed as
///   [RawTokens.bannedMutedLabel] purely so a test can assert it is unused.
abstract final class EjadahColors {
  // Brand
  static const Color red = RawTokens.brandRed;

  /// Fills and icons only. Never text — use [orangeText].
  static const Color orange = RawTokens.brandOrange;
  static const Color amber = RawTokens.brandAmber;
  static const Color gold = RawTokens.brandGold;

  // Surfaces
  static const Color background = RawTokens.surfaceOffWhite;
  static const Color card = RawTokens.surfaceWhite;
  static const Color inset = RawTokens.surfacePaleGray;
  static const Color border = RawTokens.surfaceBorderGray;
  static const Color charcoal = RawTokens.surfaceCharcoal;
  static const Color deep = RawTokens.surfaceDeep;

  /// The persistent offline banner.
  static const Color espresso = RawTokens.surfaceEspresso;

  // Text
  static const Color textPrimary = RawTokens.textPrimary;
  static const Color textSecondary = RawTokens.textSecondary;

  /// Micro labels below 12sp.
  static const Color labelMuted = RawTokens.textLabelMuted;
  static const Color labelStrong = RawTokens.textLabelStrong;

  /// The text-safe orange. Use for any orange copy, at any size.
  static const Color orangeText = RawTokens.textOrangeText;
  static const Color onDark = RawTokens.textOnDark;
  static const Color onDarkMuted = RawTokens.textOnDarkMuted;
  static const Color onDarkFaint = RawTokens.textOnDarkFaint;

  // Semantic
  static const Color success = RawTokens.semanticSuccess;
  static const Color info = RawTokens.semanticInfo;
  static const Color danger = RawTokens.semanticDanger;
  static const Color warningText = RawTokens.semanticWarningText;
  static const Color infoText = RawTokens.semanticInfoText;
  static const Color successText = RawTokens.semanticSuccessText;
  static const Color dangerText = RawTokens.semanticDangerText;

  /// A tint of [colour] over the app background, for chip and alert fills.
  static Color tint(Color colour, [double opacity = 0.08]) =>
      Color.alphaBlend(colour.withValues(alpha: opacity), background);

  /// A lighter tint, for surfaces that carry text at the AA boundary.
  ///
  /// `orangeText` measures 4.83:1 on the plain background, so an 8% orange
  /// tint under it drops to 4.46 and fails. The selected filter chip is the one
  /// place that combination occurs, and lightening the surface is the fix that
  /// keeps the canonical text colour intact.
  static const double subtleTintOpacity = 0.05;
}

/// The spacing scale: 4 · 8 · 12 · 16 · 20 · 24 · 32 · 40 · 48 · 64.
///
/// Nothing else. An 18 or a 22 in a layout is a defect.
abstract final class EjadahSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;

  /// The compact-width page gutter.
  static const double gutter = 20;

  /// The medium-and-up page gutter.
  static const double gutterWide = 24;
  static const double lg = 24;

  /// Between sections on a page.
  static const double section = 32;
  static const double xl = 40;
  static const double xxl = 48;
  static const double xxxl = 64;

  /// Between peer cards in a list.
  static const double cardGap = 12;

  static const List<double> scale = RawTokens.space;
}

/// The radius scale. Cards are [xl] (20) at card level.
abstract final class EjadahRadius {
  static const double xs = RawTokens.radiusXs;
  static const double sm = RawTokens.radiusSm;
  static const double md = RawTokens.radiusMd;
  static const double lg = RawTokens.radiusLg;

  /// Card radius. 18px instances in older material map here.
  static const double xl = RawTokens.radiusXl;

  /// Bottom-sheet top corners.
  static const double xxl = RawTokens.radiusXxl;
  static const double pill = RawTokens.radiusPill;

  static BorderRadius all(double radius) => BorderRadius.circular(radius);

  static const BorderRadius card = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius sheet = BorderRadius.vertical(
    top: Radius.circular(xxl),
  );
}

/// Elevation, expressed as the shadow lists the tokens describe.
abstract final class EjadahElevation {
  static const List<BoxShadow> card = RawTokens.elevationCard;
  static const List<BoxShadow> raised = RawTokens.elevationRaised;
  static const List<BoxShadow> overlay = RawTokens.elevationOverlay;

  /// The warm glow under a primary button.
  static const List<BoxShadow> primaryGlow = RawTokens.elevationPrimaryGlow;

  /// Cast upward by a sticky bottom bar.
  static const List<BoxShadow> stickyTop = RawTokens.elevationStickyTop;
}

/// Opacity constants.
abstract final class EjadahOpacity {
  static const double disabled = RawTokens.opacityDisabled;
  static const double comingSoon = RawTokens.opacityComingSoon;

  /// Applied to the roadmap stages a guest may not read yet.
  static const double blurLocked = RawTokens.opacityBlurLocked;
}

/// Motion.
///
/// Reduced motion suppresses transforms and keeps opacity fades at or below
/// [fast]; [durationFor] applies that rule in one place so no widget has to
/// remember it.
abstract final class EjadahMotion {
  static const Duration fast = Duration(milliseconds: RawTokens.durationMsFast);
  static const Duration base = Duration(milliseconds: RawTokens.durationMsBase);
  static const Duration slow = Duration(milliseconds: RawTokens.durationMsSlow);

  static const Curve curve = Cubic(0.4, 0, 0.2, 1);

  /// How far a pressed control scales down.
  static const double pressScale = RawTokens.pressScale;

  /// Delay between staggered list items, applied once on first appearance.
  static const Duration listStagger = Duration(
    milliseconds: RawTokens.staggerListMs,
  );

  static Duration durationFor(
    Duration requested, {
    required bool reduceMotion,
  }) {
    if (!reduceMotion) return requested;
    return requested > fast ? fast : requested;
  }
}

/// Fluid breakpoints. Device models are never checked — only width.
abstract final class EjadahBreakpoints {
  static const double medium = RawTokens.breakpointMedium;
  static const double expanded = RawTokens.breakpointExpanded;

  static EjadahWindowClass of(double width) {
    if (width >= expanded) return EjadahWindowClass.expanded;
    if (width >= medium) return EjadahWindowClass.medium;
    return EjadahWindowClass.compact;
  }
}

enum EjadahWindowClass {
  compact,
  medium,
  expanded;

  bool get isCompact => this == EjadahWindowClass.compact;

  bool get isAtLeastMedium => this != EjadahWindowClass.compact;

  /// Page gutter for this width.
  double get gutter =>
      isCompact ? EjadahSpacing.gutter : EjadahSpacing.gutterWide;

  /// Columns for card grids: 1 → 2 → 3.
  int get gridColumns => switch (this) {
    EjadahWindowClass.compact => 1,
    EjadahWindowClass.medium => 2,
    EjadahWindowClass.expanded => 3,
  };

  /// Explore tiles: 2-up compact → 4-up expanded.
  int get tileColumns => switch (this) {
    EjadahWindowClass.compact => 2,
    EjadahWindowClass.medium => 3,
    EjadahWindowClass.expanded => 4,
  };
}

/// Icon sizes.
abstract final class EjadahIconSize {
  static const double inline = RawTokens.iconSizeInline;

  /// Inside a badge or a chip, where the label is already small.
  static const double badge = RawTokens.iconSizeBadge;

  /// An adornment beside body text — the outbound-link mark, a clear button.
  static const double adornment = RawTokens.iconSizeAdornment;
  static const double nav = RawTokens.iconSizeNav;
  static const double feature = RawTokens.iconSizeFeature;
}

/// Component sizing.
abstract final class EjadahSizes {
  static const double primaryButtonHeight = RawTokens.buttonHeightPrimary;
  static const double secondaryButtonHeight = RawTokens.buttonHeightSecondary;
  static const double compactButtonHeight = RawTokens.buttonHeightCompact;
  static const double inputHeight = RawTokens.inputHeight;
  static const double chipMinHeight = RawTokens.chipMinHeight;

  /// The minimum interactive target, in both dimensions. One of the two most
  /// felt accessibility rules in the product.
  static const double tapTargetMin = RawTokens.tapTargetMin;
  static const double bottomNavHeight = RawTokens.bottomNavHeight;
  static const double cardBorderWidth = RawTokens.cardBorderWidth;

  /// Phone-style screens stay this narrow even on a wide window.
  static const double phoneContentMaxWidth = RawTokens.phoneContentMaxWidth;

  /// Comfortable reading width for country guides.
  static const double readingMaxWidth = 720;

  /// The numbered step marker on a stage list.
  static const double stepMarkerSize = 28;
}

/// The six things the brand gradient is allowed to be.
///
/// Scarcity is what keeps it premium: at most [EjadahGradient.maxPerScreen]
/// gradient elements may be visible at once, and only for these uses.
enum GradientUse {
  primaryButton,
  logoTile,
  stepMarker,
  headingEmphasisPhrase,
  closingCtaBand,
  activeTabIndicator,
}

/// The Ejadah brand gradient: red → orange → gold.
///
/// The angle mirrors with reading direction (135° LTR, 225° RTL) so the light
/// always comes from the leading edge.
abstract final class EjadahGradient {
  static const int maxPerScreen = RawTokens.gradientMaxPerScreen;

  /// How many numbered step markers may carry the gradient at once.
  ///
  /// One under the screen budget, because a stage list always shares its screen
  /// with at least one other permitted use — the primary button or the closing
  /// CTA band. A list longer than this renders every marker in charcoal rather
  /// than gradient-marking the first few and not the rest: Germany's guide has
  /// seven steps, and a list where markers 1–5 glow and 6–7 do not reads as a
  /// rendering bug, not as restraint.
  static const int maxStepMarkers = maxPerScreen - 1;

  /// Whether a stage list of [total] steps may use the gradient at all.
  static bool allowsStepMarkers(int total) => total <= maxStepMarkers;

  static LinearGradient of(TextDirection direction) {
    final rtl = direction == TextDirection.rtl;
    return LinearGradient(
      colors: RawTokens.gradientStops,
      stops: RawTokens.gradientPositions,
      // 135° runs from the top-leading corner to the bottom-trailing one; the
      // RTL form is its mirror.
      begin: rtl ? Alignment.topRight : Alignment.topLeft,
      end: rtl ? Alignment.bottomLeft : Alignment.bottomRight,
    );
  }

  /// Resolves the gradient for the ambient direction.
  static LinearGradient ofContext(BuildContext context) =>
      of(Directionality.of(context));
}
