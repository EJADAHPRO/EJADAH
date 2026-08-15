import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../auth/auth_controller.dart';

/// Profile.
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
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: EjadahColors.inset,
                      borderRadius: EjadahRadius.all(EjadahRadius.pill),
                    ),
                    child: Center(
                      child: Text(
                        user.initials(language),
                        style: context.type.h5(),
                      ),
                    ),
                  ),
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
                        if (user.isPremium && user.premiumRenewsOn != null)
                          EjadahBadge(
                            label: strings.rowMembership,
                            foreground: EjadahColors.warningText,
                            background: EjadahColors.tint(
                              EjadahColors.amber,
                              0.16,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: EjadahSpacing.lg),
              EjadahListRow(
                title: strings.rowShortlist,
                onTap: () => context.push('/shortlist'),
                trailing: const DirectionalIcon(
                  EjadahIcons.chevronForward,
                  color: EjadahColors.labelMuted,
                ),
              ),
              EjadahListRow(
                title: strings.languageLabel,
                subtitle: language == AppLanguage.ar ? 'العربية' : 'English',
                onTap: () => ref
                    .read(languageProvider.notifier)
                    .set(
                      language == AppLanguage.ar
                          ? AppLanguage.en
                          : AppLanguage.ar,
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
}
