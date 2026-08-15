import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../application/profile_controllers.dart';
import '../data/profile_repository.dart';
import 'nfc_editor_screen.dart';
import 'widgets/profile_widgets.dart';
import 'widgets/qr_code.dart';

/// PR-03 · The user's own NFC card.
///
/// Shows the card exactly as a visitor sees it, the QR that opens it, and the
/// two things you can do with it: share the link, or order the physical card.
///
/// Ordering is an **external checkout**, like sessions — a physical product is
/// not digital content, so it does not go through in-app purchase.
class NfcCardScreen extends ConsumerWidget {
  const NfcCardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final card = ref.watch(myCardProvider);

    return Scaffold(
      appBar: EjadahAppBar(
        title: strings.rowNfc,
        onBack: () => Navigator.of(context).maybePop(),
        backLabel: strings.back,
      ),
      body: SafeArea(
        top: false,
        child: EjadahPageBody(
          child: card.when(
            loading: () => ListView(
              children: const [
                SizedBox(height: EjadahSpacing.md),
                Skeleton(width: double.infinity, height: 140),
                SizedBox(height: EjadahSpacing.cardGap),
                CardSkeleton(),
              ],
            ),
            error: (error, _) => EjadahErrorState(
              title: FailureCopy.errorTitle(context),
              body: error is Failure
                  ? error.message(context)
                  : FailureCopy.server(context),
              retryLabel: strings.retry,
              onRetry: () => ref.invalidate(myCardProvider),
            ),
            data: (data) => _Card(card: data),
          ),
        ),
      ),
    );
  }
}

class _Card extends ConsumerWidget {
  const _Card({required this.card});

  final MyProfileCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final language = context.language;
    final name = card.displayName.resolve(language);

    if (!card.isPublished) {
      // Nothing to share yet, and the empty state routes straight to the one
      // action that changes that.
      return EjadahEmptyState(
        title: strings.ctaSetUpCard,
        body: strings.publicPageNote,
        actionLabel: strings.editCard,
        onAction: () => _openEditor(context, ref),
      );
    }

    return ListView(
      key: const PageStorageKey('nfc-card'),
      children: [
        const SizedBox(height: EjadahSpacing.md),
        NfcCardPreview(
          name: name,
          title: card.title.resolve(language),
          clinic: card.clinic.resolve(language),
          url: card.shareUrl,
        ),
        const SizedBox(height: EjadahSpacing.md),
        Center(
          child: QrCodeView(
            data: card.shareUrl ?? '',
            semanticLabel: strings.publicCardTitle,
          ),
        ),
        const SizedBox(height: EjadahSpacing.md),
        InlineAlert(message: strings.nfcNote, tone: AlertTone.info),
        const SizedBox(height: EjadahSpacing.md),
        EjadahPrimaryButton(
          label: strings.shareCard,
          onPressed: () => _share(context, card.shareUrl!),
        ),
        const SizedBox(height: EjadahSpacing.xs),
        EjadahSecondaryButton(
          label: strings.editCard,
          onPressed: () => _openEditor(context, ref),
        ),
        const SizedBox(height: EjadahSpacing.xs),
        // External checkout, stated as such before the tap.
        EjadahGhostButton(
          label: strings.orderPhysical,
          onPressed: _orderPhysicalCard,
        ),
        const SizedBox(height: EjadahSpacing.xxs),
        Text(
          strings.payNoteExternal,
          style: context.type.caption(color: EjadahColors.textSecondary),
        ),
        const SizedBox(height: EjadahSpacing.section),
      ],
    );
  }

  Future<void> _openEditor(BuildContext context, WidgetRef ref) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GradientBudget(
          screenName: 'nfc-editor',
          child: NfcEditorScreen(card: card),
        ),
      ),
    );
    ref.invalidate(myCardProvider);
  }

  /// Copies the link and says so.
  ///
  /// The platform share sheet is not available to this build, so the action
  /// does the honest thing it can do rather than opening nothing.
  Future<void> _share(BuildContext context, String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (!context.mounted) return;
    showEjadahToast(context, message: url);
  }

  Future<void> _orderPhysicalCard() => launchUrl(
    Uri.parse('https://ejadah.international/checkout/nfc-card'),
    mode: LaunchMode.externalApplication,
  );
}
