import 'dart:async';

import 'package:intl/intl.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/models/attachment.dart';
import 'package:starapp/core/models/money.dart';
import 'package:starapp/core/network/paged.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/messages/data/models/attachment_preview.dart';
import 'package:starapp/features/messages/data/models/conversation.dart';
import 'package:starapp/features/messages/data/models/direct_conversation.dart';
import 'package:starapp/features/messages/data/models/inbox.dart';
import 'package:starapp/features/messages/data/models/message.dart';
import 'package:starapp/features/messages/data/models/offer.dart';
import 'package:starapp/features/messages/data/models/participant.dart';
import 'package:starapp/features/messages/data/repositories/messages_repository.dart';

/// An in-memory inbox seeded from JSON fixtures shaped like the API's
/// responses and parsed through the real `fromJson`. Sends, reads, mutes and
/// offer replies change that state and are pushed to [watchInbox] and
/// [watchConversation], as the live API would.
class MockMessagesRepository implements MessagesRepository {
  MockMessagesRepository() {
    final now = DateTime.now();
    final fixtures = _fixtures(now);
    for (final json in fixtures.conversations) {
      final c = Conversation.fromJson(json);
      _conversations[c.id] = c;
    }
    for (final json in fixtures.summaries) {
      final s = ConversationSummary.fromJson(json);
      _summaries[s.id] = s;
    }
    for (final MapEntry(:key, :value) in fixtures.messages.entries) {
      _messages[key] = readList(value, Message.fromJson);
    }
    for (final json in fixtures.attachments) {
      final a = AttachmentPreview.fromJson(json);
      _attachments[a.attachment.id] = a;
    }
    _directory = readList(fixtures.directory, Participant.fromJson);
    _requests = InboxSummary.fromJson(fixtures.requests);
  }

  static const me = 'me';

  final _conversations = <String, Conversation>{};
  final _summaries = <String, ConversationSummary>{};

  /// Newest first, like the API.
  final _messages = <String, List<Message>>{};
  final _attachments = <String, AttachmentPreview>{};
  late final List<Participant> _directory;
  late final InboxSummary _requests;

  final _inboxChanges = StreamController<InboxSummary>.broadcast();
  final _threadChanges = <String, StreamController<List<Message>>>{};
  var _nextId = 0;

  InboxSummary get _summary => InboxSummary(
    totalUnread: _summaries.values.fold(0, (sum, s) => sum + s.unreadCount),
    pendingScoutRequests: _requests.pendingScoutRequests,
    requestPreview: _requests.requestPreview,
    firstRequestId: _requests.firstRequestId,
  );

  StreamController<List<Message>> _thread(String id) =>
      _threadChanges.putIfAbsent(id, StreamController.broadcast);

  void _emit(String conversationId) {
    _thread(conversationId).add(List.of(_messages[conversationId] ?? []));
    _inboxChanges.add(_summary);
  }

  /// Puts [message] at the top of its thread and the thread at the top of
  /// the inbox.
  void _append(Message message, String preview) {
    final id = message.conversationId;
    _messages[id] = [message, ...?_messages[id]];
    final row = _summaries[id];
    if (row != null) {
      _summaries[id] = ConversationSummary.fromJson({
        ...row.toJson(),
        'lastMessagePreview': preview,
        'lastMessageAt': message.sentAt.toUtc().toIso8601String(),
      });
    }
    _emit(id);
  }

  T _find<T>(T? value) => value ?? (throw StateError('Not in the mock inbox'));

  // Inbox

  @override
  Future<InboxSummary> getInboxSummary() async => _summary;

