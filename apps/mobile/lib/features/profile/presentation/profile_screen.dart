import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../auth/auth_controller.dart';
import '../application/profile_controllers.dart';
import 'certificates_screen.dart';
import 'cpd_screen.dart';
import 'nfc_card_screen.dart';
import 'public_profile_screen.dart';
import 'settings_screen.dart';
import 'widgets/profile_widgets.dart';

/// PR-01 · Profile home.
///
/// The five Profile features hang off this screen: the NFC card and its
/// editor, the public profile, certificates, the CPD ledger and settings.
///
/// Premium is read-only in Phase 1: status and renewal date, never prices —
/// membership is managed on the web.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final user = ref.watch(authControllerProvider).user;
    final language = ref.watch(languageProvider);

    if (user == null) {
      return Scaffold(
        body: SafeArea(
          child: EjadahEmptyState(
            title: strings.signIn,
            body: strings.registerSub,
            actionLabel: strings.signIn,
            onAction: () => context.push('/sign-in?next=/profile'),
          ),
        ),
      );
    }

    final card = ref.watch(myCardProvider);

    return Scaffold(
      body: SafeArea(
        child: EjadahPageBody(
          child: ListView(
            key: const PageStorageKey('profile'),
            children: [
              const SizedBox(height: EjadahSpacing.md),
              Row(
                children: [
                  // Initials on the inset surface — never a broken image, and
                  // never a placeholder stock portrait.
                  InitialsAvatar(name: user.fullName.resolve(language)),
                  const SizedBox(width: EjadahSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          user.fullName.resolve(language),
                          style: context.type.h5(),
                        ),
                        Text(
                          _stageLabel(strings, user.stage),
                          style: context.type.small(
                            color: EjadahColors.textSecondary,
                          ),
                        ),
                        if (user.isPremium && user.premiumRenewsOn != null) ...[
                          const SizedBox(height: EjadahSpacing.xxs),
                          EjadahBadge(
                            label: strings.rowMembership,
                            foreground: EjadahColors.warningText,
                            background: EjadahColors.tint(
                              EjadahColors.amber,
                              0.16,
                            ),
                          ),
                          const SizedBox(height: EjadahSpacing.xxs),
                          // The scope names the renewal date, not just the
                          // status: "Premium status (read-only) — status and
                          // renewal date, never prices". A badge alone left the
                          // date the user actually needs off the screen.
                          Text(
                            strings.premiumRenews(
                              formatCertificateDate(
                                user.premiumRenewsOn!,
                                language,
                              ),
                            ),
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

              // Premium: status and renewal date, never a price.
              if (user.isPremium && user.premiumRenewsOn != null) ...[
                const SizedBox(height: EjadahSpacing.md),
                EjadahListRow(
                  title: strings.currentPlan,
                  subtitle: toWesternDigits(
                    DateFormat(
                      'd MMM yyyy',
                      language.code,
                    ).format(user.premiumRenewsOn!.toLocal()),
                  ),
                  trailing: Text(
                    strings.manageOnWeb,
                    style: context.type.caption(
                      color: EjadahColors.labelMuted,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: EjadahSpacing.lg),
              SectionHeader(title: strings.profileEyebrow),
              EjadahListRow(
                title: strings.rowNfc,
                subtitle: card.maybeWhen(
                  data: (data) => data.shareUrl,
                  orElse: () => null,
                ),
                onTap: () => _push(context, ref, 'nfc-card', const NfcCardScreen()),
                trailing: const DirectionalIcon(
                  EjadahIcons.chevronForward,
                  color: EjadahColors.labelMuted,
                ),
              ),
              // The public page, seen exactly as a visitor sees it. Only
              // offered once a handle exists, so the row can never lead
              // somewhere that does not resolve.
              card.maybeWhen(
                data: (data) => data.isPublished
                    ? EjadahListRow(
                        title: strings.publicCardTitle,
                        subtitle: strings.publicPageNote,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => GradientBudget(
                              screenName: 'public-profile',
                              child: PublicProfileScreen(slug: data.slug!),
                            ),
                          ),
                        ),
                        trailing: const DirectionalIcon(
                          EjadahIcons.chevronForward,
                          color: EjadahColors.labelMuted,
                        ),
                      )
                    : const SizedBox.shrink(),
                orElse: () => const SizedBox.shrink(),
              ),
              EjadahListRow(
                title: strings.rowCertificates,
                subtitle: strings.tileCertificatesMeta,
                onTap: () => _push(context, ref, 'certificates', const CertificatesScreen()),
                trailing: const DirectionalIcon(
                  EjadahIcons.chevronForward,
                  color: EjadahColors.labelMuted,
                ),
              ),
              EjadahListRow(
                title: strings.incCpd,
                onTap: () => _push(context, ref, 'cpd', const CpdScreen()),
                trailing: const DirectionalIcon(
                  EjadahIcons.chevronForward,
                  color: EjadahColors.labelMuted,
                ),
              ),

              const SizedBox(height: EjadahSpacing.lg),
              SectionHeader(title: strings.account),
              EjadahListRow(
                title: strings.rowShortlist,
                onTap: () => context.push('/shortlist'),
                trailing: const DirectionalIcon(
                  EjadahIcons.chevronForward,
                  color: EjadahColors.labelMuted,
                ),
              ),
              EjadahListRow(
                title: strings.rowSettings,
                onTap: () => _push(context, ref, 'settings', const SettingsScreen()),
                trailing: const DirectionalIcon(
                  EjadahIcons.chevronForward,
                  color: EjadahColors.labelMuted,
                ),
              ),

              const SizedBox(height: EjadahSpacing.lg),
              EjadahSecondaryButton(
                label: strings.signOut,
                onPressed: () =>
                    ref.read(authControllerProvider.notifier).logout(),
              ),
              const SizedBox(height: EjadahSpacing.section),
            ],
          ),
        ),
      ),
    );
  }

  /// Sub-screens are pushed onto the root navigator, over the tab shell, and
  /// the card is refreshed on return so an edit is reflected immediately.
  Future<void> _push(
    BuildContext context,
    WidgetRef ref,
    String name,
    Widget screen,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        // Pushed outside the router, so the six-gradients-per-screen budget
        // is installed here rather than inherited from the route.
        builder: (_) => GradientBudget(screenName: name, child: screen),
      ),
    );
    ref.invalidate(myCardProvider);
  }

  static String _stageLabel(EjadahStrings strings, CareerStage stage) =>
      switch (stage) {
        CareerStage.student => strings.stageStudent,
        CareerStage.freshGraduate => strings.stageFreshGraduate,
        CareerStage.generalDentist => strings.stageGeneralDentist,
        CareerStage.specialist => strings.stageSpecialist,
        CareerStage.consultantOwner => strings.stageConsultantOwner,
      };
}
