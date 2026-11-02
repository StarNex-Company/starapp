import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starapp/features/videos/data/models/feed_video.dart';
import 'package:starapp/features/videos/data/models/video_comment.dart';
import 'package:starapp/features/videos/data/provider/videos_providers.dart';
import 'package:starapp/features/videos/data/repositories/mock_videos_repository.dart';

const _repo = MockVideosRepository();

/// Rejects stars and comment likes.
class _FailingRepository extends MockVideosRepository {
  const _FailingRepository();

  @override
  Future<void> setStarred(String videoId, {required bool starred}) async =>
      throw Exception('offline');

  @override
  Future<void> setCommentLiked(
    String videoId,
    String commentId, {
    required bool liked,
  }) async => throw Exception('offline');
}

ProviderContainer _container(MockVideosRepository repo) {
  final container = ProviderContainer(
    overrides: [videosRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('both feeds parse and cover the designed captions', () async {
    final forYou = await _repo.fetchFeed(VideosFeed.forYou);
    final following = await _repo.fetchFeed(VideosFeed.following);

    expect(forYou.items, isNotEmpty);
    expect(following.items, isNotEmpty);
    final all = [...forYou.items, ...following.items];
    expect(all.any((v) => v.caption.contains('\n')), isTrue);
    expect(all.any((v) => !v.caption.contains('\n')), isTrue);
    expect(all.every((v) => v.duration > Duration.zero), isTrue);
    expect(all.every((v) => v.posterUrl != null), isTrue);
  });

  test('comments parse with a folded reply thread', () async {
    final page = await _repo.fetchComments('fyp-chidi-eze');
    final folded = page.items.firstWhere(
      (c) => c.replyCount > c.replies.length,
    );
    expect(folded.replies.single.isAuthor, isTrue);

    final replies = await _repo.fetchReplies('fyp-chidi-eze', folded.id);
    expect(replies.items.length, folded.replyCount);
  });

  test('toJson round-trips', () async {
    for (final feed in VideosFeed.values) {
      for (final v in (await _repo.fetchFeed(feed)).items) {
        expect(FeedVideo.fromJson(v.toJson()).toJson(), v.toJson());
      }
    }
    for (final c in (await _repo.fetchComments('x')).items) {
      expect(VideoComment.fromJson(c.toJson()).toJson(), c.toJson());
    }
  });

  test('missing fields fall back', () {
    final v = FeedVideo.fromJson({
      'id': 'v',
      'creator': {'id': 'c', 'name': 'C', 'handle': 'c'},
      'stars': '12',
    });
    expect(v.stars, 12);
    expect(v.duration, Duration.zero);
    expect(v.isStarred, isFalse);

    final c = VideoComment.fromJson({
      'id': 'c',
      'author': {'id': 'a', 'name': 'A', 'handle': 'a'},
      'replies': [
        {
          'id': 'r',
          'author': {'id': 'b', 'name': 'B', 'handle': 'b'},
        },
      ],
    });
    expect(c.replyCount, 1, reason: 'defaults to the replies sent');
  });

  test('a star shows at once and rolls back when the server fails', () async {
    final container = _container(const _FailingRepository());
    final provider = videoFeedProvider(VideosFeed.forYou);
    final sub = container.listen(provider, (_, _) {});
    addTearDown(sub.close);

    final before = (await container.read(provider.future)).first;
    final star = container.read(provider.notifier).toggleStar(before.id);
    final shown = container.read(provider).value!.first;
    expect(shown.isStarred, !before.isStarred);
    expect(shown.stars, before.stars + 1);

    await expectLater(star, throwsException);
    final after = container.read(provider).value!.first;
    expect(after.isStarred, before.isStarred);
    expect(after.stars, before.stars);
  });

  test('comments: replies load, posts and likes update the thread', () async {
    final container = _container(const MockVideosRepository());
    final provider = videoCommentsProvider('fyp-chidi-eze');
    final sub = container.listen(provider, (_, _) {});
    addTearDown(sub.close);
    final notifier = container.read(provider.notifier);

    final thread = await container.read(provider.future);
    final folded = thread.comments.firstWhere(
      (c) => c.replyCount > c.replies.length,
    );
    await notifier.loadReplies(folded.id);
    final opened = container
        .read(provider)
        .value!
        .comments
        .firstWhere((c) => c.id == folded.id);
    expect(opened.replies.length, opened.replyCount);
    expect(notifier.hasMoreReplies(opened), isFalse);

    await notifier.post('Nice one');
    final posted = container.read(provider).value!;
    expect(posted.added, 1);
    expect(posted.comments.last.text, 'Nice one');
    expect(posted.comments.last.id, isNot(startsWith('pending')));

    final first = posted.comments.first;
    await notifier.toggleLike(first.id);
    final liked = container.read(provider).value!.comments.first;
    expect(liked.isLiked, isTrue);
    expect(liked.likes, first.likes + 1);
  });

  test('a comment like rolls back when the server fails', () async {
    final container = _container(const _FailingRepository());
    final provider = videoCommentsProvider('fyp-chidi-eze');
    final sub = container.listen(provider, (_, _) {});
    addTearDown(sub.close);

    final first = (await container.read(provider.future)).comments.first;
    await expectLater(
      container.read(provider.notifier).toggleLike(first.id),
      throwsException,
    );
    final after = container.read(provider).value!.comments.first;
    expect(after.isLiked, first.isLiked);
    expect(after.likes, first.likes);
  });
}
