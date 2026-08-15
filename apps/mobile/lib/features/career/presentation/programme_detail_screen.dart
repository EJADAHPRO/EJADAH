import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../auth/auth_controller.dart';
import '../data/career_repository.dart';

final programmeProvider = AsyncNotifierProvider.family<
  ProgrammeDetailController,
  Programme,
  int
>(ProgrammeDetailController.new);

/// One programme, with the save state the screen can move ahead of the server.
class ProgrammeDetailController
    extends FamilyAsyncNotifier<Programme, int> {
  @override
  Future<Programme> build(int programmeId) =>
      ref.watch(careerRepositoryProvider).programme(programmeId);

  /// Moves the heart without waiting for the round trip.
  void setSaved(bool isSaved, {required Programme of}) {
    state = AsyncData(of.withSummary(of.summary.copyWith(isSaved: isSaved)));
  }
}

/// A programme's full record.
///
/// Facts are dense on purpose: dentists distrust prose, and every figure here
/// is a verbatim database row. Nothing is estimated to fill a gap.
class ProgrammeDetailScreen extends ConsumerWidget {
  const ProgrammeDetailScreen({required this.programmeId, super.key});

  final int programmeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final programme = ref.watch(programmeProvider(programmeId));

    return Scaffold(
      body: SafeArea(
        child: programme.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(EjadahSpacing.gutter),
            child: CardSkeleton(),
          ),
          error: (error, _) => EjadahErrorState(
            title: FailureCopy.errorTitle(context),
            body: error is Failure
                ? error.message(context)
                : FailureCopy.server(context),
            retryLabel: strings.retry,
            onRetry: () => ref.invalidate(programmeProvider(programmeId)),
          ),
          data: (data) => Column(
            children: [
              EjadahAppBar(
                title: data.summary.university,
                onBack: () => context.pop(),
                backLabel: strings.back,
              ),
              Expanded(child: _Body(programme: data)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.programme});

  final Programme programme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final summary = programme.summary;
    final isAuthenticated = ref.watch(authControllerProvider).isAuthenticated;

    return EjadahPageBody(
      child: ListView(
        children: [
          const SizedBox(height: EjadahSpacing.xs),
          Text(summary.programmeName, style: context.type.h3()),
          const SizedBox(height: EjadahSpacing.xs),
          Text(
            '${summary.city} · ${summary.country}',
            style: context.type.bodyText(color: EjadahColors.textSecondary),
          ),
          const SizedBox(height: EjadahSpacing.sm),
          DeadlineBadge(
            status: summary.deadlineStatus,
            daysRemaining: summary.daysRemaining,
            closingSoonLabel: strings.daysLeftCount(
              summary.daysRemaining ?? 0,
            ),
            openLabel: strings.openNow,
            closedLabel: strings.closed,
          ),
          const SizedBox(height: EjadahSpacing.lg),
          SectionHeader(title: strings.keyFacts),
          const SizedBox(height: EjadahSpacing.xs),
          _FactRow(
            label: strings.fTuition,
            value: summary.tuitionUsd == null
                ? null
                : CurrencyText(amount: summary.tuitionUsd!, currency: 'USD'),
          ),
          _FactRow(
            label: strings.fDuration,
            text: programme.studyMode.isEmpty
                ? summary.durationRaw
                : '${summary.durationRaw} · ${programme.studyMode}',
          ),
          _FactRow(label: strings.fIntake, text: programme.intakeMonth),
          _FactRow(label: strings.fLanguage, text: programme.language),
          _FactRow(
            label: strings.fIelts,
            text: programme.ieltsRequirement.isEmpty
                ? null
                : programme.ieltsRequirement,
          ),
          _FactRow(label: strings.fGpa, text: programme.gpaRequirement),
          _FactRow(
            label: strings.fRank,
            text: programme.qsRank == null ? null : '${programme.qsRank}',
          ),
          _FactRow(
            label: strings.fThesis,
            text: switch (programme.thesisRequired) {
              true => strings.yes,
              false => strings.no,
              // "Not stated" and "not required" are different answers, and the
              // record distinguishes them.
              null => null,
            },
          ),
          _FactRow(
            label: strings.fScholarship,
            text: switch (programme.hasScholarship) {
              true => strings.schYes,
              false => strings.schNo,
              null => null,
            },
          ),
          const SizedBox(height: EjadahSpacing.lg),
          // The source data's recognition labels lost their status in
          // extraction, so the app shows nothing rather than guessing.
          InlineAlert(
            title: strings.recognitionLabel,
            message: strings.recognitionBody,
            tone: AlertTone.info,
          ),
          const SizedBox(height: EjadahSpacing.md),
          Text(
            programme.sourceDeadlineText,
            style: context.type.micro(color: EjadahColors.labelMuted),
          ),
          const SizedBox(height: EjadahSpacing.lg),
          EjadahPrimaryButton(
            label: summary.isSaved ? strings.savedProg : strings.saveProg,
            icon: summary.isSaved ? EjadahIcons.saveFilled : EjadahIcons.save,
            onPressed: () => _toggleSave(context, ref, isAuthenticated),
          ),
          const SizedBox(height: EjadahSpacing.section),
        ],
      ),
    );
  }

  Future<void> _toggleSave(
    BuildContext context,
    WidgetRef ref,
    bool isAuthenticated,
  ) async {
    if (!isAuthenticated) {
      // Saving is a gate. The user comes straight back here afterwards.
      await context.push('/sign-up?next=/programme/${programme.id}');
      return;
    }

    final repository = ref.read(careerRepositoryProvider);
    final wasSaved = programme.summary.isSaved;

    // Optimistic, like the list version of the same action. Two screens doing
    // the same thing differently is a defect in itself, and a heart that waits
    // on the network is the one the design explicitly rules out.
    ref
        .read(programmeProvider(programme.id).notifier)
        .setSaved(!wasSaved, of: programme);

    try {
      if (wasSaved) {
        await repository.unsave(programme.id);
      } else {
        await repository.save(programme.id);
        await ref
            .read(analyticsProvider)
            .track(AnalyticsEvents.programmeSaved, {
              'id': programme.id,
              'country': programme.summary.country,
              'days_to_deadline': programme.summary.daysRemaining,
            });
      }
      if (!context.mounted) return;

      showEjadahToast(
        context,
        message: wasSaved
            ? context.strings.undoRemove
            : context.strings.savedToast,
        // Removal is reversible for five seconds, here as in the list.
        undoLabel: wasSaved ? context.strings.undo : null,
        onUndo: wasSaved
            ? () => _toggleSave(context, ref, isAuthenticated)
            : null,
      );
    } on Failure catch (failure) {
      // The heart goes back to what the server still believes.
      ref
          .read(programmeProvider(programme.id).notifier)
          .setSaved(wasSaved, of: programme);
      if (!context.mounted) return;
      showEjadahToast(context, message: failure.message(context));
    }
  }
}

/// One label/value row.
///
/// A value the record does not carry renders "Not listed" — never a blank and
/// never a zero.
class _FactRow extends StatelessWidget {
  const _FactRow({required this.label, this.text, this.value});

  final String label;
  final String? text;
  final Widget? value;

  @override
  Widget build(BuildContext context) {
    final resolved =
        value ??
        Text(
          text == null || text!.isEmpty ? context.strings.notListed : text!,
          style: text == null || text!.isEmpty
              ? context.type.small(color: EjadahColors.labelMuted)
              : context.type.bodyStrong(),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: EjadahSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: context.type.small(color: EjadahColors.labelMuted),
            ),
          ),
          Expanded(child: resolved),
        ],
      ),
    );
  }
}
