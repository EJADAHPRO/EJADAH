import 'package:flutter/widgets.dart';

import '../foundation/ejadah_icons.dart';
import '../foundation/ejadah_pressable.dart';
import '../foundation/gradient_budget.dart';
import '../theme/ejadah_theme.dart';
import '../tokens/ejadah_tokens.dart';
import 'ejadah_buttons.dart';

/// A destination in the bottom navigation.
class EjadahNavDestination {
  const EjadahNavDestination({
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.badgeCount = 0,
  });

  final String label;

  /// Outline, for the inactive state.
  final IconData icon;

  /// Filled — the only place filled icons are used, besides the saved heart and
  /// rating stars.
  final IconData activeIcon;

  /// Drives the 8px dot. Zero hides it.
  final int badgeCount;
}

/// The five-tab bottom navigation.
///
/// Home · Learn · Career · People · Profile. Five, not six: any six-tab
/// structure in older material is legacy, and the prototype's Courses/Connect/
/// Masters labels map onto Learn/People/Career.
///
/// The active indicator is a gradient bar that slides between tabs — one of the
/// six permitted gradient uses, and one of the reasons this is a custom
/// component rather than a restyled Material bar.
class EjadahBottomNav extends StatelessWidget {
  const EjadahBottomNav({
    required this.destinations,
    required this.currentIndex,
    required this.onSelected,
    super.key,
  });

  final List<EjadahNavDestination> destinations;
  final int currentIndex;

  /// Re-tapping the active tab resets that tab to its root; the caller owns
  /// that behaviour because it owns the navigation stacks.
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.ejadah;

    return Container(
      decoration: const BoxDecoration(
        color: EjadahColors.card,
        border: Border(top: BorderSide(color: EjadahColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: EjadahSizes.bottomNavHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tabWidth = constraints.maxWidth / destinations.length;
              return Stack(
                children: [
                  // The indicator travels from the leading edge, which mirrors
                  // with the reading direction rather than being flipped by hand.
                  AnimatedPositionedDirectional(
                    duration: tokens.motion(EjadahMotion.base),
                    curve: EjadahMotion.curve,
                    start: tabWidth * currentIndex,
                    top: 0,
                    width: tabWidth,
                    height: 3,
                    child: Center(
                      child: SizedBox(
                        width: tabWidth * 0.5,
                        height: 3,
                        child: BrandGradient(
                          use: GradientUse.activeTabIndicator,
                          borderRadius: EjadahRadius.all(EjadahRadius.pill),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (var i = 0; i < destinations.length; i++)
                        Expanded(
                          child: _NavItem(
                            destination: destinations[i],
                            isActive: i == currentIndex,
                            onTap: () => onSelected(i),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.isActive,
    required this.onTap,
  });

  final EjadahNavDestination destination;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: isActive,
    button: true,
    label: destination.label,
    child: ExcludeSemantics(
      child: EjadahPressable(
        onTap: onTap,
        haptic: PressHaptic.selection,
        enforceMinimumTarget: false,
        child: SizedBox(
          height: EjadahSizes.bottomNavHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    isActive ? destination.activeIcon : destination.icon,
                    size: EjadahIconSize.nav,
                    color: isActive
                        ? EjadahColors.textPrimary
                        : EjadahColors.labelMuted,
                  ),
                  if (destination.badgeCount > 0)
                    PositionedDirectional(
                      end: -2,
                      top: -2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: EjadahColors.danger,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: EjadahColors.card,
                            width: EjadahSizes.cardBorderWidth,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: EjadahSpacing.xxs),
              Text(
                destination.label,
                style: context.type.micro(
                  color: isActive
                      ? EjadahColors.textPrimary
                      : EjadahColors.labelMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// The Ejadah app bar. The back affordance mirrors in Arabic.
class EjadahAppBar extends StatelessWidget implements PreferredSizeWidget {
  const EjadahAppBar({
    required this.title,
    this.onBack,
    required this.backLabel,
    this.action,
    super.key,
  });

  final String title;

  /// Null hides the back affordance. Back is never the only way back — every
  /// screen also has an edge swipe and a route out of its content.
  final VoidCallback? onBack;
  /// Required rather than defaulted to 'Back': an icon-only control with an
  /// English default is a label nobody notices is wrong.
  final String backLabel;
  final Widget? action;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) => Container(
    height: 56,
    padding: const EdgeInsetsDirectional.symmetric(
      horizontal: EjadahSpacing.xs,
    ),
    color: EjadahColors.background,
    child: Row(
      children: [
        if (onBack != null)
          EjadahIconButton(
            // Points "back in reading order", so it flips under RTL.
            icon: EjadahIcons.chevronBack,
            semanticLabel: backLabel,
            onPressed: onBack,
          )
        else
          const SizedBox(width: EjadahSpacing.sm),
        Expanded(
          child: Text(
            title,
            style: context.type.h6(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (action != null) action!,
      ],
    ),
  );
}

/// Eyebrow, title and optional subtitle at the top of a page.
class PageHeader extends StatelessWidget {
  const PageHeader({
    required this.title,
    this.eyebrow,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? eyebrow;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final type = context.type;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (eyebrow != null) ...[
          Text(
            type.eyebrowText(eyebrow!),
            style: type.eyebrow(color: EjadahColors.orangeText),
          ),
          const SizedBox(height: EjadahSpacing.xs),
        ],
        // The Arabic long-heading rule is applied by passing the text in, so
        // the reduction happens centrally rather than per screen.
        Text(title, style: type.h2(text: title)),
        if (subtitle != null) ...[
          const SizedBox(height: EjadahSpacing.xs),
          Text(
            subtitle!,
            style: type.bodyText(color: EjadahColors.textSecondary),
          ),
        ],
      ],
    );
  }
}

/// A section eyebrow with an optional "See all".
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          context.type.eyebrowText(title),
          style: context.type.eyebrow(color: EjadahColors.labelMuted),
        ),
      ),
      if (actionLabel != null && onAction != null)
        // 12sp plus 8 of padding is about 33. "See all" is a real destination
        // and gets a real target.
        EjadahPressable(
          onTap: onAction,
          haptic: PressHaptic.selection,
          semanticLabel: actionLabel,
          child: Padding(
            padding: const EdgeInsets.all(EjadahSpacing.xs),
            child: Text(
              actionLabel!,
              style: context.type.caption(color: EjadahColors.orangeText),
            ),
          ),
        ),
    ],
  );
}

/// Constrains phone-style content and applies the width-appropriate gutter.
class EjadahPageBody extends StatelessWidget {
  const EjadahPageBody({
    required this.child,
    this.maxWidth = EjadahSizes.phoneContentMaxWidth,
    super.key,
  });

  final Widget child;

  /// Guides use [EjadahSizes.readingMaxWidth] instead.
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: context.ejadah.gutter,
        ),
        child: child,
      ),
    ),
  );
}
