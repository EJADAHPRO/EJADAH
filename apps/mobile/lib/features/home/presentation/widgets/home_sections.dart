import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers.dart';
import '../../data/home_repository.dart';

/// The greeting. Time-of-day plus the user's own name, nothing more.
class HomeGreeting extends ConsumerWidget {
  const HomeGreeting({required this.displayName, super.key});

  final LocalizedText displayName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final language = ref.watch(languageProvider);
    final hour = DateTime.now().hour;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.type.eyebrowText(
                  hour < 12
                      ? strings.homeGreetingMorning
                      : strings.homeGreetingEvening,
                ),
                style: context.type.eyebrow(color: EjadahColors.labelMuted),
              ),
              const SizedBox(height: EjadahSpacing.xxs),
              Text(
                displayName.resolve(language),
                // The Arabic long-heading rule applies to a name too.
                style: context.type.h4(text: displayName.resolve(language)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        EjadahGhostButton(
          label: language == AppLanguage.ar ? 'English' : 'العربية',
          onPressed: () => ref
              .read(languageProvider.notifier)
              .set(
                language == AppLanguage.ar ? AppLanguage.en : AppLanguage.ar,
              ),
        ),
      ],
    );
  }
}

/// The persona's primary call to action.
///
/// Six personas, six destinations. The choice is the server's, so a specialist
/// cannot be shown an emigration CTA by a client-side branch that drifted.
class HomePrimaryCta extends StatelessWidget {
  const HomePrimaryCta({required this.feed, super.key});

  final HomeFeed feed;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    final (eyebrow, title, body, action, route) = switch (feed.primaryAction) {
      HomePrimaryAction.buildRoadmap => (
        strings.roadmapCtaEyebrow,
        strings.roadmapCtaTitle,
        strings.roadmapCtaBody,
        strings.buildRoute,
        '/roadmap/new',
      ),
      HomePrimaryAction.continueRoadmap => (
        strings.currentStage,
        strings.roadmapCtaTitle,
        feed.roadmap?.thisMonthAction.resolve(
              AppLanguage.fromCode(Localizations.localeOf(context).languageCode),
            ) ??
            strings.roadmapCtaBody,
        strings.ctaContinueRoadmap,
        '/roadmap/${feed.roadmap?.id ?? ''}',
      ),
      HomePrimaryAction.studyPlan => (
        strings.myLearning,
        strings.coursesTitle,
        strings.stubBody,
        strings.ctaStudyPlan,
        '/learn',
      ),
      HomePrimaryAction.setUpCard => (
        strings.profileEyebrow,
        strings.publicCardTitle,
        strings.nfcNote,
        strings.ctaSetUpCard,
        '/profile',
      ),
      HomePrimaryAction.findConsulting => (
        strings.connectEyebrow,
        strings.consultingTitle,
        strings.consultingBlurb,
        strings.ctaFindConsulting,
        '/people',
      ),
      HomePrimaryAction.teachingDashboard => (
        strings.connectEyebrow,
        strings.becomeTitle,
        strings.becomeBlurb,
        strings.ctaTeaching,
        '/people',
      ),
    };

    return RoadmapCtaCard(
      eyebrow: eyebrow,
      title: title,
      body: body,
      actionLabel: action,
      onAction: () => context.push(route),
    );
  }
}

/// The dark hero card that carries the primary action.
///
/// The button inside it is one of the six permitted gradient uses.
class RoadmapCtaCard extends StatelessWidget {
  const RoadmapCtaCard({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => DarkCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.type.eyebrowText(eyebrow),
          style: context.type.eyebrow(color: EjadahColors.gold),
        ),
        const SizedBox(height: EjadahSpacing.xs),
        Text(
          title,
          style: context.type.h4(text: title, color: EjadahColors.onDark),
        ),
        const SizedBox(height: EjadahSpacing.xs),
        Text(
          body,
          style: context.type.small(color: EjadahColors.onDarkMuted),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: EjadahSpacing.md),
        EjadahPrimaryButton(label: actionLabel, onPressed: onAction),
      ],
    ),
  );
}

/// Roadmap progress: rings fill rather than appearing complete.
class RoadmapProgressCard extends ConsumerWidget {
  const RoadmapProgressCard({required this.roadmap, super.key});

  final Roadmap roadmap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final done = roadmap.completedStageCount;
    final total = roadmap.stages.length;

    return EjadahCard(
      onTap: () => context.push('/roadmap/${roadmap.id}'),
      semanticLabel: roadmap.destinationName.resolve(language),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  roadmap.destinationName.resolve(language),
                  style: context.type.h6(),
                ),
              ),
              // Fit is Western digits, LTR, in both languages.
              LtrIsland(
                child: Text(
                  '${roadmap.fitScore}%',
                  style: context.type.tabular(color: EjadahColors.orangeText),
                ),
              ),
            ],
          ),
          const SizedBox(height: EjadahSpacing.xs),
          Text(
            context.strings.roadmapProgress(done, total),
            style: context.type.small(color: EjadahColors.textSecondary),
          ),
          const SizedBox(height: EjadahSpacing.xs),
          ClipRRect(
            borderRadius: EjadahRadius.all(EjadahRadius.pill),
            child: LinearProgressIndicator(
              value: roadmap.progress,
              minHeight: 4,
              backgroundColor: EjadahColors.inset,
              valueColor: const AlwaysStoppedAnimation(EjadahColors.orange),
            ),
          ),
        ],
      ),
    );
  }
}

