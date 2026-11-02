import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starapp/core/models/attachment.dart';
import 'package:starapp/core/models/money.dart';
import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/core/session/data/provider/session_providers.dart';
import 'package:starapp/features/messages/data/models/attachment_preview.dart';
import 'package:starapp/features/messages/data/models/conversation.dart';
import 'package:starapp/features/messages/data/models/direct_conversation.dart';
import 'package:starapp/features/messages/data/models/inbox.dart';
import 'package:starapp/features/messages/data/models/message.dart';
import 'package:starapp/features/messages/data/models/offer.dart';
import 'package:starapp/features/messages/data/models/participant.dart';
import 'package:starapp/features/messages/data/repositories/api_messages_repository.dart';
import 'package:starapp/features/messages/data/repositories/messages_repository.dart';
import 'package:starapp/features/messages/data/repositories/mock_messages_repository.dart';

final messagesRepositoryProvider = Provider<MessagesRepository>(
  (ref) => selectRepository(
    ref,
    mock: MockMessagesRepository.new,
    api: ApiMessagesRepository.new,
  ),
);

/// Live inbox counts: unread messages (the Messages tab's dot), pending Scout
/// requests and the banner's preview. Follows `watchInbox`, so it updates on
/// its own.
final inboxSummaryProvider = StreamProvider.autoDispose<InboxSummary>(
  (ref) => ref.watch(messagesRepositoryProvider).watchInbox(),
);

// Inbox

/// What the inbox search field holds; [conversationsProvider] refetches
/// whenever it changes.
final conversationQueryProvider =
    NotifierProvider.autoDispose<ConversationQueryNotifier, String>(
      ConversationQueryNotifier.new,
    );

class ConversationQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String query) => state = query.trim();
}

/// The inbox rows for the current search. [ConversationsNotifier.loadMore]
/// appends the next page. Every inbox change refreshes the first page.
final conversationsProvider =
    AsyncNotifierProvider.autoDispose<
      ConversationsNotifier,
      List<ConversationSummary>
    >(ConversationsNotifier.new);

class ConversationsNotifier extends AsyncNotifier<List<ConversationSummary>> {
  String? _nextCursor;
  var _pages = 0;
  var _loadingMore = false;

  MessagesRepository get _repository => ref.read(messagesRepositoryProvider);

  String? get _query {
    final query = ref.read(conversationQueryProvider);
    return query.isEmpty ? null : query;
  }

  @override
  Future<List<ConversationSummary>> build() async {
    final repository = ref.watch(messagesRepositoryProvider);
    final query = ref.watch(conversationQueryProvider);
    ref.listen(inboxSummaryProvider, (previous, next) {
      if ((previous?.hasValue ?? false) && next.hasValue) _refreshFirstPage();
    });
    final page = await repository.listConversations(
      query: query.isEmpty ? null : query,
    );
    _nextCursor = page.nextCursor;
    _pages = 1;
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
      final page = await _repository.listConversations(
        query: _query,
        cursor: cursor,
      );
      if (!ref.mounted) return;
      _nextCursor = page.nextCursor;
      _pages++;
      state = AsyncData([...items, ...page.items]);
    } finally {
      _loadingMore = false;
    }
  }

  /// Clears a row's unread badge as its thread opens; the thread itself
  /// tells the server.
  void markOpened(String conversationId) {
    final items = state.value;
    if (items == null) return;
    state = AsyncData([
      for (final c in items)
        c.id == conversationId && c.unreadCount > 0
            ? c.copyWith(unreadCount: 0)
            : c,
    ]);
  }

  /// Swaps in the latest first page, keeping any older pages already loaded.
  /// A failed refresh keeps what's on screen; the next change tries again.
  Future<void> _refreshFirstPage() async {
    if (state.value == null || _loadingMore) return;
    final query = _query;
    try {
      final page = await _repository.listConversations(query: query);
      final items = state.value;
      if (!ref.mounted || items == null || query != _query) return;
      if (_pages <= 1) {
        _nextCursor = page.nextCursor;
        state = AsyncData(page.items);
        return;
      }
      final fresh = {for (final c in page.items) c.id};
      state = AsyncData([
        ...page.items,
        for (final c in items)
          if (!fresh.contains(c.id)) c,
      ]);
    } catch (_) {
      // Keep the current rows.
    }
  }
}

// Thread

/// A conversation and its loaded messages, newest first.
class ConversationThread {
  const ConversationThread({
    required this.conversation,
    required this.messages,
    this.hasMore = false,
  });

  final Conversation conversation;
  final List<Message> messages;

  /// Older messages are left to load.
  final bool hasMore;

