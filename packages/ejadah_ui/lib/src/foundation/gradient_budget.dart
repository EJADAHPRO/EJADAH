import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../tokens/ejadah_tokens.dart';

/// Counts the brand-gradient elements on screen, in debug builds.
///
/// The gradient is limited to six elements per screen on six permitted uses.
/// That scarcity is what keeps it premium, and it is exactly the kind of rule
/// that erodes one reasonable-looking addition at a time. Making it assert in
/// development turns a slow drift into an immediate failure.
///
/// Release builds do no counting and pay nothing.
class GradientBudget extends StatefulWidget {
  const GradientBudget({
    required this.child,
    this.screenName = 'screen',
    super.key,
  });

  final Widget child;

  /// Named in the assertion so the offending screen is obvious.
  final String screenName;

  static _GradientBudgetScope? _of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_GradientBudgetScope>();

  @override
  State<GradientBudget> createState() => _GradientBudgetState();
}

class _GradientBudgetState extends State<GradientBudget> {
  final Set<Object> _active = {};
  bool _checkScheduled = false;

  void _register(Object token) {
    if (!kDebugMode) return;
    _active.add(token);
    _scheduleCheck();
  }

  void _unregister(Object token) {
    if (!kDebugMode) return;
    _active.remove(token);
  }

  /// Counting happens once per frame, after the tree has settled — asserting
  /// mid-build would fire on transient states during a rebuild.
  void _scheduleCheck() {
    if (_checkScheduled) return;
    _checkScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScheduled = false;
      if (!mounted) return;
      assert(
        _active.length <= EjadahGradient.maxPerScreen,
        'Gradient budget exceeded on "${widget.screenName}": '
        '${_active.length} gradient elements, limit '
        '${EjadahGradient.maxPerScreen}. The brand gradient is permitted on '
        'primary buttons, the logo tile, numbered step markers, one emphasised '
        'phrase per heading, the closing CTA band and the active tab indicator '
        '— and on at most six of them at once.',
      );
    });
  }

  @override
  Widget build(BuildContext context) =>
      _GradientBudgetScope(state: this, child: widget.child);
}

class _GradientBudgetScope extends InheritedWidget {
  const _GradientBudgetScope({required this.state, required super.child});

  final _GradientBudgetState state;

  @override
  bool updateShouldNotify(_GradientBudgetScope oldWidget) => false;
}

/// Paints the brand gradient and counts itself against the screen's budget.
///
/// Every gradient surface in the product goes through this widget, which is
/// what makes the budget enforceable rather than aspirational.
class BrandGradient extends StatefulWidget {
  const BrandGradient({
    required this.use,
    required this.child,
    this.borderRadius,
    super.key,
  });

  /// Which of the six permitted uses this is. Documented at the call site so a
  /// seventh kind of usage is visible in review.
  final GradientUse use;
  final Widget child;
  final BorderRadius? borderRadius;

  @override
  State<BrandGradient> createState() => _BrandGradientState();
}

class _BrandGradientState extends State<BrandGradient> {
  final Object _token = Object();
  _GradientBudgetState? _budget;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final budget = GradientBudget._of(context)?.state;
    if (budget != _budget) {
      _budget?._unregister(_token);
      _budget = budget;
      _budget?._register(_token);
    }
  }

  @override
  void dispose() {
    _budget?._unregister(_token);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: EjadahGradient.ofContext(context),
      borderRadius: widget.borderRadius,
    ),
    child: widget.child,
  );
}
