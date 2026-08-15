import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The Career hub — roadmap entry, the programme database, country guides and
/// the shortlist.
///
/// The postgraduate database lives under Career: the prototype's separate
/// "Masters" tab is legacy and folds in here.
class CareerHubScreen extends StatelessWidget {
  const CareerHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return GradientBudget(
      screenName: 'career-hub',
      child: Scaffold(
        body: SafeArea(
          child: EjadahPageBody(
            child: ListView(
              key: const PageStorageKey('career'),
              children: [
                const SizedBox(height: EjadahSpacing.md),
                PageHeader(
                  eyebrow: strings.careerEyebrow,
                  title: strings.careerTitle,
                  subtitle: strings.careerSub,
                ),
                const SizedBox(height: EjadahSpacing.lg),
                EjadahCard(
                  onTap: () => context.push('/roadmap/new'),
                  semanticLabel: strings.roadmapCtaTitle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(strings.roadmapCtaTitle, style: context.type.h6()),
                      const SizedBox(height: EjadahSpacing.xxs),
                      Text(
                        strings.roadmapFunnelBody,
                        style: context.type.small(
                          color: EjadahColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: EjadahSpacing.cardGap),
                EjadahListRow(
                  title: strings.tileProgrammes,
                  subtitle: strings.programmesBlurb,
                  trailing: const DirectionalIcon(
                    EjadahIcons.chevronForward,
                    color: EjadahColors.labelMuted,
                  ),
                  onTap: () => context.push('/programmes'),
                ),
                EjadahListRow(
                  title: strings.tileCountries,
                  subtitle: strings.countriesBlurb,
                  trailing: const DirectionalIcon(
                    EjadahIcons.chevronForward,
                    color: EjadahColors.labelMuted,
                  ),
                  onTap: () => context.push('/countries'),
                ),
                EjadahListRow(
                  title: strings.myShortlist,
                  trailing: const DirectionalIcon(
                    EjadahIcons.chevronForward,
                    color: EjadahColors.labelMuted,
                  ),
                  onTap: () => context.push('/shortlist'),
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
