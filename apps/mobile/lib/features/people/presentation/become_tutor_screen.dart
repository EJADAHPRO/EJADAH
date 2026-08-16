import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/auth_controller.dart';
import '../application/tutor_application_controller.dart';
import '../data/tutor_application_repository.dart';

/// PE-10 — the become-a-tutor pitch. Public.
///
/// Public deliberately: the split is the first thing anyone weighing this wants
/// to know, and putting it behind sign-up would mean asking someone to open an
/// account to find out what they would be paid. The gate lands on the
/// application itself, which is the first request that stores anything.
///
/// The percentage is read from the server, never written into the copy, so the
/// number on this screen and the number in the earnings ledger cannot drift
/// apart.
class BecomeTutorScreen extends ConsumerWidget {
  const BecomeTutorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final state = ref.watch(tutorApplicationControllerProvider);

    return GradientBudget(
      screenName: 'become-tutor',
      child: Scaffold(
        appBar: EjadahAppBar(
          title: strings.becomeTitle,
          backLabel: strings.back,
          onBack: () => context.pop(),
        ),
        body: SafeArea(
          top: false,
          child: switch (state) {
            TutorApplicationLoading() => const _PitchSkeleton(),
            TutorApplicationFailed(:final failure) => EjadahErrorState(
              title: FailureCopy.errorTitle(context),
              body: failure.message(context),
              retryLabel: strings.retry,
              onRetry: () => ref
                  .read(tutorApplicationControllerProvider.notifier)
                  .retry(),
            ),
            TutorApplicationReady(:final snapshot) => _Pitch(snapshot: snapshot),
          },
        ),
      ),
    );
  }
}

class _Pitch extends ConsumerWidget {
  const _Pitch({required this.snapshot});

  final TutorApplicationSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final type = context.type;

    final asks = <String>[
      strings.teachAskBasics,
      strings.teachAskQualifications,
      strings.teachAskSubjects,
      strings.teachAskRate,
      strings.teachAskAvailability,
      strings.teachAskMedia,
    ];

    return ListView(
      padding: const EdgeInsets.only(bottom: EjadahSpacing.xxl),
      children: [
        EjadahPageBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: EjadahSpacing.md),
              PageHeader(
                eyebrow: strings.teachEyebrow,
                title: strings.becomeTitle,
                subtitle: strings.teachLead,
              ),
              const SizedBox(height: EjadahSpacing.lg),

              // The split, stated before anything is asked for.
              DarkCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.teachSplitTitle(
                        snapshot.professionalSharePercent,
                      ),
                      style: type.h3(color: EjadahColors.onDark),
                    ),
                    const SizedBox(height: EjadahSpacing.xs),
                    Text(
                      strings.teachSplitBody(snapshot.platformFeePercent),
                      style: type.bodyText(color: EjadahColors.onDarkMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: EjadahSpacing.lg),

              SectionHeader(title: strings.teachAsksTitle),
              const SizedBox(height: EjadahSpacing.xs),
              for (var i = 0; i < asks.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: EjadahSpacing.xs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EjadahStepMarker(position: i + 1, total: asks.length),
                      const SizedBox(width: EjadahSpacing.sm),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(asks[i], style: type.bodyText()),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: EjadahSpacing.md),

              // The promise the status screen has to keep, made here first.
              InlineAlert(
                message: strings.teachReplyPromise,
                tone: AlertTone.info,
              ),
              const SizedBox(height: EjadahSpacing.lg),

              _PitchAction(snapshot: snapshot),
            ],
          ),
        ),
      ],
    );
  }
}

/// The one action, whose label depends on what already exists.
///
/// A returning applicant is never shown "Start the application" over a draft
/// they are halfway through, and someone under review is not invited to start
/// a second one.
class _PitchAction extends ConsumerWidget {
  const _PitchAction({required this.snapshot});

  final TutorApplicationSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final application = snapshot.application;

    final isUnderReviewOrLive =
        application != null && !application.isEditable;

    final label = switch (application) {
      null => strings.teachStart,
      _ when isUnderReviewOrLive => strings.teachSeeStatus,
      _ => strings.teachResume,
    };

    return EjadahPrimaryButton(
      label: label,
      onPressed: () => _open(context, ref, toStatus: isUnderReviewOrLive),
    );
  }

  /// Applying is one of the five gates: a guest is taken to sign-up carrying
  /// where they were headed and comes straight back here.
  Future<void> _open(
    BuildContext context,
    WidgetRef ref, {
    required bool toStatus,
  }) async {
    final destination = toStatus ? '/teach/status' : '/teach/apply';

    if (!ref.read(authControllerProvider).isAuthenticated) {
      final next = Uri.encodeComponent(destination);
      await context.push('/sign-up?intent=teach&next=$next');
      if (!context.mounted) return;
      if (!ref.read(authControllerProvider).isAuthenticated) return;
      // The snapshot was read as a guest and knows nothing about this account.
      await ref.read(tutorApplicationControllerProvider.notifier).load();
      if (!context.mounted) return;
    }

    await context.push(destination);
  }
}

class _PitchSkeleton extends StatelessWidget {
  const _PitchSkeleton();

  @override
  Widget build(BuildContext context) => EjadahPageBody(
    // Scrollable: a skeleton stands in for content that scrolls, and a fixed
    // column of blocks overflows on a short viewport — which paints Flutter's
    // striped overflow bar exactly where a loading state should look calm.
    child: ListView(
      children: [
        const SizedBox(height: EjadahSpacing.md),
        const Skeleton(width: 180, height: 28),
        const SizedBox(height: EjadahSpacing.sm),
        const Skeleton(width: double.infinity, height: 60),
        const SizedBox(height: EjadahSpacing.lg),
        const Skeleton(width: double.infinity, height: 120),
        const SizedBox(height: EjadahSpacing.lg),
        for (var i = 0; i < 6; i++)
          const Padding(
            padding: EdgeInsets.only(bottom: EjadahSpacing.sm),
            child: Skeleton(width: double.infinity, height: 20),
          ),
      ],
    ),
  );
}
