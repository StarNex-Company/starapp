import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/core/network/paged.dart';
import 'package:starapp/features/home/data/models/feed_category.dart';
import 'package:starapp/features/home/data/models/home_feed.dart';
import 'package:starapp/features/home/data/models/post.dart';
import 'package:starapp/features/home/data/repositories/api_home_repository.dart';
import 'package:starapp/features/home/data/repositories/home_repository.dart';
import 'package:starapp/features/home/data/repositories/mock_home_repository.dart';

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => selectRepository(
    ref,
    mock: MockHomeRepository.new,
    api: ApiHomeRepository.new,
  ),
);

/// The home tab: stories, the two carousels and the posts of the selected
/// tab. [HomeFeedNotifier.loadMore] appends the next page of posts. Stars,
/// bookmarks, reports and hidden suggestions show at once and roll back if
/// the server rejects them; follows go through the shared
/// `followingProvider`. The greeting reads `currentUserProvider`.
final homeFeedProvider = AsyncNotifierProvider<HomeFeedNotifier, HomeFeed>(
  HomeFeedNotifier.new,
);

class HomeFeedNotifier extends AsyncNotifier<HomeFeed> {
  String? _nextCursor;
  bool _loadingMore = false;

  HomeRepository get _repository => ref.read(homeRepositoryProvider);

  @override
  Future<HomeFeed> build() async {
    final repository = ref.watch(homeRepositoryProvider);
    final results = await Future.wait<Object>([
      repository.fetchSections(),
      repository.fetchPosts(),
    ]);
    final page = results[1] as Paged<Post>;
    _nextCursor = page.nextCursor;
    return HomeFeed(sections: results[0] as HomeSections, posts: page.items);
  }

  bool get hasMore => _nextCursor != null;

  /// Appends the next page; a no-op on the last page or while loading.
  Future<void> loadMore() async {
    final feed = state.value;
    final cursor = _nextCursor;
    if (feed == null || cursor == null || _loadingMore) return;
    _loadingMore = true;
    try {
      final page = await _repository.fetchPosts(
        category: feed.category,
        cursor: cursor,
      );
      final current = state.value;
      // The tab changed meanwhile; this page belongs to the old one.
      if (current == null || current.category != feed.category) return;
      _nextCursor = page.nextCursor;
      state = AsyncData(
        current.copyWith(posts: [...current.posts, ...page.items]),
      );
    } finally {
      _loadingMore = false;
    }
  }

  /// Switches the feed tab and loads its first page. The chip moves at once
  /// and moves back if the page fails to load.
  Future<void> selectCategory(FeedCategory category) async {
    final feed = state.value;
    if (feed == null || feed.category == category) return;
    state = AsyncData(feed.copyWith(category: category));
    try {
      final page = await _repository.fetchPosts(category: category);
      final current = state.value;
      if (current == null || current.category != category) return;
      _nextCursor = page.nextCursor;
      state = AsyncData(current.copyWith(posts: page.items));
    } catch (_) {
      final current = state.value;
      if (current != null && current.category == category) {
        state = AsyncData(current.copyWith(category: feed.category));
      }
      rethrow;
    }
  }

  Future<void> toggleStar(String postId) => _toggle(
    postId,
    read: (p) => p.isStarred,
    apply: (p, on) =>
        p.copyWith(isStarred: on, stars: math.max(0, p.stars + (on ? 1 : -1))),
    request: (on) => _repository.setStarred(postId, starred: on),
  );

  Future<void> toggleBookmark(String postId) => _toggle(
    postId,
    read: (p) => p.isBookmarked,
    apply: (p, on) => p.copyWith(isBookmarked: on),
    request: (on) => _repository.setBookmarked(postId, bookmarked: on),
  );

  /// Reports the post, or withdraws the report.
  Future<void> toggleReport(String postId) => _toggle(
    postId,
    read: (p) => p.isReported,
    apply: (p, on) => p.copyWith(isReported: on),
    request: (on) => _repository.setReported(postId, reported: on),
  );

  /// Removes the creator from "Suggested Creators"; puts them back if the
  /// server rejects it.
  Future<void> hideSuggestion(String creatorId) async {
    final feed = state.value;
    if (feed == null) return;
    final suggestions = feed.sections.suggestedCreators;
    final index = suggestions.indexWhere((s) => s.creator.id == creatorId);
    if (index < 0) return;
    final hidden = suggestions[index];
    state = AsyncData(
      feed.copyWith(
        sections: feed.sections.copyWith(
          suggestedCreators: [...suggestions]..removeAt(index),
        ),
      ),
    );
    try {
      await _repository.hideSuggestion(creatorId);
    } catch (_) {
      final current = state.value;
      if (current != null) {
        final shown = current.sections.suggestedCreators;
        state = AsyncData(
          current.copyWith(
            sections: current.sections.copyWith(
              suggestedCreators: [...shown]
                ..insert(math.min(index, shown.length), hidden),
            ),
          ),
        );
      }
      rethrow;
    }
  }

  /// Flips one of the user's flags on a post, sends it, and flips it back on
  /// failure. Only that flag is reverted, so other changes made meanwhile
  /// stay.
  Future<void> _toggle(
    String postId, {
    required bool Function(Post post) read,
    required Post Function(Post post, bool on) apply,
    required Future<void> Function(bool on) request,
  }) async {
    final post = state.value?.posts.where((p) => p.id == postId).firstOrNull;
    if (post == null) return;
    final on = !read(post);
    _update(postId, (p) => apply(p, on));
    try {
      await request(on);
    } catch (_) {
      _update(postId, (p) => apply(p, !on));
      rethrow;
    }
  }

  void _update(String postId, Post Function(Post post) change) {
    final feed = state.value;
    if (feed == null) return;
    state = AsyncData(
      feed.copyWith(
        posts: [for (final p in feed.posts) p.id == postId ? change(p) : p],
      ),
    );
  }
}
