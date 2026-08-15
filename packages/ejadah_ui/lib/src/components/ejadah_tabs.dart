import 'package:flutter/material.dart';

import '../theme/ejadah_theme.dart';
import '../tokens/ejadah_tokens.dart';

/// The Ejadah tab strip.
///
/// A thin composition over Material's `TabBar` rather than a reimplementation:
/// the gesture, the animation and the semantics are all correct there, and what
/// this product needs to own is the type, the colour and the indicator.
///
/// It exists so those three are decided once. A raw `TabBar` styled at the call
/// site is how a second look creeps in — the country guide had one, and its
/// indicator weight and label case had already drifted from the design system.
class EjadahTabs extends StatelessWidget implements PreferredSizeWidget {
  const EjadahTabs({required this.controller, required this.labels, super.key});

  final TabController controller;

  /// Already in the reader's language. Arabic is never uppercased, so the
  /// labels arrive as authored rather than being transformed here.
  final List<String> labels;

  /// Tall enough to hold a 44 target with the indicator below it.
  @override
  Size get preferredSize => const Size.fromHeight(EjadahSizes.tapTargetMin);

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: EjadahColors.border,
          width: EjadahSizes.cardBorderWidth,
        ),
      ),
    ),
    child: TabBar(
      controller: controller,
      labelColor: EjadahColors.textPrimary,
      unselectedLabelColor: EjadahColors.labelMuted,
      indicatorColor: EjadahColors.orange,
      indicatorWeight: EjadahSizes.cardBorderWidth,
      // The indicator sits under the label, not the whole tab box.
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: context.type.caption(color: EjadahColors.textPrimary),
      unselectedLabelStyle: context.type.caption(
        color: EjadahColors.labelMuted,
      ),
      dividerColor: Colors.transparent,
      // Tabs scroll when they do not fit: Arabic labels run longer than
      // English at the same size, and squeezing them is what truncates them.
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      tabs: [for (final label in labels) Tab(text: label)],
    ),
  );
}
