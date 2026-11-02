import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/core/network/paged.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/notifications/data/models/app_notification.dart';
import 'package:starapp/features/notifications/data/repositories/notifications_repository.dart';

class ApiNotificationsRepository implements NotificationsRepository {
  const ApiNotificationsRepository(this._client);

  final ApiClient _client;

  @override
  Future<Paged<AppNotification>> fetchNotifications({String? cursor}) =>
      _client.get(
        '/notifications',
        query: {'cursor': cursor},
        decode: (json) =>
            Paged.fromJson(json as Json, AppNotification.fromJson),
      );

  @override
  Future<void> markRead(Iterable<String> ids) => _client.post<void>(
    '/notifications/read',
    data: {
      'ids': [...ids],
    },
  );

  @override
  Future<void> markUnread(Iterable<String> ids) => _client.post<void>(
    '/notifications/unread',
    data: {
      'ids': [...ids],
    },
  );
}