  @override
  Future<Paged<ConversationSummary>> listConversations({
    String? query,
    String? cursor,
  }) async {
    final q = query?.trim().toLowerCase() ?? '';
    final rows = _summaries.values.where(
      (s) =>
          q.isEmpty ||
          s.counterpart.displayName.toLowerCase().contains(q) ||
          s.lastMessagePreview.toLowerCase().contains(q),
    );
    return Paged(
      items: rows.toList()
        ..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt)),
    );
  }

  // Thread

  /// An id the inbox doesn't have yet (a Scout request just accepted:
  /// `c-<companyId>`) opens as a new, empty thread with that company.
  @override
  Future<Conversation> getConversation(String id) async =>
      _conversations[id] ??= _newThread(id);

  Conversation _newThread(String id) {
    final companyId = id.startsWith('c-') ? id.substring(2) : id;
    final company = _find(
      _summary.requestPreview.where((c) => c.id == companyId).firstOrNull,
    );
    return Conversation.fromJson({
      'id': id,
      'kind': 'scout',
      'counterpart': {
        'id': company.id,
        'displayName': company.name,
        'kind': 'company',
        'avatarUrl': company.logoUrl,
        'isVerified': company.isVerified,
      },
      'canSend': true,
    });
  }

  @override
  Future<Paged<Message>> listMessages(
    String conversationId, {
    String? beforeCursor,
  }) async => Paged(items: List.of(_messages[conversationId] ?? const []));

  @override
  Stream<InboxSummary> watchInbox() async* {
    yield _summary;
    yield* _inboxChanges.stream;
  }

  @override
  Stream<List<Message>> watchConversation(String conversationId) =>
      _thread(conversationId).stream;

  // Sending

  Message _mine(
    String conversationId, {
    required MessageType type,
    String? clientId,
    String? text,
    Attachment? attachment,
  }) {
    final id = 'm-local-${_nextId++}';
    return Message(
      id: id,
      clientId: clientId,
      conversationId: conversationId,
      senderId: me,
      isMine: true,
      type: type,
      text: text,
      attachment: attachment,
      sentAt: DateTime.now(),
      status: MessageStatus.sent,
    );
  }

  @override
  Future<Message> sendMessage(
    String conversationId,
    String text, {
    required String clientId,
  }) async {
    final message = _mine(
      conversationId,
      type: MessageType.text,
      clientId: clientId,
      text: text,
    );
    _append(message, text);
    return message;
  }

  @override
  Future<Message> sendAttachment(
    String conversationId,
    String filePath,
    AttachmentKind kind,
  ) async {
    final name = filePath.split(RegExp(r'[\\/]')).last;
    final message = _mine(
      conversationId,
      type: MessageType.attachment,
      attachment: Attachment(
        id: 'att-local-${_nextId++}',
        kind: kind,
        fileName: name,
        url: filePath,
      ),
    );
    _append(message, name);
    return message;
  }

  @override
  Future<Message> shareTalentPassport(String conversationId) async {
    final message = _mine(
      conversationId,
      type: MessageType.attachment,
      attachment: Attachment(
        id: 'att-local-${_nextId++}',
        kind: AttachmentKind.talentPassport,
        fileName: 'Talent Passport',
        url: 'https://starapp.io/passport/me',
      ),
    );
    _append(message, 'Shared their Talent Passport');
    return message;
  }

  // Thread actions

  @override
  Future<void> markRead(String conversationId, String upToMessageId) async {
    final row = _summaries[conversationId];
    if (row == null || row.unreadCount == 0) return;
    _summaries[conversationId] = row.copyWith(unreadCount: 0);
    _inboxChanges.add(_summary);
  }

  @override
  Future<void> muteConversation(
    String conversationId, {
    required bool muted,
  }) async {
    final c = _find(_conversations[conversationId]);
    _conversations[conversationId] = c.copyWith(isMuted: muted);
    final row = _summaries[conversationId];
    if (row != null) {
      _summaries[conversationId] = ConversationSummary.fromJson({
        ...row.toJson(),
        'isMuted': muted,
      });
    }
    _inboxChanges.add(_summary);
  }

  @override
  Future<void> reportConversation(
    String conversationId, {
    String? reason,
  }) async {}

  // Offers

  Future<Offer> _updateOffer(
    String offerId,
    Offer Function(Offer offer) change,
  ) async {
    for (final MapEntry(key: threadId, value: thread) in _messages.entries) {
      final index = thread.indexWhere((m) => m.offer?.id == offerId);
      if (index < 0) continue;
      final offer = change(thread[index].offer!);
      thread[index] = thread[index].copyWith(offer: offer);
      final c = _conversations[threadId];
      if (c?.proposal?.offerId == offerId) {
        _conversations[threadId] = c!.copyWith(
          proposal: c.proposal!.copyWith(status: offer.status),
        );
      }
      _emit(threadId);
      return offer;
    }
    throw StateError('Offer $offerId is not in the mock inbox');
  }

  @override
  Future<Offer> acceptOffer(String offerId) =>
      _updateOffer(offerId, (o) => o.copyWith(status: OfferStatus.accepted));

  @override
  Future<Offer> counterOffer(String offerId, Money amount, String note) =>
      _updateOffer(
        offerId,
        (o) => o.copyWith(
          status: OfferStatus.countered,
          lastCounter: CounterOffer(
            amount: amount,
            note: note,
            createdAt: DateTime.now(),
          ),
        ),
      );

  // New message

  @override
  Future<List<Participant>> suggestedRecipients() async =>
      _directory.take(3).toList();

  @override
  Future<List<Participant>> searchRecipients(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return [
      for (final p in _directory)
        if (p.displayName.toLowerCase().contains(q) ||
            (p.handle?.toLowerCase().contains(q) ?? false))
          p,
    ];
  }

  /// Opens the existing thread with anyone in the mock directory (creating
  /// one if needed). Anyone else, e.g. a creator opened from a profile, gets
  /// a message request.
  @override
  Future<DirectConversationResult> getOrCreateDirectConversation(
    String userId,
  ) async {
    for (final c in _conversations.values) {
      if (c.counterpart.id == userId) {
        return DirectConversationResult.opened(c.id);
      }
    }
    final person = _directory.where((p) => p.id == userId).firstOrNull;
    if (person == null) {
      return const DirectConversationResult.messageRequestSent();
    }
    final id = 'c-${person.id}';
    _conversations[id] = Conversation(
      id: id,
      kind: person.kind == ParticipantKind.company
          ? ConversationKind.scout
          : ConversationKind.direct,
      counterpart: person,
    );
    _summaries[id] = ConversationSummary(
      id: id,
      kind: _conversations[id]!.kind,
      counterpart: person,
      lastMessagePreview: '',
      lastMessageAt: DateTime.now(),
    );
    _messages[id] = [];
    _inboxChanges.add(_summary);
    return DirectConversationResult.opened(id);
  }

  // Attachments

  @override
  Future<AttachmentPreview> getAttachment(String id) async {
    final known = _attachments[id];
    if (known != null) return known;
    for (final thread in _messages.values) {
      for (final m in thread) {
        if (m.attachment?.id == id) {
          return AttachmentPreview(attachment: m.attachment!);
        }
      }
    }
    throw StateError('Attachment $id is not in the mock inbox');
  }
}

