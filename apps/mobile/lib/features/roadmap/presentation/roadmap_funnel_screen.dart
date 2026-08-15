import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../application/funnel_controller.dart';
import '../data/roadmap_repository.dart';

/// The four-question roadmap funnel.
///
/// Completable without an account, from the first question to the generated
/// result. The wall falls *after* the result, not before the funnel: four
/// answers are invested by then, and that is the highest-leverage decision in
/// the product.
class RoadmapFunnelScreen extends ConsumerStatefulWidget {
  const RoadmapFunnelScreen({this.seedPath, super.key});

  /// From `/roadmap/new?path=…`, which seeds the first answer.
  final String? seedPath;

  @override
  ConsumerState<RoadmapFunnelScreen> createState() => _FunnelState();
}

class _FunnelState extends ConsumerState<RoadmapFunnelScreen> {
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    final seed = widget.seedPath;
    if (seed != null) {
      Future.microtask(
        () => ref
            .read(funnelControllerProvider.notifier)
            .seedPath(RoadmapPath.fromWire(seed)),
      );
    }
    Future.microtask(
      () => ref.read(analyticsProvider).track(AnalyticsEvents.roadmapStarted, {
        'entry_point': widget.seedPath == null ? 'career_tab' : 'deep_link',
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final draft = ref.watch(funnelControllerProvider);
    final controller = ref.read(funnelControllerProvider.notifier);

    if (_isGenerating) return const _GeneratingScreen();

    return GradientBudget(
      screenName: 'roadmap-funnel',
      child: Scaffold(
        appBar: EjadahAppBar(
          title: strings.roadmapCtaTitle,
          onBack: draft.step > 1 ? controller.back : () => context.pop(),
          backLabel: strings.back,
        ),
        body: SafeArea(
          top: false,
          child: EjadahPageBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress fills from the leading edge and mirrors in Arabic.
                Semantics(
                  label: strings.stageOf(draft.step, FunnelDraft.stepCount),
                  child: ClipRRect(
                    borderRadius: EjadahRadius.all(EjadahRadius.pill),
                    child: LinearProgressIndicator(
                      value: draft.step / FunnelDraft.stepCount,
                      minHeight: 4,
                      backgroundColor: EjadahColors.inset,
                      valueColor: const AlwaysStoppedAnimation(
                        EjadahColors.orange,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: EjadahSpacing.lg),
                Expanded(
                  child: SingleChildScrollView(
                    child: switch (draft.step) {
                      1 => _PathStep(draft: draft),
                      2 => _StageStep(draft: draft),
                      3 => _LimitsStep(draft: draft),
                      _ => _RegionStep(draft: draft),
                    },
                  ),
                ),
                // A sticky bar with the single main action, on every step.
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: EjadahSpacing.md,
                  ),
                  child: EjadahPrimaryButton(
                    label: draft.step == FunnelDraft.stepCount
                        ? strings.buildRoute
                        : strings.continueAction,
                    onPressed: draft.canAdvanceFrom(draft.step)
                        ? () => draft.step == FunnelDraft.stepCount
                              ? _generate()
                              : controller.advance()
                        : null,
                    // A disabled control explains itself when tapped — and the
                    // explanation has to be about what is missing. "Next
                    // question" was the name of the thing that would happen,
                    // not the reason it could not.
                    disabledReason: strings.answerToContinue,
                    onDisabledTap: (reason) =>
                        showEjadahToast(context, message: reason),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _generate() async {
    setState(() => _isGenerating = true);
    final started = DateTime.now();

    try {
      final view = await ref
          .read(roadmapRepositoryProvider)
          .generate(ref.read(funnelControllerProvider).toAnswers());

      await ref
          .read(analyticsProvider)
          .track(AnalyticsEvents.roadmapGenerated, {
            'destination': view.roadmap.destinationIso,
            'fit_score': view.roadmap.fitScore,
          });

      // Generation is instant, but the pacing gives the result room to land.
      final elapsed = DateTime.now().difference(started);
      const minimumDisplay = Duration(milliseconds: 2200);
      if (elapsed < minimumDisplay) {
        await Future<void>.delayed(minimumDisplay - elapsed);
      }

      if (!mounted) return;
      context.pushReplacement('/roadmap/${view.roadmap.id}');
    } on Failure catch (failure) {
      if (!mounted) return;
      setState(() => _isGenerating = false);
      // "…your answers are saved" is true, and the copy says so.
      showEjadahToast(context, message: failure.message(context));
    }
  }
}

/// The generating screen.
///
/// Paced deliberately: the deterministic generator returns immediately, and a
/// result that appears instantly reads as canned rather than as calculated.
class _GeneratingScreen extends StatelessWidget {
  const _GeneratingScreen();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: EjadahPageBody(
        child: ListView(
          children: [
            const SizedBox(height: EjadahSpacing.section),
            Text(context.strings.roadmapCtaTitle, style: context.type.h4()),
            const SizedBox(height: EjadahSpacing.lg),
            // Skeletons, not a spinner: the shapes are the ones the roadmap is
            // about to fill — headline, then stages — so the wait shows what is
            // coming rather than that something is happening.
            const Skeleton(width: 220, height: 20),
            const SizedBox(height: EjadahSpacing.md),
            const Skeleton(width: double.infinity, height: 120),
            const SizedBox(height: EjadahSpacing.section),
            const CardSkeleton(),
            const SizedBox(height: EjadahSpacing.cardGap),
            const CardSkeleton(),
            const SizedBox(height: EjadahSpacing.cardGap),
            const CardSkeleton(),
          ],
        ),
      ),
    ),
  );
}

class _PathStep extends ConsumerWidget {
  const _PathStep({required this.draft});

  final FunnelDraft draft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    // The four directions out of the same qualification.
    final paths = <(RoadmapPath, String)>[
      (RoadmapPath.generalPractice, strings.pathGpAbroad),
      (RoadmapPath.specialise, strings.pathSpecialise),
      (RoadmapPath.digital, strings.pathDigital),
      (RoadmapPath.business, strings.pathBusiness),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(eyebrow: strings.pathsLabel, title: strings.q2),
        const SizedBox(height: EjadahSpacing.md),
        for (final (path, label) in paths)
          Padding(
            padding: const EdgeInsets.only(bottom: EjadahSpacing.cardGap),
            child: EjadahCard(
              isSelected: draft.path == path,
              onTap: () =>
                  ref.read(funnelControllerProvider.notifier).choosePath(path),
              semanticLabel: label,
              child: Text(label, style: context.type.bodyStrong()),
            ),
          ),
      ],
    );
  }
}

class _StageStep extends ConsumerWidget {
  const _StageStep({required this.draft});

  final FunnelDraft draft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final stages = <(CareerStage, String)>[
      (CareerStage.student, strings.stageStudent),
      (CareerStage.freshGraduate, strings.stageFreshGraduate),
      (CareerStage.generalDentist, strings.stageGeneralDentist),
      (CareerStage.specialist, strings.stageSpecialist),
      (CareerStage.consultantOwner, strings.stageConsultantOwner),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(eyebrow: strings.yourStage, title: strings.q3),
        const SizedBox(height: EjadahSpacing.md),
        Wrap(
          spacing: EjadahSpacing.xs,
          runSpacing: EjadahSpacing.xs,
          children: [
            for (final (stage, label) in stages)
              EjadahFilterChip(
                label: label,
                isSelected: draft.stage == stage,
                onTap: () => ref
                    .read(funnelControllerProvider.notifier)
                    .chooseStage(stage),
              ),
          ],
        ),
      ],
    );
  }
}

class _LimitsStep extends ConsumerWidget {
  const _LimitsStep({required this.draft});

  final FunnelDraft draft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final controller = ref.read(funnelControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(eyebrow: strings.budgetLabel, title: strings.q4),
        const SizedBox(height: EjadahSpacing.xs),
        // "We use this as a ceiling, not a target. A plan you can't afford
        // isn't a plan."
        Text(
          strings.q4sub,
          style: context.type.small(color: EjadahColors.textSecondary),
        ),
        const SizedBox(height: EjadahSpacing.lg),
        CurrencyText(
          amount: draft.budgetUsd,
          currency: 'USD',
          style: context.type.h3(),
        ),
        Slider(
          value: draft.budgetUsd.toDouble(),
          min: 500,
          max: 60000,
          divisions: 119,
          activeColor: EjadahColors.orange,
          onChanged: (value) => controller.setBudget(value.round()),
        ),
        const SizedBox(height: EjadahSpacing.md),
        Row(
          children: [
            Text(
              context.type.eyebrowText(strings.timeLabel),
              style: context.type.eyebrow(color: EjadahColors.labelMuted),
            ),
            const Spacer(),
            RangeText(
              from: draft.monthsAvailable,
              to: draft.monthsAvailable,
              suffix: strings.monthsTypical,
              style: context.type.tabular(),
            ),
          ],
        ),
        Slider(
          value: draft.monthsAvailable.toDouble(),
          min: 3,
          max: 60,
          divisions: 57,
          activeColor: EjadahColors.orange,
          onChanged: (value) => controller.setMonths(value.round()),
        ),
      ],
    );
  }
}

class _RegionStep extends ConsumerWidget {
  const _RegionStep({required this.draft});

