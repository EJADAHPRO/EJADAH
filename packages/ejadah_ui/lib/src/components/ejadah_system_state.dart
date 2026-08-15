import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/ejadah_theme.dart';
import '../tokens/ejadah_tokens.dart';
import 'ejadah_buttons.dart';

/// One thing the user can do from a system state.
///
/// The label is written in the active language by the caller — this component
/// never authors copy — and [onPressed] must lead somewhere real. "Verb plus
/// object", never "Get started".
@immutable
class EjadahSystemAction {
  const EjadahSystemAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;
}

/// How serious the state is. Only the icon treatment changes.
///
/// Status is never colour-only: the icon and the copy carry the meaning, and
/// the tone merely tunes the icon's weight.
enum SystemStateTone {
  /// Offline, maintenance, content unavailable, rate limited — conditions, not
  /// faults. Espresso and grey rather than red.
  neutral,

  /// Something failed and can be retried.
  warning,

  /// The user cannot continue past this screen: force update.
  blocking,
}

/// The one system-state template. All ten states are this widget with different
/// arguments.
///
/// Anatomy, top to bottom: **icon tile · title · body · primary action ·
/// optional secondary action**. There is no variant per state, because ten
/// hand-tuned near-copies is how a design system rots.
///
/// Three rules are structural rather than advisory:
///
/// * **[primaryAction] is required.** A failure that does not route anywhere is
///   a dead end, and this constructor makes one impossible to build. Story
///   E6-02: "All 10 system states route to action."
/// * **The title announces itself.** It is a `liveRegion`, so a screen reader
///   speaks the state the moment it replaces the content it failed to load.
/// * **It never clips.** The whole state scrolls, so at 200% text scale the
///   copy and both actions stay reachable instead of overflowing.
///
/// The copy itself is the caller's: no status codes, no exclamation marks, and
/// "your answers are saved" wherever that is true.
class EjadahSystemState extends StatelessWidget {
  const EjadahSystemState({
    required this.icon,
    required this.title,
    required this.body,
    required this.primaryAction,
    this.secondaryAction,
    this.tone = SystemStateTone.neutral,
    super.key,
  });

  final IconData icon;

  /// Plain words. What happened, from the user's side.
  final String title;

  /// What survived, and what happens next.
  final String body;

  /// Mandatory. See the class docs.
  final EjadahSystemAction primaryAction;

  /// Omitted only when there genuinely is no second route — force update is
  /// the single state that has none, and its body says why.
  final EjadahSystemAction? secondaryAction;

  final SystemStateTone tone;

  Color get _iconColour => switch (tone) {
    SystemStateTone.neutral => EjadahColors.textSecondary,
    SystemStateTone.warning => EjadahColors.warningText,
    SystemStateTone.blocking => EjadahColors.dangerText,
  };

  Color get _tileColour => switch (tone) {
    SystemStateTone.neutral => EjadahColors.inset,
    SystemStateTone.warning => EjadahColors.tint(EjadahColors.amber),
    SystemStateTone.blocking => EjadahColors.tint(EjadahColors.danger),
  };

  @override
  Widget build(BuildContext context) {
    final gutter = context.ejadah.gutter;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Centred when the copy is short, scrolled when it is not. At 200% text
        // scale the Arabic body runs past the viewport, and without this the
        // column overflows instead of scrolling.
        final minHeight = constraints.hasBoundedHeight
            ? (constraints.maxHeight - EjadahSpacing.section * 2)
                  .clamp(0.0, constraints.maxHeight)
            : 0.0;

        return SingleChildScrollView(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: gutter,
            vertical: EjadahSpacing.section,
          ),
          child: Align(
            alignment: AlignmentDirectional.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: minHeight,
                maxWidth: EjadahSizes.phoneContentMaxWidth,
              ),
              child: Column(
                // `min` with a minimum height is what lets the column centre
                // itself when it fits and grow past the viewport when it does
                // not.
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: AlignmentDirectional.center,
                    heightFactor: 1,
                    child: Container(
                      width: EjadahSpacing.xxl,
                      height: EjadahSpacing.xxl,
                      decoration: BoxDecoration(
                        color: _tileColour,
                        borderRadius: EjadahRadius.all(EjadahRadius.lg),
                      ),
                      child: Icon(
                        icon,
                        size: EjadahIconSize.feature,
                        color: _iconColour,
                      ),
                    ),
                  ),
                  const SizedBox(height: EjadahSpacing.md),
                  Semantics(
                    // The state speaks itself. Replacing a screen's content
                    // silently leaves a screen-reader user on a page that has
                    // simply gone quiet.
                    liveRegion: true,
                    header: true,
                    child: Text(
                      title,
                      style: context.type.h5(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: EjadahSpacing.xs),
                  Text(
                    body,
                    style: context.type.bodyText(
                      color: EjadahColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: EjadahSpacing.lg),
                  SystemStateFocusRing(
                    onActivate: primaryAction.onPressed,
                    child: EjadahPrimaryButton(
                      label: primaryAction.label,
                      onPressed: primaryAction.onPressed,
                    ),
                  ),
                  if (secondaryAction case final secondary?) ...[
                    const SizedBox(height: EjadahSpacing.xs),
                    SystemStateFocusRing(
                      onActivate: secondary.onPressed,
                      child: EjadahGhostButton(
                        label: secondary.label,
                        onPressed: secondary.onPressed,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Makes an action keyboard-reachable and shows where the focus is.
///
/// Ejadah's buttons acknowledge a press by scaling; they do not draw a focus
/// ring, and on Flutter Web a keyboard user needs both a visible ring and
/// Enter/Space activation. The ring is drawn outside the control with a
/// [EjadahSpacing.xxs] offset so it never covers the label.
class SystemStateFocusRing extends StatefulWidget {
  const SystemStateFocusRing({
    required this.child,
    required this.onActivate,
    super.key,
  });

  final Widget child;
  final VoidCallback onActivate;

  @override
  State<SystemStateFocusRing> createState() => _SystemStateFocusRingState();
}

class _SystemStateFocusRingState extends State<SystemStateFocusRing> {
  bool _focused = false;

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final isActivation =
        event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter ||
        event.logicalKey == LogicalKeyboardKey.space;
    if (!isActivation) return KeyEventResult.ignored;
    widget.onActivate();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) => Focus(
    onKeyEvent: _onKey,
    onFocusChange: (focused) => setState(() => _focused = focused),
    child: Container(
      padding: const EdgeInsetsDirectional.all(EjadahSpacing.xxs),
      decoration: BoxDecoration(
        borderRadius: EjadahRadius.all(EjadahRadius.xl),
        border: Border.all(
          // Always drawn, so gaining focus does not nudge the layout: unfocused
          // it is background-on-background and therefore invisible.
          color: _focused ? EjadahColors.orange : EjadahColors.background,
          width: EjadahSizes.cardBorderWidth,
        ),
      ),
      child: widget.child,
    ),
  );
}
