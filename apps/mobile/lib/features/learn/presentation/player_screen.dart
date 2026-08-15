import 'dart:async';

import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/learn_controllers.dart';
import 'lesson_complete_screen.dart';
import 'widgets/learn_labels.dart';

/// LN-05 · The course player.
///
/// Two behaviours are the whole point of this screen and both are server-backed:
///
/// * **Resume.** Playback starts within ten seconds of where the user stopped —
///   a short rewind for context, never a jump forward — because the position is
///   read from the server rather than from device state, and therefore survives
///   a reinstall.
/// * **Checkpointing.** The position is written about every five seconds, and
///   once more when the screen closes, so a killed app loses seconds rather
///   than a session.
///
/// The transport controls never mirror in Arabic: a flipped play triangle reads
/// as broken rather than as localized, and the scrubber's time always flows
/// left to right.
///
/// **Not yet real playback.** The application has no media dependency, so the
/// surface below advances a playhead on a timer instead of decoding video. The
/// position it produces is real and is stored exactly as a player's would be;
/// swapping in a video widget replaces the surface and leaves the position,
/// resume and completion logic untouched.
class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({required this.slug, required this.lessonId, super.key});

  final String slug;
  final int lessonId;

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen>
    with WidgetsBindingObserver {
  Timer? _ticker;
  int _position = 0;
  bool _isPlaying = false;
  bool _hasResumed = false;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    // Fire-and-forget: the screen is going away, and losing the final
    // checkpoint would cost the user the last few seconds of progress.
    unawaited(
      ref.read(playbackRecorderProvider(widget.lessonId)).flush(_position),
    );
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Backgrounding is the most common way a session ends, so it checkpoints
    // exactly like closing does.
    if (state != AppLifecycleState.resumed) {
      _pause();
      unawaited(
        ref.read(playbackRecorderProvider(widget.lessonId)).flush(_position),
      );
    }
  }

  void _resumeFrom(Lesson lesson) {
    if (_hasResumed) return;
    _hasResumed = true;
    _position = ref
        .read(playbackRecorderProvider(widget.lessonId))
        .resumeFrom(lesson.positionSeconds);
  }

  void _togglePlay(Lesson lesson) {
    if (_isPlaying) {
      _pause();
      return;
    }
    setState(() => _isPlaying = true);
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final next = _position + 1;
      if (next >= lesson.durationSeconds) {
        setState(() => _position = lesson.durationSeconds);
        _pause();
        unawaited(_complete(lesson));
        return;
      }
      setState(() => _position = next);
      unawaited(
        ref.read(playbackRecorderProvider(widget.lessonId)).save(_position),
      );
    });
  }

  void _pause() {
    _ticker?.cancel();
    _ticker = null;
    if (mounted && _isPlaying) setState(() => _isPlaying = false);
  }

  Future<void> _complete(Lesson lesson) async {
    if (_isCompleting) return;
    _isCompleting = true;
    _pause();

    try {
      final completion = await ref
          .read(playbackRecorderProvider(widget.lessonId))
          .repository
          .completeLesson(lesson.id, positionSeconds: lesson.durationSeconds);
      ref.invalidate(courseDetailProvider(widget.slug));
      if (!mounted) return;

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => LessonCompleteScreen(
            slug: widget.slug,
            completedLesson: lesson,
            completion: completion,
          ),
        ),
      );
    } on Failure catch (failure) {
      _isCompleting = false;
      if (!mounted) return;
      showEjadahToast(context, message: failure.message(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final detail = ref.watch(courseDetailProvider(widget.slug));

    return GradientBudget(
      screenName: 'course-player',
      child: Scaffold(
        backgroundColor: EjadahColors.charcoal,
        body: SafeArea(
          child: detail.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(EjadahSpacing.gutter),
                child: Skeleton(width: double.infinity, height: 200),
              ),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(EjadahSpacing.gutter),
              child: EjadahErrorState(
                title: FailureCopy.errorTitle(context),
                body: error is Failure
                    ? error.message(context)
                    : FailureCopy.server(context),
                retryLabel: strings.retry,
                onRetry: () =>
                    ref.invalidate(courseDetailProvider(widget.slug)),
              ),
            ),
            data: (data) {
              final lesson = data.lessonAt(widget.lessonId);
              if (lesson == null || !lesson.isUnlocked) {
                return Padding(
                  padding: const EdgeInsets.all(EjadahSpacing.gutter),
                  child: EjadahErrorState(
                    title: strings.notIncluded,
                    body: FailureCopy.contentUnavailable(context),
                    retryLabel: strings.back,
                    onRetry: () => Navigator.of(context).maybePop(),
                  ),
                );
              }
              _resumeFrom(lesson);
              return _Player(
                lesson: lesson,
                position: _position,
                isPlaying: _isPlaying,
                onTogglePlay: () => _togglePlay(lesson),
                onSeek: (value) {
                  setState(() => _position = value);
                  unawaited(
                    ref
                        .read(playbackRecorderProvider(widget.lessonId))
                        .flush(value),
                  );
                },
                onClose: () => Navigator.of(context).maybePop(),
                onFinish: () => _complete(lesson),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Player extends StatelessWidget {
  const _Player({
    required this.lesson,
    required this.position,
    required this.isPlaying,
    required this.onTogglePlay,
    required this.onSeek,
    required this.onClose,
    required this.onFinish,
  });

  final Lesson lesson;
  final int position;
  final bool isPlaying;
  final VoidCallback onTogglePlay;
  final ValueChanged<int> onSeek;
  final VoidCallback onClose;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final type = context.type;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: EjadahSpacing.xs),
          child: Row(
            children: [
              EjadahIconButton(
                icon: EjadahIcons.close,
                semanticLabel: strings.back,
                onPressed: onClose,
                color: EjadahColors.onDark,
              ),
              Expanded(
                child: Text(
                  type.eyebrowText(strings.nowPlaying),
                  style: type.eyebrow(color: EjadahColors.onDarkMuted),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: EjadahSizes.tapTargetMin),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(EjadahSpacing.gutter),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // The play control is a symbol, not a direction: it never
                  // mirrors under right-to-left. It is announced as a toggle
                  // on "now playing" rather than with a made-up verb, so the
                  // label stays inside the approved string table.
                  Semantics(
                    toggled: isPlaying,
                    child: EjadahPressable(
                      onTap: onTogglePlay,
                      semanticLabel: strings.nowPlaying,
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: EjadahColors.onDark.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPlaying ? Icons.pause : EjadahIcons.play,
                          size: EjadahIconSize.feature,
                          color: EjadahColors.onDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: EjadahSpacing.lg),
                  Text(
                    lesson.title(context),
                    style: type.h5(color: EjadahColors.onDark),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(EjadahSpacing.gutter),
          child: Column(
            children: [
              // The scrubber and its times flow left to right in both
              // languages: a timeline is not a paragraph.
              LtrIsland(
                child: Column(
                  children: [
                    Slider(
                      value: position
                          .clamp(0, lesson.durationSeconds)
                          .toDouble(),
                      max: lesson.durationSeconds.toDouble().clamp(
                        1,
                        double.infinity,
                      ),
                      activeColor: EjadahColors.orange,
                      inactiveColor: EjadahColors.onDarkFaint,
                      onChanged: (value) => onSeek(value.round()),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: EjadahSpacing.xs,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            durationLabel(position),
                            style: type.tabular(
                              fontSize: 12,
                              color: EjadahColors.onDarkMuted,
                            ),
                          ),
                          Text(
                            durationLabel(lesson.durationSeconds),
                            style: type.tabular(
                              fontSize: 12,
                              color: EjadahColors.onDarkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: EjadahSpacing.sm),
              EjadahSecondaryButton(label: strings.done, onPressed: onFinish),
            ],
          ),
        ),
      ],
    );
  }
}
