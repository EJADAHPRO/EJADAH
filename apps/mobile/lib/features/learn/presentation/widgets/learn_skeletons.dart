import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/widgets.dart';

/// Loading skeletons for the Learn tab.
///
/// The screen state matrix flags LN-01 and LN-02 as missing a loading
/// treatment. These close that gap with Home's shimmer blocks, shaped per card
/// type: a shape that matches the incoming content tells the user what to
/// expect, which a spinner cannot.

/// Three department doors, in the shape of the cards that follow.
class LearnHubSkeleton extends StatelessWidget {
  const LearnHubSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var i = 0; i < 3; i++) ...[
        Container(
          padding: const EdgeInsets.all(EjadahSpacing.md),
          decoration: BoxDecoration(
            color: EjadahColors.card,
            borderRadius: EjadahRadius.card,
            border: Border.all(
              color: EjadahColors.border,
              width: EjadahSizes.cardBorderWidth,
            ),
          ),
          child: Row(
            children: [
              Skeleton(
                width: 44,
                height: 44,
                borderRadius: EjadahRadius.all(EjadahRadius.md),
              ),
              const SizedBox(width: EjadahSpacing.sm),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(width: 140, height: 16),
                    SizedBox(height: EjadahSpacing.xs),
                    Skeleton(width: 72, height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: EjadahSpacing.cardGap),
      ],
    ],
  );
}

/// A list of course cards on their way.
class CourseListSkeleton extends StatelessWidget {
  const CourseListSkeleton({this.count = 3, super.key});

  final int count;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var i = 0; i < count; i++) ...[
        const CardSkeleton(),
        const SizedBox(height: EjadahSpacing.cardGap),
      ],
    ],
  );
}

/// The course detail screen: a hero block, then a curriculum list.
class CourseDetailSkeleton extends StatelessWidget {
  const CourseDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Skeleton(width: 100, height: 12),
      SizedBox(height: EjadahSpacing.xs),
      Skeleton(width: double.infinity, height: 28),
      SizedBox(height: EjadahSpacing.xs),
      Skeleton(width: 220, height: 16),
      SizedBox(height: EjadahSpacing.lg),
      CardSkeleton(),
      SizedBox(height: EjadahSpacing.cardGap),
      Skeleton(width: 120, height: 12),
      SizedBox(height: EjadahSpacing.sm),
      Skeleton(width: double.infinity, height: 44),
      SizedBox(height: EjadahSpacing.xs),
      Skeleton(width: double.infinity, height: 44),
      SizedBox(height: EjadahSpacing.xs),
      Skeleton(width: double.infinity, height: 44),
    ],
  );
}

/// A list of rows — handouts, or a deck list.
class LearnRowsSkeleton extends StatelessWidget {
  const LearnRowsSkeleton({this.count = 4, super.key});

  final int count;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var i = 0; i < count; i++) ...[
        const Row(
          children: [
            Skeleton(width: 32, height: 32),
            SizedBox(width: EjadahSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton(width: 180, height: 14),
                  SizedBox(height: EjadahSpacing.xxs),
                  Skeleton(width: 80, height: 10),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: EjadahSpacing.md),
      ],
    ],
  );
}
