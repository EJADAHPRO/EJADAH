import 'package:flutter/widgets.dart';

import '../foundation/gradient_budget.dart';
import '../theme/ejadah_theme.dart';
import '../tokens/ejadah_tokens.dart';

/// The numbered marker on a stage or step list.
///
/// One of the six permitted gradient uses — and the only one that repeats,
/// which is what makes it the use that breaks the six-per-screen budget. A
/// country guide is as long as its licensing pathway really is: Germany's has
/// seven steps, and a roadmap mirrors its destination's guide one-for-one.
///
/// So the decision is made once, here, from the length of the whole list:
/// either every marker carries the gradient or none does. Marking the first
/// five and leaving the rest plain would read as a rendering bug rather than as
/// restraint, and would still be the same visual noise the budget exists to
/// prevent.
class EjadahStepMarker extends StatelessWidget {
  const EjadahStepMarker({
    required this.position,
    required this.total,
    super.key,
  });

  /// 1-based, as the user counts.
  final int position;

  /// How many steps the list holds. The gradient decision follows from this,
  /// not from where this marker sits, so a list never mixes the two treatments.
  final int total;

  @override
  Widget build(BuildContext context) {
    final number = SizedBox(
      width: EjadahSizes.stepMarkerSize,
      height: EjadahSizes.stepMarkerSize,
      child: Center(
        // A step number is a numeral in a Latin-numeral product; it stays LTR
        // in both languages.
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            '$position',
            style: context.type.caption(color: EjadahColors.onDark),
          ),
        ),
      ),
    );

    if (!EjadahGradient.allowsStepMarkers(total)) {
      return DecoratedBox(
        decoration: const BoxDecoration(
          color: EjadahColors.charcoal,
          shape: BoxShape.circle,
        ),
        child: number,
      );
    }

    return BrandGradient(
      use: GradientUse.stepMarker,
      borderRadius: EjadahRadius.all(EjadahRadius.pill),
      child: number,
    );
  }
}