/// The next confirmed session.
class UpcomingSessionCard extends ConsumerWidget {
  const UpcomingSessionCard({required this.booking, super.key});

  final Booking booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final start = booking.firstSessionStart!;

    return EjadahCard(
      onTap: () => context.push('/bookings'),
      semanticLabel: booking.professionalName.resolve(language),
      child: Row(
        children: [
          // The date block. Digits stay Western and LTR.
          Container(
            width: 52,
            padding: const EdgeInsets.symmetric(vertical: EjadahSpacing.xs),
            decoration: BoxDecoration(
              color: EjadahColors.inset,
              borderRadius: EjadahRadius.all(EjadahRadius.md),
            ),
            child: LtrIsland(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${start.day}', style: context.type.h5()),
                  Text(
                    _monthLabel(start.month),
                    style: context.type.micro(color: EjadahColors.labelMuted),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: EjadahSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  booking.professionalName.resolve(language),
                  style: context.type.bodyStrong(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: EjadahSpacing.xxs),
                // 24-hour time with the zone named, per the localization rules.
                Row(
                  children: [
                    LtrIsland(
                      child: Text(
                        '${start.hour.toString().padLeft(2, '0')}:'
                        '${start.minute.toString().padLeft(2, '0')}',
                        style: context.type.tabular(
                          fontSize: EjadahTypeSize.small,
                        ),
                      ),
                    ),
                    const SizedBox(width: EjadahSpacing.xxs),
                    Text(
                      context.strings.cairoTime,
                      style: context.type.small(
                        color: EjadahColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const DirectionalIcon(
            EjadahIcons.chevronForward,
            color: EjadahColors.labelMuted,
          ),
        ],
      ),
    );
  }

  /// Three-letter month. Localized month names come from the string table where
  /// the design shows them in full; the date block is deliberately terse.
  static String _monthLabel(int month) => const [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
  ][month - 1];
}

/// Saved programmes with a live deadline, most urgent first.
///
/// Carries three of Home's states in one place: the section's own failure (the
/// partial-data case), the empty state that names a real number, and the list.
class DeadlineStrip extends StatelessWidget {
  const DeadlineStrip({required this.feed, super.key});

  final HomeFeed feed;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    if (feed.sectionFailed('deadlines')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: strings.deadlinesLabel),
          const SizedBox(height: EjadahSpacing.xs),
          // Home is the only screen where one section failing leaves the rest
          // standing. The note says which part, and that the rest is current.
          InlineAlert(
            message: strings.partialSectionNote,
            tone: AlertTone.info,
          ),
        ],
      );
    }

    if (feed.deadlines.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: strings.deadlinesLabel),
          const SizedBox(height: EjadahSpacing.xs),
          EjadahCard(
            onTap: () => context.push('/programmes'),
            semanticLabel: strings.browseProgrammes,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(strings.emptySavedTitle, style: context.type.bodyStrong()),
                const SizedBox(height: EjadahSpacing.xxs),
                // Names a real number rather than saying "nothing here".
                Text(
                  strings.emptySavedRelaxed(feed.openProgrammeCount),
                  style: context.type.small(
                    color: EjadahColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: strings.deadlinesLabel,
          actionLabel: strings.seeAllDeadlines,
          onAction: () => context.push('/shortlist'),
        ),
        const SizedBox(height: EjadahSpacing.xs),
        for (final programme in feed.deadlines)
          EjadahListRow(
            title: programme.university,
            subtitle: programme.programmeName,
            onTap: () => context.push('/programme/${programme.id}'),
            trailing: DeadlineBadge(
              status: programme.deadlineStatus,
              daysRemaining: programme.daysRemaining,
              closingSoonLabel:
                  '${programme.daysRemaining ?? 0} ${strings.daysLeft}',
              openLabel: strings.openNow,
              closedLabel: strings.closed,
            ),
          ),
      ],
    );
  }
}

/// The explore tiles: 2-up on a phone, 4-up on a wide window.
class ExploreTiles extends StatelessWidget {
  const ExploreTiles({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final tiles = <({String title, String meta, String route})>[
      (
        title: strings.tileProgrammes,
        meta: strings.tileProgrammesMeta,
        route: '/programmes',
      ),
      (
        title: strings.tileCountries,
        meta: strings.tileCountriesMeta,
        route: '/countries',
      ),
      (
        title: strings.myShortlist,
        meta: strings.tileShortlistMeta,
        route: '/shortlist',
      ),
      (
        title: strings.roadmapLabel,
        meta: strings.roadmapCtaEyebrow,
        route: '/roadmap/new',
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: context.ejadah.windowClass.tileColumns,
      crossAxisSpacing: EjadahSpacing.cardGap,
      mainAxisSpacing: EjadahSpacing.cardGap,
      childAspectRatio: 1.5,
      children: [
        for (final tile in tiles)
          EjadahCard(
            onTap: () => context.push(tile.route),
            semanticLabel: tile.title,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  tile.title,
                  style: context.type.bodyStrong(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: EjadahSpacing.xxs),
                Text(
                  tile.meta,
                  style: context.type.micro(color: EjadahColors.labelMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
