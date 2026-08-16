import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../application/dashboard_controller.dart';
import '../data/dashboard_repository.dart';
import 'widgets/cairo_time.dart';

/// PE-13 — the tutor's working day.
///
/// Ordered by what a tutor opens the app to find out, in that order: what is
/// happening today, what they have earned, what is holding money up, and what
/// the week ahead looks like.
///
/// **Money is a number and a date, not a chart.** A tutor with six sessions a
/// month has nothing to plot, and a sparkline over six points is decoration
/// standing where a figure should be. The two numbers that matter — what can be
/// asked for now, and what is still waiting — sit at the top with the rule that
/// separates them written underneath.
class TutorDashboardScreen extends ConsumerWidget {
  const TutorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final state = ref.watch(dashboardControllerProvider);

    return GradientBudget(
      screenName: 'tutor-dashboard',
      child: Scaffold(
        appBar: EjadahAppBar(
          title: strings.dashboardTitle,
          backLabel: strings.back,
          onBack: () =>
              context.canPop() ? context.pop() : context.go('/people'),
        ),
        body: SafeArea(
          top: false,
          child: switch (state) {
            AsyncData(:final value) => _Dashboard(dashboard: value),
            AsyncError(:final error) => EjadahErrorState(
              title: FailureCopy.errorTitle(context),
              body: error is Failure
                  ? error.message(context)
                  : FailureCopy.generic(context),
              retryLabel: strings.retry,
              onRetry: () =>
                  ref.read(dashboardControllerProvider.notifier).refresh(),
            ),
            _ => const _DashboardSkeleton(),
          },
        ),
      ),
    );
  }
}

class _Dashboard extends ConsumerWidget {
  const _Dashboard({required this.dashboard});

  final TutorDashboard dashboard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final type = context.type;

    return RefreshIndicator(
      onRefresh: () => ref.read(dashboardControllerProvider.notifier).refresh(),
      child: ListView(
        key: const PageStorageKey('tutor-dashboard'),
        padding: const EdgeInsets.only(bottom: EjadahSpacing.xxl),
        children: [
          EjadahPageBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: EjadahSpacing.md),

                if (dashboard.isHidden) ...[
                  // Stated at the top, every time. Being invisible is the kind
                  // of setting people forget they turned on and then blame the
                  // marketplace for.
                  InlineAlert(
                    message: strings.hiddenNow,
                    tone: AlertTone.warning,
                  ),
                  const SizedBox(height: EjadahSpacing.md),
                ],

                // --- Today ------------------------------------------------
                SectionHeader(title: strings.todaySessions),
                const SizedBox(height: EjadahSpacing.xs),
                if (dashboard.today.isEmpty)
                  Text(
                    strings.todayNone,
                    style: type.bodyText(color: EjadahColors.textSecondary),
                  )
                else
                  for (final session in dashboard.today)
                    Padding(
                      padding: const EdgeInsets.only(bottom: EjadahSpacing.sm),
                      child: _SessionCard(
                        session: session,
                        meetingUrl: dashboard.meetingUrl,
                        showJoin: true,
                      ),
                    ),

                const SizedBox(height: EjadahSpacing.lg),

                // --- Money ------------------------------------------------
                _Money(dashboard: dashboard),

                // --- Unmarked ---------------------------------------------
                if (dashboard.unmarked.isNotEmpty) ...[
                  const SizedBox(height: EjadahSpacing.lg),
                  SectionHeader(title: strings.unmarkedTitle),
                  const SizedBox(height: EjadahSpacing.xxs),
                  Text(
                    strings.unmarkedWhy,
                    style: type.caption(color: EjadahColors.textSecondary),
                  ),
                  const SizedBox(height: EjadahSpacing.xxs),
                  // The backstop, said out loud: forgetting is not punished.
                  Text(
                    strings.unmarkedAuto(dashboard.autoCompleteAfterDays),
                    style: type.caption(color: EjadahColors.labelMuted),
                  ),
                  const SizedBox(height: EjadahSpacing.sm),
                  for (final session in dashboard.unmarked)
                    Padding(
                      padding: const EdgeInsets.only(bottom: EjadahSpacing.sm),
                      child: _SessionCard(
                        session: session,
                        meetingUrl: dashboard.meetingUrl,
                        showMark: true,
                      ),
                    ),
                ],

                // --- The week ---------------------------------------------
                const SizedBox(height: EjadahSpacing.lg),
                SectionHeader(title: strings.restOfWeek),
                const SizedBox(height: EjadahSpacing.xs),
                if (dashboard.week.isEmpty)
                  Text(
                    strings.weekNone,
                    style: type.bodyText(color: EjadahColors.textSecondary),
                  )
                else
                  for (final session in dashboard.week)
                    Padding(
                      padding: const EdgeInsets.only(bottom: EjadahSpacing.sm),
                      child: _SessionCard(
                        session: session,
                        meetingUrl: dashboard.meetingUrl,
                      ),
                    ),

                const SizedBox(height: EjadahSpacing.xl),
                _HideMe(isHidden: dashboard.isHidden),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Two figures and the rule that separates them.
class _Money extends StatelessWidget {
  const _Money({required this.dashboard});

  final TutorDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final type = context.type;

    return DarkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            type.eyebrowText(strings.earningsAvailable),
            style: type.eyebrow(color: EjadahColors.onDarkMuted),
          ),
          const SizedBox(height: EjadahSpacing.xxs),
          CurrencyText(
            amount: dashboard.availableEgp,
            currency: 'EGP',
            style: type.h2(color: EjadahColors.onDark),
          ),
          if (dashboard.pendingEgp > 0) ...[
            const SizedBox(height: EjadahSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Text(
                    strings.earningsPending,
                    style: type.small(color: EjadahColors.onDarkMuted),
                  ),
                ),
                CurrencyText(
                  amount: dashboard.pendingEgp,
                  currency: 'EGP',
                  style: type.small(color: EjadahColors.onDarkMuted),
                ),
              ],
            ),
          ],
          const SizedBox(height: EjadahSpacing.sm),
          EjadahSecondaryButton(
            label: strings.earningsLink,
            expand: false,
            onPressed: () => context.push('/teach/earnings'),
          ),
        ],
      ),
    );
  }
}