typedef _Fixtures = ({
  List<Json> summaries,
  List<Json> conversations,
  Map<String, List<Json>> messages,
  List<Json> attachments,
  List<Json> directory,
  Json requests,
});

const _avatarEmmanuel = 'assets/images/messages/avatar_emmanuel.png';
const _avatarAyeni = 'assets/images/messages/avatar_ayeni.png';
const _avatarAmina = 'assets/images/search/creator_amina_k.png';
const _avatarTunde = 'assets/images/challenges/detail_avatar_tunde.png';

/// The minimum that shows every designed state: the Afrowave Records Scout
/// thread with a pending offer and a PDF brief, a peer thread, a muted
/// thread, the system thread, and two pending Scout requests.
_Fixtures _fixtures(DateTime now) {
  String ago(Duration d) => now.subtract(d).toUtc().toIso8601String();

  final afrowave = {
    'id': 'afrowave-records',
    'displayName': 'Afrowave Records',
    'kind': 'company',
    'isVerified': true,
    'roleLabel': 'Record label',
  };
  final emmanuel = {
    'id': 'emmanuel-f',
    'displayName': 'Emmanuel F.',
    'handle': 'emmanuel_f',
    'avatarUrl': _avatarEmmanuel,
    'kind': 'creator',
    'roleLabel': 'Dancer',
  };
  final ayeni = {
    'id': 'ayeni',
    'displayName': 'Ayeni Micheal',
    'handle': 'ayeni_micheal',
    'avatarUrl': _avatarAyeni,
    'kind': 'creator',
    'roleLabel': 'Singer',
  };
  final team = {
    'id': 'star-app-team',
    'displayName': 'Star App Team',
    'kind': 'system',
    'isVerified': true,
  };
  final senders = {
    'c-afrowave': afrowave['id'],
    'c-emmanuel': emmanuel['id'],
    'c-ayeni': ayeni['id'],
    'c-star-app': team['id'],
  };
  const naira850k = {'amountMinor': 85000000, 'currency': 'NGN'};

  final start = DateTime(now.year, now.month, now.day + 13);
  final end = DateTime(now.year, now.month, now.day + 15);
  final shootDates =
      '${DateFormat('MMM d').format(start)} – ${DateFormat('d, y').format(end)}';

  final brief = {
    'id': 'att-gbedu-brief',
    'kind': 'document',
    'fileName': 'Gbedu_brief.pdf',
    'url': 'https://files.example.com/attachments/gbedu_brief.pdf',
    'mimeType': 'application/pdf',
    'sizeBytes': 1258291,
    'pageCount': 4,
  };

  Json message(
    String id,
    String conversationId,
    Duration age, {
    required String type,
    bool mine = false,
    String status = 'seen',
    String? text,
    Json? offer,
  }) => {
    'id': id,
    'conversationId': conversationId,
    'senderId': mine ? MockMessagesRepository.me : senders[conversationId],
    'isMine': mine,
    'type': type,
    'text': text,
    'offer': offer,
    'sentAt': ago(age),
    'status': mine ? status : 'seen',
  };

  return (
    summaries: [
      {
        'id': 'c-afrowave',
        'kind': 'scout',
        'counterpart': afrowave,
        'lastMessagePreview': 'Proposal: ₦850,000 · 3 shoot days',
        'lastMessageAt': ago(const Duration(minutes: 2)),
        'unreadCount': 2,
      },
      {
        'id': 'c-emmanuel',
        'kind': 'direct',
        'counterpart': emmanuel,
        'lastMessagePreview': 'That routine was unreal. Collab soon?',
        'lastMessageAt': ago(const Duration(hours: 3)),
      },
      {
        'id': 'c-ayeni',
        'kind': 'direct',
        'counterpart': ayeni,
        'lastMessagePreview': 'Are you entering the Vocal Clash too?',
        'lastMessageAt': ago(const Duration(days: 4)),
        'isMuted': true,
      },
      {
        'id': 'c-star-app',
        'kind': 'system',
        'counterpart': team,
        'lastMessagePreview': 'Your post "Studio session freestyle" was paused',
        'lastMessageAt': ago(const Duration(days: 9)),
        'deepLink': AppRoutes.moderationPaused,
      },
    ],
    conversations: [
      {
        'id': 'c-afrowave',
        'kind': 'scout',
        'counterpart': afrowave,
        'isOnline': true,
        'proposal': {
          'offerId': 'offer-gbedu',
          'title': 'Featured Dancer',
          'amount': naira850k,
          'status': 'pending',
        },
        'scoutRequestId': 'sr-gbedu',
      },
      {
        'id': 'c-emmanuel',
        'kind': 'direct',
        'counterpart': emmanuel,
        'lastActiveAt': ago(const Duration(hours: 2)),
      },
      {
        'id': 'c-ayeni',
        'kind': 'direct',
        'counterpart': ayeni,
        'lastActiveAt': ago(const Duration(days: 1)),
        'isMuted': true,
      },
      {
        'id': 'c-star-app',
        'kind': 'system',
        'counterpart': team,
        'canSend': false,
      },
    ],
    messages: {
      'c-afrowave': [
        message(
          'm-a5',
          'c-afrowave',
          const Duration(minutes: 2),
          type: 'text',
          mine: true,
          status: 'delivered',
          text: 'Thank you! Reviewing the brief now 👀',
        ),
        message(
          'm-a4',
          'c-afrowave',
          const Duration(minutes: 6),
          type: 'offer',
          offer: {
            'id': 'offer-gbedu',
            'role': 'Featured dancer',
            'amount': naira850k,
            'startDate': start.toUtc().toIso8601String(),
            'endDate': end.toUtc().toIso8601String(),
            'usage': 'Music video + socials',
            'expiresAt': now
                .add(const Duration(days: 3, hours: 1))
                .toUtc()
                .toIso8601String(),
            'status': 'pending',
            'attachments': [brief],
          },
        ),
        message(
          'm-a3',
          'c-afrowave',
          const Duration(minutes: 7),
          type: 'text',
          text:
              '${DateFormat('MMM d').format(start)}–${end.day} in Lekki. '
              "Here's the brief and our offer:",
        ),
        message(
          'm-a2',
          'c-afrowave',
          const Duration(minutes: 9),
          type: 'text',
          mine: true,
          text:
              "Thank you so much! I'd love to hear more. What are the shoot "
              'dates?',
        ),
        message(
          'm-a1',
          'c-afrowave',
          const Duration(minutes: 12),
          type: 'text',
          text:
              "Hi Emmanuel! We loved your Afro-Beats Clash entry. We'd like "
              'you as the featured dancer in our next video.',
        ),
      ],
      'c-emmanuel': [
        message(
          'm-e2',
          'c-emmanuel',
          const Duration(hours: 3),
          type: 'text',
          text: 'That routine was unreal. Collab soon?',
        ),
        message(
          'm-e1',
          'c-emmanuel',
          const Duration(days: 1, hours: 2),
          type: 'text',
          mine: true,
          text: 'Saw your Afro-Beats entry 🔥',
        ),
      ],
      'c-ayeni': [
        message(
          'm-y1',
          'c-ayeni',
          const Duration(days: 4),
          type: 'text',
          text: 'Are you entering the Vocal Clash too?',
        ),
      ],
      'c-star-app': [
        message(
          'm-s1',
          'c-star-app',
          const Duration(days: 9),
          type: 'system',
          text: 'Your post "Studio session freestyle" was paused',
        ),
      ],
    },
    attachments: [
      {
        ...brief,
        'ownerName': 'Afrowave Records',
        'title': '"Gbedu" Music Video Brief',
        'sections': [
          {
            'heading': 'Concept',
            'body':
                'A night-market party in Lekki. The featured dancer leads '
                'the final chorus with a solo routine.',
          },
          {
            'heading': 'Shoot dates',
            'body': '$shootDates · 8 hours per day · Lekki Phase 1',
          },
          {
            'heading': 'Fee',
            'body':
                '₦850,000 plus transport and meals. Paid through Star App '
                'within 7 days of the shoot.',
          },
          {
            'heading': 'Usage',
            'body':
                'Music video, social clips and the official visualiser for '
                '24 months.',
          },
        ],
      },
    ],
    directory: [
      {
        'id': 'tunde-beats',
        'displayName': 'Tunde Beats',
        'handle': 'tunde_beats',
        'avatarUrl': _avatarTunde,
        'kind': 'creator',
        'roleLabel': 'Producer',
      },
      {
        'id': 'amina',
        'displayName': 'Amina K.',
        'handle': 'amina_k',
        'avatarUrl': _avatarAmina,
        'kind': 'creator',
        'roleLabel': 'Dancer',
      },
      afrowave,
      emmanuel,
      ayeni,
    ],
    requests: {
      'totalUnread': 0,
      'pendingScoutRequests': 2,
      'requestPreview': [
        {
          'id': 'afrowave-records',
          'name': 'Afrowave Records',
          'type': 'Record label',
          'city': 'Lagos',
          'country': 'Nigeria',
          'isVerified': true,
        },
        {
          'id': 'kora-studios',
          'name': 'Kora Studios',
          'type': 'Film studio',
          'city': 'Accra',
          'country': 'Ghana',
          'isVerified': true,
        },
      ],
      'firstRequestId': 'sr-gbedu',
    },
  );
}
