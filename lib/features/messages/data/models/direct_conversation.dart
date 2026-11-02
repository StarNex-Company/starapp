import 'package:starapp/core/utils/json.dart';

/// [opened]: the user can message them; [messageRequestSent]: their privacy
/// settings turned the first message into a request they must accept.
enum DirectConversationStatus { opened, messageRequestSent }

/// What `POST /conversations/direct` did for a recipient.
class DirectConversationResult {
  const DirectConversationResult.opened(String this.conversationId)
    : status = DirectConversationStatus.opened;

  const DirectConversationResult.messageRequestSent()
    : status = DirectConversationStatus.messageRequestSent,
      conversationId = null;

  factory DirectConversationResult.fromJson(Json json) {
    final id = json['conversationId'] as String?;
    final status = readEnum(
      DirectConversationStatus.values,
      json['status'],
      id == null
          ? DirectConversationStatus.messageRequestSent
          : DirectConversationStatus.opened,
    );
    return status == DirectConversationStatus.opened && id != null
        ? DirectConversationResult.opened(id)
        : const DirectConversationResult.messageRequestSent();
  }

  final DirectConversationStatus status;

  /// Set when [status] is [DirectConversationStatus.opened].
  final String? conversationId;

  Json toJson() => {'status': status.name, 'conversationId': conversationId};
}
