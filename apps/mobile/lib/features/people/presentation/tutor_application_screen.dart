import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../uploads/file_field.dart';
import '../../uploads/upload_repository.dart' as uploads;
import '../application/tutor_application_controller.dart';
import '../data/tutor_application_repository.dart';

/// PE-11 — the six-step application.
///
/// Two rules from the flow decide almost every choice on this screen:
///
/// * **draft-saved each.** Leaving a step saves it, and the screen says so.
///   Nothing here is held only in a `TextEditingController` waiting for a
///   submit that might never come — a six-step form on a phone that loses
///   step 4 is a form nobody finishes;
/// * **blocked submit names every missing item.** The review step lists them
///   all, before the tap, computed by the server. The button is disabled *with*
///   the reason visible rather than disabled and silent.
class TutorApplicationScreen extends ConsumerStatefulWidget {
  const TutorApplicationScreen({super.key});

  @override
  ConsumerState<TutorApplicationScreen> createState() =>
      _TutorApplicationScreenState();
}

class _TutorApplicationScreenState
    extends ConsumerState<TutorApplicationScreen> {
  final _nameEn = TextEditingController();
  final _nameAr = TextEditingController();
  final _headline = TextEditingController();
  final _qualifications = TextEditingController();
  final _subjects = TextEditingController();
  final _rate = TextEditingController();

  /// Answers the text fields cannot hold: an uploaded key is produced by the
  /// server, and the availability grid is a list rather than a string.
  String? _documentKey;
  String? _avatarKey;
  List<AvailabilityWindow> _windows = const [];

  /// Whether the controllers have been filled from the saved draft.
  ///
  /// Once, on the first ready build. Re-seeding on every rebuild would fight
  /// the user for the cursor on each keystroke.
  bool _seeded = false;

  @override
  void dispose() {
    _nameEn.dispose();
    _nameAr.dispose();
    _headline.dispose();
    _qualifications.dispose();
    _subjects.dispose();
    _rate.dispose();
    super.dispose();
  }

  TutorApplicationController get _controller =>
      ref.read(tutorApplicationControllerProvider.notifier);

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final state = ref.watch(tutorApplicationControllerProvider);

    if (state is TutorApplicationReady) _seed(state);

    return GradientBudget(
      screenName: 'tutor-application',
      child: Scaffold(
        appBar: EjadahAppBar(
          title: strings.applyToTeach,
          backLabel: strings.back,
          onBack: () => _leave(state),
        ),
        body: SafeArea(
          top: false,
          child: switch (state) {
            TutorApplicationLoading() => const _FormSkeleton(),
            TutorApplicationFailed(:final failure) => EjadahErrorState(
              title: FailureCopy.errorTitle(context),
              body: failure.message(context),
              retryLabel: strings.retry,
              onRetry: _controller.retry,
            ),
            TutorApplicationReady() => _Form(
              state: state,
              nameEn: _nameEn,
              nameAr: _nameAr,
              headline: _headline,
              qualifications: _qualifications,
              subjects: _subjects,
              rate: _rate,
              documentKey: _documentKey,
              avatarKey: _avatarKey,
              windows: _windows,
              onDocument: (key) => setState(() => _documentKey = key),
              onAvatar: (key) => setState(() => _avatarKey = key),
              onWindows: (windows) => setState(() => _windows = windows),
              onContinue: () => _controller.saveAndAdvance(
                state.step,
                _answersFor(state.step),
              ),
              onBack: () => _back(state),
              onEditStep: (step) => _controller.goTo(step),
              onSubmit: () => _submit(state),
            ),
          },
        ),
      ),
    );
  }

  void _seed(TutorApplicationReady state) {
    if (_seeded) return;
    _seeded = true;

    final basics = state.answersFor(ApplicationStep.basics);
    _nameEn.text = basics['display_name_en'] as String? ?? '';
    _nameAr.text = basics['display_name_ar'] as String? ?? '';
    _headline.text = basics['headline'] as String? ?? '';

    final qualifications = state.answersFor(ApplicationStep.qualifications);
    _qualifications.text = _linesOf(qualifications['items']);
    _documentKey = qualifications['document_key'] as String?;

    _subjects.text = _linesOf(
      state.answersFor(ApplicationStep.subjects)['items'],
    );

    final rate = state.answersFor(ApplicationStep.rate)['hourly_rate_egp'];
    _rate.text = rate is num ? rate.toInt().toString() : '';

    _windows = state.application?.availability ?? const [];
    _avatarKey =
        state.answersFor(ApplicationStep.media)['avatar_key'] as String?;
  }

  /// What the current step would save.
  Map<String, dynamic> _answersFor(ApplicationStep step) => switch (step) {
    ApplicationStep.basics => {
      'display_name_en': _nameEn.text.trim(),
      'display_name_ar': _nameAr.text.trim(),
      'headline': _headline.text.trim(),
    },
    ApplicationStep.qualifications => {
      'items': _itemsOf(_qualifications.text),
      if (_documentKey != null) 'document_key': _documentKey,
    },
    ApplicationStep.subjects => {'items': _itemsOf(_subjects.text)},
    ApplicationStep.rate => {
      'hourly_rate_egp': int.tryParse(_rate.text.trim()) ?? 0,
    },
    ApplicationStep.availability => {
      'rules': _windows.map((window) => window.toJson()).toList(),
    },
    ApplicationStep.media => {if (_avatarKey != null) 'avatar_key': _avatarKey},
  };

  /// Going back a step saves the one being left.
  ///
  /// The same rule as going forward: which direction someone moves has nothing
  /// to do with whether their answer is worth keeping.
  Future<void> _back(TutorApplicationReady state) async {
    if (state.onReview) {
      _controller.goTo(ApplicationStep.media);
      return;
    }
    final previous = ApplicationStep.fromPosition(state.step.position - 1);
    if (previous == null) {
      await _leave(state);
      return;
    }
    await _controller.saveStep(state.step, _answersFor(state.step));
    _controller.goTo(previous);
  }

  /// Leaving the screen saves first, so closing the app mid-step loses nothing.
  Future<void> _leave(TutorApplicationState state) async {
    if (state is TutorApplicationReady && state.isEditable && !state.onReview) {
      await _controller.saveStep(state.step, _answersFor(state.step));
    }
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/teach');
    }
  }

  Future<void> _submit(TutorApplicationReady state) async {
    if (!await _controller.submit()) return;
    if (!mounted) return;
    // Replaces rather than stacks: the form is finished, and a back gesture
    // must not return someone to a draft they can no longer edit.
    context.pushReplacement('/teach/status');
  }

  static String _linesOf(Object? value) =>
      value is List ? value.map((item) => item.toString()).join('\n') : '';

  static List<String> _itemsOf(String text) => text
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
}

