import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/navigation/creator_navigation.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/core/session/data/provider/session_providers.dart';
import 'package:starapp/features/videos/data/models/feed_video.dart';
import 'package:starapp/features/videos/data/provider/videos_providers.dart';
import 'package:starapp/features/videos/presentation/widgets/video_comments_sheet.dart';
import 'package:starapp/features/videos/presentation/widgets/video_slide.dart';
import 'package:starapp/features/videos/presentation/widgets/video_top_bar.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_share_sheet.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

// The router builds `VideosPage(initialFeed: VideosFeed.…)` from this import.

/// Full-screen vertical video feed (Following | For You). It opens over the
/// shell, so it has no bottom navigation.
class VideosPage extends ConsumerStatefulWidget {
  const VideosPage({super.key, this.initialFeed = VideosFeed.forYou});

  final VideosFeed initialFeed;

  @override
  ConsumerState<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends ConsumerState<VideosPage> {
  // The next page starts loading this many clips before the end.
  static const _loadMoreAhead = 2;

  late VideosFeed _feed;

  // Made when a feed is first shown, then kept so each feed remembers its
  // clip (and stays loaded) while the page is open.
  final _controllers = <VideosFeed, PageController>{};
  final _current = <VideosFeed, int>{};

  /// Videos whose comments were opened; their threads stay loaded while the
  /// feed is open.
  final _openedThreads = <String>{};

  bool _muted = false;
  double _volume = 0.8;

  @override
  void initState() {
    super.initState();
    _feed = widget.initialFeed;
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _back() => context.canPop() ? context.pop() : context.go(AppRoutes.home);

  void _selectFeed(VideosFeed feed) {
    if (feed != _feed) setState(() => _feed = feed);
  }

  PageController _controllerFor(VideosFeed feed) =>
      _controllers.putIfAbsent(feed, () {
        _current[feed] = 0;
        return PageController();
      });

  /// Tracks the clip on screen and loads the next page as the end nears.
  void _onPageChanged(VideosFeed feed, int page, int loaded) {
    setState(() => _current[feed] = page);
    if (page >= loaded - _loadMoreAhead) {
      ref.read(videoFeedProvider(feed).notifier).loadMore().ignore();
    }
  }

  Future<void> _openComments(FeedVideo video, int count) async {
    setState(() => _openedThreads.add(video.id));
    await showVideoComments(context, videoId: video.id, count: count);
  }

  /// Awaits an optimistic change; if the server rejected it (and it was
  /// rolled back), says why.
  Future<void> _mutate(Future<void> change) async {
    try {
      await change;
    } catch (e) {
      if (mounted) showStarToast(context, describeError(e));
    }
  }

  void _share(FeedVideo video) {
    showStarShareSheet(
      context,
      title: 'Share video',
      link: 'starapp.io/v/${video.id}',
      linkCaption: 'Video link',
      onShared: () => _mutate(
        ref.read(videoFeedProvider(_feed).notifier).recordShare(video.id),
      ),
    );
  }

  void _toggleMute() {
    setState(() {
      if (_muted || _volume == 0) {
        _muted = false;
        if (_volume == 0) _volume = 0.8;
      } else {
        _muted = true;
      }
    });
    if (_muted) showStarToast(context, 'Sound off');
  }

  void _setVolume(double v) => setState(() {
    _volume = v;
    _muted = v == 0;
  });

  void _soundSaved() =>
      showStarToast(context, 'Sound saved · use it in your next post');

  Widget _slide(
    FeedVideo video,
    bool active,
    Set<String> following,
    Map<String, int> addedComments,
  ) {
    final notifier = ref.read(videoFeedProvider(_feed).notifier);
    final follows = ref.read(followingProvider.notifier);
    final creatorId = video.creator.id;
    final comments = video.comments + (addedComments[video.id] ?? 0);

    return VideoSlide(
      video: video,
      active: active,
      comments: comments,
      following: following.contains(creatorId),
      muted: _muted,
      volume: _volume,
      onStar: () => _mutate(notifier.toggleStar(video.id)),
      onComments: () => _openComments(video, video.comments),
      onShare: () => _share(video),
      onSave: () => _mutate(notifier.toggleSave(video.id)),
      onFollow: () => follows.toggle(creatorId),
      // The covered slide's clock stops with its ticker, so nothing plays
      // under the profile.
      onCreator: () => context.pushCreator(creatorId),
      onSound: _soundSaved,
      onMute: _toggleMute,
      onVolume: _setVolume,
    );
  }

  @override
  Widget build(BuildContext context) {
    final feed = _feed;
    final videos = ref.watch(videoFeedProvider(feed));
    // Feeds shown earlier stay loaded, so switching back keeps their clip.
    for (final shown in _controllers.keys) {
      if (shown != feed) ref.watch(videoFeedProvider(shown));
    }
    final hasMore = ref.read(videoFeedProvider(feed).notifier).hasMore;
    final following = ref.watch(followingProvider);
    final addedComments = {
      for (final id in _openedThreads)
        id: ref.watch(videoCommentsProvider(id)).value?.added ?? 0,
    };

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Positioned.fill(
              child: StarAsyncView(
                value: videos,
                onRetry: () => ref.invalidate(videoFeedProvider(feed)),
                builder: (videos) => videos.isEmpty
                    ? const SizedBox.shrink()
                    : PageView.builder(
                        key: PageStorageKey(feed),
                        controller: _controllerFor(feed),
                        scrollDirection: Axis.vertical,
                        // Once every page is in, the feed loops.
                        itemCount: hasMore ? videos.length : null,
                        onPageChanged: (i) =>
                            _onPageChanged(feed, i, videos.length),
                        itemBuilder: (context, i) => _slide(
                          videos[i % videos.length],
                          i == _current[feed],
                          following,
                          addedComments,
                        ),
                      ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: VideoTopBar(
                followingSelected: feed == VideosFeed.following,
                onFollowing: () => _selectFeed(VideosFeed.following),
                onForYou: () => _selectFeed(VideosFeed.forYou),
                onBack: _back,
                onSaved: () => context.go(AppRoutes.profileSaved),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
