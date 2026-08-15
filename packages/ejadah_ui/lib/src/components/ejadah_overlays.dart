import 'package:flutter/material.dart';

import '../theme/ejadah_theme.dart';
import '../tokens/ejadah_tokens.dart';
import 'ejadah_buttons.dart';

/// Presents an Ejadah bottom sheet.
///
/// Sheets carry options, filters and confirmations — **never long forms**. A
/// multi-step form belongs on its own screen where the back stack, scroll
/// restoration and keyboard all behave.
Future<T?> showEjadahSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
}) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  isDismissible: isDismissible,
  enableDrag: isDismissible,
  backgroundColor: EjadahColors.card,
  barrierColor: EjadahColors.charcoal.withValues(alpha: 0.4),
  shape: const RoundedRectangleBorder(borderRadius: EjadahRadius.sheet),
  constraints: const BoxConstraints(
    // Full width on a phone, capped on anything wider.
    maxWidth: EjadahSizes.phoneContentMaxWidth,
  ),
  builder: (context) => _SheetFrame(child: builder(context)),
);

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: EjadahSpacing.sm),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: EjadahColors.border,
                borderRadius: EjadahRadius.all(EjadahRadius.pill),
              ),
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                EjadahSpacing.gutter,
                0,
                EjadahSpacing.gutter,
                EjadahSpacing.gutter,
              ),
              child: child,
            ),
          ),
        ],
      ),
    ),
  );
}

/// A destructive confirmation.
///
/// The body must state the **exact** consequence before the button is offered —
/// including the refund amount in EGP where money is involved. Cancel-then-
/// surprise is the failure this dialog exists to prevent, which is why
/// [consequence] is required rather than optional.
Future<bool> showEjadahConfirmDialog({
  required BuildContext context,
  required String title,
  required String consequence,
  required String confirmLabel,
  required String cancelLabel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor: EjadahColors.charcoal.withValues(alpha: 0.4),
    builder: (context) => Dialog(
      backgroundColor: EjadahColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: EjadahRadius.all(EjadahRadius.xl),
      ),
      insetPadding: const EdgeInsets.all(EjadahSpacing.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, minWidth: 320),
        child: Padding(
          padding: const EdgeInsets.all(EjadahSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.type.h5()),
              const SizedBox(height: EjadahSpacing.xs),
              Text(
                consequence,
                style: context.type.bodyText(color: EjadahColors.textSecondary),
              ),
              const SizedBox(height: EjadahSpacing.md),
              EjadahDestructiveButton(
                label: confirmLabel,
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: EjadahSpacing.xs),
              EjadahGhostButton(
                label: cancelLabel,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  return result ?? false;
}

/// Shows a toast, optionally with an Undo action.
///
/// Reversible actions apply optimistically and offer Undo for five seconds;
/// plain acknowledgements hold for four. A toast is also how a disabled control
/// explains itself when tapped.
void showEjadahToast(
  BuildContext context, {
  required String message,
  String? undoLabel,
  VoidCallback? onUndo,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: context.type.small(color: EjadahColors.onDark),
      ),
      backgroundColor: EjadahColors.charcoal,
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: onUndo != null ? 5 : 4),
      shape: RoundedRectangleBorder(
        borderRadius: EjadahRadius.all(EjadahRadius.md),
      ),
      action: onUndo == null || undoLabel == null
          ? null
          : SnackBarAction(
              label: undoLabel,
              textColor: EjadahColors.gold,
              onPressed: onUndo,
            ),
    ),
  );
}
