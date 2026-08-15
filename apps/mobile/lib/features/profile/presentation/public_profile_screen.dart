import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';

/// The public NFC profile at `/dr/{slug}`.
///
/// Renders for a signed-out visitor by design: it is the product's only organic
/// growth loop, so it is never gated. Only fields intended to be public appear,
/// and view analytics stay private — a viewer is never named.
class PublicProfileScreen extends StatelessWidget {
  const PublicProfileScreen({required this.slug, super.key});

  final String slug;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: EjadahPageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: EjadahSpacing.md),
            PageHeader(eyebrow: context.strings.publicCardTitle, title: slug),
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
