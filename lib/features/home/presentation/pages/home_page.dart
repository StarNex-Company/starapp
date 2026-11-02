import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/navigation/creator_navigation.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/core/session/data/models/current_user.dart';
import 'package:starapp/core/session/data/provider/session_providers.dart';
import 'package:starapp/features/home/data/models/home_feed.dart';
import 'package:starapp/features/home/data/models/post.dart';
import 'package:starapp/features/home/data/provider/home_providers.dart';
import 'package:starapp/features/home/presentation/widgets/feed_category_chips.dart';
import 'package:starapp/features/home/presentation/widgets/home_header.dart';
import 'package:starapp/features/home/presentation/widgets/post_card.dart';
import 'package:starapp/features/home/presentation/widgets/story_strip.dart';
import 'package:starapp/features/home/presentation/widgets/suggested_creators.dart';
import 'package:starapp/features/home/presentation/widgets/trending_talents.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

const _backdrop = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [AppColors.brandNavy, Color(0x00919192)],
  stops: [0, 0.31354],
);

// Where the carousels sit among the posts, as in the design: "Trending
// Talents" after the first post, "Suggested Creators" after the second.
const _trendingAfterPosts = 1;
const _suggestedAfterPosts = 2;

/// Home feed tab. It has no Scaffold of its own: `MainShell` hosts it and
/// supplies the bottom navigation.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key, this.onCreate});

  /// Opens the create flow; supplied by the shell so home doesn't depend on it.
  final VoidCallback? onCreate;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  HomeFeedNotifier get _feed => ref.read(homeFeedProvider.notifier);

  // The create flow when the shell doesn't supply one.
  void _comingSoon() => showStarToast(context, 'Coming soon');

  void _openStory(String storyKey) =>
      context.push('${AppRoutes.story}?creator=$storyKey');

  static String _greeting(DateTime now) => switch (now.hour) {
    < 12 => 'Good Morning',
    < 17 => 'Good Afternoon',
    _ => 'Good Evening',
  };

  /// Runs a feed change; the feed has already rolled back if it failed.
  Future<void> _run(Future<void> Function() change) async {
    try {
      await change();
    } catch (e) {
      if (mounted) showStarToast(context, describeError(e));
    }
  }

  /// Fetches the next page of posts as the end of the feed comes into view.
  /// Only the feed's own scrolling counts, not the horizontal rows in it.
  bool _onScroll(ScrollUpdateNotification scroll) {
    if (scroll.depth == 0 && scroll.metrics.extentAfter < 600) {
      // A failed page is simply asked for again on the next scroll.
      _feed.loadMore().catchError((Object _) {});
    }
    return false;
  }

  Widget _content(HomeFeed feed, Set<String> following, CurrentUser? me) {
    final follows = ref.read(followingProvider.notifier);
    final sections = feed.sections;

    Widget padded(Widget child) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: child,
    );
    Widget post(Post p) => padded(
      PostCard(
        key: ValueKey(p.id),
        post: p,
        isFollowing: following.contains(p.author.id),
        onAuthorTap: () => context.pushCreator(p.author.id),
        onFollow: () => follows.toggle(p.author.id),
        onStar: () => _run(() => _feed.toggleStar(p.id)),
        onBookmark: () => _run(() => _feed.toggleBookmark(p.id)),
        onFlag: () => _run(() => _feed.toggleReport(p.id)),
      ),
    );

    final items = [for (final p in feed.posts) post(p)];
    // Insert the later section first so the earlier index still counts posts.
    items.insert(
      math.min(_suggestedAfterPosts, items.length),
      // Full bleed: the card row scrolls under the screen edges.
      SuggestedCreators(
        creators: sections.suggestedCreators,
        following: following,
        onSeeAll: () => context.push(AppRoutes.discoverSuggested),
        onCreatorTap: (c) => context.pushCreator(c.creator.id),
        onFollow: (c) => follows.toggle(c.creator.id),
        onDismiss: (c) => _run(() => _feed.hideSuggestion(c.creator.id)),
      ),
    );
    items.insert(
      math.min(_trendingAfterPosts, items.length),
      padded(
        TrendingTalents(
          talents: sections.trendingTalents,
          onViewAll: () => context.push(AppRoutes.videos),
          onAuthorTap: (t) => context.pushCreator(t.author.id),
        ),
      ),
    );

    return NotificationListener<ScrollUpdateNotification>(
      onNotification: _onScroll,
      child: ListView(
        // Bottom inset clears the nav bar the shell floats over us.
        padding: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(context).bottom + 12,
        ),
        children: [
          GreetingCard(
            greeting: _greeting(DateTime.now()),
            userName: me?.firstName ?? '',
            avatarUrl: me?.avatarUrl,
            onCreate: widget.onCreate ?? _comingSoon,
          ),
          const SizedBox(height: 2),
          FeedCategoryChips(
            selected: feed.category,
            onSelected: (c) => _run(() => _feed.selectCategory(c)),
          ),
          const SizedBox(height: 2),
          StoryStrip(
            userAvatarUrl: me?.avatarUrl,
            stories: sections.stories,
            onAddStory: () => context.push(AppRoutes.storyCreate),
            onStoryTap: (story) => _openStory(story.storyKey),
            // The prototype opens the first creator's story here.
            onViewAll: sections.stories.isEmpty
                ? null
                : () => _openStory(sections.stories.first.storyKey),
          ),
          const SizedBox(height: 2 + 15),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            items[i],
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(homeFeedProvider);
    final following = ref.watch(followingProvider);
    final me = ref.watch(currentUserProvider).value;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Material(
        color: Colors.white,
        child: DecoratedBox(
          decoration: const BoxDecoration(gradient: _backdrop),
          // Laid out bottom-up so the top bar, painted last, keeps its shadow
          // above the feed scrolling beneath it.
          child: Column(
            verticalDirection: VerticalDirection.up,
            children: [
              Expanded(
                child: StarAsyncView(
                  value: feed,
                  onRetry: () => ref.invalidate(homeFeedProvider),
                  builder: (feed) => _content(feed, following, me),
                ),
              ),
              const SizedBox(height: 4),
              HomeHeader(
                onSearch: () => context.push(AppRoutes.search),
                onNotifications: () => context.push(AppRoutes.notifications),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
