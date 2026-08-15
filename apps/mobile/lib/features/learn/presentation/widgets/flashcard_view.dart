import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/widgets.dart';

/// One flashcard, front or back.
///
/// Tapping anywhere flips it — there is no separate "reveal" button, because
/// the card *is* the control. The prompt to flip stays visible on the front so
/// the affordance is never a guess.
///
/// The card shows no progress number of its own: what the user has to do next
/// is answer honestly, and a percentage invites gaming a schedule that is only
/// useful when it is truthful.
class FlashcardView extends StatelessWidget {
  const FlashcardView({
    required this.card,
    required this.isFlipped,
    required this.onFlip,
    super.key,
  });

  final Flashcard card;
  final bool isFlipped;
  final VoidCallback onFlip;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final type = context.type;
    final text = isFlipped ? card.back(context) : card.front(context);

    return Semantics(
      button: true,
      label: text,
      child: ExcludeSemantics(
        child: EjadahPressable(
          onTap: onFlip,
          isButton: false,
          enforceMinimumTarget: false,
          child: AnimatedContainer(
            duration: context.ejadah.motion(EjadahMotion.base),
            curve: EjadahMotion.curve,
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 260),
            padding: const EdgeInsets.all(EjadahSpacing.lg),
            decoration: BoxDecoration(
              color: isFlipped ? EjadahColors.inset : EjadahColors.card,
              borderRadius: EjadahRadius.card,
              border: Border.all(
                color: isFlipped ? EjadahColors.orange : EjadahColors.border,
                width: EjadahSizes.cardBorderWidth,
              ),
              boxShadow: EjadahElevation.card,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.eyebrowText(
                    isFlipped ? strings.gotIt : strings.flashcards,
                  ),
                  style: type.eyebrow(
                    color: isFlipped
                        ? EjadahColors.orangeText
                        : EjadahColors.labelMuted,
                  ),
                ),
                const SizedBox(height: EjadahSpacing.md),
                Text(text, style: type.h5()),
                const SizedBox(height: EjadahSpacing.md),
                if (!isFlipped)
                  Text(
                    strings.tapToFlip,
                    style: type.small(color: EjadahColors.labelMuted),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
