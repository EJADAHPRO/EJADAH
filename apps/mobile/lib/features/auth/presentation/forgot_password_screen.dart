import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth_controller.dart';

/// Password recovery.
///
/// The confirmation is deliberately conditional — "if that email is
/// registered" — and identical whether or not it is. The server answers the
/// same way for both, so the screen would be lying if it said "sent".
///
/// The link in the mail opens the website, which is where the new password is
/// set; there is no in-app reset step to reach.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();

  bool _isSubmitting = false;
  bool _isSent = false;
  LocalizedText? _error;

  @override
  void initState() {
    super.initState();
    // Enables the button the moment there is something to send.
    _email.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return GradientBudget(
      screenName: 'forgot-password',
      child: Scaffold(
        appBar: EjadahAppBar(
          title: strings.forgotTitle,
          onBack: () => context.pop(),
          backLabel: strings.back,
        ),
        body: SafeArea(
          top: false,
          child: EjadahPageBody(
            child: ListView(
              children: [
                const SizedBox(height: EjadahSpacing.lg),
                if (_error != null) ...[
                  InlineAlert(
                    message: _error!(context),
                    tone: AlertTone.danger,
                  ),
                  const SizedBox(height: EjadahSpacing.md),
                ],
                if (_isSent) ...[
                  // Confirmed, and honest about what was confirmed.
                  InlineAlert(
                    message: strings.forgotSent,
                    tone: AlertTone.success,
                  ),
                  const SizedBox(height: EjadahSpacing.lg),
                  EjadahPrimaryButton(
                    label: strings.backToSignIn,
                    onPressed: () => context.pop(),
                  ),
                ] else ...[
                  Text(
                    strings.forgotBody,
                    style: context.type.bodyText(),
                  ),
                  const SizedBox(height: EjadahSpacing.lg),
                  EjadahInput(
                    label: strings.email,
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    onSubmitted: (_) => _canSubmit ? _submit() : null,
                  ),
                  const SizedBox(height: EjadahSpacing.lg),
                  EjadahPrimaryButton(
                    label: strings.sendLink,
                    isLoading: _isSubmitting,
                    onPressed: _canSubmit ? _submit : null,
                    // A disabled control says why it is disabled.
                    disabledReason: strings.emailRequired,
                  ),
                ],
                const SizedBox(height: EjadahSpacing.section),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get _canSubmit => !_isSubmitting && _email.text.trim().isNotEmpty;

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      await ref
          .read(authRepositoryProvider)
          .requestPasswordReset(_email.text.trim());
      if (!mounted) return;
      setState(() {
        _isSent = true;
        _isSubmitting = false;
      });
    } on Failure catch (failure) {
      // A network failure is worth showing; the server's own answer never
      // distinguishes a known address from an unknown one.
      setState(() {
        _error = failure.message;
        _isSubmitting = false;
      });
    }
  }
}
