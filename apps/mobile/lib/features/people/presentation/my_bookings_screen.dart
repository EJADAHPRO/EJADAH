import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/bookings_controller.dart';
import 'widgets/cairo_time.dart';
import 'widgets/professional_card.dart';

/// PE-08 — My bookings. Upcoming · Past · Cancelled.
///
/// The rule that shapes this screen: **the refund tier is on the card, before
/// the cancel button.** Every row arrives carrying what it would pay back right
/// now, projected on the server from the same function the cancellation itself
/// uses, so the figure the user reads and the figure they receive cannot
/// disagree. Cancel-then-surprise is the failure this prevents.
class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final state = ref.watch(bookingsControllerProvider);

    return GradientBudget(
      screenName: 'my-bookings',
      child: Scaffold(
        appBar: EjadahAppBar(
          title: strings.bookingsTitle,
          backLabel: strings.back,
          onBack: () => context.pop(),
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              TabBar(
                controller: _tabs,
                labelColor: EjadahColors.textPrimary,
                unselectedLabelColor: EjadahColors.labelMuted,
                indicatorColor: EjadahColors.orange,
                dividerColor: EjadahColors.border,
                labelStyle: context.type.caption(),
                tabs: [
                  Tab(text: strings.bookingsUpcoming),
                  Tab(text: strings.bookingsPast),
                  Tab(text: strings.bookingsCancelled),
                ],
              ),
              Expanded(
                child: switch (state) {
                  BookingsLoading() => const _BookingsSkeleton(),
                  BookingsFailed(:final failure) => EjadahErrorState(
                    title: FailureCopy.errorTitle(context),
                    body: failure.message(context),
                    retryLabel: strings.retry,
                    onRetry: () =>
                        ref.read(bookingsControllerProvider.notifier).retry(),
                  ),
                  final BookingsReady ready => TabBarView(
                    controller: _tabs,
                    children: [
                      for (final tab in BookingTab.values)
                        _BookingsTab(tab: tab, bookings: ready.forTab(tab)),
                    ],
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingsTab extends ConsumerWidget {
  const _BookingsTab({required this.tab, required this.bookings});

  final BookingTab tab;
  final List<Booking> bookings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;

    if (bookings.isEmpty) {
      return EjadahEmptyState(
        title: strings.emptyBookTitle,
        body: strings.emptyBookBody,
        // Routes to action: the mentoring door, which is where a first session
        // most often comes from.
        actionLabel: strings.nextMentor,
        onAction: () => context.push('/people/mentoring'),
      );
    }

    return EjadahPageBody(
      child: ListView.separated(
        key: PageStorageKey('bookings-${tab.name}'),
        padding: const EdgeInsets.symmetric(vertical: EjadahSpacing.md),
        itemCount: bookings.length,
        separatorBuilder: (_, _) =>
            const SizedBox(height: EjadahSpacing.cardGap),
        itemBuilder: (context, index) =>
            _BookingCard(booking: bookings[index], tab: tab),
      ),
    );
  }
}

class _BookingCard extends ConsumerWidget {
  const _BookingCard({required this.booking, required this.tab});

  final Booking booking;
  final BookingTab tab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final start = booking.firstSessionStart;
    final name = booking.professionalName(context);

    return EjadahCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfessionalAvatar(name: name, avatarUrl: booking.avatarUrl),
              const SizedBox(width: EjadahSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: context.type.bodyStrong(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (start != null) ...[
                      const SizedBox(height: EjadahSpacing.xxs),
                      TimeText(
                        CairoTime.stamp(start),
                        style: context.type.small(
                          color: EjadahColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (booking.isMultiSession) ...[
            const SizedBox(height: EjadahSpacing.xs),
            Row(
              children: [
                LtrIsland(
                  child: Text(
                    '${booking.sessions.length}',
                    style: context.type.tabular(),
                  ),
                ),
                const SizedBox(width: EjadahSpacing.xxs),
                Text(
                  strings.sessionsLabel,
                  style: context.type.micro(color: EjadahColors.labelMuted),
                ),
              ],
            ),
          ],
          const SizedBox(height: EjadahSpacing.sm),
          Row(
            children: [
              Text(
                strings.sessionFee,
                style: context.type.small(color: EjadahColors.textSecondary),
              ),
              const Spacer(),
              CurrencyText(
                amount: booking.totalEgp,
                currency: 'EGP',
                style: context.type.bodyStrong(),
              ),
            ],
          ),
          // The tier, stated before the button — not after it, and not only in
          // the confirmation sheet.
          if (tab == BookingTab.upcoming) ...[
            const SizedBox(height: EjadahSpacing.xs),
            _RefundLine(booking: booking),
            const SizedBox(height: EjadahSpacing.sm),
            EjadahSecondaryButton(
              label: strings.cancel,
              expand: false,
              onPressed: () => _cancel(context, ref),
            ),
          ] else if (tab == BookingTab.cancelled &&
              booking.refundableEgp > 0) ...[
            const SizedBox(height: EjadahSpacing.xs),
            _RefundLine(booking: booking),
          ],
        ],
      ),
    );
  }

  /// The confirmation names the exact amount, and the result reports what was
  /// actually refunded rather than assuming the two agreed.
  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final strings = context.strings;

    final confirmed = await showEjadahConfirmDialog(
      context: context,
      title: strings.cancel,
      consequence: strings.refundIfCancelled(
        '${formatThousands(booking.refundableEgp)} EGP',
        '${formatThousands(booking.totalEgp)} EGP',
      ),
      confirmLabel: strings.cancel,
      cancelLabel: strings.back,
    );
    if (!confirmed || !context.mounted) return;

    try {
      final outcome = await ref
          .read(bookingsControllerProvider.notifier)
          .cancel(booking);
      if (!context.mounted) return;
      showEjadahToast(
        context,
        message: strings.refundIfCancelled(
          '${formatThousands(outcome.refundedEgp)} EGP',
          '${formatThousands(outcome.totalEgp)} EGP',
        ),
      );
    } on Failure catch (failure) {
      if (!context.mounted) return;
      showEjadahToast(context, message: failure.message(context));
    }
  }
}

/// "You'll be refunded EGP 800 of EGP 800."
///
/// Both figures are LTR islands inside one localized sentence, composed through
/// its placeholders rather than by concatenation.
class _RefundLine extends StatelessWidget {
  const _RefundLine({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Text(
      context.strings.refundIfCancelled(
        'EGP ${formatThousands(booking.refundableEgp)}',
        'EGP ${formatThousands(booking.totalEgp)}',
      ),
      style: context.type.small(
        color: booking.refundableEgp == 0
            ? EjadahColors.dangerText
            : EjadahColors.textSecondary,
      ),
    ),
  );
}

class _BookingsSkeleton extends StatelessWidget {
  const _BookingsSkeleton();

  @override
  Widget build(BuildContext context) => EjadahPageBody(
    child: ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: EjadahSpacing.md),
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(height: EjadahSpacing.cardGap),
      itemBuilder: (_, _) => const ProfessionalCardSkeleton(),
    ),
  );
}
