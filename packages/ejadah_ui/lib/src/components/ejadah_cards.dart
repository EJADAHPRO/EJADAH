import 'package:flutter/widgets.dart';

import '../foundation/ejadah_pressable.dart';
import '../theme/ejadah_theme.dart';
import '../tokens/ejadah_tokens.dart';

/// The base Ejadah card: white, 1.5px border, radius 20, one soft shadow.
///
/// Warm neutrals rather than white-on-grey is what makes the product read as
/// editorial rather than as SaaS, and the card is where that shows most.
/// Pressing scales the card itself, not its contents.
class EjadahCard extends StatelessWidget {
  const EjadahCard({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(EjadahSpacing.md),
    this.semanticLabel,
    this.isSelected = false,
    this.isDimmed = false,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;

  /// A secondary action on the same card — comparison selection, where a card
  /// has one. The tap stays with the card's primary action.
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry padding;
  final String? semanticLabel;

  /// Checked for comparison.
  final bool isSelected;

  /// A coming-soon card: visible, dimmed, and not focusable.
  final bool isDimmed;

  @override
  Widget build(BuildContext context) {
    final Widget card = AnimatedContainer(
      duration: context.ejadah.motion(EjadahMotion.fast),
      curve: EjadahMotion.curve,
      padding: padding,
      decoration: BoxDecoration(
        color: EjadahColors.card,
        borderRadius: EjadahRadius.card,
        border: Border.all(
          color: isSelected ? EjadahColors.orange : EjadahColors.border,
          width: EjadahSizes.cardBorderWidth,
        ),
        boxShadow: EjadahElevation.card,
      ),
      child: child,
    );

    if (isDimmed) {
      return ExcludeSemantics(
        child: Opacity(opacity: EjadahOpacity.comingSoon, child: card),
      );
    }

    if (onTap == null && onLongPress == null) return card;

    return EjadahPressable(
      onTap: onTap,
      onLongPress: onLongPress,
      semanticLabel: semanticLabel,
      isButton: false,
      enforceMinimumTarget: false,
      child: card,
    );
  }
}

/// The charcoal card with a radial gold glow, used for heroes and the guest
/// gate. Its content sits on dark, so it uses the on-dark text roles.
class DarkCard extends StatelessWidget {
  const DarkCard({
    required this.child,
    this.padding = const EdgeInsets.all(EjadahSpacing.lg),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: EjadahColors.charcoal,
      borderRadius: EjadahRadius.card,
      gradient: RadialGradient(
        center: Alignment(0.8, -0.9),
        radius: 1.2,
        // The gold glow, at 20%. Derived from the token rather than
        // transcribed, so a palette change reaches it.
        colors: [
          EjadahColors.gold.withValues(alpha: 0.2),
          EjadahColors.charcoal,
        ],
      ),
    ),
    child: DefaultTextStyle(
      style: context.type.bodyText(color: EjadahColors.onDark),
      child: child,
    ),
  );
}

/// A figure with its label. Used on the tutor dashboard and earnings screens.
class StatCard extends StatelessWidget {
  const StatCard({
    required this.value,
    required this.label,
    this.emphasis,
    super.key,
  });

  /// Pre-formatted, in Western digits.
  final Widget value;
  final String label;
  final Color? emphasis;

  @override
  Widget build(BuildContext context) => EjadahCard(
    padding: const EdgeInsets.all(EjadahSpacing.sm),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        DefaultTextStyle(
          style: context.type.h4(color: emphasis ?? EjadahColors.textPrimary),
          child: value,
        ),
        const SizedBox(height: EjadahSpacing.xxs),
        Text(
          context.type.eyebrowText(label),
          style: context.type.micro(color: EjadahColors.labelMuted),
        ),
      ],
    ),
  );
}

/// A row that is at least 44 tall with a mirrored trailing chevron.
class EjadahListRow extends StatelessWidget {
  const EjadahListRow({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;

  /// Replaces the default chevron.
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => EjadahPressable(
    onTap: onTap,
    isButton: false,
    semanticLabel: title,
    haptic: PressHaptic.selection,
    child: Container(
      constraints: const BoxConstraints(minHeight: EjadahSizes.tapTargetMin),
      padding: const EdgeInsetsDirectional.symmetric(
        vertical: EjadahSpacing.sm,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: EjadahSpacing.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: context.type.bodyStrong(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: context.type.small(
                      color: EjadahColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: EjadahSpacing.sm),
            trailing!,
          ],
        ],
      ),
    ),
  );
}
