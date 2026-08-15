import 'package:flutter/widgets.dart';

import '../theme/ejadah_theme.dart';
import '../tokens/ejadah_tokens.dart';

/// A responsive grid of cards: one column on a phone, two on a tablet, three on
/// a wide window.
///
/// Built as rows inside a list rather than a `SliverGrid`, because a grid
/// delegate needs a fixed aspect ratio and these cards are as tall as their
/// content — a programme with a long university name is taller than one
/// without, and forcing them to a shared ratio either clips the tall one or
/// pads the short one. Each row sizes to its own tallest card instead.
class SliverCardGrid extends StatelessWidget {
  const SliverCardGrid({
    required this.itemCount,
    required this.itemBuilder,
    this.spacing = EjadahSpacing.cardGap,
    super.key,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final columns = context.ejadah.windowClass.gridColumns;

    if (columns <= 1) {
      return SliverList.separated(
        itemCount: itemCount,
        separatorBuilder: (_, _) => SizedBox(height: spacing),
        itemBuilder: itemBuilder,
      );
    }

    final rowCount = (itemCount + columns - 1) ~/ columns;
    return SliverList.separated(
      itemCount: rowCount,
      separatorBuilder: (_, _) => SizedBox(height: spacing),
      itemBuilder: (context, row) => IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var column = 0; column < columns; column++) ...[
              if (column > 0) SizedBox(width: spacing),
              Expanded(
                child: row * columns + column < itemCount
                    ? itemBuilder(context, row * columns + column)
                    // The last row is padded rather than stretched, so a
                    // lone card on it stays card-width instead of spanning.
                    : const SizedBox.shrink(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
