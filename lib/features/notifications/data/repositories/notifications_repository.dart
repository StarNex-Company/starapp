import 'package:starapp/core/network/paged.dart';
import 'package:starapp/features/notifications/data/models/app_notification.dart';

/// The user's activity feed. Screens read `notificationsProvider`;
/// `notificationsRepositoryProvider` picks the mock or API implementation.
abstract interface class NotificationsRepository {
  /// Newest first; pass the previous page's `nextCursor` for the next one.
  Future<Paged<AppNotification>> fetchNotifications({String? cursor});

  Future<void> markRead(Iterable<String> ids);

  Future<void> markUnread(Iterable<String> ids);
}
