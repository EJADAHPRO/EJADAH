import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/auth_controller.dart';
import '../application/learn_controllers.dart';
import '../data/learn_models.dart';
import '../data/learn_repository.dart';

/// LN-04 · The in-app purchase sheet.
///
/// Courses are digital content and are therefore bought **only** through the
/// app store (Apple §3.1.1). There is no external checkout for a course
/// anywhere in this product, and this sheet quotes no price of its own: the
/// store is the pricing authority, so a figure printed here could disagree with
/// what the user is actually charged.
///
/// Sessions are the opposite case — they are paid on the website through the
/// redirect sheet — and the two must never be harmonised.
Future<void> showIapPurchaseSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String slug,
}) async {
  // Purchasing is one of the five gates. The guest is taken to sign-in and
  // comes straight back to the course they were looking at.
  if (!ref.read(authControllerProvider).isAuthenticated) {
    await context.push<bool>('/sign-in?next=${Uri.encodeComponent('/learn')}');
    if (!context.mounted) return;
    if (!ref.read(authControllerProvider).isAuthenticated) return;
  }

  if (!context.mounted) return;
  await showEjadahSheet<void>(
    context: context,
    builder: (context) => _PurchaseSheet(slug: slug),
  );
}

class _PurchaseSheet extends ConsumerStatefulWidget {
  const _PurchaseSheet({required this.slug});

  final String slug;

  @override
  ConsumerState<_PurchaseSheet> createState() => _PurchaseSheetState();
}

class _PurchaseSheetState extends ConsumerState<_PurchaseSheet> {
  bool _isBuying = false;
  bool _isRestoring = false;
  String? _failureMessage;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final detail = ref.watch(courseDetailProvider(widget.slug));

    return detail.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: EjadahSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Skeleton(width: 200, height: 20),
            SizedBox(height: EjadahSpacing.sm),
            Skeleton(width: double.infinity, height: 14),
            SizedBox(height: EjadahSpacing.lg),
            Skeleton(width: double.infinity, height: 52),
          ],
        ),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: EjadahSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InlineAlert(
              tone: AlertTone.danger,
              message: error is Failure
                  ? error.message(context)
                  : FailureCopy.server(context),
            ),
            const SizedBox(height: EjadahSpacing.md),
            EjadahSecondaryButton(
              label: strings.retry,
              onPressed: () =>
                  ref.invalidate(courseDetailProvider(widget.slug)),
            ),
          ],
        ),
      ),
      data: (data) => _body(context, data),
    );
  }

  Widget _body(BuildContext context, CourseDetail detail) {
    final strings = context.strings;
    final course = detail.course;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(course.title(context), style: context.type.h5()),
        const SizedBox(height: EjadahSpacing.xxs),
        Text(
          strings.lessonOneFree,
          style: context.type.small(color: EjadahColors.successText),
        ),
        const SizedBox(height: EjadahSpacing.md),
        for (final line in [
          strings.incLifetime,
          if (detail.handouts.isNotEmpty) strings.incHandouts,
          if (course.cpdPoints > 0) strings.incCpd,
          strings.incCert,
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: EjadahSpacing.xs),
            child: Row(
              children: [
                const Icon(
                  EjadahIcons.check,
                  size: EjadahIconSize.inline,
                  color: EjadahColors.successText,
                ),
                const SizedBox(width: EjadahSpacing.xs),
                Expanded(child: Text(line, style: context.type.small())),
              ],
            ),
          ),
        if (_failureMessage != null) ...[
          const SizedBox(height: EjadahSpacing.sm),
          InlineAlert(tone: AlertTone.danger, message: _failureMessage!),
        ],
        const SizedBox(height: EjadahSpacing.md),
        // No price. The store shows the price and takes the payment; printing
        // a number here would be a second source of truth for money.
        EjadahPrimaryButton(
          label: strings.buyCourse,
          isLoading: _isBuying,
          onPressed: _isRestoring ? null : () => _buy(course.id),
          // Restoring holds the store connection; buying meanwhile would race
          // it. Grey with no explanation reads as a broken purchase button on
          // the one screen where that costs a sale.
          disabledReason: strings.whileRestoring,
          onDisabledTap: (reason) => showEjadahToast(context, message: reason),
        ),
        const SizedBox(height: EjadahSpacing.xs),
        Text(
          strings.storePurchaseNote,
          style: context.type.micro(color: EjadahColors.labelMuted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: EjadahSpacing.xs),
        EjadahSecondaryButton(
          label: strings.restorePurchases,
          isLoading: _isRestoring,
          onPressed: _isBuying ? null : _restore,
        ),
        const SizedBox(height: EjadahSpacing.xs),
        EjadahGhostButton(
          label: strings.maybeLater,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }

  /// Completes the purchase.
  ///
  /// On a real build this is where the store's purchase flow runs and hands
  /// back a receipt, which the server verifies. Until the store plugin is
  /// wired, the development payment simulator stands in — and the server
  /// refuses that source outside development, so this cannot become the
  /// shipping path by accident.
  Future<void> _buy(int courseId) async {
    setState(() {
      _isBuying = true;
      _failureMessage = null;
    });

    try {
      await ref.read(learnRepositoryProvider).purchase(courseId, source: 'dev');
      ref.invalidate(courseDetailProvider(widget.slug));
      ref.invalidate(catalogueProvider);
      if (!mounted) return;
      Navigator.of(context).maybePop();
      showEjadahToast(context, message: context.strings.ownedCourse);
    } on Failure catch (failure) {
      if (!mounted) return;
      setState(() {
        _isBuying = false;
        _failureMessage = failure.message(context);
      });
    }
  }

  /// Restores what this account already owns.
  ///
  /// Entitlements live on the server, so a purchase made on another device is
  /// simply read back — this is what makes "yours for good" true across
  /// devices.
  Future<void> _restore() async {
    setState(() {
      _isRestoring = true;
      _failureMessage = null;
    });

    try {
      await ref.read(learnRepositoryProvider).restorePurchases();
      ref.invalidate(courseDetailProvider(widget.slug));
      ref.invalidate(catalogueProvider);
      if (!mounted) return;
      setState(() => _isRestoring = false);
      showEjadahToast(context, message: context.strings.done);
    } on Failure catch (failure) {
      if (!mounted) return;
      setState(() {
        _isRestoring = false;
        _failureMessage = failure.message(context);
      });
    }
  }
}