  final FunnelDraft draft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final controller = ref.read(funnelControllerProvider.notifier);
    final regions = <(RoadmapRegion, String)>[
      (RoadmapRegion.gulf, strings.regionGulf),
      (RoadmapRegion.ukIreland, strings.regionUkIreland),
      (RoadmapRegion.europe, strings.regionEurope),
      (RoadmapRegion.northAmerica, strings.regionNorthAmerica),
      // Staying in Egypt is a destination, never a consolation prize.
      (RoadmapRegion.stayEgypt, strings.regionStayEgypt),
    ];
    const languages = <(String, String)>[
      ('ar', 'العربية'),
      ('en', 'English'),
      ('de', 'Deutsch'),
      ('fr', 'Français'),
      ('es', 'Español'),
      ('tr', 'Türkçe'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(eyebrow: strings.regionLabel, title: strings.q5),
        const SizedBox(height: EjadahSpacing.md),
        Wrap(
          spacing: EjadahSpacing.xs,
          runSpacing: EjadahSpacing.xs,
          children: [
            for (final (region, label) in regions)
              EjadahFilterChip(
                label: label,
                isSelected: draft.regions.contains(region),
                onTap: () => controller.toggleRegion(region),
              ),
          ],
        ),
        const SizedBox(height: EjadahSpacing.lg),
        Text(
          context.type.eyebrowText(strings.languageLabel),
          style: context.type.eyebrow(color: EjadahColors.labelMuted),
        ),
        const SizedBox(height: EjadahSpacing.xs),
        Wrap(
          spacing: EjadahSpacing.xs,
          runSpacing: EjadahSpacing.xs,
          children: [
            for (final (code, label) in languages)
              EjadahFilterChip(
                label: label,
                isSelected: draft.languages.contains(code),
                onTap: () => controller.toggleLanguage(code),
              ),
          ],
        ),
      ],
    );
  }
}
