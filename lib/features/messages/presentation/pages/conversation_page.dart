import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/models/attachment.dart';
import 'package:starapp/core/navigation/creator_navigation.dart';
import 'package:starapp/core/navigation/tab_navigation.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/features/messages/data/models/conversation.dart';
import 'package:starapp/features/messages/data/models/message.dart';
import 'package:starapp/features/messages/data/models/offer.dart';
import 'package:starapp/features/messages/data/models/participant.dart';
import 'package:starapp/features/messages/data/provider/messages_providers.dart';
import 'package:starapp/features/messages/presentation/widgets/conversation_chrome.dart';
import 'package:starapp/features/messages/presentation/widgets/conversation_sheets.dart';
import 'package:starapp/features/messages/presentation/widgets/message_bubbles.dart';
import 'package:starapp/features/messages/presentation/widgets/messages_style.dart';
import 'package:starapp/features/messages/presentation/widgets/offer_widgets.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

/// One thread, full screen (Figma "Inbox — Scout Conversation"). Scout
/// threads pin their proposal on top and carry the offer card. Messages
/// update live; the user's own show their delivery state.
class ConversationPage extends ConsumerWidget {
  const ConversationPage({super.key, required this.conversationId});

  final String conversationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = conversationProvider(conversationId);
    final thread = ref.watch(provider);
    final conversation = thread.value?.conversation;

    void back() {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.messages);
      }
    }

    return Scaffold(
      backgroundColor: MessagesColors.thread,
      appBar: ConversationHeader(
        title: conversation?.counterpart.displayName ?? '',
        subtitle: conversation == null
            ? ''
            : conversationSubtitle(conversation),
        online: conversation?.isOnline ?? false,
        onBack: back,
        onTitle: conversation == null
            ? null
            : _profileOpener(context, conversation.counterpart),
        onMenu: conversation == null
            ? null
            : () => _menu(context, ref, conversation),
      ),
      body: StarAsyncView(
        value: thread,
        onRetry: () => ref.invalidate(provider),
        builder: (thread) => _ThreadBody(thread: thread),
      ),
    );
  }

  /// The counterpart's page: a company profile or a creator profile.
  static VoidCallback? _profileOpener(BuildContext context, Participant p) =>
      switch (p.kind) {
        // The company page lives in the Messages tab; this page is full
        // screen, so it goes through the tab-route mirror.
        ParticipantKind.company => () => context.pushInTab(
          AppRoutes.company(p.id),
        ),
        ParticipantKind.creator => () => context.pushCreator(p.id),
        ParticipantKind.system => null,
      };

  Future<void> _menu(
    BuildContext context,
    WidgetRef ref,
    Conversation conversation,
  ) async {
    final action = await showConversationMenu(context, conversation);
    if (action == null || !context.mounted) return;
    final notifier = ref.read(conversationProvider(conversationId).notifier);
    try {
      switch (action) {
        case ConversationMenuAction.profile:
          _profileOpener(context, conversation.counterpart)?.call();
        case ConversationMenuAction.mute:
          final muted = !conversation.isMuted;
          await notifier.setMuted(muted: muted);
          if (context.mounted) {
            showStarToast(
              context,
              muted ? 'Conversation muted' : 'Conversation unmuted',
            );
          }
        case ConversationMenuAction.report:
          await notifier.report();
          if (context.mounted) {
            showStarToast(context, 'Thanks, our team will review this');
          }
      }
    } catch (e) {
      if (context.mounted) showStarToast(context, describeError(e));
    }
  }
}

class _ThreadBody extends ConsumerWidget {
  const _ThreadBody({required this.thread});

  final ConversationThread thread;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversation = thread.conversation;
    final notifier = ref.read(conversationProvider(conversation.id).notifier);
    final proposal = conversation.proposal;
    final requestId = conversation.scoutRequestId;
    final entries = _entries(thread.messages);