  ConversationThread copyWith({
    Conversation? conversation,
    List<Message>? messages,
    bool? hasMore,
  }) => ConversationThread(
    conversation: conversation ?? this.conversation,
    messages: messages ?? this.messages,
    hasMore: hasMore ?? this.hasMore,
  );
}

/// One thread: the history, merged with `watchConversation` as it updates,
/// plus the user's optimistic sends (matched to the server's copies by
/// `clientId`). Offer replies and mute update at once and roll back on
/// failure; a failed send stays in the thread, marked failed, for [retry].
final conversationProvider = AsyncNotifierProvider.autoDispose
    .family<ConversationNotifier, ConversationThread, String>(
      ConversationNotifier.new,
    );

class ConversationNotifier extends AsyncNotifier<ConversationThread> {
  ConversationNotifier(this.conversationId);

  final String conversationId;
  String? _nextCursor;
  String? _lastReadId;
  var _loadingMore = false;

  MessagesRepository get _repository => ref.read(messagesRepositoryProvider);

  @override
  Future<ConversationThread> build() async {
    final repository = ref.watch(messagesRepositoryProvider);
    final conversationRequest = repository.getConversation(conversationId);
    final pageRequest = repository.listMessages(conversationId);
    // Both in parallel; rethrows the first failure as-is.
    await Future.wait([conversationRequest, pageRequest]);
    final conversation = await conversationRequest;
    final page = await pageRequest;
    final messages = page.items;
    _nextCursor = page.nextCursor;

    final live = repository.watchConversation(conversationId).listen(_onLive);
    ref.onDispose(live.cancel);
    _markRead(messages);

    return _syncProposal(
      ConversationThread(
        conversation: conversation,
        messages: messages,
        hasMore: _nextCursor != null,
      ),
    );
  }

  /// Fetches older messages; a no-op on the oldest page or while loading.
  Future<void> loadMore() async {
    final cursor = _nextCursor;
    if (state.value == null || cursor == null || _loadingMore) return;
    _loadingMore = true;
    try {
      final page = await _repository.listMessages(
        conversationId,
        beforeCursor: cursor,
      );
      final thread = state.value;
      if (!ref.mounted || thread == null) return;
      _nextCursor = page.nextCursor;
      state = AsyncData(
        thread.copyWith(
          messages: _merge(thread.messages, page.items),
          hasMore: page.hasMore,
        ),
      );
    } finally {
      _loadingMore = false;
    }
  }

  /// Shows [text] at once as "Sending…", then as the server stored it.
  Future<void> send(String text) async {
    final body = text.trim();
    if (body.isEmpty || state.value == null) return;
    final clientId = _newClientId();
    await _deliver(
      Message(
        id: clientId,
        clientId: clientId,
        conversationId: conversationId,
        senderId: ref.read(currentUserProvider).value?.id ?? '',
        isMine: true,
        type: MessageType.text,
        text: body,
        sentAt: DateTime.now(),
        status: MessageStatus.sending,
      ),
    );
  }

  /// Sends a failed message again.
  Future<void> retry(Message failed) =>
      _deliver(failed.copyWith(status: MessageStatus.sending));

  Future<void> _deliver(Message pending) async {
    _put([pending]);
    try {
      final sent = await _repository.sendMessage(
        conversationId,
        pending.text ?? '',
        clientId: pending.clientId ?? pending.id,
      );
      _put([sent]);
    } catch (_) {
      _put([pending.copyWith(status: MessageStatus.failed)]);
      rethrow;
    }
  }

  /// Uploads a photo, video or document from the device.
  Future<void> sendAttachment(String filePath, AttachmentKind kind) async =>
      _put([await _repository.sendAttachment(conversationId, filePath, kind)]);

  Future<void> shareTalentPassport() async =>
      _put([await _repository.shareTalentPassport(conversationId)]);

  Future<void> setMuted({required bool muted}) async {
    final before = state.value;
    if (before == null) return;
    state = AsyncData(
      before.copyWith(
        conversation: before.conversation.copyWith(isMuted: muted),
      ),
    );
    try {
      await _repository.muteConversation(conversationId, muted: muted);
    } catch (_) {
      if (ref.mounted) state = AsyncData(before);
      rethrow;
    }
  }

  Future<void> report({String? reason}) =>
      _repository.reportConversation(conversationId, reason: reason);

  Future<void> acceptOffer(String offerId) => _changeOffer(
    offerId,
    (offer) => offer.copyWith(status: OfferStatus.accepted),
    () => _repository.acceptOffer(offerId),
  );

