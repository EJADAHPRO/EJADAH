import 'dart:async';

import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/learn_models.dart';
import 'course_complete_screen.dart';
import 'player_screen.dart';

/// LN-06 · Lesson complete.
///
/// The next lesson starts automatically after five seconds, and the countdown
/// is visible with a cancel beside it. Auto-advance without a way out is the
/// version of this screen that gets complained about: someone who wants to stop
/// after one lesson must be able to, without racing a timer they cannot see.
class LessonCompleteScreen extends ConsumerStatefulWidget {
  const LessonCompleteScreen({
    required this.slug,
    required this.completedLesson,
    required this.completion,
    super.key,
  });

  final String slug;
  final Lesson completedLesson;
  final LessonCompletion completion;

  @override
  ConsumerState<LessonCompleteScreen> createState() =>
      _LessonCompleteScreenState();
}

class _LessonCompleteScreenState extends ConsumerState<LessonCompleteScreen> {
  static const int _autoAdvanceSeconds = 5;

  Timer? _countdown;
  int _remaining = _autoAdvanceSeconds;
  bool _cancelled = false;

  @override
  void initState() {
    super.initState();
    if (widget.completion.nextLesson != null) _start();
  }

  @override
  void dispose() {
    _countdown?.cancel();
    super.dispose();
  }

  void _start() {
    _countdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remaining <= 1) {
        timer.cancel();
        _advance();
        return;
      }
      setState(() => _remaining -= 1);
    });
  }

  void _cancel() {
    _countdown?.cancel();
    setState(() => _cancelled = true);
  }

  void _advance() {
    final next = widget.completion.nextLesson;
    if (next == null || !mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => PlayerScreen(slug: widget.slug, lessonId: next.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final type = context.type;
    final next = widget.completion.nextLesson;
    final progress = widget.completion.progress;

    return GradientBudget(
      screenName: 'lesson-complete',
      child: Scaffold(
        body: SafeArea(
          child: EjadahPageBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: EjadahSpacing.section),
                const Icon(
                  EjadahIcons.check,
                  size: EjadahIconSize.feature,
                  color: EjadahColors.successText,
                ),
                const SizedBox(height: EjadahSpacing.md),
                Text(
                  widget.completedLesson.title(context),
                  style: type.h4(text: widget.completedLesson.title(context)),
                ),
                const SizedBox(height: EjadahSpacing.xs),
                Row(
                  children: [
                    LtrIsland(
                      child: Text(
                        '${progress.completedCount}/${progress.lessonCount}',
                        style: type.tabular(),
                      ),
                    ),
                    const SizedBox(width: EjadahSpacing.xs),
                    Text(
                      strings.lessons,
                      style: type.small(color: EjadahColors.textSecondary),
                    ),
                  ],
                ),
                const Spacer(),
                if (widget.completion.courseComplete)
                  EjadahPrimaryButton(
                    label: strings.incCert,
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (_) => CourseCompleteScreen(slug: widget.slug),
                      ),
                    ),
                  )
                else if (next != null) ...[
                  Text(
                    next.title(context),
                    style: type.bodyStrong(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: EjadahSpacing.sm),
                  EjadahPrimaryButton(
                    // The countdown is visible in the label, never a hidden
                    // timer that fires while the user is reading.
                    label: _cancelled
                        ? strings.continueAction
                        : '${strings.continueAction} · $_remaining',
                    onPressed: _advance,
                  ),
                  const SizedBox(height: EjadahSpacing.xs),
                  if (!_cancelled)
                    EjadahGhostButton(
                      label: strings.cancel,
                      onPressed: _cancel,
                    ),
                ] else
                  EjadahSecondaryButton(
                    label: strings.backToCourse,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                const SizedBox(height: EjadahSpacing.xs),
                EjadahGhostButton(
                  label: strings.back,
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                ),
                const SizedBox(height: EjadahSpacing.section),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
