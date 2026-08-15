import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';

/// Public certificate verification at `/verify/{code}`.
///
/// No account, never charged for: someone checking a credential is free
/// marketing arriving at the door.
class VerifyCertificateScreen extends StatelessWidget {
  const VerifyCertificateScreen({required this.code, super.key});

  final String code;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: EjadahPageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: EjadahSpacing.md),
            PageHeader(eyebrow: context.strings.certCode, title: code),
            const SizedBox(height: EjadahSpacing.lg),
            InlineAlert(
              message: context.strings.stubBody,
              tone: AlertTone.info,
            ),
          ],
        ),
      ),
    ),
  );
}
