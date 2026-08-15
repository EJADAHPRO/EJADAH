import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/auth_controller.dart';
import '../application/professional_profile_controller.dart';
import '../data/people_repository.dart';
import 'booking_flow_screen.dart';
import 'widgets/cairo_time.dart';
import 'widgets/professional_card.dart';

/// PE-03 — a tutor, mentor or consultant's profile.
///
/// The order of the page is the order of the decision: who they are, what they
/// can *prove*, what a plan actually looks like, when they are free, what other
/// students said, and what happens if you change your mind. The cancellation
/// terms are on this page rather than behind the booking flow, because reading
/// them after paying is not reading them.
class ProfessionalProfileScreen extends ConsumerWidget {
  const ProfessionalProfileScreen({required this.slug, super.key});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final state = ref.watch(professionalProfileControllerProvider(slug));

    return GradientBudget(
      screenName: 'professional-profile',
      child: Scaffold(
        appBar: EjadahAppBar(
          title: switch (state) {
            ProfessionalProfileReady(:final professional) =>
              professional.displayName(context),
            _ => strings.viewProfile,
          },
          backLabel: strings.back,
          onBack: () => context.pop(),
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: switch (state) {
            ProfessionalProfileLoading() => const _ProfileSkeleton(),
            ProfessionalProfileFailed(:final failure) => EjadahErrorState(
              title: FailureCopy.errorTitle(context),
              body: failure.message(context),
              retryLabel: strings.retry,
              onRetry: () => ref
                  .read(professionalProfileControllerProvider(slug).notifier)
                  .retry(),
            ),
            final ProfessionalProfileReady ready => _Profile(state: ready),
          },
        ),
        // The sticky bar carries the one main action on a screen taller than a
        // viewport, so "book" is never scrolled past.
        bottomNavigationBar: switch (state) {
          final ProfessionalProfileReady ready => _BookBar(state: ready),
          _ => null,
        },
      ),
    );
  }
}

class _Profile extends StatelessWidget {
  const _Profile({required this.state});

  final ProfessionalProfileReady state;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final professional = state.professional;

