import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/navigation/creator_navigation.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/features/notifications/data/models/app_notification.dart';
import 'package:starapp/features/notifications/data/provider/notifications_providers.dart';
import 'package:starapp/features/notifications/presentation/widgets/notification_card.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

/// Activity list inside the Home tab (Figma "Notification" / "Marked Notif").
/// Unread items are grouped under "New"; "Mark read" moves them all to
/// "Earlier" and the action flips to "Mark unread", which restores them.
class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _open(BuildContext context, AppNotification n) {
    switch ((n.kind, n.actor?.id)) {
      case (NotificationKind.star, _):
        context.push(AppRoutes.videos);
      case (NotificationKind.follow, final String follower):
        context.pushCreator(follower);
      case _:
        showStarToast(context, 'Coming soon');
    }
  }

  /// Runs a read-state change; the list has already rolled back on failure.
  Future<void> _update(
    BuildContext context,
    Future<void> Function() change,
  ) async {
    try {
      await change();
    } on ApiException catch (e) {
      if (context.mounted) showStarToast(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final notifier = ref.read(notificationsProvider.notifier);
    final items = notifications.value ?? const <AppNotification>[];
    final hasUnread = items.any((n) => !n.isRead);
    final bottom = MediaQuery.paddingOf(context).bottom + 24;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StarScreenHeader(
        title: 'Notifications',
        leading: StarIconButton.back(onPressed: () => _back(context)),
        trailing: items.isEmpty
            ? null
            : _HeaderAction(
                label: hasUnread ? 'Mark read' : 'Mark unread',
                onTap: () => _update(
                  context,
                  hasUnread ? notifier.markAllRead : notifier.markUnread,
                ),
              ),
      ),
      body: StarAsyncView(
        value: notifications,
        onRetry: () => ref.invalidate(notificationsProvider),
        builder: (items) {
          final fresh = [
            for (final n in items)
              if (!n.isRead) n,
          ];
          final earlier = [
            for (final n in items)
              if (n.isRead) n,
          ];

          return NotificationListener<ScrollUpdateNotification>(
            // Fetch the next page as the end comes into view.
            onNotification: (scroll) {
              if (scroll.metrics.extentAfter < 400) notifier.loadMore();
              return false;
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 29, 24, bottom),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                layoutBuilder: (current, previous) => Stack(
                  alignment: Alignment.topCenter,
                  children: [...previous, ?current],
                ),
                child: Column(
                  key: ValueKey(fresh.map((n) => n.id).join(',')),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 15,
                  children: [
                    if (items.isEmpty)
                      const _EmptyState()
                    else ...[
                      if (fresh.isNotEmpty)
                        _Section(
                          title: 'New',
                          count: fresh.length,
                          items: fresh,
                          unread: true,
                          onTap: (n) => _open(context, n),
                        ),
                      if (earlier.isNotEmpty)
                        _Section(
                          title: 'Earlier',
                          items: earlier,
                          unread: false,
                          onTap: (n) => _open(context, n),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.items,
    required this.unread,
    required this.onTap,
    this.count,
  });

  final String title;
  final List<AppNotification> items;
  final bool unread;
  final ValueChanged<AppNotification> onTap;

  /// Shown as an "N new" pill beside the title.
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                height: notificationsLeading,
                letterSpacing: 0,
                fontWeight: FontWeight.w600,
                color: AppColors.brandNavy,
              ),
            ),
            if (count != null) _CountPill(count: count!),
          ],
        ),
        for (final n in items)
          NotificationCard(
            key: ValueKey(n.id),
            notification: n,
            unread: unread,
            onTap: () => onTap(n),
          ),
      ],
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: const ShapeDecoration(
        color: NotificationColors.countPill,
        shape: StadiumBorder(),
      ),
      child: Text(
        '$count new',
        style: const TextStyle(
          fontSize: 12,
          height: 16 / 12,
          letterSpacing: 0,
          fontWeight: FontWeight.w500,
          color: AppColors.brandNavy,
        ),
      ),
    );
  }
}

/// "Mark read" / "Mark unread" text action in the header's trailing slot.
class _HeaderAction extends StatelessWidget {
  const _HeaderAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              height: 20 / 14,
              letterSpacing: 0,
              fontWeight: FontWeight.w500,
              color: AppColors.brandNavy,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 40),
      child: Text(
        'No notifications yet.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          height: notificationsLeading,
          letterSpacing: 0,
          color: NotificationColors.time,
        ),
      ),
    );
  }
}
