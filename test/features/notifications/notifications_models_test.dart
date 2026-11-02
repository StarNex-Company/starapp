import 'package:flutter_test/flutter_test.dart';
import 'package:starapp/core/models/creator_summary.dart';
import 'package:starapp/features/notifications/data/models/app_notification.dart';
import 'package:starapp/features/notifications/data/repositories/mock_notifications_repository.dart';

void main() {
  test(
    'the mock page parses and covers every state the screen shows',
    () async {
      final page = await const MockNotificationsRepository()
          .fetchNotifications();

      expect(page.items, isNotEmpty);
      expect(page.items.any((n) => !n.isRead), isTrue, reason: '"New" group');
      expect(
        page.items.any((n) => n.isRead),
        isTrue,
        reason: '"Earlier" group',
      );
      expect(
        page.items.any(
          (n) => n.kind == NotificationKind.follow && n.actor != null,
        ),
        isTrue,
        reason: 'a follow opens the follower',
      );
    },
  );

  test('toJson round-trips', () async {
    final page = await const MockNotificationsRepository().fetchNotifications();

    for (final n in page.items) {
      final copy = AppNotification.fromJson(n.toJson());
      expect(copy.toJson(), n.toJson());
    }
  });

  test('unknown kinds and missing fields fall back instead of throwing', () {
    final n = AppNotification.fromJson({
      'id': 'x',
      'kind': 'somethingNew',
      'message': 'Hi',
    });

    expect(n.kind, NotificationKind.tier);
    expect(n.isRead, isFalse);
    expect(n.actor, isNull);
  });

  test('CreatorSummary round-trips', () {
    const creator = CreatorSummary(
      id: 'chidi',
      name: 'Chidi Eze',
      handle: 'chidi_eze',
      avatarUrl: 'https://cdn.example.com/a.jpg',
      isVerified: true,
    );

    expect(CreatorSummary.fromJson(creator.toJson()), creator);
  });
}
