import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/ejadah_theme.dart';
import '../tokens/ejadah_tokens.dart';

/// How firmly a press is acknowledged.
enum PressHaptic {
  /// Chips, tabs and toggles.
  selection,

  /// Primary actions.
  light,

  /// Booking confirmed, payment returned.
  medium,

  none,
}

/// The press behaviour shared by every interactive Ejadah surface.
///
/// Three product rules live here so that no individual control has to remember
/// them:
///
/// * feedback within 100ms — the scale starts on press-*down*, not on tap-up;
/// * a disabled control explains itself on tap rather than doing nothing, which
///   is one of the two most-felt accessibility rules in the product;
/// * the minimum target is 44×44 regardless of how small the visual is.
class EjadahPressable extends StatefulWidget {
  const EjadahPressable({
    required this.child,
    this.onTap,
    this.onDisabledTap,
    this.haptic = PressHaptic.light,
    this.semanticLabel,
    this.isButton = true,
    this.enforceMinimumTarget = true,
    this.borderRadius,
    super.key,
  });

  final Widget child;

  /// Null means disabled.
  final VoidCallback? onTap;

  /// Called when a disabled control is tapped, so the reason can be surfaced.
  /// A disabled control that swallows taps silently is a defect.
  final VoidCallback? onDisabledTap;
  final PressHaptic haptic;
  final String? semanticLabel;
  final bool isButton;
  final bool enforceMinimumTarget;
  final BorderRadius? borderRadius;

  bool get isEnabled => onTap != null;

  @override
  State<EjadahPressable> createState() => _EjadahPressableState();
}

class _EjadahPressableState extends State<EjadahPressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  void _handleTapDown(TapDownDetails _) {
    if (!widget.isEnabled) return;
    _setPressed(true);
    switch (widget.haptic) {
      case PressHaptic.selection:
        HapticFeedback.selectionClick();
      case PressHaptic.light:
        HapticFeedback.lightImpact();
      case PressHaptic.medium:
        HapticFeedback.mediumImpact();
      case PressHaptic.none:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.ejadah;

    Widget result = AnimatedScale(
      // Reduce-motion suppresses transforms, so the scale is simply not applied.
      scale: _pressed && !tokens.reduceMotion ? EjadahMotion.pressScale : 1,
      duration: tokens.motion(EjadahMotion.fast),
      curve: EjadahMotion.curve,
      child: widget.child,
    );

    if (widget.enforceMinimumTarget) {
      result = ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: EjadahSizes.tapTargetMin,
          minHeight: EjadahSizes.tapTargetMin,
        ),
        child: result,
      );
    }

    return Semantics(
      label: widget.semanticLabel,
      button: widget.isButton,
      enabled: widget.isEnabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _handleTapDown,
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.isEnabled ? widget.onTap : widget.onDisabledTap,
        child: result,
      ),
    );
  }
}
