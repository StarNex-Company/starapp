import 'package:starapp/core/models/creator_summary.dart';
import 'package:starapp/core/utils/json.dart';

enum NotificationKind {
  /// Someone starred your post; opens the video feed.
  star,
  comment,

  /// Someone followed you; opens their profile.
  follow,

  /// Tier / Stars progress.
  tier,
}

/// One activity item (`GET /notifications`).
class AppNotification {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.message,
    required this.createdAt,
    this.actor,
    this.imageUrl,
    this.postId,
    this.isRead = false,
  });

  factory AppNotification.fromJson(Json json) => AppNotification(
    id: json['id'] as String,
    kind: readEnum(
      NotificationKind.values,
      json['kind'],
      NotificationKind.tier,
    ),
    message: json['message'] as String,
    createdAt: readDate(json['createdAt']) ?? DateTime.now(),
    actor: json['actor'] == null
        ? null
        : CreatorSummary.fromJson(json['actor'] as Json),
    imageUrl: json['imageUrl'] as String?,
    postId: json['postId'] as String?,
    isRead: json['isRead'] as bool? ?? false,
  );

  final String id;
  final NotificationKind kind;

  /// Server-rendered sentence, e.g. "Chidi and 23 others starred your video".
  final String message;
  final DateTime createdAt;

  /// Who did it; null for system items such as tier progress.
  final CreatorSummary? actor;

  /// Picture beside the message; falls back to [actor]'s photo.
  final String? imageUrl;

  /// The post a star or comment is about.
  final String? postId;
  final bool isRead;

  String? get image => imageUrl ?? actor?.avatarUrl;

  Json toJson() => {
    'id': id,
    'kind': kind.name,
    'message': message,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'actor': actor?.toJson(),
    'imageUrl': imageUrl,
    'postId': postId,
    'isRead': isRead,
  };

  AppNotification copyWith({bool? isRead}) => AppNotification(
    id: id,
    kind: kind,
    message: message,
    createdAt: createdAt,
    actor: actor,
    imageUrl: imageUrl,
    postId: postId,
    isRead: isRead ?? this.isRead,
  );
}
