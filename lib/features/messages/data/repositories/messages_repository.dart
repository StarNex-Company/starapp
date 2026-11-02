import 'package:starapp/core/models/attachment.dart';
import 'package:starapp/core/models/money.dart';
import 'package:starapp/core/network/paged.dart';
import 'package:starapp/features/messages/data/models/attachment_preview.dart';
import 'package:starapp/features/messages/data/models/conversation.dart';
import 'package:starapp/features/messages/data/models/direct_conversation.dart';
import 'package:starapp/features/messages/data/models/inbox.dart';
import 'package:starapp/features/messages/data/models/message.dart';
import 'package:starapp/features/messages/data/models/offer.dart';
import 'package:starapp/features/messages/data/models/participant.dart';

/// Inbox, threads, offers and recipients. Screens read the providers in
/// `messages_providers.dart`; `messagesRepositoryProvider` picks the mock or
/// API implementation.
abstract interface class MessagesRepository {
  // Inbox

  Future<InboxSummary> getInboxSummary();

  /// Most recent activity first; [query] filters by name or message text.
  Future<Paged<ConversationSummary>> listConversations({
    String? query,
    String? cursor,
  });

  // Thread

  Future<Conversation> getConversation(String id);

  /// Newest first: the first page holds the latest messages, and passing a
  /// page's `nextCursor` as [beforeCursor] fetches older ones.
  Future<Paged<Message>> listMessages(
    String conversationId, {
    String? beforeCursor,
  });

  // Live updates

  /// The summary now and after every change.
  Stream<InboxSummary> watchInbox();

  /// The thread's latest messages (newest first) whenever they change.
  Stream<List<Message>> watchConversation(String conversationId);

  // Sending

  /// Sends a text. [clientId] comes back on the stored message so the
  /// optimistic copy can be matched with it.
  Future<Message> sendMessage(
    String conversationId,
    String text, {
    required String clientId,
  });

  /// Uploads the file at [filePath] and posts it as a message.
  Future<Message> sendAttachment(
    String conversationId,
    String filePath,
    AttachmentKind kind,
  );

  /// Posts a link to the user's Talent Passport.
  Future<Message> shareTalentPassport(String conversationId);

  // Thread actions

  /// Marks everything up to and including [upToMessageId] as read.
  Future<void> markRead(String conversationId, String upToMessageId);

  Future<void> muteConversation(String conversationId, {required bool muted});

  Future<void> reportConversation(String conversationId, {String? reason});

  // Offers

  /// Returns the offer as stored, now accepted.
  Future<Offer> acceptOffer(String offerId);

  /// Returns the offer as stored, now countered.
  Future<Offer> counterOffer(String offerId, Money amount, String note);

  // New message

  Future<List<Participant>> suggestedRecipients();

  Future<List<Participant>> searchRecipients(String query);

  /// Opens (or creates) the one-to-one thread with [userId], or sends them a
  /// message request when their settings require one.
  Future<DirectConversationResult> getOrCreateDirectConversation(String userId);

  // Attachments

  Future<AttachmentPreview> getAttachment(String id);
}
