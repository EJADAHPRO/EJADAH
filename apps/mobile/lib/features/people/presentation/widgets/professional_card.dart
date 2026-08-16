import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';

/// A professional's avatar.
///
/// **Always initials.** No licensed photograph exists for any professional in
/// this release, so there is no image to load, nothing to 404, and no stock
/// portrait pretending to be a real dentist. Initials on the inset surface are
/// the designed state, not a fallback waiting to be replaced — and when real
/// photographs are licensed, [avatarUrl] is the one place that changes.
class ProfessionalAvatar extends StatelessWidget {
  const ProfessionalAvatar({
    required this.name,
    this.avatarUrl,
    this.size = 48,
    super.key,
  });

  final String name;

  /// Reserved for licensed photography. Null everywhere today.
  final String? avatarUrl;
  final double size;

  /// Up to two initials, taken from the name in the language being read.
  static String initialsFor(String name) {
    final words = name
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        // "Dr." is a title, not a name: "Dr. Mona Adel" reads as MA, not DM.
        .where(
          (word) =>
              !RegExp(r'^(dr\.?|د\.?)$', caseSensitive: false).hasMatch(word),
        )
        .toList();
    if (words.isEmpty) return '';
    if (words.length == 1) return words.first.characters.take(1).toString();
    return words.first.characters.take(1).toString() +
        words[1].characters.take(1).toString();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: EjadahColors.inset,
        borderRadius: EjadahRadius.all(EjadahRadius.lg),
      ),
      child: Text(
        initialsFor(name),
        style: context.type.bodyStrong(color: EjadahColors.labelStrong),
      ),
    ),
  );
}

/// A professional as they appear in a list, a rail or a profile hero.
///
/// A mentor's card leads with the journey — "Cairo → London · 2021" — rather
/// than with a rating, because "someone who made my exact move" is what the
/// mentoring door is for. A tutor's leads with the specialty.
///
/// Someone with no reviews shows a "New this month" badge rather than an empty
/// row of stars: a blank rating reads as a bad rating, and burying every new
/// professional is how a marketplace fails to start.
class ProfessionalCard extends StatelessWidget {
  const ProfessionalCard({
    required this.professional,
    required this.onTap,
    this.onBook,
    super.key,
  });

  final Professional professional;
  final VoidCallback onTap;

  /// Shown as a secondary action in list contexts. Null in the rail, where the
  /// card is the whole target.
  final VoidCallback? onBook;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final name = professional.displayName(context);

    return EjadahCard(
      onTap: onTap,
      semanticLabel: name,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfessionalAvatar(name: name, avatarUrl: professional.avatarUrl),
              const SizedBox(width: EjadahSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: context.type.h6(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: EjadahSpacing.xxs),
                    _LeadLine(professional: professional),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: EjadahSpacing.sm),
          Wrap(
            spacing: EjadahSpacing.xs,
            runSpacing: EjadahSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (professional.showsNewBadge)
                EjadahBadge(
                  label: strings.newThisMonth,
                  foreground: EjadahColors.orangeText,
                  background: EjadahColors.tint(EjadahColors.orange),
                )
              else
                _Rating(
                  rating: professional.rating,
                  reviewCount: professional.reviewCount,
                ),
              if (professional.offersFreeIntroCall)
                EjadahBadge(
                  label: strings.freeIntroCall,
                  foreground: EjadahColors.successText,
                  background: EjadahColors.tint(EjadahColors.success),
                ),
              for (final specialty in professional.specialties.take(2))
                EjadahTag(specialty),
            ],
          ),
          const SizedBox(height: EjadahSpacing.sm),
          Row(
            children: [
              // Never an inline price string: the code and the figure are one
              // LTR island in both languages.
              CurrencyText(
                amount: professional.hourlyRateEgp,
                currency: 'EGP',
                style: context.type.bodyStrong(),
              ),
              const SizedBox(width: EjadahSpacing.xxs),
              Flexible(
                child: Text(
                  strings.perHourRate,
                  style: context.type.micro(color: EjadahColors.labelMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              if (onBook != null)
                EjadahGhostButton(
                  label: strings.bookNow,
                  onPressed: onBook,
                  color: EjadahColors.orangeText,
                )
              else
                const DirectionalIcon(
                  EjadahIcons.chevronForward,
                  size: EjadahIconSize.inline,
                  color: EjadahColors.labelMuted,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The journey for a mentor, the headline for everyone else.
class _LeadLine extends StatelessWidget {
  const _LeadLine({required this.professional});

  final Professional professional;

  @override
  Widget build(BuildContext context) {
    final style = context.type.small(color: EjadahColors.textSecondary);

    if (professional.hasJourney) {
      // Place names and the year are a Latin-context run: "Cairo → London ·
      // 2021" must not reorder inside an Arabic card.
      return LtrIsland(
        child: Text(
          '${professional.journeyFrom} → ${professional.journeyTo}'
          '${professional.journeyYear == null ? '' : ' · ${professional.journeyYear}'}',
          style: style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    return Text(
      professional.headline(context),
      style: style,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Stars plus the count, as one LTR run.
///
/// The number is never colour-alone or icon-alone: "4.8" and "12 reviews" both
/// appear, so the standing survives a greyscale screenshot.
class _Rating extends StatelessWidget {
  const _Rating({required this.rating, required this.reviewCount});

  final double? rating;
  final int reviewCount;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      // A star never mirrors.
      const Icon(
        EjadahIcons.star,
        size: EjadahIconSize.inline - 2,
        color: EjadahColors.amber,
      ),
      const SizedBox(width: EjadahSpacing.xxs),
      LtrIsland(
        child: Text(
          rating == null ? '—' : rating!.toStringAsFixed(1),
          style: context.type.caption(),
        ),
      ),
      const SizedBox(width: EjadahSpacing.xxs),
      Text(
        context.strings.reviewsCount(reviewCount),
        style: context.type.micro(color: EjadahColors.labelMuted),
      ),
    ],
  );
}

/// A skeleton in the shape of a [ProfessionalCard].
class ProfessionalCardSkeleton extends StatelessWidget {
  const ProfessionalCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(EjadahSpacing.md),
    decoration: BoxDecoration(
      color: EjadahColors.card,
      borderRadius: EjadahRadius.card,
      border: Border.all(
        color: EjadahColors.border,
        width: EjadahSizes.cardBorderWidth,
      ),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Skeleton(width: 48, height: 48),
            SizedBox(width: EjadahSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton(width: 140, height: 16),
                  SizedBox(height: EjadahSpacing.xs),
                  Skeleton(width: 180, height: 12),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: EjadahSpacing.sm),
        Row(
          children: [
            Skeleton(width: 72, height: 20),
            SizedBox(width: EjadahSpacing.xs),
            Skeleton(width: 88, height: 20),
          ],
        ),
        SizedBox(height: EjadahSpacing.sm),
        Skeleton(width: 120, height: 16),
      ],
    ),
  );
}