/// One session: when, with whom, what for, and the one action it offers.
class _SessionCard extends ConsumerWidget {
  const _SessionCard({
    required this.session,
    this.meetingUrl,
    this.showJoin = false,
    this.showMark = false,
  });

  final TutorSession session;
  final String? meetingUrl;
  final bool showJoin;
  final bool showMark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final type = context.type;
    final hasLink = meetingUrl != null && meetingUrl!.isNotEmpty;

    return EjadahCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  strings.sessionWith(session.studentName(context)),
                  style: type.h6(),
                ),
              ),
              // A clock time stays LTR in both languages.
              CodeText(
                CairoTime.time(session.startsAt),
                style: type.tabular(fontSize: EjadahTypeSize.small),
              ),
            ],
          ),
          if (session.subject.isNotEmpty) ...[
            const SizedBox(height: EjadahSpacing.xxs),
            Text(
              session.subject,
              style: type.small(color: EjadahColors.textSecondary),
            ),
          ],
          if (session.goal.isNotEmpty) ...[
            const SizedBox(height: EjadahSpacing.xxs),
            // Why the session is worth preparing for. It reaches this tutor
            // and nobody else.
            Text(
              session.goal,
              style: type.caption(color: EjadahColors.textSecondary),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (showJoin) ...[
            const SizedBox(height: EjadahSpacing.sm),
            if (hasLink)
              EjadahPrimaryButton(
                label: strings.joinSession,
                icon: EjadahIcons.externalLink,
                onPressed: () => launchUrl(
                  Uri.parse(meetingUrl!),
                  mode: LaunchMode.externalApplication,
                ),
              )
            else
              // Never a Join button that goes nowhere. The missing link is the
              // problem, so the action is to supply it.
              EjadahSecondaryButton(
                label: strings.addMeetingLink,
                onPressed: () => _editMeetingUrl(context, ref),
              ),
          ],
          if (showMark) ...[
            const SizedBox(height: EjadahSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: EjadahPrimaryButton(
                    label: strings.markHeld,
                    onPressed: () => _mark(context, ref),
                  ),
                ),
                const SizedBox(width: EjadahSpacing.sm),
                // What marking is worth, on the row that marks it.
                CurrencyText(
                  amount: session.netEgp,
                  currency: 'EGP',
                  style: type.bodyText(),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _mark(BuildContext context, WidgetRef ref) async {
    final failure = await ref
        .read(dashboardControllerProvider.notifier)
        .mark(session.id);
    if (!context.mounted) return;
    showEjadahToast(
      context,
      message: failure?.message(context) ?? context.strings.markedLabel,
    );
  }
}

/// Asks for the tutor's meeting room.
Future<void> _editMeetingUrl(BuildContext context, WidgetRef ref) async {
  final controller = TextEditingController(
    text: ref.read(dashboardControllerProvider).valueOrNull?.meetingUrl ?? '',
  );
  final strings = context.strings;

  final url = await showEjadahSheet<String>(
    context: context,
    screenName: 'meeting-url',
    builder: (sheetContext) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EjadahInput(
          label: strings.meetingLinkLabel,
          controller: controller,
          hint: strings.meetingLinkHint,
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: EjadahSpacing.md),
        EjadahPrimaryButton(
          label: strings.save,
          onPressed: () =>
              Navigator.of(sheetContext).pop(controller.text.trim()),
        ),
        const SizedBox(height: EjadahSpacing.sm),
      ],
    ),
  );
  controller.dispose();
  if (url == null || !context.mounted) return;

  final failure = await ref
      .read(dashboardControllerProvider.notifier)
      .setMeetingUrl(url);
  if (context.mounted && failure != null) {
    showEjadahToast(context, message: failure.message(context));
  }
}

/// "Hide me for now."
class _HideMe extends ConsumerWidget {
  const _HideMe({required this.isHidden});

  final bool isHidden;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final type = context.type;

    return EjadahCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.hideMeTitle, style: type.h6()),
                const SizedBox(height: EjadahSpacing.xxs),
                // The half people worry about, said before they touch it: an
                // already-booked session still happens.
                Text(
                  strings.hideMeBody,
                  style: type.caption(color: EjadahColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: EjadahSpacing.sm),
          Switch.adaptive(
            value: isHidden,
            onChanged: (value) => _toggle(context, ref, value),
          ),
        ],
      ),
    );
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref, bool hidden) async {
    final failure = await ref
        .read(dashboardControllerProvider.notifier)
        .setHidden(hidden);
    if (context.mounted && failure != null) {
      showEjadahToast(context, message: failure.message(context));
    }
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) => EjadahPageBody(
    // Scrollable: a skeleton stands in for content that scrolls, and a fixed
    // column of blocks overflows on a short viewport.
    child: ListView(
      children: const [
        SizedBox(height: EjadahSpacing.md),
        Skeleton(width: 120, height: 16),
        SizedBox(height: EjadahSpacing.sm),
        Skeleton(width: double.infinity, height: 96),
        SizedBox(height: EjadahSpacing.lg),
        Skeleton(width: double.infinity, height: 140),
        SizedBox(height: EjadahSpacing.lg),
        Skeleton(width: double.infinity, height: 96),
      ],
    ),
  );
}
