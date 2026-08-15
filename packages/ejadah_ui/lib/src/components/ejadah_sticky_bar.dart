import 'package:flutter/material.dart';

import '../theme/ejadah_theme.dart';
import '../tokens/ejadah_tokens.dart';
import 'ejadah_shell.dart';

/// The bar that keeps a screen's decision reachable.
///
/// On a screen whose content scrolls — a plan being assembled, a CV being
/// written, a card being ordered, a month of earnings — the action must not be
/// something you have to scroll to find. A primary button that leaves the
/// viewport is a primary button people believe is missing.
///
/// It carries three things every one of these bars needs and each of which had
/// been re-typed per screen until this existed: the top hairline and lift so it
/// reads as sitting above the content, the bottom safe area so it clears the
/// home indicator, and the page gutter so its button lines up with the column
/// above it.
///
/// [reason] is the other half. Every disabled control in this product owes an
/// explanation, and on a sticky bar the natural place for it is directly above
/// the button rather than behind a tap on something that looks broken.
class EjadahStickyBar extends StatelessWidget {
  const EjadahStickyBar({
    required this.child,
    this.reason,
    this.background = EjadahColors.card,
    super.key,
  });

  /// Usually the primary button, or a Row of back-and-continue.
  final Widget child;

  /// Shown above [child] when the action is unavailable. Null when it is not.
  final String? reason;

  final Color background;

  @override
  Widget build(BuildContext context) {
    final type = context.type;

    return Container(
      decoration: BoxDecoration(
        color: background,
        border: const Border(top: BorderSide(color: EjadahColors.border)),
        boxShadow: EjadahElevation.stickyTop,
      ),
      child: SafeArea(
        top: false,
        child: EjadahPageBody(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: EjadahSpacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (reason != null) ...[
                  Semantics(
                    // Announced when it appears: a reason nobody hears is a
                    // reason only sighted users get.
                    liveRegion: true,
                    child: Text(
                      reason!,
                      style: type.caption(color: EjadahColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: EjadahSpacing.xs),
                ],
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
