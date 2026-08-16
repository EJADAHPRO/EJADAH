import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/widgets.dart';

import 'learn_labels.dart';

/// One lesson in the curriculum.
///
/// Three states, and the difference between them is never colour alone:
///
/// * **free preview** — lesson one, in every course, labelled "Lesson 1 is
///   free" and playable by anyone;
/// * **unlocked** — the course is owned; a play affordance and any saved
///   position;
/// * **locked** — a padlock and the words "Not included". Tapping it opens the
///   purchase sheet rather than doing nothing, because a disabled control that
///   cannot explain itself is a dead end.
class LessonRow extends StatelessWidget {
  const LessonRow({
    required this.lesson,
    required this.onTap,
    required this.onLockedTap,
    super.key,
  });

  final Lesson lesson;
  final VoidCallback onTap;
  final VoidCallback onLockedTap;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final type = context.type;
    final isLocked = !lesson.isUnlocked;

    return EjadahListRow(
      title: lesson.title(context),
      subtitle: isLocked
          ? strings.notIncluded
          : (lesson.isFreePreview ? strings.lessonOneFree : null),
      onTap: isLocked ? onLockedTap : onTap,
      leading: SizedBox(
        width: 32,
        child: Center(
          child: isLocked
              ? const Icon(
                  EjadahIcons.locked,
                  size: EjadahIconSize.inline,
                  color: EjadahColors.labelMuted,
                )
              : Icon(
                  lesson.isComplete ? EjadahIcons.check : EjadahIcons.play,
                  size: EjadahIconSize.inline,
                  color: lesson.isComplete
                      ? EjadahColors.successText
                      : EjadahColors.textPrimary,
                ),
        ),
      ),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Durations flow left to right in both languages.
          LtrIsland(
            child: Text(
              durationLabel(lesson.durationSeconds),
              style: type.tabular(fontSize: EjadahTypeSize.caption),
            ),
          ),
          if (!isLocked && lesson.positionSeconds > 0 && !lesson.isComplete)
            Text(
              strings.resumeLesson,
              style: type.micro(color: EjadahColors.orangeText),
            ),
        ],
      ),
    );
  }
}
