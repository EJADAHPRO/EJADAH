import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../documents/document_viewer.dart';
import '../data/learn_models.dart';
import '../data/learn_repository.dart';
import 'widgets/learn_skeletons.dart';

/// The course's handouts, owner-only.
final _handoutsProvider = FutureProvider.family<List<Handout>, int>(
  (ref, courseId) => ref.watch(learnRepositoryProvider).handouts(courseId),
);

/// LN-07 · Handouts.
///
/// Each row states the file's size before it is fetched, because a dentist on
/// a phone plan deserves to know what a tap will cost them.
///
/// A handout **opens in a viewer**; it is never written to the device. LN-11
/// Downloads is cut (owner decision, 16 Aug 2026), so there is no offline
/// library, no storage screen and nothing to delete — a tap fetches the bytes,
/// shows them, and lets them go.
class HandoutsScreen extends ConsumerStatefulWidget {
  const HandoutsScreen({
    required this.courseId,
    required this.title,
    super.key,
  });

  final int courseId;
  final String title;

  @override
  ConsumerState<HandoutsScreen> createState() => _HandoutsScreenState();
}

class _HandoutsScreenState extends ConsumerState<HandoutsScreen> {
  final Set<int> _inFlight = {};
  final Set<int> _fetched = {};

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final handouts = ref.watch(_handoutsProvider(widget.courseId));

    return GradientBudget(
      screenName: 'handouts',
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              EjadahAppBar(
                title: strings.handoutsTitle,
                backLabel: strings.back,
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: EjadahPageBody(
                  child: handouts.when(
                    loading: () => ListView(
                      children: const [
                        SizedBox(height: EjadahSpacing.md),
                        LearnRowsSkeleton(),
                      ],
                    ),
                    error: (error, _) => EjadahErrorState(
                      title: FailureCopy.errorTitle(context),
                      body: error is Failure
                          ? error.message(context)
                          : FailureCopy.server(context),
                      retryLabel: strings.retry,
                      onRetry: () =>
                          ref.invalidate(_handoutsProvider(widget.courseId)),
                    ),
                    data: (items) => items.isEmpty
                        ? EjadahEmptyState(
                            title: strings.handoutsTitle,
                            body: strings.contentUnavailableBody,
                            actionLabel: strings.back,
                            onAction: () => Navigator.of(context).maybePop(),
                          )
                        : ListView(
                            children: [
                              const SizedBox(height: EjadahSpacing.sm),
                              Text(widget.title, style: context.type.h6()),
                              const SizedBox(height: EjadahSpacing.sm),
                              for (final handout in items)
                                _HandoutRow(
                                  handout: handout,
                                  isFetching: _inFlight.contains(handout.id),
                                  isFetched: _fetched.contains(handout.id),
                                  onFetch: () => _open(handout),
                                ),
                              const SizedBox(height: EjadahSpacing.section),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Fetches the handout and hands it to the platform's document viewer.
  ///
  /// The bytes are held for exactly as long as the viewer needs them. Nothing
  /// reaches the file system, which is the whole shape of the feature after
  /// Downloads was cut.
  Future<void> _open(Handout handout) async {
    if (_inFlight.contains(handout.id)) return;
    setState(() => _inFlight.add(handout.id));

    try {
      final bytes = await ref
          .read(learnRepositoryProvider)
          .fetchHandout(handout.id);
      if (!mounted) return;
      setState(() {
        _inFlight.remove(handout.id);
        _fetched.add(handout.id);
      });
      await ref.read(documentViewerProvider)(
        bytes: bytes,
        name: handout.title(context),
      );
    } on Failure catch (failure) {
      if (!mounted) return;
      setState(() => _inFlight.remove(handout.id));
      showEjadahToast(context, message: failure.message(context));
    }
  }
}

class _HandoutRow extends StatelessWidget {
  const _HandoutRow({
    required this.handout,
    required this.isFetching,
    required this.isFetched,
    required this.onFetch,
  });

  final Handout handout;
  final bool isFetching;
  final bool isFetched;
  final VoidCallback onFetch;

  @override
  Widget build(BuildContext context) => EjadahListRow(
    title: handout.title(context),
    onTap: isFetching ? null : onFetch,
    leading: const Icon(
      EjadahIcons.certificate,
      size: EjadahIconSize.inline,
      color: EjadahColors.labelStrong,
    ),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // File sizes are Latin-context: "1.2 MB" must not be reordered.
        LtrIsland(
          child: Text(
            handout.sizeLabel,
            style: context.type.tabular(fontSize: 12),
          ),
        ),
        const SizedBox(width: EjadahSpacing.xs),
        Icon(
          // Opens, not downloads — the glyph has to agree with what happens.
          isFetched ? EjadahIcons.check : EjadahIcons.externalLink,
          size: EjadahIconSize.inline,
          color: isFetched ? EjadahColors.successText : EjadahColors.labelMuted,
        ),
      ],
    ),
  );
}