class _Form extends StatelessWidget {
  const _Form({
    required this.state,
    required this.nameEn,
    required this.nameAr,
    required this.headline,
    required this.qualifications,
    required this.subjects,
    required this.rate,
    required this.documentKey,
    required this.avatarKey,
    required this.windows,
    required this.onDocument,
    required this.onAvatar,
    required this.onWindows,
    required this.onContinue,
    required this.onBack,
    required this.onEditStep,
    required this.onSubmit,
  });

  final TutorApplicationReady state;
  final TextEditingController nameEn;
  final TextEditingController nameAr;
  final TextEditingController headline;
  final TextEditingController qualifications;
  final TextEditingController subjects;
  final TextEditingController rate;
  final String? documentKey;
  final String? avatarKey;
  final List<AvailabilityWindow> windows;
  final ValueChanged<String> onDocument;
  final ValueChanged<String> onAvatar;
  final ValueChanged<List<AvailabilityWindow>> onWindows;
  final VoidCallback onContinue;
  final VoidCallback onBack;
  final ValueChanged<ApplicationStep> onEditStep;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Column(
      children: [
        EjadahPageBody(
          child: Padding(
            padding: const EdgeInsets.only(top: EjadahSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BookingStepper(
                  currentStep: state.onReview
                      ? ApplicationStep.count
                      : state.step.position,
                  totalSteps: ApplicationStep.count,
                  semanticsLabel: strings.stepOfSteps(
                    state.onReview
                        ? ApplicationStep.count
                        : state.step.position,
                    ApplicationStep.count,
                  ),
                ),
                const SizedBox(height: EjadahSpacing.xs),
                _SaveIndicator(state: state),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: EjadahSpacing.lg),
            children: [
              EjadahPageBody(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: EjadahSpacing.sm),
                    if (!state.isEditable) ...[
                      // Under review: the answers are shown, and the reason the
                      // fields are dead is stated rather than left to be
                      // discovered by tapping them.
                      InlineAlert(
                        message: strings.statusUnderReviewBody,
                        title: strings.statusUnderReview,
                        tone: AlertTone.info,
                      ),
                      const SizedBox(height: EjadahSpacing.md),
                    ],
                    if (state.onReview)
                      _ReviewStep(state: state, onEditStep: onEditStep)
                    else
                      _StepBody(
                        state: state,
                        nameEn: nameEn,
                        nameAr: nameAr,
                        headline: headline,
                        qualifications: qualifications,
                        subjects: subjects,
                        rate: rate,
                        documentKey: documentKey,
                        avatarKey: avatarKey,
                        windows: windows,
                        onDocument: onDocument,
                        onAvatar: onAvatar,
                        onWindows: onWindows,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _ActionBar(
          state: state,
          onContinue: onContinue,
          onBack: onBack,
          onSubmit: onSubmit,
        ),
      ],
    );
  }
}

/// "Saved" — the visible half of the draft promise.
class _SaveIndicator extends StatelessWidget {
  const _SaveIndicator({required this.state});

  final TutorApplicationReady state;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final type = context.type;

    final (label, colour) = switch (state.saveState) {
      SaveState.saving => (strings.applicationSaving, EjadahColors.labelMuted),
      SaveState.saved => (strings.applicationSaved, EjadahColors.successText),
      // A failed save is not a quiet label: it means an answer did not reach
      // the server, which is the one thing this form promises cannot happen.
      SaveState.failed => (
        state.saveFailure?.message(context) ?? strings.retry,
        EjadahColors.dangerText,
      ),
      SaveState.idle => (strings.applicationDraftNote, EjadahColors.labelMuted),
    };

    return Semantics(
      liveRegion: state.saveState != SaveState.idle,
      child: Text(label, style: type.caption(color: colour)),
    );
  }
}

class _StepBody extends StatelessWidget {
  const _StepBody({
    required this.state,
    required this.nameEn,
    required this.nameAr,
    required this.headline,
    required this.qualifications,
    required this.subjects,
    required this.rate,
    required this.documentKey,
    required this.avatarKey,
    required this.windows,
    required this.onDocument,
    required this.onAvatar,
    required this.onWindows,
  });

  final TutorApplicationReady state;
  final TextEditingController nameEn;
  final TextEditingController nameAr;
  final TextEditingController headline;
  final TextEditingController qualifications;
  final TextEditingController subjects;
  final TextEditingController rate;
  final String? documentKey;
  final String? avatarKey;
  final List<AvailabilityWindow> windows;
  final ValueChanged<String> onDocument;
  final ValueChanged<String> onAvatar;
  final ValueChanged<List<AvailabilityWindow>> onWindows;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final enabled = state.isEditable;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(title: _title(strings, state.step)),
        const SizedBox(height: EjadahSpacing.md),
        ...switch (state.step) {
          ApplicationStep.basics => [
            EjadahInput(
              label: strings.fieldNameEn,
              controller: nameEn,
              enabled: enabled,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: EjadahSpacing.md),
            EjadahInput(
              label: strings.fieldNameAr,
              controller: nameAr,
              enabled: enabled,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: EjadahSpacing.md),
            EjadahInput(
              label: strings.fieldHeadline,
              controller: headline,
              hint: strings.fieldHeadlineHint,
              enabled: enabled,
            ),
          ],
          ApplicationStep.qualifications => [
            EjadahInput(
              label: strings.fieldQualifications,
              controller: qualifications,
              helperText: strings.fieldOnePerLine,
              enabled: enabled,
              maxLines: 4,
            ),
            const SizedBox(height: EjadahSpacing.md),
            EjadahFileField(
              label: strings.fieldDocument,
              purpose: uploads.UploadPurpose.document,
              storedKey: documentKey,
              enabled: enabled,
              onUploaded: (file) => onDocument(file.key),
            ),
          ],
          ApplicationStep.subjects => [
            EjadahInput(
              label: strings.fieldSubjects,
              controller: subjects,
              helperText: strings.fieldOnePerLine,
              enabled: enabled,
              maxLines: 4,
            ),
          ],
          ApplicationStep.rate => [
            EjadahInput(
              label: strings.fieldHourlyRate,
              controller: rate,
              enabled: enabled,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: EjadahSpacing.md),
            _RateEstimate(state: state, rate: rate, windows: windows),
          ],
          ApplicationStep.availability => [
            _AvailabilityEditor(
              windows: windows,
              enabled: enabled,
              minimumHours: state.snapshot.minimumWeeklyHours,
              onChanged: onWindows,
            ),
          ],
          ApplicationStep.media => [
            EjadahFileField(
              label: strings.stepMediaTitle,
              purpose: uploads.UploadPurpose.avatar,
              storedKey: avatarKey,
              enabled: enabled,
              onUploaded: (file) => onAvatar(file.key),
            ),
          ],
        },
      ],
    );
  }

  static String _title(EjadahStrings strings, ApplicationStep step) =>
      switch (step) {
        ApplicationStep.basics => strings.stepBasicsTitle,
        ApplicationStep.qualifications => strings.stepQualificationsTitle,
        ApplicationStep.subjects => strings.stepSubjectsTitle,
        ApplicationStep.rate => strings.stepRateTitle,
        ApplicationStep.availability => strings.stepAvailabilityTitle,
        ApplicationStep.media => strings.stepMediaTitle,
      };
}

