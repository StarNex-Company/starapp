import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/features/messages/data/models/inbox.dart';
import 'package:starapp/features/messages/data/provider/messages_providers.dart';
import 'package:starapp/features/messages/presentation/widgets/inbox_widgets.dart';
import 'package:starapp/features/messages/presentation/widgets/messages_style.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';

/// The Messages tab's first page (Figma "Inbox — Messages"): search, the
/// All / Scout / Requests segments, the Scout Requests banner and the
/// conversations. Search filters the list in place.
class MessagesPage extends ConsumerStatefulWidget {
  const MessagesPage({super.key});

  @override
  ConsumerState<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends ConsumerState<MessagesPage> {
  final _search = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearch(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) ref.read(conversationQueryProvider.notifier).set(text);
    });
  }

  void _openBanner(InboxSummary summary) {
    final only = summary.firstRequestId;
    if (summary.pendingScoutRequests == 1 && only != null) {
      context.push(AppRoutes.scoutRequest(only));
    } else {
      context.push(AppRoutes.messageRequests);
    }
  }

  void _openConversation(ConversationSummary c) {
    final link = c.deepLink;
    if (link != null) {
      context.push(link);
      return;
    }
    ref.read(conversationsProvider.notifier).markOpened(c.id);
    context.push(AppRoutes.conversation(c.id));
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(inboxSummaryProvider).value;
    final conversations = ref.watch(conversationsProvider);
    final query = ref.watch(conversationQueryProvider);
    final bottom = MediaQuery.paddingOf(context).bottom + 24;
    final requests = summary?.pendingScoutRequests ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StarScreenHeader(
        title: 'Messages',
        trailing: StarIconButton(
          icon: MessagesIcons.edit,
          tooltip: 'New message',
          onPressed: () => context.push(AppRoutes.newMessage),
        ),
      ),
      body: NotificationListener<ScrollUpdateNotification>(
        // Fetch the next page as the end comes into view.
        onNotification: (scroll) {
          if (scroll.metrics.extentAfter < 400) {
            ref.read(conversationsProvider.notifier).loadMore();
          }
          return false;
        },
        child: RefreshIndicator(
          color: AppColors.brandNavy,
          onRefresh: () => ref.refresh(conversationsProvider.future),
          child: ListView(
            padding: EdgeInsets.fromLTRB(24, 25, 24, bottom),
            children: [
              InboxSearchField(controller: _search, onChanged: _onSearch),
              const SizedBox(height: 12),
              InboxSegments(
                requestCount: requests,
                onScout: () => context.push(AppRoutes.scout),
                onRequests: () => context.push(AppRoutes.messageRequests),
              ),
              if (summary != null && requests > 0) ...[
                const SizedBox(height: 12),
                ScoutRequestsBanner(
                  summary: summary,
                  onTap: () => _openBanner(summary),
                ),
              ],
              const SizedBox(height: 12),
              if (conversations.hasValue)
                ..._rows(conversations.requireValue, query)
              else
                SizedBox(
                  height: 240,
                  child: StarAsyncView(
                    value: conversations,
                    onRetry: () => ref.invalidate(conversationsProvider),
                    builder: (_) => const SizedBox.shrink(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _rows(List<ConversationSummary> items, String query) {
    if (items.isEmpty) {
      return [
        _EmptyState(
          query.isEmpty
              ? 'No conversations yet.'
              : 'No conversations match “$query”.',
        ),
      ];
    }
    return [
      for (final c in items)
        Padding(
          key: ValueKey(c.id),
          padding: const EdgeInsets.only(bottom: 12),
          child: ConversationRow(
            conversation: c,
            onTap: () => _openConversation(c),
          ),
        ),
    ];
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: messagesText(14, color: AppColors.textSubtle),
      ),
    );
  }
}
