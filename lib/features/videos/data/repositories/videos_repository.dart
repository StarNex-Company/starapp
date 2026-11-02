import 'package:starapp/core/network/paged.dart';
import 'package:starapp/features/videos/data/models/feed_video.dart';
import 'package:starapp/features/videos/data/models/video_comment.dart';

/// Feed videos and their comments, and the user's stars, saves, shares and
/// comments on them. Screens read `videoFeedProvider` and
/// `videoCommentsProvider`; `videosRepositoryProvider` picks the mock or API
/// implementation.
abstract interface class VideosRepository {
  /// One page of [feed] in swipe order; pass the previous page's
  /// `nextCursor` for the next one.
  Future<Paged<FeedVideo>> fetchFeed(VideosFeed feed, {String? cursor});

  Future<void> setStarred(String videoId, {required bool starred});

  Future<void> setSaved(String videoId, {required bool saved});

  /// Counts a share of [videoId].
  Future<void> recordShare(String videoId);

  /// Top-level comments, oldest first, each with its first few replies.
  Future<Paged<VideoComment>> fetchComments(String videoId, {String? cursor});

  /// The replies to [commentId], oldest first.
  Future<Paged<VideoComment>> fetchReplies(
    String videoId,
    String commentId, {
    String? cursor,
  });

  /// Posts a comment, or a reply to the comment [replyTo], and returns it as
  /// saved.
  Future<VideoComment> postComment(
    String videoId,
    String text, {
    String? replyTo,
  });

  Future<void> setCommentLiked(
    String videoId,
    String commentId, {
    required bool liked,
  });
}
