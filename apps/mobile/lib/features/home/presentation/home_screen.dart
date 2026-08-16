import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../application/home_controller.dart';
import '../data/home_repository.dart';
import 'widgets/home_sections.dart';

/// Home.
///
/// The feed is composed of sections, not screens, and it is the router to
/// everything else. Two rules shape it:
///
/// * **The CTA follows the persona.** A specialist is never shown an emigration
///   call to action; a student's leads to their study plan. The server decides,
///   so the rule lives in one place.
/// * **Partial data is a designed state, here and nowhere else.** If the
///   deadline strip fails, the rest of the feed is still correct and still
///   useful — the section says it did not load and the rest carries on.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeControllerProvider);

    return GradientBudget(
      screenName: 'home',
      child: Scaffold(
        body: SafeArea(
          child: switch (state) {
            HomeLoading() => const _HomeSkeleton(),
            HomeSignedOut() => const _GuestHome(),
            HomeFailed(:final failure) => EjadahErrorState(
              title: context.strings.errTitle,
              body: failure.message(context),
              retryLabel: context.strings.retry,
              onRetry: () =>
                  ref.read(homeControllerProvider.notifier).refresh(),
            ),
            HomeReady(:final feed, :final isOffline) => _Feed(
              feed: feed,
              isOffline: isOffline,
            ),
          },
        ),
      ),
    );
  }
}

/// The signed-out Home.
///
/// A guest is a first-class caller: this is an invitation into the funnel, not
/// a wall. The funnel itself needs no account.
class _GuestHome extends ConsumerWidget {
  const _GuestHome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    return EjadahPageBody(
      child: ListView(
        children: [
          const SizedBox(height: EjadahSpacing.md),
          const _LanguageRow(),
          const SizedBox(height: EjadahSpacing.md),
          RoadmapCtaCard(
            eyebrow: strings.roadmapCtaEyebrow,
            title: strings.roadmapCtaTitle,
            body: strings.roadmapCtaBody,
            actionLabel: strings.buildRoute,
            onAction: () => context.push('/roadmap/new'),
          ),
          const SizedBox(height: EjadahSpacing.section),
          SectionHeader(title: strings.exploreLabel),
          const SizedBox(height: EjadahSpacing.xs),
          const ExploreTiles(),
          const SizedBox(height: EjadahSpacing.section),
        ],
      ),
    );
  }
}

class _Feed extends ConsumerWidget {
  const _Feed({required this.feed, required this.isOffline});

  final HomeFeed feed;
  final bool isOffline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;

    return Column(
      children: [
        // Offline is a condition, not an error — the content below is real.
        if (isOffline) OfflineBanner(message: strings.offlineBanner),
        Expanded(
          child: RefreshIndicator(
            color: EjadahColors.orange,
            onRefresh: () =>
                ref.read(homeControllerProvider.notifier).refresh(),
            child: EjadahPageBody(
              child: ListView(
                key: const PageStorageKey('home'),
                children: [
                  const SizedBox(height: EjadahSpacing.md),
                  HomeGreeting(displayName: feed.displayName),
                  const SizedBox(height: EjadahSpacing.md),

                  // 1 · The persona's primary action.
                  HomePrimaryCta(feed: feed),

                  // 2 · Roadmap progress, once there is one.
                  if (feed.roadmap != null) ...[
                    const SizedBox(height: EjadahSpacing.cardGap),
                    RoadmapProgressCard(roadmap: feed.roadmap!),
                  ],

                  // 3 · The next session.
                  if (feed.upcomingBooking != null) ...[
                    const SizedBox(height: EjadahSpacing.section),
                    SectionHeader(title: strings.sessionUpcoming),
                    const SizedBox(height: EjadahSpacing.xs),
                    UpcomingSessionCard(booking: feed.upcomingBooking!),
                  ],

                  // 4 · Saved deadlines, urgency first.
                  const SizedBox(height: EjadahSpacing.section),
                  DeadlineStrip(feed: feed),

                  // 5 · Explore.
                  const SizedBox(height: EjadahSpacing.section),
                  SectionHeader(title: strings.exploreLabel),
                  const SizedBox(height: EjadahSpacing.xs),
                  const ExploreTiles(),

                  const SizedBox(height: EjadahSpacing.section),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The loading state: shapes of the coming feed, not a spinner.
class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) => EjadahPageBody(
    child: ListView(
      children: const [
        SizedBox(height: EjadahSpacing.lg),
        Skeleton(width: 180, height: 24),
        SizedBox(height: EjadahSpacing.md),
        Skeleton(width: double.infinity, height: 160),
        SizedBox(height: EjadahSpacing.cardGap),
        CardSkeleton(),
        SizedBox(height: EjadahSpacing.section),
        Skeleton(width: 120, height: 12),
        SizedBox(height: EjadahSpacing.xs),
        CardSkeleton(),
      ],
    ),
  );
}

/// The language switch. Instant, with no reload and no lost state.
class _LanguageRow extends ConsumerWidget {
  const _LanguageRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: EjadahGhostButton(
        label: language == AppLanguage.ar ? 'English' : 'العربية',
        onPressed: () => ref
            .read(languageProvider.notifier)
            .set(language == AppLanguage.ar ? AppLanguage.en : AppLanguage.ar),
      ),
    );
  }
}
