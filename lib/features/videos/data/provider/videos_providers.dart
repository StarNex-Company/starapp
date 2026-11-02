import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/core/session/data/provider/session_providers.dart';
import 'package:starapp/features/videos/data/models/feed_video.dart';
import 'package:starapp/features/videos/data/models/video_comment.dart';
import 'package:starapp/features/videos/data/repositories/api_videos_repository.dart';
import 'package:starapp/features/videos/data/repositories/mock_videos_repository.dart';
import 'package:starapp/features/videos/data/repositories/videos_repository.dart';

final videosRepositoryProvider = Provider<VideosRepository>(
  (ref) => selectRepository(
    ref,
    mock: MockVideosRepository.new,
    api: ApiVideosRepository.new,
  ),
);

/// A feed's clips in swipe order, with the user's stars and saves.
/// [VideoFeedNotifier.loadMore] appends the next page. It lives while the
/// feed page shows it; follows go through the shared `followingProvider`.
final videoFeedProvider = AsyncNotifierProvider.autoDispose
    .family<VideoFeedNotifier, List<FeedVideo>, VideosFeed>(
      VideoFeedNotifier.new,
    );

class VideoFeedNotifier extends AsyncNotifier<List<FeedVideo>> {
  VideoFeedNotifier(this.feed);

  final VideosFeed feed;

  String? _nextCursor;
  bool _loadingMore = false;

  VideosRepository get _repository => ref.read(videosRepositoryProvider);

  @override
  Future<List<FeedVideo>> build() async {
    final page = await ref.watch(videosRepositoryProvider).fetchFeed(feed);
    _nextCursor = page.nextCursor;
    return page.items;
  }

  bool get hasMore => _nextCursor != null;

  /// Appends the next page; a no-op on the last page or while loading.
  Future<void> loadMore() async {
    final videos = state.value;
    final cursor = _nextCursor;
    if (videos == null || cursor == null || _loadingMore) return;
    _loadingMore = true;
    try {
      final page = await _repository.fetchFeed(feed, cursor: cursor);
      _nextCursor = page.nextCursor;
      state = AsyncData([...videos, ...page.items]);
    } finally {
      _loadingMore = false;
    }
  }

  Future<void> toggleStar(String videoId) => _optimistic(
    videoId,
    (v) => v.copyWith(
      isStarred: !v.isStarred,
      stars: v.stars + (v.isStarred ? -1 : 1),
    ),
    (v) => _repository.setStarred(videoId, starred: v.isStarred),
  );

  Future<void> toggleSave(String videoId) => _optimistic(
    videoId,
    (v) =>
        v.copyWith(isSaved: !v.isSaved, saves: v.saves + (v.isSaved ? -1 : 1)),
    (v) => _repository.setSaved(videoId, saved: v.isSaved),
  );

  /// Counts a share.
  Future<void> recordShare(String videoId) => _optimistic(
    videoId,
    (v) => v.copyWith(shares: v.shares + 1),
    (_) => _repository.recordShare(videoId),
  );

  /// Shows [change] on [videoId] at once and sends [request] with the
  /// changed video; puts the video back if the server rejects it.
  Future<void> _optimistic(
    String videoId,
    FeedVideo Function(FeedVideo video) change,
    Future<void> Function(FeedVideo changed) request,
  ) async {
    final original = state.value?.where((v) => v.id == videoId).firstOrNull;
    if (original == null) return;
    final changed = change(original);
    _replace(changed);
    try {
      await request(changed);
    } catch (_) {
      if (ref.mounted) _replace(original);
      rethrow;
    }
  }

  void _replace(FeedVideo video) {
    final videos = state.value;
    if (videos == null) return;
    state = AsyncData([for (final v in videos) v.id == video.id ? video : v]);
  }
}

/// One video's comments, with the replies opened so far and the comments
/// the user posts and likes. [VideoCommentsNotifier.loadMore] appends the
/// next page. The feed keeps each opened thread alive until it closes, so
/// new comments survive closing the sheet.
final videoCommentsProvider = AsyncNotifierProvider.autoDispose
    .family<VideoCommentsNotifier, VideoCommentThread, String>(
      VideoCommentsNotifier.new,
    );

class VideoCommentsNotifier extends AsyncNotifier<VideoCommentThread> {
  VideoCommentsNotifier(this.videoId);

  final String videoId;

  String? _nextCursor;
  bool _loadingMore = false;

  /// Each opened comment's next replies cursor; null once all are loaded.
  final _replyCursors = <String, String?>{};
  int _pending = 0;

  VideosRepository get _repository => ref.read(videosRepositoryProvider);

  @override
  Future<VideoCommentThread> build() async {
    final page = await ref
        .watch(videosRepositoryProvider)
        .fetchComments(videoId);
    _nextCursor = page.nextCursor;
    return VideoCommentThread(comments: page.items);
  }

  bool get hasMore => _nextCursor != null;

