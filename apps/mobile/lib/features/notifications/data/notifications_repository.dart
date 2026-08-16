import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';

/// What the centre holds, and how much of it is unread.
class NotificationCentre {
  const NotificationCentre({required this.items, required this.unread});

  const NotificationCentre.empty() : items = const [], unread = 0;

  final List<AppNotification> items;
  final int unread;

  factory NotificationCentre.fromJson(Map<String, dynamic> json) =>
      NotificationCentre(
        items: (json['items'] as List<dynamic>? ?? const [])
            .map(
              (item) => AppNotification.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList(),
        unread: jsonInt(json['unread']) ?? 0,
      );
}

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => NotificationsRepository(ref.watch(apiClientProvider)),
);

/// Talks to `/notifications`.
///
/// The centre is the system of record rather than the OS tray: a user who
/// declined push permission, or who was offline when a reminder went out, still
/// finds every notification here.
class NotificationsRepository {
  const NotificationsRepository(this._client);

  final ApiClient _client;

  Future<NotificationCentre> centre() =>
      _client.get('/notifications/', parse: NotificationCentre.fromJson);

  Future<void> markAllRead() => _client.postVoid('/notifications/read');

  Future<NotificationPreferences> preferences() => _client.get(
    '/notifications/preferences',
    parse: NotificationPreferences.fromJson,
  );

  /// Sends only what changed, so a client that knows about two switches cannot
  /// silently reset a third it has never heard of.
  Future<NotificationPreferences> updatePreferences(
    Map<String, bool> changes,
  ) => _client.put(
    '/notifications/preferences',
    body: changes,
    parse: NotificationPreferences.fromJson,
  );
}
