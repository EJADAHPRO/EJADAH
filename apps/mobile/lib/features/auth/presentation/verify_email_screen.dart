import 'dart:async';

import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth_controller.dart';

/// Confirming the email address.
///
/// Skippable on purpose. Nothing in Phase 1 is gated on a confirmed address —
/// the roadmap, the shortlist and browsing all work without it — so blocking
/// the app behind a code that landed in spam would cost more than it protects.
/// The screen says so, and offers the way past.
///
/// The 60-second resend cooldown is counted down in words rather than shown as
/// a greyed button, because a control that does nothing without saying why is
/// the failure this product's state matrix exists to prevent.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends ConsumerState<VerifyEmailScreen> {
  final _code = TextEditingController();

  bool _isSubmitting = false;
  LocalizedText? _error;
  int _cooldown = 0;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _code.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _code.dispose();
    super.dispose();
  }

  void _startCooldown(int seconds) {
    _ticker?.cancel();
    setState(() => _cooldown = seconds);
    if (seconds <= 0) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      setState(() => _cooldown -= 1);
      if (_cooldown <= 0) timer.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      appBar: EjadahAppBar(
        title: strings.verifyEmailTitle,
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
                InlineAlert(message: _error!(context), tone: AlertTone.danger),
                const SizedBox(height: EjadahSpacing.md),
              ],
              Text(
                strings.verifyEmailBody(user?.email ?? ''),
                style: context.type.bodyText(),
              ),
              const SizedBox(height: EjadahSpacing.lg),
              EjadahInput(
                label: strings.verificationCode,
                controller: _code,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                onSubmitted: (_) => _canSubmit ? _submit() : null,
              ),
              const SizedBox(height: EjadahSpacing.lg),
              EjadahPrimaryButton(
                label: strings.verifyEmailAction,
                isLoading: _isSubmitting,
                onPressed: _canSubmit ? _submit : null,
                disabledReason: strings.codeRequired,
                onDisabledTap: (reason) =>
                    showEjadahToast(context, message: reason),
              ),
              const SizedBox(height: EjadahSpacing.sm),
              EjadahGhostButton(
                // The cooldown is the label, not a disabled state.
                label: _cooldown > 0
                    ? strings.resendIn(_cooldown)
                    : strings.resendCode,
                onPressed: _cooldown > 0 ? null : _resend,
                disabledReason: strings.resendIn(_cooldown),
                onDisabledTap: (reason) =>
                    showEjadahToast(context, message: reason),
              ),
              const SizedBox(height: EjadahSpacing.md),
              EjadahGhostButton(
                // Nothing in Phase 1 needs a confirmed address, so this is a
                // real way out rather than a token one.
                label: strings.verifyLater,
                onPressed: () => context.pop(),
              ),
              const SizedBox(height: EjadahSpacing.section),
            ],
          ),
        ),
      ),
    );
  }

  bool get _canSubmit => !_isSubmitting && _code.text.trim().isNotEmpty;

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      await ref.read(authRepositoryProvider).verifyEmail(_code.text.trim());
      // Re-read the user so every screen keying off `emailVerified` updates.
      await ref.read(authControllerProvider.notifier).refreshUser();
      if (!mounted) return;
      showEjadahToast(context, message: context.strings.verifyEmailDone);
      context.pop();
    } on Failure catch (failure) {
      setState(() {
        _error = failure.message;
        _isSubmitting = false;
      });
    }
  }

  Future<void> _resend() async {
    try {
      final remaining = await ref
          .read(authRepositoryProvider)
          .resendVerification();
      if (!mounted) return;
      // Zero means one was actually sent; anything else is the server telling
      // us how long is left, and the label says so.
      _startCooldown(remaining > 0 ? remaining : 60);
    } on Failure catch (failure) {
      if (!mounted) return;
      showEjadahToast(context, message: failure.message(context));
    }
  }
}
