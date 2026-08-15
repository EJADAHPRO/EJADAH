import 'package:ejadah_models/ejadah_models.dart';
import 'package:flutter/widgets.dart';

import '../foundation/ejadah_icons.dart';
import '../foundation/ejadah_pressable.dart';
import '../theme/ejadah_theme.dart';
import '../tokens/ejadah_tokens.dart';

/// A small tinted label.
class EjadahBadge extends StatelessWidget {
  const EjadahBadge({
    required this.label,
    required this.foreground,
    required this.background,
    this.icon,
    super.key,
  });

  final String label;
  final Color foreground;
  final Color background;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsetsDirectional.symmetric(
      horizontal: EjadahSpacing.xs,
      vertical: EjadahSpacing.xxs,
    ),
    decoration: BoxDecoration(
      color: background,
      borderRadius: EjadahRadius.all(EjadahRadius.sm),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: EjadahIconSize.inline - 4, color: foreground),
          const SizedBox(width: EjadahSpacing.xxs),
        ],
        Text(label, style: context.type.micro(color: foreground)),
      ],
    ),
  );
}

/// A neutral tag on the inset surface.
class EjadahTag extends StatelessWidget {
  const EjadahTag(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) => EjadahBadge(
    label: label,
    foreground: EjadahColors.labelStrong,
    background: EjadahColors.inset,
  );
}

/// The urgency chip on a programme card.
///
/// Status is never colour alone — the words carry it too, so the state survives
/// a colour-blind reader and a greyscale screenshot.
class DeadlineBadge extends StatelessWidget {
  const DeadlineBadge({
    required this.status,
    required this.daysRemaining,
    required this.closingSoonLabel,
    required this.openLabel,
    required this.closedLabel,
    super.key,
  });

  final DeadlineStatus status;
  final int? daysRemaining;

  /// "{n} days left" with the count already substituted by the caller's
  /// localization — never concatenated here.
  final String closingSoonLabel;
  final String openLabel;
  final String closedLabel;

  @override
  Widget build(BuildContext context) => switch (status) {
    DeadlineStatus.closingSoon => EjadahBadge(
      label: closingSoonLabel,
      foreground: EjadahColors.dangerText,
      background: EjadahColors.tint(EjadahColors.danger),
    ),
    DeadlineStatus.open => EjadahBadge(
      label: openLabel,
      foreground: EjadahColors.successText,
      background: EjadahColors.tint(EjadahColors.success),
    ),
    DeadlineStatus.expired => EjadahBadge(
      label: closedLabel,
      foreground: EjadahColors.labelMuted,
      background: EjadahColors.inset,
    ),
  };
}

/// Verified by Ejadah versus stated by the person claiming it.
///
/// Conflating these is exactly the credibility problem the product exists to
/// solve, so the two states differ in icon, colour *and* wording — never in
/// colour alone, and never with the stated variant borrowing verified styling.
class VerificationBadge extends StatelessWidget {
  const VerificationBadge({
    required this.evidence,
    required this.verifiedLabel,
    required this.statedLabel,
    super.key,
  });

  final CredentialEvidence evidence;

  /// "Verified by Ejadah" / «موثّق من إجادة»
  final String verifiedLabel;

  /// "Stated by the tutor" / «مُقدَّم من المدرّس»
  final String statedLabel;

  @override
  Widget build(BuildContext context) => switch (evidence) {
    CredentialEvidence.verifiedByEjadah => EjadahBadge(
      label: verifiedLabel,
      foreground: EjadahColors.successText,
      background: EjadahColors.tint(EjadahColors.success),
      icon: EjadahIcons.verified,
    ),
    CredentialEvidence.statedByProfessional => EjadahBadge(
      label: statedLabel,
      foreground: EjadahColors.labelStrong,
      background: EjadahColors.inset,
    ),
  };
}

/// The exact words for a fact Ejadah cannot source yet.
///
/// "Pending source" / «بانتظار المصدر» — verbatim, no variants. Never "N/A",
/// never "~$450", never "approximately", never blank. This visible honesty is
/// what makes every other number in the product believable, so the widget takes
/// the string rather than any value at all: there is nothing to accidentally
/// print.
class PendingSourceChip extends StatelessWidget {
  const PendingSourceChip({required this.label, super.key});

