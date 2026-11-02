import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/core/network/paged.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/videos/data/models/feed_video.dart';
import 'package:starapp/features/videos/data/models/video_comment.dart';
import 'package:starapp/features/videos/data/repositories/videos_repository.dart';

class ApiVideosRepository implements VideosRepository {
  const ApiVideosRepository(this._client);

  final ApiClient _client;

  @override
  Future<Paged<FeedVideo>> fetchFeed(VideosFeed feed, {String? cursor}) =>
      _client.get(
        switch (feed) {
          VideosFeed.forYou => '/feed/for-you',
          VideosFeed.following => '/feed/following',
        },
        query: {'cursor': cursor},
        decode: (json) => Paged.fromJson(json as Json, FeedVideo.fromJson),
      );

  @override
  Future<void> setStarred(String videoId, {required bool starred}) => starred
      ? _client.put<void>('/videos/$videoId/star')
      : _client.delete<void>('/videos/$videoId/star');

  @override
  Future<void> setSaved(String videoId, {required bool saved}) => saved
      ? _client.put<void>('/videos/$videoId/save')
      : _client.delete<void>('/videos/$videoId/save');

  @override
  Future<void> recordShare(String videoId) =>
      _client.post<void>('/videos/$videoId/shares');

  @override
  Future<Paged<VideoComment>> fetchComments(String videoId, {String? cursor}) =>
      _client.get(
        '/videos/$videoId/comments',
        query: {'cursor': cursor},
        decode: (json) => Paged.fromJson(json as Json, VideoComment.fromJson),
      );

  @override
  Future<Paged<VideoComment>> fetchReplies(
    String videoId,
    String commentId, {
    String? cursor,
  }) => _client.get(
    '/videos/$videoId/comments/$commentId/replies',
    query: {'cursor': cursor},
    decode: (json) => Paged.fromJson(json as Json, VideoComment.fromJson),
  );

  @override
  Future<VideoComment> postComment(
    String videoId,
    String text, {
    String? replyTo,
  }) => _client.post(
    '/videos/$videoId/comments',
    data: {'text': text, 'replyTo': replyTo},
    decode: (json) => VideoComment.fromJson(json as Json),
  );

  @override
  Future<void> setCommentLiked(
    String videoId,
    String commentId, {
    required bool liked,
  }) => liked
      ? _client.put<void>('/videos/$videoId/comments/$commentId/like')
      : _client.delete<void>('/videos/$videoId/comments/$commentId/like');
}
