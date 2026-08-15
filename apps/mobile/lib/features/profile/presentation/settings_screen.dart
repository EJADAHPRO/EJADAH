import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/providers.dart';
import '../application/profile_controllers.dart';
import '../data/profile_repository.dart';
import 'delete_account_screen.dart';

/// PR-11 · Settings.
///
/// Language, the three notification categories, wi-fi-only downloads, cache,
/// the legal pages and the version.
///
/// There are **three** notification toggles and there is deliberately no
/// marketing category — not switched off by default, not present at all. A
/// product that pings people about offers is not the product this is.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final language = ref.watch(languageProvider);
    final preferences = ref.watch(notificationPreferencesProvider);
    final wifiOnly = ref.watch(wifiOnlyDownloadsProvider);

    return Scaffold(
      appBar: EjadahAppBar(
        title: strings.rowSettings,
        onBack: () => Navigator.of(context).maybePop(),
        backLabel: strings.back,
      ),
      body: SafeArea(
        top: false,
        child: EjadahPageBody(
          child: ListView(
            key: const PageStorageKey('settings'),
            children: [
              const SizedBox(height: EjadahSpacing.md),
              SectionHeader(title: strings.languageLabel),
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
              SectionHeader(title: strings.notifPrefs),
              preferences.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: EjadahSpacing.sm),
                  child: Column(
                    children: [
                      Skeleton(width: double.infinity, height: EjadahSizes.tapTargetMin),
                      SizedBox(height: EjadahSpacing.xs),
                      Skeleton(width: double.infinity, height: EjadahSizes.tapTargetMin),
                      SizedBox(height: EjadahSpacing.xs),
                      Skeleton(width: double.infinity, height: EjadahSizes.tapTargetMin),
                    ],
                  ),
                ),
                error: (error, _) => EjadahErrorState(
                  title: FailureCopy.errorTitle(context),
                  body: error is Failure
                      ? error.message(context)
                      : FailureCopy.server(context),
                  retryLabel: strings.retry,
                  onRetry: () =>
                      ref.invalidate(notificationPreferencesProvider),
                ),
                data: (current) => Column(
                  children: [
                    _Toggle(
                      title: strings.notifDeadline,
                      value: current.deadlineAlerts,
                      onChanged: (value) => _save(
                        ref,
                        current.copyWith(deadlineAlerts: value),
                      ),
                    ),
                    _Toggle(
                      title: strings.notifBooking,
                      value: current.sessionReminders,
                      onChanged: (value) => _save(
                        ref,
                        current.copyWith(sessionReminders: value),
                      ),
                    ),
                    _Toggle(
                      title: strings.notifStudy,
                      value: current.studyNudges,
                      onChanged: (value) =>
                          _save(ref, current.copyWith(studyNudges: value)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: EjadahSpacing.lg),
              SectionHeader(title: strings.toolsLabel),
              // Wi-fi-only downloads. A device preference, not an account one.
              _Toggle(
                title: strings.download,
                value: wifiOnly,
                onChanged: (value) =>
                    ref.read(wifiOnlyDownloadsProvider.notifier).set(value),
              ),
              EjadahListRow(
                title: strings.clearCache,
                onTap: () {
                  // Clears what the app actually caches in memory. Saved work
                  // lives on the server and is untouched, which is why this
                  // needs no confirmation.
                  PaintingBinding.instance.imageCache
                    ..clear()
                    ..clearLiveImages();
                  showEjadahToast(context, message: strings.done);
                },
              ),

              const SizedBox(height: EjadahSpacing.lg),
              SectionHeader(title: strings.account),
              EjadahListRow(
                title: strings.privacy,
                subtitle: strings.webOnly,
                onTap: () => _open('https://ejadah.international/privacy'),
                trailing: const Icon(
                  EjadahIcons.externalLink,
                  size: EjadahIconSize.inline,
                  color: EjadahColors.labelMuted,
                ),
              ),
              EjadahListRow(
                title: strings.terms,
                subtitle: strings.webOnly,
                onTap: () => _open('https://ejadah.international/terms'),
                trailing: const Icon(
                  EjadahIcons.externalLink,
                  size: EjadahIconSize.inline,
                  color: EjadahColors.labelMuted,
                ),
              ),
              EjadahListRow(
                title: strings.appName,
                subtitle: appVersion,
              ),

              const SizedBox(height: EjadahSpacing.lg),
              EjadahGhostButton(
                label: strings.deleteAccount,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const GradientBudget(
                      screenName: 'delete-account',
                      child: DeleteAccountScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: EjadahSpacing.section),
            ],
          ),
        ),
      ),
    );
  }

  /// Applies the change optimistically, then persists it.
  Future<void> _save(WidgetRef ref, NotificationPreferences next) async {
    final repository = ref.read(profileRepositoryProvider);
    try {
      await repository.saveNotificationPreferences(next);
    } finally {
      ref.invalidate(notificationPreferencesProvider);
    }
  }

  Future<void> _open(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => EjadahListRow(
    title: title,
    onTap: () => onChanged(!value),
    trailing: Switch.adaptive(
      value: value,
      onChanged: onChanged,
      activeTrackColor: EjadahColors.orange,
    ),
  );
}
