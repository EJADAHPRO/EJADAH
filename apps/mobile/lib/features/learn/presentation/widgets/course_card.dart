import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/widgets.dart';

import 'learn_labels.dart';

/// A course in a list.
///
/// The card leads with the department, then the title, then the instructor —
/// the order a dentist scans in. What it never shows is a price: courses are
/// in-app purchase only and the store is the pricing authority, so the app has
/// no number of its own to print. Ownership is shown instead, because "Yours
/// for good" is the thing a returning user is looking for.
class CourseCard extends StatelessWidget {
  const CourseCard({
    required this.course,
    this.onTap,
    this.progress,
    super.key,
  });

  final Course course;
  final VoidCallback? onTap;

  /// 0–1 through the course, where the user has started it.
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final type = context.type;

    return EjadahCard(
      onTap: onTap,
      semanticLabel: course.title(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  type.eyebrowText(departmentLabel(context, course.department)),
                  style: type.eyebrow(color: EjadahColors.orangeText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (course.isOwned)
                EjadahBadge(
                  label: strings.ownedCourse,
                  foreground: EjadahColors.successText,
                  background: EjadahColors.tint(EjadahColors.success),
                  icon: EjadahIcons.check,
                ),
            ],
          ),
          const SizedBox(height: EjadahSpacing.xxs),
          Text(
            course.title(context),
            style: type.h6(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (course.subtitle.isNotEmpty) ...[
            const SizedBox(height: EjadahSpacing.xxs),
            Text(
              course.subtitle(context),
              style: type.small(color: EjadahColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: EjadahSpacing.xs),
          Text(
            course.instructorName(context),
            style: type.caption(color: EjadahColors.labelStrong),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: EjadahSpacing.sm),
          Wrap(
            spacing: EjadahSpacing.xs,
            runSpacing: EjadahSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Counts and durations are Latin-context islands: "6" and "84"
              // must not be reordered by the Arabic paragraph around them.
              _MetaChip(
                icon: EjadahIcons.learn,
                value: '${course.lessonCount}',
                label: strings.lessons,
              ),
              _MetaChip(
                icon: EjadahIcons.clock,
                value: '${course.totalMinutes}',
                label: strings.totalTime,
              ),
              if (course.level.isNotEmpty) EjadahTag(course.level(context)),
              if (course.cpdPoints > 0)
                EjadahBadge(
                  label: strings.incCpd,
                  foreground: EjadahColors.labelStrong,
                  background: EjadahColors.inset,
                  icon: EjadahIcons.certificate,
                ),
            ],
          ),
          if (progress != null && progress! > 0) ...[
            const SizedBox(height: EjadahSpacing.sm),
            _ProgressBar(value: progress!),
          ],
        ],
      ),
    );
  }
}

/// An icon, a number and its unit — the number inside its own island.
class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        icon,
        size: EjadahIconSize.inline - 4,
        color: EjadahColors.labelMuted,
      ),
      const SizedBox(width: EjadahSpacing.xxs),
      LtrIsland(child: Text(value, style: context.type.tabular(fontSize: 12))),
      const SizedBox(width: EjadahSpacing.xxs),
      Text(label, style: context.type.micro(color: EjadahColors.labelMuted)),
    ],
  );
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: EjadahRadius.all(EjadahRadius.pill),
    child: Stack(
      children: [
        Container(height: 6, color: EjadahColors.inset),
        // Progress fills from the reading-start edge, so it mirrors in Arabic.
        FractionallySizedBox(
          widthFactor: value.clamp(0.0, 1.0),
          child: Container(height: 6, color: EjadahColors.orange),
        ),
      ],
    ),
  );
}