    Future<void> run(Future<void> Function() action, [String? done]) async {
      try {
        await action();
        if (done != null && context.mounted) showStarToast(context, done);
      } catch (e) {
        if (context.mounted) showStarToast(context, describeError(e));
      }
    }

    void openAttachment(Attachment a) =>
        context.pushInTab(AppRoutes.attachment(a.id));

    Future<void> counter(Offer offer) async {
      final input = await showCounterOfferSheet(
        context,
        subtitle: proposal?.offerId == offer.id && proposal!.title.isNotEmpty
            ? proposal.title
            : offer.role,
        recipient: conversation.counterpart.shortName,
        current: offer.amount,
      );
      if (input == null || !context.mounted) return;
      await run(
        () => notifier.counterOffer(offer.id, input.amount, input.note),
        'Counter offer sent to ${conversation.counterpart.shortName}',
      );
    }

    Future<void> attach() async {
      final option = await showAttachSheet(context);
      if (option == null || !context.mounted) return;
      switch (option) {
        // No file picker in the app yet.
        case AttachOption.media || AttachOption.document:
          showStarToast(context, 'Coming soon');
        case AttachOption.talentPassport:
          await run(notifier.shareTalentPassport);
      }
    }

    Widget message(Message m) => switch (m.type) {
      MessageType.text => TextBubble(
        message: m,
        onRetry: () => run(() => notifier.retry(m)),
      ),
      MessageType.attachment => AttachmentBubble(
        message: m,
        onOpen: () => openAttachment(m.attachment!),
      ),
      MessageType.offer when m.offer != null => OfferCard(
        offer: m.offer!,
        mine: m.isMine,
        onAccept: () => run(
          () => notifier.acceptOffer(m.offer!.id),
          'Offer accepted · contract sent to your inbox',
        ),
        onCounter: () => counter(m.offer!),
        onOpenAttachment: openAttachment,
      ),
      _ => SystemNotice(text: m.text ?? ''),
    };

    return Column(
      children: [
        if (conversation.kind == ConversationKind.scout && proposal != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 19, 24, 0),
            child: PinnedProposalBar(
              proposal: proposal,
              onView: requestId == null
                  ? null
                  : () => context.push(AppRoutes.scoutRequest(requestId)),
            ),
          ),
        Expanded(
          child: NotificationListener<ScrollUpdateNotification>(
            // Older messages load as the top comes into view.
            onNotification: (scroll) {
              if (scroll.metrics.extentAfter < 400) notifier.loadMore();
              return false;
            },
            child: ListView.separated(
              reverse: true,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              itemCount: entries.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) => switch (entries[i]) {
                final Message m => KeyedSubtree(
                  key: ValueKey(m.id),
                  child: message(m),
                ),
                final DateTime day => DaySeparator(day: day),
                _ => const SizedBox.shrink(),
              },
            ),
          ),
        ),
        if (conversation.canSend)
          MessageComposer(
            hint: 'Message ${conversation.counterpart.shortName}…',
            onSend: (text) => run(() => notifier.send(text)),
            onAttach: attach,
          )
        else
          const _ReadOnlyNote(),
      ],
    );
  }

  /// Messages (newest first) with a day marker above each day's first one.
  static List<Object> _entries(List<Message> messages) {
    final entries = <Object>[];
    for (var i = 0; i < messages.length; i++) {
      final m = messages[i];
      entries.add(m);
      final older = i + 1 < messages.length ? messages[i + 1] : null;
      if (older == null || !DateUtils.isSameDay(older.sentAt, m.sentAt)) {
        entries.add(DateUtils.dateOnly(m.sentAt));
      }
    }
    return entries;
  }
}

class _ReadOnlyNote extends StatelessWidget {
  const _ReadOnlyNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.paddingOf(context).bottom + 16,
      ),
      child: Text(
        "You can't reply to this conversation.",
        textAlign: TextAlign.center,
        style: messagesText(13, color: AppColors.textSubtle),
      ),
    );
  }
}