    return EjadahPageBody(
      child: ListView(
        key: PageStorageKey('profile-${professional.slug}'),
        children: [
          const SizedBox(height: EjadahSpacing.md),
          _Hero(professional: professional),
          if (professional.bio(context).isNotEmpty) ...[
            const SizedBox(height: EjadahSpacing.section),
            _Section(
              title: strings.aboutTutor,
              child: Text(
                professional.bio(context),
                style: context.type.bodyText(),
              ),
            ),
          ],
          if (professional.qualifications.isNotEmpty) ...[
            const SizedBox(height: EjadahSpacing.section),
            _Section(
              title: strings.qualificationsLabel,
              child: _Qualifications(
                qualifications: professional.qualifications,
              ),
            ),
          ],
          if (professional.packages.isNotEmpty) ...[
            const SizedBox(height: EjadahSpacing.section),
            _Section(
              title: strings.packagesLabel,
              child: _Packages(professional: professional),
            ),
          ],
          const SizedBox(height: EjadahSpacing.section),
          _Section(
            title: strings.availabilityLabel,
            child: _AvailabilityPreview(state: state),
          ),
          const SizedBox(height: EjadahSpacing.section),
          _Section(
            title: strings.reviewsLabel,
            child: _Reviews(reviews: state.profile.reviews),
          ),
          const SizedBox(height: EjadahSpacing.section),
          _Section(
            title: strings.cancelTermsLabel,
            // Stated before booking, in the professional's own recorded policy.
            child: Text(
              professional.cancellationPolicy(context),
              style: context.type.bodyText(color: EjadahColors.textSecondary),
            ),
          ),
          const SizedBox(height: EjadahSpacing.section),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.professional});

  final Professional professional;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final name = professional.displayName(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Initials, always — no licensed photography exists, and a stock
            // portrait of a stranger would undo the credibility this page is
            // built to establish.
            ProfessionalAvatar(
              name: name,
              avatarUrl: professional.avatarUrl,
              size: 72,
            ),
            const SizedBox(width: EjadahSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(name, style: context.type.h4(text: name)),
                  const SizedBox(height: EjadahSpacing.xxs),
                  Text(
                    professional.headline(context),
                    style: context.type.small(
                      color: EjadahColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: EjadahSpacing.sm),
        Wrap(
          spacing: EjadahSpacing.xs,
          runSpacing: EjadahSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (professional.isNewThisMonth)
              EjadahBadge(
                label: strings.newThisMonth,
                foreground: EjadahColors.orangeText,
                background: EjadahColors.tint(EjadahColors.orange),
              ),
            if (professional.offersFreeIntroCall)
              EjadahBadge(
                label: strings.freeIntroCall,
                foreground: EjadahColors.successText,
                background: EjadahColors.tint(EjadahColors.success),
                icon: EjadahIcons.check,
              ),
            for (final specialty in professional.specialties)
              EjadahTag(specialty),
            for (final language in professional.languages) EjadahTag(language),
          ],
        ),
        if (professional.reviewCount > 0) ...[
          const SizedBox(height: EjadahSpacing.xs),
          Row(
            children: [
              const Icon(
                EjadahIcons.star,
                size: EjadahIconSize.inline,
                color: EjadahColors.amber,
              ),
              const SizedBox(width: EjadahSpacing.xxs),
              LtrIsland(
                child: Text(
                  professional.rating?.toStringAsFixed(1) ?? '—',
                  style: context.type.bodyStrong(),
                ),
              ),
              const SizedBox(width: EjadahSpacing.xs),
              Text(
                strings.reviewsCount(professional.reviewCount),
                style: context.type.small(color: EjadahColors.labelMuted),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Verified versus stated, never conflated.
///
/// The two states differ in icon, colour *and* wording, and the row that says
/// "Stated by the tutor" is the honest one — pretending Ejadah checked a
/// document it never saw is exactly the credibility problem the product exists
/// to solve.
class _Qualifications extends StatelessWidget {
  const _Qualifications({required this.qualifications});

  final List<Qualification> qualifications;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final qualification in qualifications) ...[
          EjadahCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  qualification.title(context),
                  style: context.type.bodyStrong(),
                ),
                const SizedBox(height: EjadahSpacing.xxs),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        qualification.issuer(context),
                        style: context.type.small(
                          color: EjadahColors.textSecondary,
                        ),
                      ),
                    ),
                    if (qualification.year != null) ...[
                      const SizedBox(width: EjadahSpacing.xs),
                      LtrIsland(
                        child: Text(
                          '${qualification.year}',
                          style: context.type.micro(
                            color: EjadahColors.labelMuted,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: EjadahSpacing.xs),
                VerificationBadge(
                  evidence: qualification.evidence,
                  verifiedLabel: strings.verifiedByEjadah,
                  statedLabel: strings.statedByTutor,
                ),
              ],
            ),
          ),
          const SizedBox(height: EjadahSpacing.cardGap),
        ],
      ],
    );
  }
}

/// Packages, each stating its own cadence.
///
/// The sentence comes from the server — "One 60-minute session a week for eight
/// weeks" — so the booking flow never re-asks what the plan already answered.
class _Packages extends ConsumerWidget {
  const _Packages({required this.professional});

  final Professional professional;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final package in professional.packages) ...[
          EjadahCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(package.title(context), style: context.type.bodyStrong()),
                const SizedBox(height: EjadahSpacing.xxs),
                Text(
                  package.cadenceSentence(context),
                  style: context.type.small(
                    color: EjadahColors.textSecondary,
                  ),
                ),
                const SizedBox(height: EjadahSpacing.sm),
                Row(
                  children: [
                    CurrencyText(
                      amount: package.priceEgp,
                      currency: 'EGP',
                      style: context.type.bodyStrong(),
                    ),
                    const Spacer(),
                    EjadahGhostButton(
                      label: strings.bookNow,
                      color: EjadahColors.orangeText,
                      onPressed: () => openBookingFlow(
                        context,
                        ref,
                        professional: professional,
                        packageId: package.id,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: EjadahSpacing.cardGap),
        ],
      ],
    );
  }
}

/// The next few open times, as a preview.
///
/// Allowed to fail on its own: a profile whose calendar is briefly unreachable
/// is still worth reading, and the preview says it did not load rather than
/// silently showing "no times".
class _AvailabilityPreview extends ConsumerWidget {
  const _AvailabilityPreview({required this.state});

  final ProfessionalProfileReady state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;

    if (state.availabilityFailed) {
      return InlineAlert(message: FailureCopy.generic(context));
    }

