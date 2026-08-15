import 'package:flutter/material.dart';

import '../theme/ejadah_theme.dart';
import '../tokens/ejadah_tokens.dart';

/// A slider with the value stated above it and an honest band hint below.
///
/// The hint is the point. A budget slider with no feedback lets a user pick a
/// figure and discover only after generating that nothing was ever within it;
/// the hint tells them while they are still choosing, in terms of real data —
/// "9 of 23 destinations have a documented cost at or under this".
///
/// "Documented" is load-bearing. A country whose cost rows are unsourced is not
/// counted, because counting it would make an undocumented destination look
/// affordable — the same rule the roadmap engine applies when it withholds the
/// budget bonus from an incomplete cost floor.
class EjadahValueSlider extends StatelessWidget {
  const EjadahValueSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    required this.valueLabel,
    this.bandHint,
    super.key,
  });

  final String label;
  final int value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<int> onChanged;

  /// Already formatted and bidi-safe — a currency or a range.
  final Widget valueLabel;

  /// What this value means against the real data. Null while it is unknown,
  /// rather than a guess or a zero.
  final String? bandHint;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        children: [
          Text(
            context.type.eyebrowText(label),
            style: context.type.eyebrow(color: EjadahColors.labelMuted),
          ),
          const Spacer(),
          valueLabel,
        ],
      ),
      Slider(
        value: value.toDouble().clamp(min, max),
        min: min,
        max: max,
        divisions: divisions,
        activeColor: EjadahColors.orange,
        // The figure is already stated above, in the product's own formatting.
        label: null,
        onChanged: (next) => onChanged(next.round()),
      ),
      if (bandHint != null)
        Semantics(
          // The hint changes as the slider moves, and a screen-reader user is
          // choosing on exactly the same information.
          liveRegion: true,
          child: Text(
            bandHint!,
            style: context.type.small(color: EjadahColors.textSecondary),
          ),
        ),
    ],
  );
}
