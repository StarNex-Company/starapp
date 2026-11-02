import 'package:starapp/core/network/paged.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/notifications/data/models/app_notification.dart';
import 'package:starapp/features/notifications/data/repositories/notifications_repository.dart';

/// Serves [_page], shaped like the `GET /notifications` response, through
/// the real `fromJson`, so mock mode exercises the same parsing as the API.
class MockNotificationsRepository implements NotificationsRepository {
  const MockNotificationsRepository();

  @override
  Future<Paged<AppNotification>> fetchNotifications({String? cursor}) async =>
      Paged.fromJson(_page(DateTime.now()), AppNotification.fromJson);

  @override
  Future<void> markRead(Iterable<String> ids) async {}

  @override
  Future<void> markUnread(Iterable<String> ids) async {}
}

const _musician = 'assets/images/notifications/notif_avatar_musician.jpg';

Json _page(DateTime now) {
  String ago(Duration d) => now.subtract(d).toUtc().toIso8601String();

  return {
    'items': [
      {
        'id': 'n1',
        'kind': 'star',
        'message': 'Chidi and 23 others starred your video',
        'createdAt': ago(const Duration(minutes: 2)),
        'imageUrl': _musician,
        'postId': 'late-night-vocal-run',
        'isRead': false,
      },
      {
        'id': 'n2',
        'kind': 'comment',
        'message': 'Emmanuel Foster commented: “OMG! I Love this”',
        'createdAt': ago(const Duration(minutes: 2)),
        'imageUrl': _musician,
        'postId': 'late-night-vocal-run',
        'isRead': false,
      },
      {
        'id': 'n3',
        'kind': 'follow',
        'message': 'Tolu Adeyemi started following you',
        'createdAt': ago(const Duration(hours: 5)),
        'actor': {
          'id': 'tolu-adeyemi',
          'name': 'Tolu Adeyemi',
          'handle': 'tolu_adeyemi',
          'avatarUrl': _musician,
        },
        'isRead': true,
      },
      {
        'id': 'n4',
        'kind': 'tier',
        'message': 'You’re 721 points from Stellar tier',
        'createdAt': ago(const Duration(hours: 1)),
        'imageUrl': _musician,
        'isRead': true,
      },
    ],
    'nextCursor': null,
  };
}
