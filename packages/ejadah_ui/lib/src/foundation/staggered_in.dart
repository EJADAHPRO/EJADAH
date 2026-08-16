import 'package:flutter/widgets.dart';

import '../theme/ejadah_theme.dart';
import '../tokens/ejadah_tokens.dart';

/// Marks a list whose items stagger in — **once**.
///
/// "Once" is the whole design. A stagger on first appearance reads as the list
/// arriving; the same stagger replaying every time a recycled row scrolls back
/// into view reads as a stutter, and after the third repetition it reads as a
/// bug. So the group remembers that it has played, and every [StaggeredIn]
/// under it after that point appears immediately.
///
/// The flag lives on the group rather than on each item because
/// `ListView.builder` disposes and rebuilds rows as they leave and re-enter the
/// viewport: a per-item flag would reset with the item.
class StaggerGroup extends StatefulWidget {
  const StaggerGroup({required this.child, super.key});

  final Widget child;

  static _StaggerScope? _of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_StaggerScope>();

  @override
  State<StaggerGroup> createState() => _StaggerGroupState();
}

class _StaggerGroupState extends State<StaggerGroup> {
  bool _played = false;

  void _markPlayed() {
    // No setState: nothing about this frame changes, and rebuilding the whole
    // list mid-animation is exactly the stutter this widget exists to avoid.
    // The flag is read by items built *after* this point.
    _played = true;
  }

  @override
  Widget build(BuildContext context) => _StaggerScope(
    played: _played,
    markPlayed: _markPlayed,
    child: widget.child,
  );
}

class _StaggerScope extends InheritedWidget {
  const _StaggerScope({
    required this.played,
    required this.markPlayed,
    required super.child,
  });

  final bool played;
  final VoidCallback markPlayed;

  @override
  bool updateShouldNotify(_StaggerScope oldWidget) =>
      played != oldWidget.played;
}

/// One item of a staggered list.
///
/// Fades and lifts into place after `index × 40ms`. Outside a [StaggerGroup] it
/// is a plain pass-through, so wrapping an item is never a requirement — a list
/// that has not opted in simply does not animate.
class StaggeredIn extends StatefulWidget {
  const StaggeredIn({required this.index, required this.child, super.key});

  /// Position in the list, zero-based.
  final int index;

  final Widget child;

  /// How many items stagger before the rest appear together.
  ///
  /// Without a cap, item 40 waits 1.6 seconds and item 200 waits eight — the
  /// animation would stop being an entrance and become a loading screen. Six
  /// is about one screenful on a compact phone, which is all anyone sees.
  static const int maxStaggered = 6;

  @override
  State<StaggeredIn> createState() => _StaggeredInState();
}

class _StaggeredInState extends State<StaggeredIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: EjadahMotion.base,
  );

  @override
  void initState() {
    super.initState();
    // Read once, in initState: an item that started animating must finish, even
    // if the group is marked played while it is in flight.
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  void _start() {
    if (!mounted) return;
    final scope = StaggerGroup._of(context);
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    if (scope == null || scope.played || reduceMotion) {
      _controller.value = 1;
      return;
    }

    if (widget.index >= StaggeredIn.maxStaggered) {
      // Past the cap: appear with the last staggered item rather than later.
      _controller.forward();
      scope.markPlayed();
      return;
    }

    Future.delayed(EjadahMotion.listStagger * widget.index, () {
      if (mounted) _controller.forward();
    });

    // The last one to be scheduled closes the group, so a scroll back up does
    // not replay what has already been seen.
    if (widget.index == StaggeredIn.maxStaggered - 1) scope.markPlayed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.ejadah;

    // Reduced motion keeps the fade and drops the transform — the rule
    // `EjadahMotion.durationFor` encodes, applied to the one property that
    // causes vestibular trouble.
    final lift = tokens.reduceMotion ? 0.0 : 8.0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _controller.value,
        child: Transform.translate(
          offset: Offset(0, lift * (1 - _controller.value)),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
