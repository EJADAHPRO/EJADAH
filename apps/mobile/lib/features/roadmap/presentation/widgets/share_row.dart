import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/providers.dart';

/// Sharing, WhatsApp first.
///
/// The distribution loop the product is built around: a dentist who reaches a
/// result and shows it to a colleague is worth more than any campaign, and the
/// handoff is explicit that it is **never gated** — a guest who has just met the
/// sign-up gate on stage three can still share what they have.
///
/// WhatsApp is first because it is where this audience already talks. Copying
/// the link is the fallback that always works, including where the app is not
/// installed.
class ShareRow extends ConsumerWidget {
  const ShareRow({
    required this.objectType,
    required this.message,
    required this.url,
    super.key,
  });

  /// `roadmap`, `programme`, `tutor`, `nfc_card` or `certificate` — the
  /// canonical taxonomy in `handoff/analytics-events.md`.
  final String objectType;

  /// What the recipient reads. Facts only, from the thing being shared.
  final String message;
  final String url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;

    return Row(
      children: [
        Expanded(
          child: EjadahSecondaryButton(
            label: strings.shareWhatsapp,
            icon: EjadahIcons.share,
            onPressed: () => _share(context, ref, channel: 'whatsapp'),
          ),
        ),
        const SizedBox(width: EjadahSpacing.sm),
        Expanded(
          child: EjadahGhostButton(
            label: strings.copyLink,
            onPressed: () => _share(context, ref, channel: 'copy'),
          ),
        ),
      ],
    );
  }

  Future<void> _share(
    BuildContext context,
    WidgetRef ref, {
    required String channel,
  }) async {
    final analytics = ref.read(analyticsProvider);
    await analytics.track(AnalyticsEvents.shareOpened, {
      'object_type': objectType,
    });

    final body = '$message\n$url';

    if (channel == 'copy') {
      await Clipboard.setData(ClipboardData(text: body));
      if (!context.mounted) return;
      showEjadahToast(context, message: context.strings.linkCopied);
    } else {
      // `wa.me` opens the app where it is installed and the web client where it
      // is not, so the fallback needs no detection.
      final uri = Uri.https('wa.me', '/', {'text': body});
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        // The share sheet did not open. Copying is the honest fallback rather
        // than a silent no-op.
        await Clipboard.setData(ClipboardData(text: body));
        if (!context.mounted) return;
        showEjadahToast(context, message: context.strings.linkCopied);
        await analytics.track(AnalyticsEvents.shareCompleted, {
          'object_type': objectType,
          'channel': 'copy',
        });
        return;
      }
    }

    await analytics.track(AnalyticsEvents.shareCompleted, {
      'object_type': objectType,
      'channel': channel,
    });
  }
}
