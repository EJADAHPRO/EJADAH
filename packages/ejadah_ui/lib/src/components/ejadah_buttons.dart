import 'package:flutter/widgets.dart';

import '../foundation/ejadah_pressable.dart';
import '../foundation/gradient_budget.dart';
import '../theme/ejadah_theme.dart';
import '../tokens/ejadah_tokens.dart';

/// The gradient primary action.
///
/// One per screen. The gradient is one of its six permitted uses, and it counts
/// against the screen's gradient budget.
///
/// While [isLoading], the spinner replaces the label **in place** and the width
/// stays frozen: a button that resizes mid-submit moves everything under the
/// user's thumb.
class EjadahPrimaryButton extends StatelessWidget {
  const EjadahPrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.disabledReason,
    this.onDisabledTap,
    this.icon,
    this.expand = true,
    super.key,
  });

  final String label;

  /// Null disables the button. Pair it with [disabledReason].
  final VoidCallback? onPressed;
  final bool isLoading;

  /// Why the button is disabled, surfaced when the user taps it.
  final String? disabledReason;

  /// Shows [disabledReason] — usually as a toast. Required for a disabled
  /// button to be able to explain itself.
  final void Function(String reason)? onDisabledTap;
  final IconData? icon;
  final bool expand;

  bool get _isEnabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final tokens = context.ejadah;

    // A minimum rather than a fixed height, so the label can wrap instead of
    // ellipsizing. At 200% text scale on a 320pt phone almost every Arabic
    // label overflows 52 — "العودة للرئيسية" needs 420pt — and a truncated
    // primary action is a button whose purpose the user cannot read.
    final content = ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: EjadahSizes.primaryButtonHeight,
      ),
      child: Center(
        child: isLoading
            ? const _ButtonSpinner(color: EjadahColors.onDark)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: EjadahSpacing.sm),
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: EjadahIconSize.inline,
                      color: EjadahColors.onDark,
                    ),
                    const SizedBox(width: EjadahSpacing.xs),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: tokens.typography.button(
                        color: EjadahColors.onDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: EjadahSpacing.sm),
                ],
              ),
      ),
    );

    Widget button = Opacity(
      opacity: _isEnabled || isLoading ? 1 : EjadahOpacity.disabled,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: EjadahRadius.all(EjadahRadius.lg),
          boxShadow: _isEnabled ? EjadahElevation.primaryGlow : null,
        ),
        child: ClipRRect(
          borderRadius: EjadahRadius.all(EjadahRadius.lg),
          child: BrandGradient(use: GradientUse.primaryButton, child: content),
        ),
      ),
    );

    if (expand) button = SizedBox(width: double.infinity, child: button);

    return EjadahPressable(
      onTap: _isEnabled ? onPressed : null,
      onDisabledTap: disabledReason == null
          ? null
          : () => onDisabledTap?.call(disabledReason!),
      semanticLabel: label,
      enforceMinimumTarget: false,
      child: button,
    );
  }
}

/// A white button with a 1.5px border. The everyday secondary action.
class EjadahSecondaryButton extends StatelessWidget {
  const EjadahSecondaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;

    Widget button = Opacity(
      opacity: enabled || isLoading ? 1 : EjadahOpacity.disabled,
      child: Container(
        height: EjadahSizes.secondaryButtonHeight,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: EjadahSpacing.md,
        ),
        decoration: BoxDecoration(
          color: EjadahColors.card,
          borderRadius: EjadahRadius.all(EjadahRadius.lg),
          border: Border.all(
            color: EjadahColors.border,
            width: EjadahSizes.cardBorderWidth,
          ),
        ),
        child: Center(
          child: isLoading
              ? const _ButtonSpinner(color: EjadahColors.textPrimary)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: EjadahIconSize.inline,
                        color: EjadahColors.textPrimary,
                      ),
                      const SizedBox(width: EjadahSpacing.xs),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        style: context.type.button(
                          color: EjadahColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );

    if (expand) button = SizedBox(width: double.infinity, child: button);

    return EjadahPressable(
      onTap: enabled ? onPressed : null,
      semanticLabel: label,
      enforceMinimumTarget: false,
      child: button,
    );
  }
}

/// A text-only action in the secondary colour.
class EjadahGhostButton extends StatelessWidget {
  const EjadahGhostButton({
    required this.label,
    required this.onPressed,
    this.color,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) => EjadahPressable(
    onTap: onPressed,
    semanticLabel: label,
    child: Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: EjadahSpacing.sm,
        vertical: EjadahSpacing.sm,
      ),
      child: Center(
        widthFactor: 1,
        child: Text(
          label,
          style: context.type.button(
            color: color ?? EjadahColors.textSecondary,
          ),
        ),
      ),
    ),
  );
}

/// A destructive action. Always confirmed before it runs, and the confirmation
/// states the exact consequence — including the refund amount where money is
/// involved.
class EjadahDestructiveButton extends StatelessWidget {
  const EjadahDestructiveButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;

    Widget button = Opacity(
      opacity: enabled || isLoading ? 1 : EjadahOpacity.disabled,
      child: Container(
        height: EjadahSizes.secondaryButtonHeight,
        decoration: BoxDecoration(
          color: EjadahColors.tint(EjadahColors.danger),
          borderRadius: EjadahRadius.all(EjadahRadius.lg),
        ),
        child: Center(
          child: isLoading
              ? const _ButtonSpinner(color: EjadahColors.dangerText)
              : Text(
                  label,
                  style: context.type.button(color: EjadahColors.dangerText),
                ),
        ),
      ),
    );

    if (expand) button = SizedBox(width: double.infinity, child: button);

    return EjadahPressable(
      onTap: enabled ? onPressed : null,
      semanticLabel: label,
      enforceMinimumTarget: false,
      child: button,
    );
  }
}

/// An icon-only control.
///
/// [semanticLabel] is required and must be written in the active language —
/// an unlabelled icon button is silent to a screen reader.
class EjadahIconButton extends StatelessWidget {
  const EjadahIconButton({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.color,
    this.size = EjadahIconSize.nav,
    super.key,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) => EjadahPressable(
    onTap: onPressed,
    semanticLabel: semanticLabel,
    haptic: PressHaptic.selection,
    child: Center(
      child: Icon(icon, size: size, color: color ?? EjadahColors.textPrimary),
    ),
  );
}

/// The in-button spinner. Sized to the label so the button never resizes.
class _ButtonSpinner extends StatefulWidget {
  const _ButtonSpinner({required this.color});

  final Color color;

  @override
  State<_ButtonSpinner> createState() => _ButtonSpinnerState();
}

class _ButtonSpinnerState extends State<_ButtonSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: EjadahIconSize.inline,
    height: EjadahIconSize.inline,
    child: RotationTransition(
      turns: _controller,
      child: CustomPaint(painter: _SpinnerPainter(widget.color)),
    ),
  );
}

class _SpinnerPainter extends CustomPainter {
  const _SpinnerPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Offset.zero & size, 0, 4.2, false, paint);
  }

  @override
  bool shouldRepaint(_SpinnerPainter oldDelegate) => oldDelegate.color != color;
}
