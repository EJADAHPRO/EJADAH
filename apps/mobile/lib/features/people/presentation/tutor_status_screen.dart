import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../profile/presentation/widgets/profile_widgets.dart';
import '../application/tutor_application_controller.dart';
import '../data/tutor_application_repository.dart';

/// PE-12 — where the application stands, and what to do once it is approved.
///
/// Under review, the screen keeps the promise the pitch made: a reply within
/// three working days, said again here rather than left as something the
/// applicant has to remember reading.
///
/// Approved, it stops being a status screen. "You're approved" on its own
/// leaves someone with a live profile and no idea what produces a first
/// student, which is how a marketplace ends up with tutors who never get
/// booked and conclude the product does not work.
class TutorStatusScreen extends ConsumerWidget {
  const TutorStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final state = ref.watch(tutorApplicationControllerProvider);

    return GradientBudget(
      screenName: 'tutor-status',
      child: Scaffold(
        appBar: EjadahAppBar(
          title: strings.applicationTitle,
          backLabel: strings.back,
          onBack: () =>
              context.canPop() ? context.pop() : context.go('/people'),
        ),
        body: SafeArea(
          top: false,
          child: switch (state) {
            TutorApplicationLoading() => const _StatusSkeleton(),
            TutorApplicationFailed(:final failure) => EjadahErrorState(
              title: FailureCopy.errorTitle(context),
              body: failure.message(context),
              retryLabel: strings.retry,
              onRetry: ref
                  .read(tutorApplicationControllerProvider.notifier)
                  .retry,
            ),
            TutorApplicationReady(:final application) => application == null
                // Nothing has been sent. Not an error and not an empty box:
                // the way in is the answer.
                ? EjadahEmptyState(
                    title: strings.becomeTitle,
                    body: strings.teachLead,
                    actionLabel: strings.teachStart,
                    onAction: () => context.go('/teach'),
                  )
                : _Status(
                    application: application,
                    minimumWeeklyHours: state.snapshot.minimumWeeklyHours,
                  ),
          },
        ),
      ),
    );
  }
}

class _Status extends ConsumerWidget {
  const _Status({
    required this.application,
    required this.minimumWeeklyHours,
  });

  final TutorApplication application;

  /// The floor the playbook's first action names. From the server, not from
  /// this file — the number the application enforces and the number the
  /// playbook asks for have to be the same number.
  final int minimumWeeklyHours;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final type = context.type;

    final (title, body, tone) = switch (application.status) {
      ProfessionalStatus.underReview => (
        strings.statusUnderReview,
        strings.statusUnderReviewBody,
        AlertTone.info,
      ),
      ProfessionalStatus.approved => (
        strings.statusApproved,
        strings.statusApprovedBody,
        AlertTone.success,
      ),
      ProfessionalStatus.rejected => (
        strings.statusRejected,
        strings.statusRejectedBody,
        AlertTone.warning,
      ),
      _ => (
        strings.statusUnderReview,
        strings.statusUnderReviewBody,
        AlertTone.info,
      ),
    };

    final isApproved = application.status == ProfessionalStatus.approved;

