import 'package:flutter/widgets.dart';

import '../foundation/ejadah_icons.dart';
import '../theme/ejadah_theme.dart';
import '../tokens/ejadah_tokens.dart';
import 'ejadah_buttons.dart';

/// A shimmering placeholder in the shape of the content that is coming.
///
/// Skeletons, not spinners: a shape that matches the incoming card tells the
/// user what to expect and makes the wait feel shorter. Reduce-motion drops the
/// shimmer and leaves a static block.
class Skeleton extends StatefulWidget {
  const Skeleton({
    required this.width,
    required this.height,
    this.borderRadius,
    super.key,
  });

  const Skeleton.line({this.width = double.infinity, super.key})
    : height = 12,
      borderRadius = null;

  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void initState() {
    super.initState();
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? EjadahRadius.all(EjadahRadius.sm);

    if (context.ejadah.reduceMotion) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: EjadahColors.inset,
          borderRadius: radius,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: LinearGradient(
            begin: Alignment(-1 + _controller.value * 2, 0),
            end: Alignment(1 + _controller.value * 2, 0),
            colors: const [
              EjadahColors.inset,
              EjadahColors.card,
              EjadahColors.inset,
            ],
          ),
        ),
      ),
    );
  }
}

/// A skeleton shaped like a programme, course or professional card.
class CardSkeleton extends StatelessWidget {
  const CardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(EjadahSpacing.md),
    decoration: BoxDecoration(
      color: EjadahColors.card,
      borderRadius: EjadahRadius.card,
      border: Border.all(
        color: EjadahColors.border,
        width: EjadahSizes.cardBorderWidth,
      ),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Skeleton(width: 120, height: 12),
        SizedBox(height: EjadahSpacing.xs),
        Skeleton(width: double.infinity, height: 18),
        SizedBox(height: EjadahSpacing.xs),
        Skeleton(width: 180, height: 12),
        SizedBox(height: EjadahSpacing.sm),
        Row(
          children: [
            Skeleton(width: 72, height: 20),
            SizedBox(width: EjadahSpacing.xs),
            Skeleton(width: 56, height: 20),
          ],
        ),
      ],
    ),
  );
}

/// An empty state.
///
/// The action is **mandatory**: an empty state that does not route somewhere is
/// a dead end, and this widget makes that structurally impossible. The copy
/// names something specific — "No saved programmes yet — 17 are open right
/// now." beats "No results" every time.
class EjadahEmptyState extends StatelessWidget {
  const EjadahEmptyState({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
    this.icon = EjadahIcons.empty,
    super.key,
  });

  final String title;
  final String body;

  /// Verb plus object — "Browse programmes", never "Get started".
  final String actionLabel;
  final VoidCallback onAction;
  final IconData icon;

  @override
  Widget build(BuildContext context) => _CentredState(
    icon: icon,
    iconColor: EjadahColors.labelMuted,
    title: title,
    body: body,
    actionLabel: actionLabel,
    onAction: onAction,
  );
}

/// A failure the user can retry.
///
/// The copy says what happened and what survived — never a status code, never
/// "Oops!".
class EjadahErrorState extends StatelessWidget {
  const EjadahErrorState({
    required this.title,
    required this.body,
    required this.retryLabel,
    required this.onRetry,
    super.key,
  });

  final String title;
  final String body;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => _CentredState(
    icon: EjadahIcons.warning,
    iconColor: EjadahColors.amber,
    title: title,
    body: body,
    actionLabel: retryLabel,
    onAction: onRetry,
  );
}

/// The persistent offline banner.
///
/// Espresso rather than red: being offline is a condition, not an error, and
/// the saved content behind it is still readable.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({required this.message, super.key});

  /// "Offline — showing your saved content" / «بلا اتصال — نعرض المحتوى المحفوظ»
  final String message;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Container(
      width: double.infinity,
      color: EjadahColors.espresso,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: EjadahSpacing.md,
        vertical: EjadahSpacing.xs,
      ),
      child: Row(
        children: [
          const Icon(
            EjadahIcons.offline,
            size: EjadahIconSize.inline,
            color: EjadahColors.onDarkMuted,
          ),
          const SizedBox(width: EjadahSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: context.type.caption(color: EjadahColors.onDark),
            ),
          ),
        ],
      ),
    ),
  );
}

/// An inline notice inside a page — the roadmap's honest watch-out, a form's
/// global error, a data caveat.
class InlineAlert extends StatelessWidget {
  const InlineAlert({
    required this.message,
    this.tone = AlertTone.warning,
    this.title,
    super.key,
  });

  final String message;
  final AlertTone tone;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final (colour, textColour, icon) = switch (tone) {
      AlertTone.warning => (
        EjadahColors.amber,
        EjadahColors.warningText,
        EjadahIcons.warning,
      ),
      AlertTone.danger => (
        EjadahColors.danger,
        EjadahColors.dangerText,
        EjadahIcons.warning,
      ),
      AlertTone.info => (
        EjadahColors.info,
        // Not the base hue: #496FA8 measures 4.28:1 on its own tint, below AA.
        EjadahColors.infoText,
        // Not the verified tick — an info alert marks a note, and on Home it
        // marks a section that failed to load. A confirmation glyph there
        // reads as the opposite of what happened.
        EjadahIcons.info,
      ),
      AlertTone.success => (
        EjadahColors.success,
        EjadahColors.successText,
        EjadahIcons.check,
      ),
    };

    return Semantics(
      // Form errors and failures must be announced, not merely shown.
      liveRegion: tone == AlertTone.danger,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(EjadahSpacing.sm),
        decoration: BoxDecoration(
          color: EjadahColors.tint(colour, 0.10),
          borderRadius: EjadahRadius.all(EjadahRadius.md),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: EjadahIconSize.inline, color: textColour),
            const SizedBox(width: EjadahSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null)
                    Text(
                      context.type.eyebrowText(title!),
                      style: context.type.eyebrow(color: textColour),
                    ),
                  Text(
                    message,
                    style: context.type.small(color: EjadahColors.textPrimary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum AlertTone { warning, danger, info, success }

class _CentredState extends StatelessWidget {
  const _CentredState({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(EjadahSpacing.section),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: EjadahColors.inset,
              borderRadius: EjadahRadius.all(EjadahRadius.lg),
            ),
            child: Icon(icon, size: EjadahIconSize.feature, color: iconColor),
          ),
          const SizedBox(height: EjadahSpacing.md),
          Text(title, style: context.type.h5(), textAlign: TextAlign.center),
          const SizedBox(height: EjadahSpacing.xs),
          Text(
            body,
            style: context.type.bodyText(color: EjadahColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: EjadahSpacing.md),
          EjadahSecondaryButton(
            label: actionLabel,
            onPressed: onAction,
            expand: false,
          ),
        ],
      ),
    ),
  );
}