  /// Appends the next page of comments; a no-op on the last page or while
  /// loading.
  Future<void> loadMore() async {
    final cursor = _nextCursor;
    if (state.value == null || cursor == null || _loadingMore) return;
    _loadingMore = true;
    try {
      final page = await _repository.fetchComments(videoId, cursor: cursor);
      _nextCursor = page.nextCursor;
      final thread = state.value!;
      state = AsyncData(
        thread.copyWith(comments: _merge(thread.comments, page.items)),
      );
    } finally {
      _loadingMore = false;
    }
  }

  /// Whether [comment] has replies that [loadReplies] can still fetch.
  bool hasMoreReplies(VideoComment comment) =>
      comment.replies.length < comment.replyCount &&
      (!_replyCursors.containsKey(comment.id) ||
          _replyCursors[comment.id] != null);

  /// Loads the next page of [commentId]'s replies after the ones it came
  /// with.
  Future<void> loadReplies(String commentId) async {
    final comment = _find(commentId);
    if (comment == null || !hasMoreReplies(comment)) return;
    final page = await _repository.fetchReplies(
      videoId,
      commentId,
      cursor: _replyCursors[commentId],
    );
    _replyCursors[commentId] = page.nextCursor;
    if (!ref.mounted) return;
    _updateComment(
      commentId,
      (c) => c.copyWith(replies: _merge(c.replies, page.items)),
    );
  }

  /// Likes or un-likes a comment or reply at once; reverts if the server
  /// rejects it.
  Future<void> toggleLike(String commentId) async {
    final original = _find(commentId);
    if (original == null) return;
    final liked = !original.isLiked;
    _updateComment(
      commentId,
      (c) => c.copyWith(isLiked: liked, likes: c.likes + (liked ? 1 : -1)),
    );
    try {
      await _repository.setCommentLiked(videoId, commentId, liked: liked);
    } catch (_) {
      if (ref.mounted) {
        _updateComment(
          commentId,
          (c) => c.copyWith(isLiked: original.isLiked, likes: original.likes),
        );
      }
      rethrow;
    }
  }

  /// Adds a comment to the end of the thread, or a reply under the comment
  /// [replyTo]. It shows at once under the signed-in user's name, is swapped
  /// for the saved copy when the server answers, and is removed if the
  /// server rejects it.
  Future<void> post(String text, {String? replyTo}) async {
    final me = ref.read(currentUserProvider).value?.summary;
    final pending = me == null
        ? null
        : VideoComment(
            id: 'pending-${_pending++}',
            author: me,
            text: text,
            createdAt: DateTime.now(),
          );
    if (pending != null) _add(pending, replyTo);
    try {
      final saved = await _repository.postComment(
        videoId,
        text,
        replyTo: replyTo,
      );
      if (!ref.mounted) return;
      if (pending == null) {
        _add(saved, replyTo);
      } else {
        _updateComment(pending.id, (_) => saved);
      }
    } catch (_) {
      if (ref.mounted && pending != null) _remove(pending.id, replyTo);
      rethrow;
    }
  }

  void _add(VideoComment comment, String? replyTo) {
    final thread = state.value;
    if (thread == null) return;
    state = AsyncData(
      VideoCommentThread(
        added: thread.added + 1,
        comments: replyTo == null
            ? [...thread.comments, comment]
            : [
                for (final c in thread.comments)
                  c.id == replyTo
                      ? c.copyWith(
                          replies: [...c.replies, comment],
                          replyCount: c.replyCount + 1,
                        )
                      : c,
              ],
      ),
    );
  }

  void _remove(String commentId, String? replyTo) {
    final thread = state.value;
    if (thread == null) return;
    state = AsyncData(
      VideoCommentThread(
        added: thread.added - 1,
        comments: [
          for (final c in thread.comments)
            if (c.id == replyTo)
              c.copyWith(
                replies: [
                  for (final r in c.replies)
                    if (r.id != commentId) r,
                ],
                replyCount: c.replyCount - 1,
              )
            else if (c.id != commentId)
              c,
        ],
      ),
    );
  }

  VideoComment? _find(String id) {
    for (final c in state.value?.comments ?? const <VideoComment>[]) {
      if (c.id == id) return c;
      for (final r in c.replies) {
        if (r.id == id) return r;
      }
    }
    return null;
  }

  /// Applies [change] to the comment or reply [id].
  void _updateComment(String id, VideoComment Function(VideoComment) change) {
    final thread = state.value;
    if (thread == null) return;
    VideoComment apply(VideoComment c) => c.id == id ? change(c) : c;
    state = AsyncData(
      thread.copyWith(
        comments: [
          for (final c in thread.comments)
            apply(
              c.replies.any((r) => r.id == id)
                  ? c.copyWith(replies: [for (final r in c.replies) apply(r)])
                  : c,
            ),
        ],
      ),
    );
  }

  /// [current] followed by the [loaded] ones it doesn't already have.
  static List<VideoComment> _merge(
    List<VideoComment> current,
    List<VideoComment> loaded,
  ) {
    final ids = {for (final c in current) c.id};
    return [
      ...current,
      for (final c in loaded)
        if (!ids.contains(c.id)) c,
    ];
  }
}
