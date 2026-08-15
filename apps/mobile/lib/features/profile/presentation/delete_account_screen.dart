import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/auth_controller.dart';
import '../data/profile_repository.dart';

/// PR-13 · Account deletion, in two deliberate steps.
///
/// Step one lists what is actually lost. Step two requires the word DELETE to
/// be typed, so the destructive action cannot be reached by a mistap.
///
/// Two facts are stated before the button is offered, because both change the
/// decision: there is a **30-day** window in which the account comes back, and
/// **tax invoices are kept** — we cannot delete those, and saying so here is
/// better than a surprise later.
class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  /// The exact word, in Latin letters, in both languages. A translated
  /// confirmation word would be guessable by muscle memory.
  static const String _confirmWord = 'DELETE';

  final _confirmation = TextEditingController();
  bool _isSecondStep = false;
  bool _isDeleting = false;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _confirmation.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _confirmation.dispose();
    super.dispose();
  }

  bool get _isConfirmed => _confirmation.text.trim() == _confirmWord;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Scaffold(
      appBar: EjadahAppBar(
        title: strings.deleteAccountTitle,
        onBack: () => Navigator.of(context).maybePop(),
        backLabel: strings.back,
      ),
      body: SafeArea(
        top: false,
        child: EjadahPageBody(
          child: ListView(
            children: [
              const SizedBox(height: EjadahSpacing.md),
              PageHeader(
                eyebrow: strings.account,
                title: strings.deleteAccountTitle,
                // "You have 30 days to change your mind. Invoices are kept
                // for tax." — stated before anything is typed.
                subtitle: strings.deleteAccountBody,
              ),
              const SizedBox(height: EjadahSpacing.md),

              // Step one: what is lost, named specifically.
              EjadahCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Loss(label: strings.rowShortlist),
                    _Loss(label: strings.rowRoadmap),
                    _Loss(label: strings.rowBookings),
                    _Loss(label: strings.rowCertificates),
                    _Loss(label: strings.publicCardTitle),
                    _Loss(label: strings.myLearning),
                  ],
                ),
              ),
              const SizedBox(height: EjadahSpacing.md),
              InlineAlert(
                message: strings.deleteAccountBody,
                tone: AlertTone.warning,
              ),

              if (!_isSecondStep) ...[
                const SizedBox(height: EjadahSpacing.lg),
                EjadahSecondaryButton(
                  label: strings.continueAction,
                  onPressed: () => setState(() => _isSecondStep = true),
                ),
              ] else ...[
                const SizedBox(height: EjadahSpacing.lg),
                // Step two: type the word.
                EjadahInput(
                  label: strings.typeDeleteToConfirm,
                  controller: _confirmation,
                  hint: _confirmWord,
                  autofillHints: const [],
                ),
                if (_formError != null) ...[
                  const SizedBox(height: EjadahSpacing.sm),
                  InlineAlert(message: _formError!, tone: AlertTone.danger),
                ],
                const SizedBox(height: EjadahSpacing.md),
                EjadahDestructiveButton(
                  label: strings.deleteAccount,
                  isLoading: _isDeleting,
                  // Disabled until the word matches exactly, and the field
                  // above says which word.
                  onPressed: _isConfirmed ? _delete : null,
                ),
              ],
              const SizedBox(height: EjadahSpacing.xs),
              EjadahGhostButton(
                label: strings.cancel,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: EjadahSpacing.section),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _delete() async {
    setState(() {
      _isDeleting = true;
      _formError = null;
    });
    try {
      // The server already implements this as a soft delete with the 30-day
      // undo window and keeps tax invoices; the client only asks for it.
      await ref.read(profileRepositoryProvider).deleteAccount();
      await ref.read(authControllerProvider.notifier).logout();
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on Failure catch (failure) {
      if (!mounted) return;
      setState(() {
        _isDeleting = false;
        _formError = failure.message.resolve(context.language);
      });
    }
  }
}

class _Loss extends StatelessWidget {
  const _Loss({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(bottom: EjadahSpacing.xxs),
    child: Row(
      children: [
        const Icon(
          EjadahIcons.close,
          size: EjadahIconSize.inline,
          color: EjadahColors.dangerText,
        ),
        const SizedBox(width: EjadahSpacing.xs),
        Expanded(child: Text(label, style: context.type.bodyText())),
      ],
    ),
  );
}