  /// Must be the canonical string from the localization table.
  final String label;

  @override
  Widget build(BuildContext context) => EjadahBadge(
    label: label,
    foreground: EjadahColors.warningText,
    background: EjadahColors.tint(EjadahColors.amber, 0.16),
  );
}

/// Renders a [Sourced] fact, or the pending chip when there is nothing to show.
///
/// Routing every sourced value through one widget is what stops a `null` from
/// being formatted into "0" or an empty string somewhere down the line.
class SourcedValue extends StatelessWidget {
  const SourcedValue({
    required this.value,
    required this.pendingLabel,
    this.style,
    super.key,
  });

  final Sourced<String> value;
  final String pendingLabel;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    if (value.isPending) return PendingSourceChip(label: pendingLabel);
    return Directionality(
      // Fees and cost ranges are Latin-context islands.
      textDirection: TextDirection.ltr,
      child: Text(value.value!, style: style ?? context.type.tabular()),
    );
  }
}

/// "{regulator} · Verified on {date}", with an outbound-link affordance.
class SourceLine extends StatelessWidget {
  const SourceLine({
    required this.sourceName,
    required this.verifiedOnLabel,
    this.onOpenSource,
    super.key,
  });

  final String sourceName;

  /// Already-formatted, e.g. "Verified on 12 Jul 2026".
  final String verifiedOnLabel;

  /// Opens the regulator's own site. Null when the record has no source URL —
  /// the line then states the regulator without pretending to link to it.
  final VoidCallback? onOpenSource;

  @override
  Widget build(BuildContext context) {
    final line = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            '$sourceName · $verifiedOnLabel',
            style: context.type.micro(color: EjadahColors.labelMuted),
          ),
        ),
        if (onOpenSource != null) ...[
          const SizedBox(width: EjadahSpacing.xxs),
          const Icon(
            EjadahIcons.externalLink,
            size: EjadahIconSize.inline - 4,
            color: EjadahColors.labelMuted,
          ),
        ],
      ],
    );

    if (onOpenSource == null) return line;
    // An 11sp row is about 20 high; the outbound link under it still needs 44.
    return EjadahPressable(
      onTap: onOpenSource,
      haptic: PressHaptic.selection,
      semanticLabel: sourceName,
      child: line,
    );
  }
}

/// A selectable filter chip.
///
/// Selected state is an orange tint plus an orange border — and the pressed
/// model is `aria-pressed`, so a screen reader announces it as a toggle rather
/// than as a button that does something unknown.
class EjadahFilterChip extends StatelessWidget {
  const EjadahFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.count,
    super.key,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  /// How many results this filter would produce, where known.
  final int? count;

  @override
  Widget build(BuildContext context) => Semantics(
    toggled: isSelected,
    child: EjadahPressable(
      onTap: onTap,
      haptic: PressHaptic.selection,
      isButton: false,
      // 36 is the chip's *visual* height. The target underneath it still has
      // to be 44 — the rule the handoff calls one of the two most-felt.
      semanticLabel: label,
      child: AnimatedContainer(
        duration: context.ejadah.motion(EjadahMotion.fast),
        curve: EjadahMotion.curve,
        constraints: const BoxConstraints(minHeight: EjadahSizes.chipMinHeight),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: EjadahSpacing.sm,
          vertical: EjadahSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              // A lighter tint than the usual 8%: `orangeText` sits at 4.83:1
              // on the plain background, and the standard tint under it drops
              // to 4.46 — below AA. The surface gives way, not the token.
              ? EjadahColors.tint(
                  EjadahColors.orange,
                  EjadahColors.subtleTintOpacity,
                )
              : EjadahColors.card,
          borderRadius: EjadahRadius.all(EjadahRadius.pill),
          border: Border.all(
            color: isSelected ? EjadahColors.orange : EjadahColors.border,
            width: EjadahSizes.cardBorderWidth,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: context.type.caption(
                color: isSelected
                    ? EjadahColors.orangeText
                    : EjadahColors.textPrimary,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: EjadahSpacing.xxs),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  '$count',
                  style: context.type.micro(color: EjadahColors.labelMuted),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
