import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/widgets.dart';

/// The canonical programme card.
///
/// One card, used everywhere a programme appears — database, shortlist, country
/// guide crossings, Home. A slightly-different per-screen variant is a defect,
/// which is why the save affordance and the deadline badge are parameters of
/// this widget rather than local re-implementations.
class ProgrammeCard extends StatelessWidget {
  const ProgrammeCard({
    required this.programme,
    required this.onTap,
    this.onToggleSave,
    this.isCompareSelected,
    this.onToggleCompare,
    super.key,
  });

  final ProgrammeSummary programme;
  final VoidCallback onTap;

  /// Null for a guest: saving is one of the five gates, and the card shows the
  /// heart only where tapping it can actually do something.
  final VoidCallback? onToggleSave;
  final bool? isCompareSelected;
  final VoidCallback? onToggleCompare;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final type = context.type;

    return EjadahCard(
      onTap: onTap,
      semanticLabel: '${programme.university} — ${programme.programmeName}',
      isSelected: isCompareSelected ?? false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // University names stay Latin in both languages.
                    CodeText(
                      programme.university,
                      style: type.caption(color: EjadahColors.labelMuted),
                    ),
                    const SizedBox(height: EjadahSpacing.xxs),
                    Text(
                      programme.programmeName,
                      style: type.h6(),
                      // Card titles ellipsise at one line; figures never do.
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (onToggleSave != null)
                EjadahIconButton(
                  // Filled only when saved — the one heart treatment in the
                  // product.
                  icon: programme.isSaved
                      ? EjadahIcons.saveFilled
                      : EjadahIcons.save,
                  semanticLabel: programme.isSaved
                      ? strings.savedProg
                      : strings.saveProg,
                  color: programme.isSaved
                      ? EjadahColors.red
                      : EjadahColors.labelMuted,
                  onPressed: onToggleSave,
                ),
            ],
          ),
          const SizedBox(height: EjadahSpacing.xs),
          Text(
            '${programme.city} · ${programme.country}',
            style: type.small(color: EjadahColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: EjadahSpacing.sm),
          Wrap(
            spacing: EjadahSpacing.xs,
            runSpacing: EjadahSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              DeadlineBadge(
                status: programme.deadlineStatus,
                daysRemaining: programme.daysRemaining,
                // The count is substituted by the localization, never
                // concatenated here: Arabic has six plural forms and a
                // concatenated fragment can only ever pick one of them.
                closingSoonLabel: strings.daysLeftCount(
                  programme.daysRemaining ?? 0,
                ),
                openLabel: strings.openNow,
                closedLabel: strings.closed,
              ),
              if (programme.degreeType.isNotEmpty)
                EjadahTag(programme.degreeType),
              if (programme.tuitionUsd != null)
                CurrencyText(
                  amount: programme.tuitionUsd!,
                  currency: 'USD',
                  style: type.tabular(fontSize: EjadahTypeSize.caption),
                )
              else
                // An unrecorded tuition is a real state. It is never rendered as
                // zero or as a blank.
                PendingSourceChip(label: strings.pendingSource),
            ],
          ),
        ],
      ),
    );
  }
}
