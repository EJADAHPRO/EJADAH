import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A link to content that no longer exists.
///
/// Never a blank screen: the state names the likely reason — an intake usually
/// closed — and offers a working way onward.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return Scaffold(
      body: SafeArea(
        child: EjadahEmptyState(
          title: strings.errTitle,
          body: strings.contentUnavailableBody,
          actionLabel: strings.browseProgrammes,
          onAction: () => context.go('/programmes'),
        ),
      ),
    );
  }
}
