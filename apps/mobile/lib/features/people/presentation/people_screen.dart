import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/people_hub_controller.dart';

/// PE-01 — the People hub. Three doors.
///
/// One roster, one profile shape and one booking flow serve all three; the
/// doors differ in who is behind them and in what a card leads with, not in the
/// machinery. Building three unrelated marketplaces is the failure this hub is
/// arranged to prevent.
///
/// Each door states how many people are behind it, so nobody walks into an
/// empty room. Browsing is open — booking is the gate, not looking.
class PeopleScreen extends ConsumerWidget {
  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final state = ref.watch(peopleHubControllerProvider);

    return GradientBudget(
      screenName: 'people-hub',
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: EjadahPageBody(
            child: ListView(
              key: const PageStorageKey('people-hub'),
              children: [
                const SizedBox(height: EjadahSpacing.md),
                PageHeader(
                  eyebrow: strings.connectEyebrow,
                  title: strings.connectTitle,
                ),
                const SizedBox(height: EjadahSpacing.lg),
                ..._doors(context, ref, state),
                const SizedBox(height: EjadahSpacing.lg),
                // The supply side's way in, on the screen that lists the
                // demand side. Without an entry point here, the only route to
                // becoming a tutor is a Home card a signed-in student may
                // never be shown.
                const _TeachRow(),
                const SizedBox(height: EjadahSpacing.section),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _doors(
    BuildContext context,
    WidgetRef ref,
    PeopleHubState state,
  ) => switch (state) {
    // Skeletons in the shape of the three doors, not a spinner.
    PeopleHubLoading() => [
      for (var i = 0; i < 3; i++) ...[
        const Skeleton(width: double.infinity, height: 108),
        const SizedBox(height: EjadahSpacing.cardGap),
      ],
    ],
    PeopleHubFailed(:final failure) => [
      EjadahErrorState(
        title: FailureCopy.errorTitle(context),
        body: failure.message(context),
        retryLabel: context.strings.retry,
        onRetry: () => ref.read(peopleHubControllerProvider.notifier).retry(),
      ),
    ],
    PeopleHubReady(:final counts) => [
      for (final kind in ServiceKind.values) ...[
        _Door(kind: kind, count: counts.forKind(kind)),
        const SizedBox(height: EjadahSpacing.cardGap),
      ],
    ],
  };
}

/// One door: what it is, who it is for, and how many are behind it.
class _Door extends StatelessWidget {
  const _Door({required this.kind, required this.count});

  final ServiceKind kind;
  final int count;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final (title, blurb) = switch (kind) {
      ServiceKind.tutoring => (
        strings.peopleTutoringDoor,
        strings.tutoringBlurb,
      ),
      ServiceKind.mentoring => (
        strings.peopleMentoringDoor,
        strings.mentoringBlurb,
      ),
      ServiceKind.consulting => (
        strings.peopleConsultingDoor,
        strings.consultingBlurb,
      ),
    };

    return EjadahCard(
      onTap: () => context.push('/people/${kind.wire}'),
      semanticLabel: title,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(child: Text(title, style: context.type.h5())),
                    const SizedBox(width: EjadahSpacing.xs),
                    // The count is a plain figure in an LTR island, in both
                    // languages, so an empty door is honest rather than hidden.
                    EjadahBadge(
                      label: '$count',
                      foreground: EjadahColors.labelStrong,
                      background: EjadahColors.inset,
                    ),
                  ],
                ),
                const SizedBox(height: EjadahSpacing.xxs),
                Text(
                  blurb,
                  style: context.type.small(color: EjadahColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: EjadahSpacing.sm),
          const DirectionalIcon(
            EjadahIcons.chevronForward,
            size: EjadahIconSize.nav,
            color: EjadahColors.labelMuted,
          ),
        ],
      ),
    );
  }
}

/// "Teach on Ejadah" — the door into the supply side.
class _TeachRow extends StatelessWidget {
  const _TeachRow();

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final type = context.type;

    return EjadahCard(
      onTap: () => context.push('/teach'),
      semanticLabel: strings.becomeTitle,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.becomeTitle, style: type.h5()),
                const SizedBox(height: EjadahSpacing.xxs),
                Text(
                  strings.teachLead,
                  style: type.caption(color: EjadahColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: EjadahSpacing.sm),
          // Directional: the chevron points the way the language reads.
          const DirectionalIcon(
            EjadahIcons.chevronForward,
            size: EjadahIconSize.nav,
            color: EjadahColors.labelMuted,
          ),
        ],
      ),
    );
  }
}
