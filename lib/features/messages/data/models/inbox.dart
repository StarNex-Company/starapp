import 'package:starapp/core/models/company_summary.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/messages/data/models/conversation.dart';
import 'package:starapp/features/messages/data/models/participant.dart';

/// Counts for the Messages tab (`GET /inbox/summary`): the tab's unread dot,
/// the Requests segment and the Scout Requests banner.
class InboxSummary {
  const InboxSummary({
    required this.totalUnread,
    required this.pendingScoutRequests,
    this.requestPreview = const [],
    this.firstRequestId,
  });

  factory InboxSummary.fromJson(Json json) => InboxSummary(
    totalUnread: readInt(json['totalUnread']),
    pendingScoutRequests: readInt(json['pendingScoutRequests']),
    requestPreview: readList(json['requestPreview'], CompanySummary.fromJson),
    firstRequestId: json['firstRequestId'] as String?,
  );

  /// Unread messages across all conversations.
  final int totalUnread;
  final int pendingScoutRequests;

  /// The companies behind the newest pending requests, for the banner.
  final List<CompanySummary> requestPreview;

  /// The newest pending request; the banner opens it when it's the only one.
  final String? firstRequestId;

  Json toJson() => {
    'totalUnread': totalUnread,
    'pendingScoutRequests': pendingScoutRequests,
    'requestPreview': [for (final c in requestPreview) c.toJson()],
    'firstRequestId': firstRequestId,
  };
}

/// One inbox row (`GET /conversations`).
class ConversationSummary {
  const ConversationSummary({
    required this.id,
    required this.kind,
    required this.counterpart,
    required this.lastMessagePreview,
    required this.lastMessageAt,
    this.unreadCount = 0,
    this.isMuted = false,
    this.deepLink,
  });

  factory ConversationSummary.fromJson(Json json) => ConversationSummary(
    id: json['id'] as String,
    kind: readEnum(
      ConversationKind.values,
      json['kind'],
      ConversationKind.direct,
    ),
    counterpart: Participant.fromJson(json['counterpart'] as Json),
    lastMessagePreview: json['lastMessagePreview'] as String? ?? '',
    lastMessageAt: readDate(json['lastMessageAt']) ?? DateTime.now(),
    unreadCount: readInt(json['unreadCount']),
    isMuted: json['isMuted'] as bool? ?? false,
    deepLink: json['deepLink'] as String?,
  );

  final String id;
  final ConversationKind kind;
  final Participant counterpart;

  /// Server-rendered, e.g. "Proposal: ₦850,000 · 3 shoot days".
  final String lastMessagePreview;
  final DateTime lastMessageAt;
  final int unreadCount;
  final bool isMuted;

  /// An app route the row opens instead of the thread, e.g. the paused-post
  /// notice for a moderation message.
  final String? deepLink;

  Json toJson() => {
    'id': id,
    'kind': kind.name,
    'counterpart': counterpart.toJson(),
    'lastMessagePreview': lastMessagePreview,
    'lastMessageAt': lastMessageAt.toUtc().toIso8601String(),
    'unreadCount': unreadCount,
    'isMuted': isMuted,
    'deepLink': deepLink,
  };

  ConversationSummary copyWith({int? unreadCount}) => ConversationSummary(
    id: id,
    kind: kind,
    counterpart: counterpart,
    lastMessagePreview: lastMessagePreview,
    lastMessageAt: lastMessageAt,
    unreadCount: unreadCount ?? this.unreadCount,
    isMuted: isMuted,
    deepLink: deepLink,
  );
}