  Future<void> counterOffer(String offerId, Money amount, String note) =>
      _changeOffer(
        offerId,
        (offer) => offer.copyWith(
          status: OfferStatus.countered,
          lastCounter: CounterOffer(
            amount: amount,
            note: note,
            createdAt: DateTime.now(),
          ),
        ),
        () => _repository.counterOffer(offerId, amount, note),
      );

  Future<void> _changeOffer(
    String offerId,
    Offer Function(Offer offer) optimistic,
    Future<Offer> Function() request,
  ) async {
    final before = state.value;
    if (before == null) return;
    state = AsyncData(_withOffer(before, offerId, optimistic));
    try {
      final stored = await request();
      final thread = state.value;
      if (!ref.mounted || thread == null) return;
      state = AsyncData(_withOffer(thread, offerId, (_) => stored));
    } catch (_) {
      if (ref.mounted) state = AsyncData(before);
      rethrow;
    }
  }

  void _onLive(List<Message> latest) {
    final thread = state.value;
    if (!ref.mounted || thread == null) return;
    final messages = _merge(thread.messages, latest);
    state = AsyncData(_syncProposal(thread.copyWith(messages: messages)));
    _markRead(messages);
  }

  /// Merges [messages] into the thread: by id, and an optimistic copy (whose
  /// id is its client id) gives way to the server's copy with that client id.
  void _put(List<Message> messages) {
    final thread = state.value;
    if (!ref.mounted || thread == null) return;
    state = AsyncData(
      thread.copyWith(messages: _merge(thread.messages, messages)),
    );
  }

  /// Tells the server the newest incoming message has been seen.
  void _markRead(List<Message> messages) {
    final newest = messages.where((m) => !m.isMine).firstOrNull;
    if (newest == null || newest.id == _lastReadId) return;
    _lastReadId = newest.id;
    unawaited(
      _repository
          .markRead(conversationId, newest.id)
          .catchError((Object _) => _lastReadId = null),
    );
  }

  static List<Message> _merge(
    List<Message> current,
    Iterable<Message> incoming,
  ) {
    final byId = {for (final m in current) m.id: m};
    for (final m in incoming) {
      final clientId = m.clientId;
      if (clientId != null && clientId != m.id) byId.remove(clientId);
      byId[m.id] = m;
    }
    return byId.values.toList()..sort((a, b) => b.sentAt.compareTo(a.sentAt));
  }

  static ConversationThread _withOffer(
    ConversationThread thread,
    String offerId,
    Offer Function(Offer offer) change,
  ) => _syncProposal(
    thread.copyWith(
      messages: [
        for (final m in thread.messages)
          if (m.offer case final offer? when offer.id == offerId)
            m.copyWith(offer: change(offer))
          else
            m,
      ],
    ),
  );

  /// Keeps the pinned proposal's status in step with its offer card.
  static ConversationThread _syncProposal(ConversationThread thread) {
    final proposal = thread.conversation.proposal;
    if (proposal == null) return thread;
    final offer = thread.messages
        .map((m) => m.offer)
        .where((o) => o?.id == proposal.offerId)
        .firstOrNull;
    if (offer == null || offer.status == proposal.status) return thread;
    return thread.copyWith(
      conversation: thread.conversation.copyWith(
        proposal: proposal.copyWith(status: offer.status),
      ),
    );
  }

  static final _random = Random();

  static String _newClientId() =>
      'local-${DateTime.now().microsecondsSinceEpoch}-'
      '${_random.nextInt(1 << 32)}';
}

// New message

final suggestedRecipientsProvider =
    FutureProvider.autoDispose<List<Participant>>(
      (ref) => ref.watch(messagesRepositoryProvider).suggestedRecipients(),
    );

final recipientSearchProvider = FutureProvider.autoDispose
    .family<List<Participant>, String>(
      (ref, query) =>
          ref.watch(messagesRepositoryProvider).searchRecipients(query),
    );

/// Opens a one-to-one thread. The state is the id of the recipient being
/// opened, so their row can show progress; null when idle.
final directConversationProvider =
    NotifierProvider.autoDispose<DirectConversationNotifier, String?>(
      DirectConversationNotifier.new,
    );

class DirectConversationNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  Future<DirectConversationResult> open(String userId) async {
    state = userId;
    try {
      return await ref
          .read(messagesRepositoryProvider)
          .getOrCreateDirectConversation(userId);
    } finally {
      if (ref.mounted) state = null;
    }
  }
}

// Attachments

final attachmentPreviewProvider = FutureProvider.autoDispose
    .family<AttachmentPreview, String>(
      (ref, id) => ref.watch(messagesRepositoryProvider).getAttachment(id),
    );
