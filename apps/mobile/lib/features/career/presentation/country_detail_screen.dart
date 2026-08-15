import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/career_repository.dart';

final countryGuideProvider = FutureProvider.family<CountryGuide, String>(
  (ref, iso) => ref.watch(careerRepositoryProvider).country(iso),
);

/// A country licensing guide, in four tabs: Pathway · Documents · Costs ·
/// Recognition.
///
/// Every unsourced figure prints "Pending source" rather than an estimate —
/// that visible honesty is what makes the sourced figures believable.
class CountryDetailScreen extends ConsumerStatefulWidget {
  const CountryDetailScreen({required this.iso, this.initialTab, super.key});

  final String iso;

  /// From the deep link: `?tab=path|docs|costs|recognition`.
  final String? initialTab;

  @override
  ConsumerState<CountryDetailScreen> createState() => _CountryDetailState();
}

class _CountryDetailState extends ConsumerState<CountryDetailScreen>
    with SingleTickerProviderStateMixin {
  static const List<String> _tabKeys = ['path', 'docs', 'costs', 'recognition'];

  late final TabController _tabs = TabController(
    length: _tabKeys.length,
    vsync: this,
    initialIndex: _tabKeys.indexOf(widget.initialTab ?? 'path').clamp(0, 3),
  );

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final guide = ref.watch(countryGuideProvider(widget.iso));

    return Scaffold(
      body: SafeArea(
        child: guide.when(
          loading: () => const Center(child: CardSkeleton()),
          error: (error, _) => EjadahErrorState(
            title: FailureCopy.errorTitle(context),
            body: error is Failure
                ? error.message(context)
                : FailureCopy.server(context),
            retryLabel: strings.retry,
            onRetry: () => ref.invalidate(countryGuideProvider(widget.iso)),
          ),
          data: (data) => Column(
            children: [
              EjadahAppBar(
                title: data.summary.name(context),
                onBack: () => context.pop(),
                backLabel: strings.back,
              ),
              TabBar(
                controller: _tabs,
                labelColor: EjadahColors.textPrimary,
                unselectedLabelColor: EjadahColors.labelMuted,
                indicatorColor: EjadahColors.orange,
                labelStyle: context.type.caption(),
                tabs: [
                  Tab(text: strings.licensingRoute),
                  Tab(text: strings.documentsTab),
                  Tab(text: strings.estCost),
                  Tab(text: strings.recognitionLabel),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _PathwayTab(guide: data),
                    _DocumentsTab(guide: data),
                    _CostsTab(guide: data),
                    _RecognitionTab(guide: data),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The three ways out of a guide, named in FLOWS §1.
///
/// A guide that only describes a pathway is a document. These make it a step:
/// the programmes that exist in this country, the mentors who have already made
/// this exact move, and the question of whether this is even the right country
/// — which is what the roadmap answers.
class _Crossings extends StatelessWidget {
  const _Crossings({required this.guide});

  final CountryGuide guide;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final country = guide.summary.name(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionHeader(title: strings.crossingsLabel),
        const SizedBox(height: EjadahSpacing.xs),
        EjadahListRow(
          title: strings.programmesHere(country),
          // Pre-filtered to this country, so the crossing lands on results
          // rather than on the whole database.
          onTap: () => context.push('/programmes?country=${guide.summary.iso}'),
        ),
        EjadahListRow(
          // A mentor is someone who made this move — the door's whole premise.
          title: strings.mentorsWhoMoved,
          onTap: () =>
              context.push('/people/mentoring?destination=${guide.summary.iso}'),
        ),
        EjadahListRow(
          title: strings.routeToHere,
          onTap: () => context.push('/roadmap/new'),
        ),
      ],
    );
  }
}

class _PathwayTab extends StatelessWidget {
  const _PathwayTab({required this.guide});

  final CountryGuide guide;

  @override
  Widget build(BuildContext context) => _GuideBody(
    children: [
      Text(guide.overview(context), style: context.type.bodyText()),
      const SizedBox(height: EjadahSpacing.lg),
      _Crossings(guide: guide),
      const SizedBox(height: EjadahSpacing.lg),
      SectionHeader(title: context.strings.theRoute),
      const SizedBox(height: EjadahSpacing.xs),
      // Steps announce as an ordered list, so a screen reader hears
      // "step n of m" rather than an undifferentiated stack of cards.
      Semantics(
        container: true,
        child: Column(
          children: [
            for (final step in guide.steps)
              Padding(
                padding: const EdgeInsets.only(bottom: EjadahSpacing.cardGap),
                child: _StepCard(step: step, total: guide.steps.length),
              ),
          ],
        ),
      ),
      const SizedBox(height: EjadahSpacing.lg),
      SectionHeader(title: context.strings.keyFacts),
      const SizedBox(height: EjadahSpacing.xs),
      for (final exam in guide.exams)
        Padding(
          padding: const EdgeInsets.only(bottom: EjadahSpacing.cardGap),
          child: EjadahCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CodeText(exam.name.en, style: context.type.bodyStrong()),
                const SizedBox(height: EjadahSpacing.xxs),
                Text(
                  exam.description(context),
                  style: context.type.small(color: EjadahColors.textSecondary),
                ),
                const SizedBox(height: EjadahSpacing.xs),
                Row(
                  children: [
                    Text(
                      context.type.eyebrowText(context.strings.examFee),
                      style: context.type.eyebrow(
                        color: EjadahColors.labelMuted,
                      ),
                    ),
                    const SizedBox(width: EjadahSpacing.xs),
                    // The 'Pending source' path is not an error state; it is
                    // what several regulator fees legitimately are today.
                    SourcedValue(
                      value: exam.fee,
                      pendingLabel: context.strings.pendingSource,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
    ],
  );
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.step, required this.total});

  final CountryStep step;
  final int total;

  @override
  Widget build(BuildContext context) => Semantics(
    label: context.strings.stageOf(step.position, total),
    child: EjadahCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The marker decides its own treatment from the length of the list:
          // Germany's guide has seven steps and the screen budget is six.
          EjadahStepMarker(position: step.position, total: total),
          const SizedBox(width: EjadahSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(step.title(context), style: context.type.bodyStrong()),
                const SizedBox(height: EjadahSpacing.xxs),
                Text(
                  step.detail(context),
                  style: context.type.small(color: EjadahColors.textSecondary),
                ),
                if (step.whenLabel != null) ...[
                  const SizedBox(height: EjadahSpacing.xs),
                  EjadahTag(step.whenLabel!),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _DocumentsTab extends StatelessWidget {
  const _DocumentsTab({required this.guide});

  final CountryGuide guide;

  @override
  Widget build(BuildContext context) => _GuideBody(
    children: [
      for (final document in guide.documents)
        Padding(
          padding: const EdgeInsets.only(bottom: EjadahSpacing.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                EjadahIcons.check,
                size: EjadahIconSize.inline,
                color: EjadahColors.success,
              ),
              const SizedBox(width: EjadahSpacing.xs),
              Expanded(
                child: Text(document(context), style: context.type.bodyText()),
              ),
            ],
          ),
        ),
    ],
  );
}

class _CostsTab extends StatelessWidget {
  const _CostsTab({required this.guide});

  final CountryGuide guide;

  @override
  Widget build(BuildContext context) => _GuideBody(
    children: [
      for (final cost in guide.costs)
        Padding(
          padding: const EdgeInsets.only(bottom: EjadahSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  cost.label(context),
                  style: context.type.bodyText(),
                ),
              ),
              const SizedBox(width: EjadahSpacing.sm),
              SourcedValue(
                value: cost.usdAmount,
                pendingLabel: context.strings.pendingSource,
              ),
            ],
          ),
        ),
      const SizedBox(height: EjadahSpacing.md),
      Text(
        guide.costNote(context),
        style: context.type.small(color: EjadahColors.labelMuted),
      ),
      const SizedBox(height: EjadahSpacing.md),
      InlineAlert(message: context.strings.disclaimer),
    ],
  );
}

class _RecognitionTab extends StatelessWidget {
  const _RecognitionTab({required this.guide});

  final CountryGuide guide;

  @override
  Widget build(BuildContext context) => _GuideBody(
    children: [
      Text(guide.recognitionNote(context), style: context.type.bodyText()),
      const SizedBox(height: EjadahSpacing.lg),
      SectionHeader(title: context.strings.visaRoute),
      const SizedBox(height: EjadahSpacing.xs),
      Text(guide.visa(context), style: context.type.bodyText()),
      const SizedBox(height: EjadahSpacing.lg),
      // The regulator and the date the guide states, together.
      SourceLine(
        sourceName: guide.authority(context),
        verifiedOnLabel: guide.updatedLabel,
      ),
    ],
  );
}

/// Guides read at a comfortable width rather than a phone width, and their
/// authority blocks always stack for sequential reading.
class _GuideBody extends StatelessWidget {
  const _GuideBody({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => EjadahPageBody(
    maxWidth: EjadahSizes.readingMaxWidth,
    child: ListView(
      padding: const EdgeInsets.symmetric(vertical: EjadahSpacing.md),
      children: children,
    ),
  );
}
