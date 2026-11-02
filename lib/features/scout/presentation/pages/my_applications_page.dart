import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/navigation/tab_navigation.dart';
import 'package:starapp/features/scout/data/models/application.dart';
import 'package:starapp/features/scout/data/provider/scout_providers.dart';
import 'package:starapp/features/scout/presentation/widgets/scout_style.dart';
import 'package:starapp/features/scout/presentation/widgets/scout_widgets.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';

/// My Applications (Figma "Scout — My Applications"), inside the Messages
/// tab: "Active" then "Closed", each paged. A row opens what comes next for
/// its status: the call, the offer's conversation, or the payout.
class MyApplicationsPage extends ConsumerWidget {
  const MyApplicationsPage({super.key});

  /// Where a row leads; null when the server didn't send the target id.
  static VoidCallback? _destination(BuildContext context, Application a) {
    final callId = a.openCallId;
    final conversationId = a.conversationId;
    final transactionId = a.transactionId;
    return switch (a.status) {
      ApplicationStatus.offer when conversationId != null => () => context.push(
        AppRoutes.conversation(conversationId),
      ),
      ApplicationStatus.completed when transactionId != null =>
        () => context.push(AppRoutes.walletTransaction(transactionId)),
      ApplicationStatus.offer || ApplicationStatus.completed => null,
      _ when callId != null => () => context.pushInTab(
        AppRoutes.scoutCall(callId),
      ),
      _ => null,
    };
  }

  static String _subtitle(Application a) {
    final when = switch (a.status) {
      ApplicationStatus.offer => 'offer received',
      _ when a.isActive => 'applied ${DateFormat('MMM d').format(a.appliedAt)}',
      _ => DateFormat('MMM y').format(a.updatedAt ?? a.appliedAt),
    };
    return '${a.company.name} · $when';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(myApplicationsProvider(true));
    final closed = ref.watch(myApplicationsProvider(false));
    final bottom = MediaQuery.paddingOf(context).bottom + 24;

    Widget section(String title, List<Application> items) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        ScoutSectionTitle(title),
        ...withDividers([
          for (final a in items)
            ScoutListRow(
              key: ValueKey(a.id),
              icon: a.status == ApplicationStatus.completed
                  ? ScoutIcons.star
                  : ScoutIcons.category(a.category),
              title: a.title,
              subtitle: _subtitle(a),
              value: applicationStatusLabel(a.status),
              onTap: _destination(context, a),
            ),
        ]),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StarScreenHeader(
        title: 'My applications',
        leading: StarIconButton.back(
          onPressed: () => scoutBack(context, AppRoutes.scout),
        ),
      ),
      body: StarAsyncView(
        value: active,
        onRetry: () => ref.invalidate(myApplicationsProvider),
        builder: (activeItems) {
          final closedItems = closed.value ?? const <Application>[];
          final activeMore = ref
              .read(myApplicationsProvider(true).notifier)
              .hasMore;
          final closedMore =
              closed.isLoading ||
              ref.read(myApplicationsProvider(false).notifier).hasMore;

          return NotificationListener<ScrollUpdateNotification>(
            onNotification: (scroll) {
              if (scroll.metrics.extentAfter < 400) {
                activeMore
                    ? ref.read(myApplicationsProvider(true).notifier).loadMore()
                    : ref
                          .read(myApplicationsProvider(false).notifier)
                          .loadMore();
              }
              return false;
            },
            child: ListView(
              padding: EdgeInsets.fromLTRB(24, 25, 24, bottom),
              children: [
                if (activeItems.isEmpty && closedItems.isEmpty && !closedMore)
                  const ScoutEmptyState(
                    "You haven't applied to any open calls yet.",
                  )
                else ...[
                  if (activeItems.isNotEmpty) section('Active', activeItems),
                  if (activeItems.isNotEmpty && closedItems.isNotEmpty)
                    const SizedBox(height: 12),
                  if (closedItems.isNotEmpty) section('Closed', closedItems),
                  if (activeMore || closedMore) const ScoutLoadingMore(),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