    final open = state.openSlots.take(4).toList();
    if (open.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            strings.noSlots,
            style: context.type.bodyText(color: EjadahColors.textSecondary),
          ),
          const SizedBox(height: EjadahSpacing.xs),
          // The empty state routes to action rather than dead-ending.
          EjadahSecondaryButton(
            label: strings.pickAnotherWeek,
            expand: false,
            onPressed: () => openBookingFlow(
              context,
              ref,
              professional: state.professional,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          strings.timezoneNote,
          style: context.type.micro(color: EjadahColors.labelMuted),
        ),
        const SizedBox(height: EjadahSpacing.xs),
        for (final slot in open) ...[
          TimeText(
            CairoTime.stamp(slot.startsAt),
            style: context.type.bodyText(),
          ),
          const SizedBox(height: EjadahSpacing.xxs),
        ],
      ],
    );
  }
}

class _Reviews extends StatelessWidget {
  const _Reviews({required this.reviews});

  final List<ProfessionalReview> reviews;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      // A professional with no reviews yet says so plainly rather than showing
      // an empty star row, which reads as a bad score.
      return Text(
        context.strings.reviewsCount(0),
        style: context.type.bodyText(color: EjadahColors.textSecondary),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final review in reviews) ...[
          EjadahCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    for (var star = 1; star <= 5; star++)
                      Icon(
                        star <= review.rating
                            ? EjadahIcons.star
                            : EjadahIcons.starOutline,
                        size: EjadahIconSize.inline - 2,
                        color: EjadahColors.amber,
                      ),
                    const SizedBox(width: EjadahSpacing.xs),
                    Expanded(
                      child: Text(
                        review.authorName(context),
                        style: context.type.caption(
                          color: EjadahColors.labelStrong,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (review.body.isNotEmpty) ...[
                  const SizedBox(height: EjadahSpacing.xs),
                  Text(review.body, style: context.type.small()),
                ],
              ],
            ),
          ),
          const SizedBox(height: EjadahSpacing.cardGap),
        ],
      ],
    );
  }
}

/// The sticky booking bar: rate, then the one primary action.
class _BookBar extends ConsumerWidget {
  const _BookBar({required this.state});

  final ProfessionalProfileReady state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;

    return Container(
      decoration: const BoxDecoration(
        color: EjadahColors.background,
        border: Border(top: BorderSide(color: EjadahColors.border)),
        boxShadow: EjadahElevation.stickyTop,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(EjadahSpacing.md),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CurrencyText(
                    amount: state.professional.hourlyRateEgp,
                    currency: 'EGP',
                    style: context.type.bodyStrong(),
                  ),
                  Text(
                    strings.perHourRate,
                    style: context.type.micro(color: EjadahColors.labelMuted),
                  ),
                ],
              ),
              const SizedBox(width: EjadahSpacing.md),
              Expanded(
                child: EjadahPrimaryButton(
                  label: strings.bookNow,
                  onPressed: () => openBookingFlow(
                    context,
                    ref,
                    professional: state.professional,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      SectionHeader(title: title),
      const SizedBox(height: EjadahSpacing.xs),
      child,
    ],
  );
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) => EjadahPageBody(
    child: ListView(
      children: const [
        SizedBox(height: EjadahSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Skeleton(width: 72, height: 72),
            SizedBox(width: EjadahSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton(width: 160, height: 22),
                  SizedBox(height: EjadahSpacing.xs),
                  Skeleton(width: 220, height: 14),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: EjadahSpacing.section),
        Skeleton(width: 120, height: 12),
        SizedBox(height: EjadahSpacing.xs),
        Skeleton(width: double.infinity, height: 96),
        SizedBox(height: EjadahSpacing.section),
        Skeleton(width: 120, height: 12),
        SizedBox(height: EjadahSpacing.xs),
        Skeleton(width: double.infinity, height: 96),
      ],
    ),
  );
}

/// Opens the booking flow, gating on an account first.
///
/// Booking is one of the five gates. A guest is taken to sign-up carrying where
/// they were headed, and comes straight back to this professional.
Future<void> openBookingFlow(
  BuildContext context,
  WidgetRef ref, {
  required Professional professional,
  int? packageId,
}) async {
  if (!ref.read(authControllerProvider).isAuthenticated) {
    final next = Uri.encodeComponent('/people/who/${professional.slug}');
    await context.push('/sign-up?intent=book&next=$next');
    if (!context.mounted) return;
    if (!ref.read(authControllerProvider).isAuthenticated) return;
  }

  if (!context.mounted) return;
  await Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) =>
          BookingFlowScreen(professional: professional, packageId: packageId),
    ),
  );
}
