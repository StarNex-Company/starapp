import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/features/notifications/data/models/app_notification.dart';
import 'package:starapp/features/notifications/data/repositories/api_notifications_repository.dart';
import 'package:starapp/features/notifications/data/repositories/mock_notifications_repository.dart';
import 'package:starapp/features/notifications/data/repositories/notifications_repository.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => selectRepository(
    ref,
    mock: MockNotificationsRepository.new,
    api: ApiNotificationsRepository.new,
  ),
);

/// The loaded notifications plus their read state. [NotificationsNotifier.loadMore]
/// appends the next page; "Mark read" moves everything to "Earlier" and
/// "Mark unread" brings back what was last unread. Both update at once and
/// roll back if the server rejects them.
final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<AppNotification>>(
      NotificationsNotifier.new,
    );

class NotificationsNotifier extends AsyncNotifier<List<AppNotification>> {
  /// What "Mark unread" restores.
  Set<String> _lastUnread = {};
  String? _nextCursor;
  bool _loadingMore = false;

  NotificationsRepository get _repository =>
      ref.read(notificationsRepositoryProvider);

  @override
  Future<List<AppNotification>> build() async {
    final page = await ref
        .watch(notificationsRepositoryProvider)
        .fetchNotifications();
    _nextCursor = page.nextCursor;
    _lastUnread = {
      for (final n in page.items)
        if (!n.isRead) n.id,
    };
    return page.items;
  }

  bool get hasMore => _nextCursor != null;

  /// Appends the next page; a no-op on the last page or while loading.
  Future<void> loadMore() async {
    final items = state.value;
    final cursor = _nextCursor;
    if (items == null || cursor == null || _loadingMore) return;
    _loadingMore = true;
    try {
      final page = await _repository.fetchNotifications(cursor: cursor);
      _nextCursor = page.nextCursor;
      state = AsyncData([...items, ...page.items]);
    } finally {
      _loadingMore = false;
    }
  }

  Future<void> markAllRead() async {
    final items = state.value;
    if (items == null) return;
    final unread = {
      for (final n in items)
        if (!n.isRead) n.id,
    };
    if (unread.isEmpty) return;
    _lastUnread = unread;
    await _optimistic(
      items,
      isRead: (_) => true,
      request: () => _repository.markRead(unread),
    );
  }

  Future<void> markUnread() async {
    final items = state.value;
    if (items == null || items.isEmpty) return;
    final restore = _lastUnread.isNotEmpty ? _lastUnread : {items.first.id};
    await _optimistic(
      items,
      isRead: (id) => !restore.contains(id),
      request: () => _repository.markUnread(restore),
    );
  }

  Future<void> _optimistic(
    List<AppNotification> items, {
    required bool Function(String id) isRead,
    required Future<void> Function() request,
  }) async {
    state = AsyncData([
      for (final n in items) n.copyWith(isRead: isRead(n.id)),
    ]);
    try {
      await request();
    } catch (_) {
      state = AsyncData(items);
      rethrow;
    }
  }
}
