import 'package:starapp/core/models/attachment.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/messages/data/models/offer.dart';

enum MessageType { text, attachment, offer, system }

/// Delivery state of the user's own messages. [sending] and [failed] exist
/// only on the device, before the server has the message.
enum MessageStatus { sending, sent, delivered, seen, failed }

/// One item in a thread (`GET /conversations/{id}/messages`).
class Message {
  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.isMine,
    required this.type,
    required this.sentAt,
    required this.status,
    this.clientId,
    this.text,
    this.attachment,
    this.offer,
  });

  factory Message.fromJson(Json json) => Message(
    id: json['id'] as String,
    clientId: json['clientId'] as String?,
    conversationId: json['conversationId'] as String,
    senderId: json['senderId'] as String? ?? '',
    isMine: json['isMine'] as bool? ?? false,
    type: readEnum(MessageType.values, json['type'], MessageType.text),
    text: json['text'] as String?,
    attachment: json['attachment'] == null
        ? null
        : Attachment.fromJson(json['attachment'] as Json),
    offer: json['offer'] == null ? null : Offer.fromJson(json['offer'] as Json),
    sentAt: readDate(json['sentAt']) ?? DateTime.now(),
    status: readEnum(MessageStatus.values, json['status'], MessageStatus.sent),
  );

  /// Server id; equals [clientId] until the server has the message.
  final String id;

  /// Set by the sender's device so its optimistic copy can be matched with
  /// the server's echo.
  final String? clientId;
  final String conversationId;
  final String senderId;
  final bool isMine;
  final MessageType type;

  /// Body of [MessageType.text] and [MessageType.system] messages.
  final String? text;
  final Attachment? attachment;
  final Offer? offer;
  final DateTime sentAt;
  final MessageStatus status;

  bool get isPending => status == MessageStatus.sending;
  bool get isFailed => status == MessageStatus.failed;

  Json toJson() => {
    'id': id,
    'clientId': clientId,
    'conversationId': conversationId,
    'senderId': senderId,
    'isMine': isMine,
    'type': type.name,
    'text': text,
    'attachment': attachment?.toJson(),
    'offer': offer?.toJson(),
    'sentAt': sentAt.toUtc().toIso8601String(),
    'status': status.name,
  };

  Message copyWith({MessageStatus? status, Offer? offer}) => Message(
    id: id,
    clientId: clientId,
    conversationId: conversationId,
    senderId: senderId,
    isMine: isMine,
    type: type,
    text: text,
    attachment: attachment,
    offer: offer ?? this.offer,
    sentAt: sentAt,
    status: status ?? this.status,
  );
}