    return ListView(
      padding: const EdgeInsets.only(bottom: EjadahSpacing.xxl),
      children: [
        EjadahPageBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: EjadahSpacing.md),
              InlineAlert(title: title, message: body, tone: tone),
              if (application.submittedAt != null) ...[
                const SizedBox(height: EjadahSpacing.sm),
                Text(
                  strings.statusSentOn(
                    formatCertificateDate(
                      application.submittedAt!,
                      context.language,
                    ),
                  ),
                  style: type.caption(color: EjadahColors.textSecondary),
                ),
              ],

              // The reviewer's reason, verbatim. A rejection with no reason is
              // a rejection nobody can act on.
              if (application.rejectionReason != null) ...[
                const SizedBox(height: EjadahSpacing.md),
                EjadahCard(
                  child: Text(
                    application.rejectionReason!,
                    style: type.bodyText(),
                  ),
                ),
              ],

              if (application.isEditable) ...[
                const SizedBox(height: EjadahSpacing.lg),
                EjadahPrimaryButton(
                  label: strings.editAndResend,
                  onPressed: () => context.push('/teach/apply'),
                ),
              ],

              if (isApproved) ...[
                const SizedBox(height: EjadahSpacing.lg),
                // The ledger is only reachable once there is one. Offering it
                // to someone still under review would promise a screen that
                // has nothing to show.
                Row(
                  children: [
                    Expanded(
                      child: EjadahSecondaryButton(
                        label: strings.availabilityTitle,
                        onPressed: () => context.push('/teach/hours'),
                      ),
                    ),
                    const SizedBox(width: EjadahSpacing.sm),
                    Expanded(
                      child: EjadahSecondaryButton(
                        label: strings.earningsLink,
                        onPressed: () => context.push('/teach/earnings'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: EjadahSpacing.xl),
                _PlaybookSection(
                  minimumWeeklyHours: minimumWeeklyHours,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// The first-student playbook: three actions, checkable.
class _PlaybookSection extends ConsumerWidget {
  const _PlaybookSection({required this.minimumWeeklyHours});

  final int minimumWeeklyHours;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final type = context.type;
    final playbook = ref.watch(playbookControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: strings.playbookTitle),
        const SizedBox(height: EjadahSpacing.xs),
        Text(
          strings.playbookLead,
          style: type.bodyText(color: EjadahColors.textSecondary),
        ),
        const SizedBox(height: EjadahSpacing.md),
        switch (playbook) {
          AsyncData(:final value) => _PlaybookList(
            playbook: value,
            minimumWeeklyHours: minimumWeeklyHours,
          ),
          AsyncError(:final error) => InlineAlert(
            message: error is Failure
                ? error.message(context)
                : FailureCopy.generic(context),
            tone: AlertTone.warning,
          ),
          _ => const Column(
            children: [
              Skeleton(width: double.infinity, height: 56),
              SizedBox(height: EjadahSpacing.sm),
              Skeleton(width: double.infinity, height: 56),
              SizedBox(height: EjadahSpacing.sm),
              Skeleton(width: double.infinity, height: 56),
            ],
          ),
        },
      ],
    );
  }
}

class _PlaybookList extends ConsumerWidget {
  const _PlaybookList({
    required this.playbook,
    required this.minimumWeeklyHours,
  });

  final Playbook playbook;
  final int minimumWeeklyHours;

  /// The order the actions are worth doing in, not the order a map iterates.
  static const List<String> _order = [
    'set_availability',
    'complete_profile',
    'share_card',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final type = context.type;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.playbookProgress(playbook.done, playbook.total),
          style: type.caption(color: EjadahColors.labelMuted),
        ),
        const SizedBox(height: EjadahSpacing.sm),
        for (final item in _order)
          if (playbook.items.containsKey(item))
            Padding(
              padding: const EdgeInsets.only(bottom: EjadahSpacing.sm),
              child: _PlaybookRow(
                item: item,
                isDone: playbook.isDone(item),
                minimumWeeklyHours: minimumWeeklyHours,
                onComplete: () => _complete(context, ref, item),
              ),
            ),
      ],
    );
  }

  Future<void> _complete(
    BuildContext context,
    WidgetRef ref,
    String item,
  ) async {
    try {
      await ref.read(playbookControllerProvider.notifier).complete(item);
    } on Failure catch (failure) {
      // The optimistic tick has already been rolled back by the controller;
      // this says why, so it does not read as a tap that did nothing.
      if (context.mounted) {
        showEjadahToast(context, message: failure.message(context));
      }
    }
  }
}

class _PlaybookRow extends StatelessWidget {
  const _PlaybookRow({
    required this.item,
    required this.isDone,
    required this.minimumWeeklyHours,
    required this.onComplete,
  });

  final String item;
  final bool isDone;
  final int minimumWeeklyHours;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final type = context.type;

    final label = switch (item) {
      'set_availability' => strings.playbookSetAvailability(minimumWeeklyHours),
      'complete_profile' => strings.playbookCompleteProfile,
      _ => strings.playbookShareCard,
    };

    return EjadahCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            isDone ? EjadahIcons.check : EjadahIcons.empty,
            size: EjadahIconSize.inline,
            color: isDone ? EjadahColors.successText : EjadahColors.labelMuted,
          ),
          const SizedBox(width: EjadahSpacing.sm),
          Expanded(child: Text(label, style: type.bodyText())),
          const SizedBox(width: EjadahSpacing.sm),
          if (isDone)
            Text(
              strings.itemDone,
              style: type.caption(color: EjadahColors.successText),
            )
          else
            EjadahGhostButton(label: strings.markDone, onPressed: onComplete),
        ],
      ),
    );
  }
}

class _StatusSkeleton extends StatelessWidget {
  const _StatusSkeleton();

  @override
  Widget build(BuildContext context) => EjadahPageBody(
    // Scrollable: a skeleton stands in for content that scrolls, and a fixed
    // column of blocks overflows on a short viewport — which paints Flutter's
    // striped overflow bar exactly where a loading state should look calm.
    child: ListView(
      children: const [
        SizedBox(height: EjadahSpacing.md),
        Skeleton(width: double.infinity, height: 80),
        SizedBox(height: EjadahSpacing.lg),
        Skeleton(width: 140, height: 16),
        SizedBox(height: EjadahSpacing.md),
        Skeleton(width: double.infinity, height: 56),
      ],
    ),
  );
}
