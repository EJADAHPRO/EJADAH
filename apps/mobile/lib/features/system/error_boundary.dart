import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'presentation/error_boundary_screen.dart';

/// Catches build-phase exceptions in [child] and shows SY-08 instead.
///
/// Flutter's own answer to a widget that throws is the red error box, which is
/// exactly right in development and indefensible in a shipped app: it shows a
/// stack trace to a dentist and offers no way out. This boundary replaces that
/// with a state that says what happened in plain words and routes to Home.
///
/// How it works: [install] swaps [ErrorWidget.builder] for one that returns a
/// silent widget instead of the red box. That widget finds the nearest
/// boundary above it and reports the failure on the next frame — it cannot do
/// so during the current one, because the tree is mid-build. The boundary then
/// swaps its whole subtree for [ErrorBoundaryScreen].
///
/// Wrap the app's content once, near the root, and optionally wrap any subtree
/// whose failure should not take the rest of the screen with it.
class SystemErrorBoundary extends StatefulWidget {
  const SystemErrorBoundary({required this.child, this.onReset, super.key});

  final Widget child;

  /// Called when the user retries, alongside the subtree rebuild — the hook for
  /// re-fetching whatever data made the widget throw.
  final VoidCallback? onReset;

  /// Installs the release-safe [ErrorWidget.builder].
  ///
  /// Debug builds keep Flutter's red box: hiding a crash from the engineer who
  /// caused it trades a visible bug for an invisible one. Tests that need the
  /// production behaviour pass [force].
  static void install({bool force = false}) {
    if (!force && !kReleaseMode) return;
    ErrorWidget.builder = (details) => _CaughtBuildError(details: details);
  }

  /// Restores Flutter's default error widget. For test teardown.
  static void uninstall() {
    ErrorWidget.builder = (details) => ErrorWidget(details.exception);
  }

  @override
  State<SystemErrorBoundary> createState() => _SystemErrorBoundaryState();
}

class _SystemErrorBoundaryState extends State<SystemErrorBoundary> {
  FlutterErrorDetails? _caught;

  void _report(FlutterErrorDetails details) {
    // The first failure wins. A broken subtree usually throws once per child,
    // and re-entering setState for each would only churn frames.
    if (!mounted || _caught != null) return;
    setState(() => _caught = details);
  }

  void _reset() {
    setState(() => _caught = null);
    widget.onReset?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_caught != null) return ErrorBoundaryScreen(onRetry: _reset);
    return _BoundaryScope(report: _report, child: widget.child);
  }
}

/// Carries the reporting hook down to whatever fails below it.
class _BoundaryScope extends InheritedWidget {
  const _BoundaryScope({required this.report, required super.child});

  final void Function(FlutterErrorDetails details) report;

  static _BoundaryScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_BoundaryScope>();

  @override
  bool updateShouldNotify(_BoundaryScope oldWidget) =>
      report != oldWidget.report;
}

/// What [ErrorWidget.builder] returns once [SystemErrorBoundary.install] has
/// run: nothing visible, and a report to the nearest boundary.
///
/// It renders an empty box rather than the error state itself, because it is
/// spliced into the exact slot that failed — inside a row, a list item, a
/// constrained box — and a full-page state there would break the layout a
/// second time. The boundary above owns the whole screen and can replace it
/// safely.
class _CaughtBuildError extends StatefulWidget {
  const _CaughtBuildError({required this.details});

  final FlutterErrorDetails details;

  @override
  State<_CaughtBuildError> createState() => _CaughtBuildErrorState();
}

class _CaughtBuildErrorState extends State<_CaughtBuildError> {
  bool _reported = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_reported) return;
    final scope = _BoundaryScope.maybeOf(context);
    if (scope == null) return;
    _reported = true;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => scope.report(widget.details),
    );
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