/// The live earnings estimate on the rate step.
///
/// Says "assumes full booking" without being asked, because a number produced
/// from an empty calendar reads as a promise. The hours come from whatever
/// availability has actually been entered — when none has, the estimate says
/// so rather than inventing a week.
class _RateEstimate extends StatelessWidget {
  const _RateEstimate({
    required this.state,
    required this.rate,
    required this.windows,
  });

  final TutorApplicationReady state;
  final TextEditingController rate;
  final List<AvailabilityWindow> windows;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final type = context.type;

    final hourly = int.tryParse(rate.text.trim()) ?? 0;
    final hours =
        windows.fold(0, (total, window) => total + window.minutes) ~/ 60;
    final share = state.snapshot.professionalSharePercent;

    return EjadahCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            type.eyebrowText(strings.rateEstimateTitle),
            style: type.eyebrow(color: EjadahColors.labelMuted),
          ),
          const SizedBox(height: EjadahSpacing.xs),
          if (hourly <= 0 || hours <= 0)
            Text(
              strings.rateEstimateNeedsHours,
              style: type.bodyText(color: EjadahColors.textSecondary),
            )
          else ...[
            Text(
              strings.rateEstimateWeekly(
                'EGP ${formatThousands(hourly * hours * share ~/ 100)}',
                hours,
                state.snapshot.platformFeePercent,
              ),
              style: type.bodyText(),
            ),
            const SizedBox(height: EjadahSpacing.xxs),
            Text(
              strings.rateEstimateAssumes,
              style: type.caption(color: EjadahColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

/// The availability grid.
///
/// Hours a week, entered as windows rather than as a number, because the number
/// alone cannot be turned into bookable slots — and a tutor who says "ten hours"
/// with no days is a tutor no student can book.
class _AvailabilityEditor extends StatelessWidget {
  const _AvailabilityEditor({
    required this.windows,
    required this.enabled,
    required this.minimumHours,
    required this.onChanged,
  });

  final List<AvailabilityWindow> windows;
  final bool enabled;
  final int minimumHours;
  final ValueChanged<List<AvailabilityWindow>> onChanged;

  static const List<int> _hours = [
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21,
    22,
  ];

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final type = context.type;

    final total = windows.fold(0, (sum, window) => sum + window.minutes) ~/ 60;
    final meetsFloor = total >= minimumHours;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < windows.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: EjadahSpacing.sm),
            child: _WindowRow(
              window: windows[i],
              enabled: enabled,
              hours: _hours,
              onChanged: (window) => onChanged([
                for (var j = 0; j < windows.length; j++)
                  if (j == i) window else windows[j],
              ]),
              onRemove: () => onChanged([
                for (var j = 0; j < windows.length; j++)
                  if (j != i) windows[j],
              ]),
            ),
          ),
        EjadahSecondaryButton(
          label: strings.addWindow,
          expand: false,
          icon: EjadahIcons.calendar,
          onPressed: enabled
              ? () => onChanged([
                  ...windows,
                  const AvailabilityWindow(
                    weekday: 1,
                    startsAt: '17:00',
                    endsAt: '20:00',
                  ),
                ])
              : null,
        ),
        const SizedBox(height: EjadahSpacing.md),
        Text(strings.availabilityWeeklyTotal(total), style: type.bodyText()),
        const SizedBox(height: EjadahSpacing.xxs),
        // Below the floor this is not a suggestion — it is the reason submit
        // will refuse, said here rather than at the end.
        Text(
          strings.availabilityFloorHint(minimumHours),
          style: type.caption(
            color: meetsFloor
                ? EjadahColors.textSecondary
                : EjadahColors.warningText,
          ),
        ),
      ],
    );
  }
}

