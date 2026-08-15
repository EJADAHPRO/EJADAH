import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth_controller.dart';

/// Sign in.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({this.next, super.key});

  /// Where the user was headed before the gate.
  final String? next;

  @override
  ConsumerState<SignInScreen> createState() => _SignInState();
}

class _SignInState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _isSubmitting = false;
  LocalizedText? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return GradientBudget(
      screenName: 'sign-in',
      child: Scaffold(
        appBar: EjadahAppBar(
          title: strings.signIn,
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
                EjadahInput(
                  label: strings.email,
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                ),
                const SizedBox(height: EjadahSpacing.md),
                EjadahInput(
                  label: strings.password,
                  controller: _password,
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                ),
                const SizedBox(height: EjadahSpacing.lg),
                EjadahPrimaryButton(
                  label: strings.signIn,
                  isLoading: _isSubmitting,
                  onPressed: _isSubmitting ? null : _submit,
                ),
                const SizedBox(height: EjadahSpacing.md),
                EjadahGhostButton(
                  label: strings.forgotPassword,
                  onPressed: () => context.push('/forgot-password'),
                ),
                const SizedBox(height: EjadahSpacing.section),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      await ref
          .read(authControllerProvider.notifier)
          .login(email: _email.text.trim(), password: _password.text);
      if (!mounted) return;

      final next = widget.next;
      if (next != null && next.isNotEmpty) {
        context.go(next);
      } else {
        context.pop(true);
      }
    } on Failure catch (failure) {
      setState(() {
        _error = failure.message;
        _isSubmitting = false;
      });
    }
  }
}
