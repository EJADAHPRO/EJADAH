import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../profile/presentation/widgets/profile_widgets.dart';
import '../application/earnings_controller.dart';
import '../data/earnings_repository.dart';

/// PE-15 — what a tutor has earned, and asking to be paid it.
///
/// The design rule this screen exists to keep: **never show a share without
/// showing what was taken to arrive at it.** Every row is the whole
/// subtraction — the session's price, Ejadah's fee, and what is left — because
/// a single "your share" figure is the number a tutor cannot check and
/// therefore does not trust.
///
/// The rows are a table inside an LTR island in both languages. Figures read
/// left to right and their columns line up, so a tutor scanning a month of
/// sessions can add them up by eye; a mirrored money column in Arabic would
/// put the units where the thousands should be.
class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final earnings = ref.watch(earningsControllerProvider);

    return GradientBudget(
      screenName: 'earnings',
      child: Scaffold(
        appBar: EjadahAppBar(
          title: strings.earningsTitle,
          backLabel: strings.back,
          onBack: () =>
              context.canPop() ? context.pop() : context.go('/profile'),
        ),
        body: SafeArea(
          top: false,
          child: switch (earnings) {
            AsyncData(:final value) => _Ledger(earnings: value),
            AsyncError(:final error) => EjadahErrorState(
              title: FailureCopy.errorTitle(context),
              body: error is Failure
                  ? error.message(context)
                  : FailureCopy.generic(context),
              retryLabel: strings.retry,
              onRetry: () =>
                  ref.read(earningsControllerProvider.notifier).refresh(),
            ),
            _ => const _EarningsSkeleton(),
          },
        ),
      ),
    );
  }
}

class _Ledger extends ConsumerWidget {
  const _Ledger({required this.earnings});

  final Earnings earnings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final type = context.type;
    final summary = earnings.summary;

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () =>
                ref.read(earningsControllerProvider.notifier).refresh(),
            child: ListView(
              key: const PageStorageKey('earnings'),
              padding: const EdgeInsets.only(bottom: EjadahSpacing.lg),
              children: [
                EjadahPageBody(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: EjadahSpacing.md),

                      // The balance, and beside it what is not yet part of it.
                      DarkCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              type.eyebrowText(strings.earningsAvailable),
                              style: type.eyebrow(
                                color: EjadahColors.onDarkMuted,
                              ),
                            ),
                            const SizedBox(height: EjadahSpacing.xxs),
                            CurrencyText(
                              amount: summary.availableEgp,
                              currency: 'EGP',
                              style: type.h2(color: EjadahColors.onDark),
                            ),
                            if (summary.pendingEgp > 0) ...[
                              const SizedBox(height: EjadahSpacing.sm),
                              _MutedLine(
                                label: strings.earningsPending,
                                amount: summary.pendingEgp,
                              ),
                              const SizedBox(height: EjadahSpacing.xxs),
                              // Why it is not in the balance, stated rather
                              // than left as a figure that will not move.
                              Text(
                                strings.earningsPendingWhy,
                                style: type.caption(
                                  color: EjadahColors.onDarkFaint,
                                ),
                              ),
                            ],
                            if (summary.requestedEgp > 0) ...[
                              const SizedBox(height: EjadahSpacing.sm),
                              _MutedLine(
                                label: strings.earningsRequested,
                                amount: summary.requestedEgp,
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: EjadahSpacing.lg),
                      SectionHeader(title: strings.earningsLifetime),
                      const SizedBox(height: EjadahSpacing.xs),
                      Text(
                        strings.earningsLifetimeRow(
                          'EGP ${formatThousands(summary.lifetimeGrossEgp)}',
                          'EGP ${formatThousands(summary.lifetimeFeeEgp)}',
                          'EGP ${formatThousands(summary.lifetimeNetEgp)}',
                        ),
                        style: type.bodyText(),
                      ),

                      const SizedBox(height: EjadahSpacing.lg),
                      SectionHeader(title: strings.earningsRowsTitle),
                      const SizedBox(height: EjadahSpacing.sm),
                    ],
                  ),
                ),
                if (earnings.rows.isEmpty)
                  EjadahPageBody(
                    child: EjadahEmptyState(
                      title: strings.earningsRowsTitle,
                      body: strings.earningsEmpty,
                      actionLabel: strings.peopleTutoringDoor,
                      onAction: () => context.go('/people'),
                    ),
                  )
                else
                  EjadahPageBody(
                    child: _RowTable(
                      rows: earnings.rows,
                      feePercent: earnings.platformFeePercent,
                    ),
                  ),
                if (earnings.payouts.isNotEmpty) ...[
                  const SizedBox(height: EjadahSpacing.lg),
                  EjadahPageBody(child: _Payouts(payouts: earnings.payouts)),
                ],
              ],
            ),
          ),
        ),
        _PayoutBar(earnings: earnings),
      ],
    );
  }
}

class _MutedLine extends StatelessWidget {
  const _MutedLine({required this.label, required this.amount});

  final String label;
  final int amount;

  @override
  Widget build(BuildContext context) {
    final type = context.type;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: type.small(color: EjadahColors.onDarkMuted),
          ),
        ),
        CurrencyText(
          amount: amount,
          currency: 'EGP',
          style: type.small(color: EjadahColors.onDarkMuted),
        ),
      ],
    );
  }
}

/// The subtraction, one row per session, columns aligned.
class _RowTable extends StatelessWidget {
  const _RowTable({required this.rows, required this.feePercent});

  final List<EarningRow> rows;
  final int feePercent;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final type = context.type;

