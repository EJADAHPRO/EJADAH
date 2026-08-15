import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../auth/auth_controller.dart';

/// Home.
///
/// The feed is composed of sections, not screens. The roadmap entry is the
/// primary call to action for every persona whose goal is the emigration
/// question; a student never sees an emigration CTA.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final auth = ref.watch(authControllerProvider);
    final language = ref.watch(languageProvider);

    return GradientBudget(
      screenName: 'home',
      child: Scaffold(
        body: SafeArea(
          child: EjadahPageBody(
            child: ListView(
              key: const PageStorageKey('home'),
              children: [
                const SizedBox(height: EjadahSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        auth.user == null
                            ? strings.welcomeBack
                            : auth.user!.fullName.resolve(language),
                        style: context.type.h4(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Language switches instantly, with no reload and no lost
                    // state — only the locale changes.
                    EjadahGhostButton(
                      label: language == AppLanguage.ar ? 'EN' : 'ع',
                      onPressed: () => ref
                          .read(languageProvider.notifier)
                          .set(
                            language == AppLanguage.ar
                                ? AppLanguage.en
                                : AppLanguage.ar,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: EjadahSpacing.md),
                _RoadmapCta(),
                const SizedBox(height: EjadahSpacing.section),
                SectionHeader(title: strings.exploreLabel),
                const SizedBox(height: EjadahSpacing.xs),
                _ExploreTiles(),
                const SizedBox(height: EjadahSpacing.section),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The activation funnel's entry point.
class _RoadmapCta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return DarkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.type.eyebrowText(strings.roadmapCtaEyebrow),
            style: context.type.eyebrow(color: EjadahColors.gold),
          ),
          const SizedBox(height: EjadahSpacing.xs),
          Text(
            strings.roadmapCtaTitle,
            style: context.type.h4(
              text: strings.roadmapCtaTitle,
              color: EjadahColors.onDark,
            ),
          ),
          const SizedBox(height: EjadahSpacing.xs),
          Text(
            strings.roadmapCtaBody,
            style: context.type.small(color: EjadahColors.onDarkMuted),
          ),
          const SizedBox(height: EjadahSpacing.md),
          EjadahPrimaryButton(
            // Verb plus object, never "Get started".
            label: strings.buildRoute,
            onPressed: () => context.push('/roadmap/new'),
          ),
        ],
      ),
    );
  }
}

class _ExploreTiles extends StatelessWidget {
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
        title: strings.tileShortlist,
        meta: strings.tileShortlistMeta,
        route: '/shortlist',
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: context.ejadah.windowClass.tileColumns,
      crossAxisSpacing: EjadahSpacing.cardGap,
      mainAxisSpacing: EjadahSpacing.cardGap,
      childAspectRatio: 1.4,
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