class _WindowRow extends StatelessWidget {
  const _WindowRow({
    required this.window,
    required this.enabled,
    required this.hours,
    required this.onChanged,
    required this.onRemove,
  });

  final AvailabilityWindow window;
  final bool enabled;
  final List<int> hours;
  final ValueChanged<AvailabilityWindow> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return EjadahCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: EjadahSpacing.xxs,
            runSpacing: EjadahSpacing.xxs,
            children: [
              for (var weekday = 1; weekday <= 7; weekday++)
                EjadahFilterChip(
                  label: _weekdayLabel(context, weekday),
                  isSelected: window.weekday == weekday,
                  onTap: () {
                    if (enabled) onChanged(window.copyWith(weekday: weekday));
                  },
                ),
            ],
          ),
          const SizedBox(height: EjadahSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _HourPicker(
                  label: strings.windowFrom,
                  value: window.startsAt,
                  hours: hours,
                  enabled: enabled,
                  onChanged: (value) =>
                      onChanged(window.copyWith(startsAt: value)),
                ),
              ),
              const SizedBox(width: EjadahSpacing.sm),
              Expanded(
                child: _HourPicker(
                  label: strings.windowTo,
                  value: window.endsAt,
                  hours: hours,
                  enabled: enabled,
                  onChanged: (value) =>
                      onChanged(window.copyWith(endsAt: value)),
                ),
              ),
            ],
          ),
          const SizedBox(height: EjadahSpacing.xs),
          EjadahGhostButton(
            label: strings.removeWindow,
            onPressed: enabled ? onRemove : null,
          ),
        ],
      ),
    );
  }

  /// The weekday's short name, from the locale rather than from seven strings
  /// of our own — `intl` already knows both languages' day names, and a hand
  /// table would be one more thing to keep in sync.
  static String _weekdayLabel(BuildContext context, int weekday) {
    // 1 Jan 2024 was a Monday, which is weekday 1 in both this app and Dart.
    final day = DateTime(2024, 1, weekday);
    return DateFormat.E(context.language.code).format(day);
  }
}

