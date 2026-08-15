/// The Ejadah design system.
///
/// Ejadah is the design language; Flutter is only the rendering framework. Every
/// visual constant here resolves to `DESIGN_TOKENS.json`, and screens compose
/// these components rather than restyling Material widgets at each call site —
/// a slightly-different per-screen variant of a card or a badge is a defect.
library;

export 'src/components/ejadah_badges.dart';
export 'src/components/ejadah_booking.dart';
export 'src/components/ejadah_buttons.dart';
export 'src/components/ejadah_cards.dart';
export 'src/components/ejadah_inputs.dart';
export 'src/components/ejadah_overlays.dart';
export 'src/components/ejadah_shell.dart';
export 'src/components/ejadah_states.dart';
export 'src/components/ejadah_step_marker.dart';
export 'src/components/ejadah_system_state.dart';
export 'src/foundation/bidi_text.dart';
export 'src/foundation/ejadah_icons.dart';
export 'src/foundation/ejadah_pressable.dart';
export 'src/foundation/gradient_budget.dart';
export 'src/theme/ejadah_theme.dart';
export 'src/tokens/ejadah_tokens.dart';
export 'src/tokens/ejadah_typography.dart';
export 'src/tokens/tokens.g.dart' show RawTokens;
