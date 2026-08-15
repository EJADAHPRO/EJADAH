import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';

/// The first screen: pick a language.
///
/// Two cards, and the tap *is* the action — no confirm step. Arabic leads
/// because it is the product default, not because it sorts first.
class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    body: SafeArea(
      child: EjadahPageBody(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (language, label) in const [
              (AppLanguage.ar, 'العربية'),
              (AppLanguage.en, 'English'),
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: EjadahSpacing.cardGap),
                child: EjadahCard(
                  semanticLabel: label,
                  onTap: () async {
                    await ref.read(languageProvider.notifier).set(language);
                    // Recorded here, at the one action that ends first run, so
                    // the pick is never asked for twice.
                    await ref.read(localStoreProvider).setOnboardingComplete();
                    if (context.mounted) context.go('/home');
                  },
                  child: Center(
                    child: Text(label, style: context.type.h4(text: label)),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
