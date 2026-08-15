import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../application/profile_controllers.dart';
import '../data/profile_repository.dart';
import 'widgets/profile_widgets.dart';
import 'widgets/qr_code.dart';

/// The public NFC profile at `/dr/{slug}`.
///
/// Renders for a signed-out visitor by design: it is the product's only organic
/// growth loop, so it is never gated. Three consequences shape this screen:
///
/// * **No tab shell.** It is a page a stranger landed on, not a tab they are
///   browsing, so it carries no bottom navigation and no account chrome.
/// * **No analytics.** Views are counted server-side in aggregate and never
///   shown here; a viewer is never named, to the owner or to anyone else.
/// * **An install call to action.** This is often first contact with Ejadah,
///   so there is a way in — offered beside the content, never in front of it.
class PublicProfileScreen extends ConsumerWidget {
  const PublicProfileScreen({required this.slug, super.key});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final profile = ref.watch(publicProfileProvider(slug));

    return Scaffold(
      body: SafeArea(
        child: EjadahPageBody(
          child: profile.when(
            loading: () => ListView(
              children: const [
                SizedBox(height: EjadahSpacing.md),
                Skeleton(width: double.infinity, height: 140),
                SizedBox(height: EjadahSpacing.cardGap),
                CardSkeleton(),
                SizedBox(height: EjadahSpacing.cardGap),
                CardSkeleton(),
              ],
            ),
            error: (error, _) => error is NotFoundFailure
                // A link to a card that no longer exists resolves to a real
                // state with a working action, never a blank screen.
                ? EjadahEmptyState(
                    title: strings.contentUnavailableBody,
                    body: strings.publicPageNote,
                    actionLabel: strings.installEjadah,
                    onAction: _openEjadah,
                  )
                : EjadahErrorState(
                    title: FailureCopy.errorTitle(context),
                    body: error is Failure
                        ? error.message(context)
                        : FailureCopy.server(context),
                    retryLabel: strings.retry,
                    onRetry: () =>
                        ref.invalidate(publicProfileProvider(slug)),
                  ),
            data: (view) => _PublicCard(view: view),
          ),
        ),
      ),
    );
  }
}

class _PublicCard extends StatelessWidget {
  const _PublicCard({required this.view});

  final PublicProfileView view;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final language = context.language;
    final profile = view.profile;
    final name = profile.displayName.resolve(language);

    return ListView(
      key: const PageStorageKey('public-profile'),
      children: [
        const SizedBox(height: EjadahSpacing.md),
        PageHeader(eyebrow: strings.publicCardTitle, title: name),
        const SizedBox(height: EjadahSpacing.md),
        NfcCardPreview(
          name: name,
          title: profile.title.resolve(language),
          clinic: profile.clinic.resolve(language),
          url: view.shareUrl,
        ),
        if (profile.bio.isNotEmpty) ...[
          const SizedBox(height: EjadahSpacing.md),
          Text(
            profile.bio.resolve(language),
            style: context.type.bodyText(color: EjadahColors.textSecondary),
          ),
        ],
        if (profile.links.isNotEmpty) ...[
          const SizedBox(height: EjadahSpacing.md),
          for (final entry in profile.links.entries)
            EjadahListRow(
              title: entry.key,
              subtitle: entry.value,
              onTap: () => _open(entry.value),
              trailing: const Icon(
                EjadahIcons.externalLink,
                size: EjadahIconSize.inline,
                color: EjadahColors.labelMuted,
              ),
            ),
        ],
        const SizedBox(height: EjadahSpacing.section),
        SectionHeader(title: strings.certificatesTitle),
        const SizedBox(height: EjadahSpacing.xs),
        if (profile.certificates.isEmpty)
          // An honest empty: this person has no Ejadah-verified certificate
          // yet, and nothing here implies otherwise.
          InlineAlert(message: strings.verifyNote, tone: AlertTone.info)
        else
          for (final certificate in profile.certificates)
            Padding(
              padding: const EdgeInsetsDirectional.only(
                bottom: EjadahSpacing.cardGap,
              ),
              // Only verified certificates reach a public card; the server
              // filters them, and the badge still says so in words.
              child: CertificateTile(certificate: certificate),
            ),
        const SizedBox(height: EjadahSpacing.md),
        Center(
          child: QrCodeView(
            data: view.shareUrl,
            semanticLabel: strings.publicCardTitle,
          ),
        ),
        const SizedBox(height: EjadahSpacing.md),
        InlineAlert(message: strings.publicPageNote, tone: AlertTone.info),
        const SizedBox(height: EjadahSpacing.md),
        InstallEjadahCta(onInstall: _openEjadah),
        const SizedBox(height: EjadahSpacing.section),
      ],
    );
  }
}

Future<void> _open(String url) async {
  final uri = Uri.tryParse(url);
  // Only https links are stored, and only https links are opened.
  if (uri == null || uri.scheme != 'https') return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

Future<void> _openEjadah() => _open('https://ejadah.international');
