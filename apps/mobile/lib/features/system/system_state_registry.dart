import 'package:ejadah_core/ejadah_core.dart';
import 'package:flutter/widgets.dart';

import 'presentation/content_unavailable_screen.dart';
import 'presentation/offline_screen.dart';
import 'presentation/rate_limited_screen.dart';
import 'presentation/server_error_screen.dart';
import 'presentation/session_expired_screen.dart';

/// The one place that decides which system state a failure deserves.
///
/// Without this, every feature repeats the same switch and they drift: one
/// screen shows "offline" for a dropped connection, the next shows a generic
/// error, and the product speaks with two voices about the same event. Features
/// call [forFailure] and render what comes back.
///
/// Only the five failure-driven states appear here. The other five are not
/// failures at all — maintenance and force update come from app configuration,
/// the two permission states from an OS prompt, and the error boundary from a
/// caught build exception — so they are constructed directly by whatever
/// detects them.
abstract final class SystemStateScreen {
  /// The screen for [failure].
  ///
  /// [onRetry] re-runs whatever failed; it is required because three of the
  /// five states have retry as their primary route and a retry button that does
  /// nothing is worse than no button.
  ///
  /// [next] is where the user was headed, so sign-in can return them there.
  static Widget forFailure(
    Failure failure, {
    required VoidCallback onRetry,
    String? next,
  }) => switch (failure) {
    // The connection, not the server. Saved content is still readable and the
    // copy says so.
    NetworkFailure() => OfflineScreen(onRetry: onRetry),

    AuthenticationFailure() => SessionExpiredScreen(next: next),

    // Signed in but not permitted. From the user's side this is
    // indistinguishable from something that is no longer there, and "browse
    // programmes" is the useful route either way — telling them what they are
    // not allowed to see would only be a different dead end.
    AuthorizationFailure() => const ContentUnavailableScreen(),

    NotFoundFailure() => const ContentUnavailableScreen(),

    RateLimitFailure() => RateLimitedScreen(onRetry: onRetry),

    // Everything else is ours to own: the server-error copy takes the blame and
    // states that nothing saved was affected.
    ValidationFailure() ||
    ConflictFailure() ||
    PaymentFailure() ||
    StorageFailure() ||
    UnexpectedFailure() => ServerErrorScreen(onRetry: onRetry),
  };

  /// Whether [failure] has a better home than a full-screen state.
  ///
  /// A validation error belongs under the field it names, and a booking
  /// conflict belongs in the slot picker showing what is still open — replacing
  /// the whole screen would throw away the context that makes either one
  /// fixable. Callers with an inline surface should check this first and only
  /// fall back to [forFailure] when they have none.
  static bool hasInlineHome(Failure failure) =>
      failure is ValidationFailure || failure is ConflictFailure;
}
