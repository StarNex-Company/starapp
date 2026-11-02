import 'package:starapp/core/models/attachment.dart';
import 'package:starapp/core/models/money.dart';
import 'package:starapp/core/network/api_client.dart';
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

class ApiMessagesRepository implements MessagesRepository {
  ApiMessagesRepository(this._client, {this.pollInterval = _defaultPoll});

  static const _defaultPoll = Duration(seconds: 5);

  final ApiClient _client;

  /// How often [watchInbox] and [watchConversation] re-fetch.
  final Duration pollInterval;

  @override
  Future<InboxSummary> getInboxSummary() => _client.get(
    '/inbox/summary',
    decode: (json) => InboxSummary.fromJson(json as Json),
  );

  @override
  Future<Paged<ConversationSummary>> listConversations({
    String? query,
    String? cursor,
  }) => _client.get(
    '/conversations',
    query: {'query': query, 'cursor': cursor},
    decode: (json) =>
        Paged.fromJson(json as Json, ConversationSummary.fromJson),
  );

  @override
  Future<Conversation> getConversation(String id) => _client.get(
    '/conversations/$id',
    decode: (json) => Conversation.fromJson(json as Json),
  );

  @override
  Future<Paged<Message>> listMessages(
    String conversationId, {
    String? beforeCursor,
  }) => _client.get(
    '/conversations/$conversationId/messages',
    query: {'before': beforeCursor},
    decode: (json) => Paged.fromJson(json as Json, Message.fromJson),
  );

  /// Polls `GET /inbox/summary` every [pollInterval] so the inbox stays live
  /// over plain REST. This (with [watchConversation]) is the one place to
  /// swap in a WebSocket or FCM data messages when the backend has them.
  @override
  Stream<InboxSummary> watchInbox() => _poll(getInboxSummary);

  /// Polls the thread's first page every [pollInterval]; see [watchInbox].
  @override
  Stream<List<Message>> watchConversation(String conversationId) =>
      _poll(() async => (await listMessages(conversationId)).items);

  /// Fetches now, then every [pollInterval] while listened to. A failed poll
  /// is skipped; the next one tries again.
  Stream<T> _poll<T>(Future<T> Function() fetch) async* {
    Future<T?> attempt() async {
      try {
        return await fetch();
      } catch (_) {
        return null;
      }
    }

    final first = await attempt();
    if (first != null) yield first;
    await for (final _ in Stream<void>.periodic(pollInterval)) {
      final next = await attempt();
      if (next != null) yield next;
    }
  }

  @override
  Future<Message> sendMessage(
    String conversationId,
    String text, {
    required String clientId,
  }) => _client.post(
    '/conversations/$conversationId/messages',
    data: {'type': MessageType.text.name, 'text': text, 'clientId': clientId},
    decode: (json) => Message.fromJson(json as Json),
  );

  @override
  Future<Message> sendAttachment(
    String conversationId,
    String filePath,
    AttachmentKind kind,
  ) => _client.upload(
    '/conversations/$conversationId/attachments',
    filePath: filePath,
    fields: {'kind': kind.name},
    decode: (json) => Message.fromJson(json as Json),
  );

  @override
  Future<Message> shareTalentPassport(String conversationId) => _client.post(
    '/conversations/$conversationId/talent-passport',
    decode: (json) => Message.fromJson(json as Json),
  );

  @override
  Future<void> markRead(String conversationId, String upToMessageId) =>
      _client.post<void>(
        '/conversations/$conversationId/read',
        data: {'upToMessageId': upToMessageId},
      );

  @override
  Future<void> muteConversation(String conversationId, {required bool muted}) =>
      _client.put<void>(
        '/conversations/$conversationId/mute',
        data: {'muted': muted},
      );

  @override
  Future<void> reportConversation(String conversationId, {String? reason}) =>
      _client.post<void>(
        '/conversations/$conversationId/report',
        data: {'reason': ?reason},
      );

  @override
  Future<Offer> acceptOffer(String offerId) => _client.post(
    '/offers/$offerId/accept',
    decode: (json) => Offer.fromJson(json as Json),
  );

  @override
  Future<Offer> counterOffer(String offerId, Money amount, String note) =>
      _client.post(
        '/offers/$offerId/counter',
        data: {'amount': amount.toJson(), 'note': note},
        decode: (json) => Offer.fromJson(json as Json),
      );

  @override
  Future<List<Participant>> suggestedRecipients() => _client.get(
    '/recipients/suggested',
    decode: (json) => readList(json, Participant.fromJson),
  );

  @override
  Future<List<Participant>> searchRecipients(String query) => _client.get(
    '/recipients',
    query: {'query': query},
    decode: (json) => readList(json, Participant.fromJson),
  );

  @override
  Future<DirectConversationResult> getOrCreateDirectConversation(
    String userId,
  ) => _client.post(
    '/conversations/direct',
    data: {'userId': userId},
    decode: (json) => DirectConversationResult.fromJson(json as Json),
  );

  @override
  Future<AttachmentPreview> getAttachment(String id) => _client.get(
    '/attachments/$id',
    decode: (json) => AttachmentPreview.fromJson(json as Json),
  );
}