    // One island around the whole table, not one per cell: the columns have to
    // agree with each other, and a per-cell island leaves the header in the
    // page's direction and the figures in the other.
    return LtrIsland(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  type.eyebrowText(strings.earningsColumnGross),
                  style: type.eyebrow(color: EjadahColors.labelMuted),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  type.eyebrowText(strings.earningsColumnFee(feePercent)),
                  textAlign: TextAlign.end,
                  style: type.eyebrow(color: EjadahColors.labelMuted),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  type.eyebrowText(strings.earningsColumnNet),
                  textAlign: TextAlign.end,
                  style: type.eyebrow(color: EjadahColors.labelMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: EjadahSpacing.xs),
          const Divider(height: 1, color: EjadahColors.border),
          for (final row in rows) _TableRow(row: row),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({required this.row});

  final EarningRow row;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final type = context.type;

    // A reversed row is shown, dimmed and struck through rather than removed:
    // a ledger that quietly drops a line is a ledger a tutor cannot reconcile
    // against their own memory of the month.
    final isReversed = row.status == EarningStatus.reversed;
    final colour = isReversed
        ? EjadahColors.labelMuted
        : EjadahColors.textPrimary;

    return Semantics(
      // Read as one sentence. Three anonymous numbers in a row is what a screen
      // reader would otherwise announce.
      label:
          '${row.subject}. '
          '${strings.earningsColumnGross} ${row.grossEgp}. '
          '${strings.earningsColumnNet} ${row.netEgp}.',
      container: true,
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: EjadahSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.subject.isEmpty
                          ? strings.earningsWith(row.description(context))
                          : row.subject,
                      style: type.bodyText(color: colour),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${formatCertificateDate(row.occurredAt, context.language)}'
                      ' · ${_statusLabel(strings, row.status)}',
                      style: type.caption(color: EjadahColors.labelMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  // The fee carries its sign. "300" beside "1,000" reads as an
                  // amount received; "−300" reads as what it is.
                  '−${formatThousands(row.platformFeeEgp)}',
                  textAlign: TextAlign.end,
                  style: type.bodyText(color: EjadahColors.labelMuted),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  formatThousands(row.netEgp),
                  textAlign: TextAlign.end,
                  style: type
                      .bodyText(color: colour)
                      .copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: isReversed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _statusLabel(EjadahStrings strings, EarningStatus status) =>
      switch (status) {
        EarningStatus.pending => strings.earningsPending,
        EarningStatus.available => strings.earningsAvailable,
        EarningStatus.requested => strings.earningsRequested,
        EarningStatus.paid => strings.earningsPaid,
        EarningStatus.reversed => strings.earningsReversed,
      };
}

class _Payouts extends StatelessWidget {
  const _Payouts({required this.payouts});

  final List<PayoutRequest> payouts;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: strings.payoutsTitle),
        const SizedBox(height: EjadahSpacing.xs),
        for (final payout in payouts)
          EjadahListRow(
            title: 'EGP ${formatThousands(payout.amountEgp)}',
            subtitle: formatCertificateDate(
              payout.requestedAt,
              context.language,
            ),
            trailing: EjadahBadge(
              label: _label(strings, payout.status),
              foreground: payout.status == 'paid'
                  ? EjadahColors.successText
                  : EjadahColors.labelStrong,
              background: EjadahColors.inset,
            ),
          ),
      ],
    );
  }

  static String _label(EjadahStrings strings, String status) =>
      switch (status) {
        'approved' => strings.payoutApproved,
        'paid' => strings.payoutPaid,
        'rejected' => strings.payoutRejected,
        _ => strings.payoutRequested,
      };
}

/// The sticky bar. The action is reachable without scrolling a month of rows.
class _PayoutBar extends ConsumerWidget {
  const _PayoutBar({required this.earnings});

  final Earnings earnings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final reason = earnings.payoutBlockedReason;

    return EjadahStickyBar(
      reason: reason?.call(context),
      child: EjadahPrimaryButton(
        label: strings.requestPayout,
        onPressed: earnings.canRequestPayout
            ? () => _request(context, ref)
            : null,
        disabledReason: reason?.call(context),
        onDisabledTap: (message) => showEjadahToast(context, message: message),
      ),
    );
  }

  Future<void> _request(BuildContext context, WidgetRef ref) async {
    final failure = await ref
        .read(earningsControllerProvider.notifier)
        .requestPayout();
    if (!context.mounted) return;
    showEjadahToast(
      context,
      // The server's own reason on failure — usually the shortfall, which is
      // the most useful sentence available.
      message: failure?.message(context) ?? context.strings.payoutOpened,
    );
  }
}

class _EarningsSkeleton extends StatelessWidget {
  const _EarningsSkeleton();

  @override
  Widget build(BuildContext context) => EjadahPageBody(
    // Scrollable: a skeleton stands in for content that scrolls, and a fixed
    // column of blocks overflows on a short viewport — which paints Flutter's
    // striped overflow bar exactly where a loading state should look calm.
    child: ListView(
      children: const [
        SizedBox(height: EjadahSpacing.md),
        Skeleton(width: double.infinity, height: 140),
        SizedBox(height: EjadahSpacing.lg),
        Skeleton(width: 160, height: 16),
        SizedBox(height: EjadahSpacing.md),
        Skeleton(width: double.infinity, height: 56),
        SizedBox(height: EjadahSpacing.sm),
        Skeleton(width: double.infinity, height: 56),
        SizedBox(height: EjadahSpacing.sm),
        Skeleton(width: double.infinity, height: 56),
      ],
    ),
  );
}
