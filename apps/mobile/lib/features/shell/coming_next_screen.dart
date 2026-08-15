import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';

/// A tab whose feature set is later in the build order.
///
/// The handoff's own `stubBody` string is used verbatim rather than an invented
/// placeholder, and the screen says plainly what *is* wired. A blank tab that
/// looks broken would be worse than an honest one.
class ComingNextScreen extends StatelessWidget {
  const ComingNextScreen({
    required this.eyebrow,
    required this.title,
    super.key,
  });

  final String eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return Scaffold(
      body: SafeArea(
        child: EjadahPageBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: EjadahSpacing.md),
              PageHeader(eyebrow: eyebrow, title: title),
              const SizedBox(height: EjadahSpacing.lg),
              InlineAlert(message: strings.stubBody, tone: AlertTone.info),
            ],
          ),
        ),
      ),
    );
  }
}