class _HourPicker extends StatelessWidget {
  const _HourPicker({
    required this.label,
    required this.value,
    required this.hours,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<int> hours;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final type = context.type;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          type.eyebrowText(label),
          style: type.eyebrow(color: EjadahColors.labelMuted),
        ),
        const SizedBox(height: EjadahSpacing.xxs),
        DropdownButton<String>(
          value: hours.map(_format).contains(value)
              ? value
              : _format(hours.first),
          isExpanded: true,
          underline: const SizedBox.shrink(),
          onChanged: enabled
              ? (next) {
                  if (next != null) onChanged(next);
                }
              : null,
          items: [
            for (final hour in hours)
              DropdownMenuItem(
                value: _format(hour),
                // A clock time stays LTR in both languages: mixing numeral
                // direction breaks scanning (REGISTER.md).
                child: CodeText(_format(hour), style: type.bodyText()),
              ),
          ],
        ),
      ],
    );
  }

  static String _format(int hour) => '${hour.toString().padLeft(2, '0')}:00';
}

/// The review step: everything that is still missing, all of it, before the tap.
class _ReviewStep extends StatelessWidget {
  const _ReviewStep({required this.state, required this.onEditStep});

  final TutorApplicationReady state;
  final ValueChanged<ApplicationStep> onEditStep;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final type = context.type;
    final missing = state.missing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(title: strings.reviewStepTitle),
        const SizedBox(height: EjadahSpacing.md),
        if (missing.isEmpty)
          InlineAlert(message: strings.nothingMissing, tone: AlertTone.success)
        else ...[
          SectionHeader(title: strings.stillNeededTitle),
          const SizedBox(height: EjadahSpacing.xs),
          Text(
            strings.stillNeededCount(missing.length),
            style: type.bodyText(color: EjadahColors.textSecondary),
          ),
          const SizedBox(height: EjadahSpacing.sm),
          // Every one of them, each a tap away from the step that fixes it.
          // The alternative — one message naming the first — is the thing that
          // makes a six-step form take six attempts.
          for (final item in missing)
            EjadahListRow(
              title: item.label(context),
              subtitle: strings.stepOfSteps(
                item.step.position,
                ApplicationStep.count,
              ),
              leading: const Icon(
                EjadahIcons.warning,
                size: EjadahIconSize.inline,
                color: EjadahColors.warningText,
              ),
              onTap: () => onEditStep(item.step),
            ),
        ],
        if (state.saveFailure != null) ...[
          const SizedBox(height: EjadahSpacing.md),
          InlineAlert(
            message: state.saveFailure!.message(context),
            tone: AlertTone.danger,
          ),
        ],
      ],
    );
  }
}

