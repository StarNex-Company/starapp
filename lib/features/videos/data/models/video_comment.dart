import 'package:starapp/core/models/creator_summary.dart';
import 'package:starapp/core/utils/json.dart';

/// A comment on a video, or a reply nested under one
/// (`GET /videos/{id}/comments`).
class VideoComment {
  const VideoComment({
    required this.id,
    required this.author,
    required this.text,
    required this.createdAt,
    this.likes = 0,
    this.isLiked = false,
    this.isAuthor = false,
    this.replies = const [],
    int? replyCount,
  }) : replyCount = replyCount ?? replies.length;

  factory VideoComment.fromJson(Json json) {
    final replies = readList(json['replies'], VideoComment.fromJson);
    return VideoComment(
      id: json['id'] as String,
      author: CreatorSummary.fromJson(json['author'] as Json),
      text: json['text'] as String? ?? '',
      createdAt: readDate(json['createdAt']) ?? DateTime.now(),
      likes: readInt(json['likes']),
      isLiked: json['isLiked'] as bool? ?? false,
      isAuthor: json['isAuthor'] as bool? ?? false,
      replies: replies,
      replyCount: readInt(json['replyCount'], replies.length),
    );
  }

  final String id;
  final CreatorSummary author;
  final String text;
  final DateTime createdAt;
  final int likes;

  /// Whether the signed-in user liked it.
  final bool isLiked;

  /// Written by the video's creator; marked with an "AUTHOR" badge.
  final bool isAuthor;

  /// The replies loaded so far: the first few come with the comment, the
  /// rest from `GET /videos/{id}/comments/{commentId}/replies`.
  final List<VideoComment> replies;

  /// All replies, loaded or not.
  final int replyCount;

  Json toJson() => {
    'id': id,
    'author': author.toJson(),
    'text': text,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'likes': likes,
    'isLiked': isLiked,
    'isAuthor': isAuthor,
    'replies': [for (final r in replies) r.toJson()],
    'replyCount': replyCount,
  };

  VideoComment copyWith({
    int? likes,
    bool? isLiked,
    List<VideoComment>? replies,
    int? replyCount,
  }) => VideoComment(
    id: id,
    author: author,
    text: text,
    createdAt: createdAt,
    likes: likes ?? this.likes,
    isLiked: isLiked ?? this.isLiked,
    isAuthor: isAuthor,
    replies: replies ?? this.replies,
    replyCount: replyCount ?? this.replyCount,
  );
}

/// What the comments sheet shows for one video: the comments loaded so far,
/// and how many the user has added since the feed's count was fetched.
class VideoCommentThread {
  const VideoCommentThread({required this.comments, this.added = 0});

  final List<VideoComment> comments;
  final int added;

  VideoCommentThread copyWith({List<VideoComment>? comments, int? added}) =>
      VideoCommentThread(
        comments: comments ?? this.comments,
        added: added ?? this.added,
      );
}
