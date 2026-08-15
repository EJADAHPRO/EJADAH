import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../data/roadmap_repository.dart';

final roadmapProvider = FutureProvider.family<RoadmapView, String>(
  (ref, id) => ref.watch(roadmapRepositoryProvider).roadmap(id),
);

/// The generated roadmap.
///
/// A guest reads the first two stages and then meets the gate. The remaining
/// stages are withheld by the *server*, not blurred by the client — blurring
/// alone would leave the full result one inspector away.
class RoadmapResultScreen extends ConsumerWidget {
  const RoadmapResultScreen({required this.roadmapId, super.key});

  final String roadmapId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final view = ref.watch(roadmapProvider(roadmapId));

    return GradientBudget(
      screenName: 'roadmap-result',
      child: Scaffold(
        appBar: EjadahAppBar(
          title: strings.bestRoute,
          onBack: () => context.pop(),
          backLabel: strings.back,
        ),
        body: SafeArea(
          top: false,
          child: view.when(
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
              onRetry: () => ref.invalidate(roadmapProvider(roadmapId)),
            ),
            data: (data) => _Result(view: data),
          ),
        ),
      ),
    );
  }
}

class _Result extends ConsumerWidget {
  const _Result({required this.view});

  final RoadmapView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final roadmap = view.roadmap;

    return EjadahPageBody(
      child: ListView(
        children: [
          const SizedBox(height: EjadahSpacing.md),
          DarkCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        roadmap.headline(context),
                        style: context.type.h4(
                          text: roadmap.headline(context),
                          color: EjadahColors.onDark,
                        ),
                      ),
                    ),
                    // Fit is a number out of 100, in Western digits, LTR.
                    LtrIsland(
                      child: Text(
                        '${roadmap.fitScore}%',
                        style: context.type.tabular(
                          fontSize: EjadahTypeSize.h4,
                          color: EjadahColors.gold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: EjadahSpacing.xs),
                Text(
                  roadmap.summary(context),
                  style: context.type.small(color: EjadahColors.onDarkMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: EjadahSpacing.md),
          // The honest watch-out names the cost in plain figures.
          InlineAlert(
            title: strings.watchOut,
            message: roadmap.watchOut(context),
          ),
          const SizedBox(height: EjadahSpacing.md),
          EjadahCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.type.eyebrowText(strings.currentStage),
                  style: context.type.eyebrow(color: EjadahColors.orangeText),
                ),
                const SizedBox(height: EjadahSpacing.xxs),
                Text(
                  roadmap.thisMonthAction(context),
                  style: context.type.bodyStrong(),
                ),
              ],
            ),
          ),
          const SizedBox(height: EjadahSpacing.lg),
          SectionHeader(title: strings.theRoute),
          const SizedBox(height: EjadahSpacing.xs),
          for (final stage in roadmap.stages)
            Padding(
              padding: const EdgeInsets.only(bottom: EjadahSpacing.cardGap),
              child: _StageCard(stage: stage, total: view.totalStageCount),
            ),
          if (view.isGated) _Gate(view: view),
          if (roadmap.alternatives.isNotEmpty) ...[
            const SizedBox(height: EjadahSpacing.lg),
            SectionHeader(title: strings.alsoWorthLabel),
            const SizedBox(height: EjadahSpacing.xs),
            for (final alternative in roadmap.alternatives)
              Padding(
                padding: const EdgeInsets.only(bottom: EjadahSpacing.cardGap),
                child: EjadahListRow(
                  title: alternative.countryName(context),
                  subtitle: alternative.reason(context),
                  trailing: LtrIsland(
                    child: Text(
                      '${alternative.fitScore}%',
                      style: context.type.tabular(),
                    ),
                  ),
                  onTap: () =>
                      context.push('/country/${alternative.countryIso}'),
                ),
              ),
          ],
          const SizedBox(height: EjadahSpacing.section),
        ],
      ),
    );
  }
}

class _StageCard extends StatelessWidget {
  const _StageCard({required this.stage, required this.total});

  final RoadmapStage stage;
  final int total;

  @override
  Widget build(BuildContext context) => Semantics(
    label: context.strings.stageOf(stage.position, total),
    child: EjadahCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BrandGradient(
                use: GradientUse.stepMarker,
                borderRadius: EjadahRadius.all(EjadahRadius.pill),
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: Center(
                    child: LtrIsland(
                      child: Text(
                        '${stage.position}',
                        style: context.type.caption(color: EjadahColors.onDark),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: EjadahSpacing.sm),
              Expanded(
                child: Text(
                  // Copied verbatim from the country guide's own step row.
                  stage.title(context),
                  style: context.type.bodyStrong(),
                ),
              ),
            ],
          ),
          const SizedBox(height: EjadahSpacing.xs),
          Text(
            stage.detail(context),
            style: context.type.small(color: EjadahColors.textSecondary),
          ),
          const SizedBox(height: EjadahSpacing.xs),
          Row(
            children: [
              Text(
                context.type.eyebrowText(context.strings.estCost),
                style: context.type.eyebrow(color: EjadahColors.labelMuted),
              ),
              const SizedBox(width: EjadahSpacing.xs),
              SourcedValue(
                value: stage.cost,
                pendingLabel: context.strings.pendingSource,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

/// The guest gate.
///
/// It falls between the funnel and the full result, on purpose. Four answers
/// are already invested by this point; a cold signup wall at the entrance
/// converts far worse. It is fired once per result.
class _Gate extends ConsumerStatefulWidget {
  const _Gate({required this.view});

  final RoadmapView view;

  @override
  ConsumerState<_Gate> createState() => _GateState();
}

class _GateState extends ConsumerState<_Gate> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(analyticsProvider).track(AnalyticsEvents.guestGateShown),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return DarkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            strings.gateTitle,
            style: context.type.h5(color: EjadahColors.onDark),
          ),
          const SizedBox(height: EjadahSpacing.xs),
          Text(
            strings.gateBody(widget.view.hiddenStageCount),
            style: context.type.small(color: EjadahColors.onDarkMuted),
          ),
          const SizedBox(height: EjadahSpacing.md),
          EjadahPrimaryButton(
            label: strings.createAccount,
            onPressed: () => context.push(
              // Signing up returns to this exact roadmap, now complete.
              '/sign-up?intent=gate&next=/roadmap/${widget.view.roadmap.id}',
            ),
          ),
        ],
      ),
    );
  }
}
