import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/notifications_repository.dart';

final notificationCentreProvider = FutureProvider<NotificationCentre>(
  (ref) => ref.watch(notificationsRepositoryProvider).centre(),
);

/// HM-02 · The notification centre.
///
/// The system of record for what the product has told this user, which is why
/// it exists at all: push can be declined, missed or cleared by the OS, and
/// none of that should lose a deadline warning.
///
/// Every row deep-links to the thing it is about. A notification that cannot be
/// acted on is a notification that should not have been sent.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final centre = ref.watch(notificationCentreProvider);

    return Scaffold(
      appBar: EjadahAppBar(
        title: strings.notifications,
        onBack: () => context.pop(),
        backLabel: strings.back,
        action: (centre.valueOrNull?.unread ?? 0) > 0
            ? EjadahGhostButton(
                label: strings.markAllRead,
                onPressed: () async {
                  await ref.read(notificationsRepositoryProvider).markAllRead();
                  ref.invalidate(notificationCentreProvider);
                },
              )
            : null,
      ),
      body: SafeArea(
        top: false,
        child: EjadahPageBody(
          child: centre.when(
            loading: () => ListView.separated(
              itemCount: 4,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: EjadahSpacing.cardGap),
              itemBuilder: (_, _) => const CardSkeleton(),
            ),
            error: (error, _) => EjadahErrorState(
              title: FailureCopy.errorTitle(context),
              body: error is Failure
                  ? error.message(context)
                  : FailureCopy.server(context),
              retryLabel: strings.retry,
              onRetry: () => ref.invalidate(notificationCentreProvider),
            ),
            data: (data) => data.items.isEmpty
                ? EjadahEmptyState(
                    // Names what will arrive and the one action that starts it,
                    // so the empty state explains rather than dead-ends.
                    title: strings.emptyNotifTitle,
                    body: strings.emptyNotifBody,
                    actionLabel: strings.browseProgrammes,
                    onAction: () => context.push('/programmes'),
                  )
                : RefreshIndicator(
                    color: EjadahColors.orange,
                    onRefresh: () async =>
                        ref.invalidate(notificationCentreProvider),
                    child: ListView.separated(
                      key: const PageStorageKey('notifications'),
                      itemCount: data.items.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: EjadahSpacing.cardGap),
                      itemBuilder: (context, index) =>
                          _NotificationRow(item: data.items[index]),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _NotificationRow extends ConsumerWidget {
  const _NotificationRow({required this.item});

  final AppNotification item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = context.language;

    return EjadahCard(
      onTap: item.deepLink == null
          ? null
          : () async {
              // Reading the centre is what marks it read; the OS tray cannot.
              await ref.read(notificationsRepositoryProvider).markAllRead();
              ref.invalidate(notificationCentreProvider);
              if (!context.mounted) return;
              context.push(item.deepLink!);
            },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            switch (item.category) {
              NotificationCategory.deadline => EjadahIcons.calendar,
              NotificationCategory.session => EjadahIcons.clock,
              NotificationCategory.study => EjadahIcons.learn,
            },
            size: EjadahIconSize.inline,
            color: item.isRead
                ? EjadahColors.labelMuted
                : EjadahColors.orangeText,
          ),
          const SizedBox(width: EjadahSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title.resolve(language),
                  style: item.isRead
                      ? context.type.bodyText()
                      : context.type.bodyStrong(),
                ),
                if (item.body.resolve(language).isNotEmpty) ...[
                  const SizedBox(height: EjadahSpacing.xxs),
                  Text(
                    item.body.resolve(language),
                    style: context.type.small(
                      color: EjadahColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (item.deepLink != null)
            const DirectionalIcon(
              EjadahIcons.chevronForward,
              color: EjadahColors.labelMuted,
            ),
        ],
      ),
    );
  }
}
