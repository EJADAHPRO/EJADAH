import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth_controller.dart';

/// Sign up.
///
/// Arriving from the guest gate is the common case, and the guest's funnel
/// answers and generated roadmap migrate to the new account in the same
/// transaction that creates it — the user lands back on the same roadmap, full.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({this.fromGate = false, this.next, super.key});

  final bool fromGate;

  /// Where to return once the account exists.
  final String? next;

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpState();
}

class _SignUpState extends ConsumerState<SignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _isSubmitting = false;
  Map<String, LocalizedText> _fieldErrors = const {};
  LocalizedText? _formError;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return GradientBudget(
      screenName: 'sign-up',
      child: Scaffold(
        appBar: EjadahAppBar(
          title: strings.createAccount,
          onBack: () => context.pop(),
          backLabel: strings.back,
        ),
        body: SafeArea(
          top: false,
          child: EjadahPageBody(
            child: ListView(
              children: [
                const SizedBox(height: EjadahSpacing.md),
                Text(strings.registerSub, style: context.type.bodyText()),
                const SizedBox(height: EjadahSpacing.lg),
                if (_formError != null) ...[
                  InlineAlert(
                    message: _formError!(context),
                    tone: AlertTone.danger,
                  ),
                  const SizedBox(height: EjadahSpacing.md),
                ],
                EjadahInput(
                  label: strings.fullName,
                  controller: _name,
                  hint: strings.namePlaceholder,
                  errorText: _fieldErrors['full_name']?.call(context),
                  autofillHints: const [AutofillHints.name],
                ),
                const SizedBox(height: EjadahSpacing.md),
                EjadahInput(
                  label: strings.email,
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  errorText: _fieldErrors['email']?.call(context),
                  autofillHints: const [AutofillHints.email],
                ),
                const SizedBox(height: EjadahSpacing.md),
                EjadahInput(
                  label: strings.password,
                  controller: _password,
                  obscureText: true,
                  helperText: strings.pwRule,
                  errorText: _fieldErrors['password']?.call(context),
                  autofillHints: const [AutofillHints.newPassword],
                ),
                const SizedBox(height: EjadahSpacing.lg),
                EjadahPrimaryButton(
                  label: strings.signUp,
                  isLoading: _isSubmitting,
                  // Duplicate submits are impossible while a submit is in
                  // flight: the callback is null, not merely ignored.
                  onPressed: _isSubmitting ? null : _submit,
                ),
                const SizedBox(height: EjadahSpacing.md),
                EjadahGhostButton(
                  label: strings.haveAccount,
                  onPressed: () => context.push('/sign-in'),
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
      _fieldErrors = const {};
      _formError = null;
    });

    try {
      await ref
          .read(authControllerProvider.notifier)
          .register(
            email: _email.text.trim(),
            password: _password.text,
            // Phase 1 collects one name; both language fields carry it until
            // the profile editor offers them separately.
            fullNameEn: _name.text.trim(),
            fullNameAr: _name.text.trim(),
            stage: CareerStage.generalDentist,
            fromGate: widget.fromGate,
          );

      if (!mounted) return;
      final next = widget.next;
      if (next != null && next.isNotEmpty) {
        context.go(next);
      } else {
        context.pop(true);
      }
    } on ValidationFailure catch (failure) {
      setState(() {
        _fieldErrors = failure.fields;
        _formError = failure.fields.isEmpty ? failure.message : null;
        _isSubmitting = false;
      });
    } on Failure catch (failure) {
      // The copy says what happened and what survived.
      setState(() {
        _formError = failure.message;
        _isSubmitting = false;
      });
    }
  }
}