/// The sticky bar. The action is always reachable without scrolling to it.
class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.state,
    required this.onContinue,
    required this.onBack,
    required this.onSubmit,
  });

  final TutorApplicationReady state;
  final VoidCallback onContinue;
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return EjadahStickyBar(
      // The reason sits above the button rather than only behind a tap on it.
      reason: state.onReview && !state.canSubmit
          ? strings.submitBlockedReason
          : null,
      child: Row(
        children: [
          Expanded(
            child: EjadahSecondaryButton(
              label: strings.back,
              onPressed: onBack,
            ),
          ),
          const SizedBox(width: EjadahSpacing.sm),
          Expanded(
            flex: 2,
            child: state.onReview
                ? EjadahPrimaryButton(
                    label: strings.submitApplication,
                    isLoading: state.submitting,
                    onPressed: state.canSubmit && state.isEditable
                        ? onSubmit
                        : null,
                    disabledReason: strings.submitBlockedReason,
                    onDisabledTap: (reason) =>
                        showEjadahToast(context, message: reason),
                  )
                : EjadahPrimaryButton(
                    label: strings.nextStep,
                    isLoading: state.saveState == SaveState.saving,
                    onPressed: state.isEditable ? onContinue : null,
                    disabledReason: strings.statusUnderReviewBody,
                    onDisabledTap: (reason) =>
                        showEjadahToast(context, message: reason),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FormSkeleton extends StatelessWidget {
  const _FormSkeleton();

  @override
  Widget build(BuildContext context) => EjadahPageBody(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: EjadahSpacing.md),
        const Skeleton(width: double.infinity, height: 4),
        const SizedBox(height: EjadahSpacing.lg),
        const Skeleton(width: 160, height: 28),
        const SizedBox(height: EjadahSpacing.lg),
        for (var i = 0; i < 3; i++)
          const Padding(
            padding: EdgeInsets.only(bottom: EjadahSpacing.md),
            child: Skeleton(width: double.infinity, height: 56),
          ),
      ],
    ),
  );
}
