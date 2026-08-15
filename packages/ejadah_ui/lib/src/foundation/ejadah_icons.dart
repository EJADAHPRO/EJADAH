import 'package:flutter/material.dart';

/// The canonical Ejadah icon map.
///
/// The reference set is Lucide-style outline at 2px stroke. Material's
/// `_outlined` family is the Flutter-bundled equivalent that preserves the
/// visual meaning, weight and placement of each glyph, so the product ships one
/// icon set with no runtime download and no extra dependency.
///
/// Two rules matter more than the glyph choice:
///
/// * **Outline by default.** Filled is reserved for the active nav item, the
///   saved heart and rating stars — nothing else.
/// * **Direction.** Chevrons, arrows, back and send mirror in Arabic; search,
///   star, heart, camera, clock, media play, logos and numbers never do.
///   [mirrorsInRtl] is the single source for that distinction, and
///   [DirectionalIcon] applies it.
///
/// No emoji is ever used as a UI icon.
abstract final class EjadahIcons {
  // Navigation — the five tabs.
  static const IconData home = Icons.home_outlined;
  static const IconData homeFilled = Icons.home;
  static const IconData learn = Icons.school_outlined;
  static const IconData learnFilled = Icons.school;
  static const IconData career = Icons.explore_outlined;
  static const IconData careerFilled = Icons.explore;
  static const IconData people = Icons.people_outline;
  static const IconData peopleFilled = Icons.people;
  static const IconData profile = Icons.person_outline;
  static const IconData profileFilled = Icons.person;

  // Actions.
  static const IconData search = Icons.search;
  static const IconData filter = Icons.tune;
  static const IconData save = Icons.favorite_border;
  static const IconData saveFilled = Icons.favorite;
  static const IconData compare = Icons.balance_outlined;
  static const IconData share = Icons.share_outlined;
  static const IconData edit = Icons.edit_outlined;
  static const IconData close = Icons.close;
  static const IconData download = Icons.download_outlined;
  static const IconData play = Icons.play_arrow;
  static const IconData retry = Icons.refresh;

  // Status and meaning.
  static const IconData bell = Icons.notifications_outlined;
  static const IconData calendar = Icons.calendar_today_outlined;
  static const IconData clock = Icons.schedule;
  static const IconData certificate = Icons.workspace_premium_outlined;
  static const IconData verified = Icons.verified_outlined;
  static const IconData locked = Icons.lock_outline;
  static const IconData offline = Icons.wifi_off_outlined;
  static const IconData warning = Icons.warning_amber_outlined;
  static const IconData externalLink = Icons.open_in_new;
  static const IconData star = Icons.star;
  static const IconData starOutline = Icons.star_border;
  static const IconData check = Icons.check;
  static const IconData empty = Icons.inbox_outlined;

  // Directional — these mirror.
  static const IconData chevronForward = Icons.chevron_right;
  static const IconData chevronBack = Icons.chevron_left;
  static const IconData arrowForward = Icons.arrow_forward;
  static const IconData back = Icons.arrow_back;
  static const IconData send = Icons.send_outlined;

  /// Whether [icon] mirrors under right-to-left.
  ///
  /// Directional affordances mirror because "forward" changes side. Symbols do
  /// not: a mirrored search glyph, clock face or play triangle reads as broken
  /// rather than as localized.
  static bool mirrorsInRtl(IconData icon) =>
      _mirroredCodePoints.contains(icon.codePoint);

  /// Compared by code point because [IconData] overrides equality, which rules
  /// it out as a constant set element.
  ///
  /// Derived from the icon constants above rather than written out as literal
  /// code points, so swapping a glyph cannot silently detach it from the
  /// mirror list.
  static final Set<int> _mirroredCodePoints = {
    chevronForward.codePoint,
    chevronBack.codePoint,
    arrowForward.codePoint,
    back.codePoint,
    send.codePoint,
  };
}

/// An icon that mirrors in Arabic when — and only when — it should.
///
/// Using this instead of a bare [Icon] is what keeps the mirror list in one
/// place; the alternative is a per-call-site judgement that drifts.
class DirectionalIcon extends StatelessWidget {
  const DirectionalIcon(
    this.icon, {
    this.size,
    this.color,
    this.semanticLabel,
    super.key,
  });

  final IconData icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final shouldMirror =
        EjadahIcons.mirrorsInRtl(icon) &&
        Directionality.of(context) == TextDirection.rtl;

    final glyph = Icon(
      icon,
      size: size,
      color: color,
      semanticLabel: semanticLabel,
    );

    if (!shouldMirror) return glyph;
    return Transform.flip(flipX: true, child: glyph);
  }
}
