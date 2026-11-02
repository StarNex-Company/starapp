import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/navigation/creator_navigation.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/stories/data/models/story_creator.dart';
import 'package:starapp/features/stories/data/provider/stories_providers.dart';
import 'package:starapp/features/stories/presentation/widgets/story_icons.dart';
import 'package:starapp/features/stories/presentation/widgets/story_media_view.dart';
import 'package:starapp/features/stories/presentation/widgets/story_progress_bars.dart';
import 'package:starapp/features/stories/presentation/widgets/story_style.dart';
import 'package:starapp/features/stories/presentation/widgets/story_viewer_chrome.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_image.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

/// Full-screen story viewer, opened from a story circle on Home or Discover
/// (`/story?creator=<key>`).
///
/// Stories auto-advance every [storyDuration]; holding the screen, typing a
/// reply or a page opened on top (the creator's profile) pauses them. Tap
/// the right of the screen for the next story and the left for the previous
/// one; after a creator's last story the next creator in the same row
/// starts, and after the row's last story the viewer closes. Swipe down or
/// tap ✕ to close.
class StoryViewerPage extends ConsumerWidget {
  const StoryViewerPage({
    super.key,
    this.creator = 'adeboye',
    this.storyDuration = const Duration(seconds: 5),
  });

  /// The creator's story key (see `storyReelProvider`).
  final String creator;

  /// How long each story stays up before advancing.
  final Duration storyDuration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reel = ref.watch(storyReelProvider(creator));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,
        body: StarAsyncView(
          value: reel,
          onRetry: () => ref.invalidate(storyReelProvider(creator)),
          builder: (reel) => reel.creators.isEmpty
              ? const SizedBox.shrink()
              : _StoryPlayer(
                  storyKey: creator,
                  reel: reel,
                  storyDuration: storyDuration,
                ),
        ),
      ),
    );
  }
}

/// Plays a [StoryReel]: progress, tap and hold, swipe down to close, and the
/// reply bar.
class _StoryPlayer extends ConsumerStatefulWidget {
  const _StoryPlayer({
    required this.storyKey,
    required this.reel,
    required this.storyDuration,
  });

  final String storyKey;
  final StoryReel reel;
  final Duration storyDuration;

  @override
  ConsumerState<_StoryPlayer> createState() => _StoryPlayerState();
}

class _StoryPlayerState extends ConsumerState<_StoryPlayer>
    with SingleTickerProviderStateMixin {
  List<StoryCreator> get _row => widget.reel.creators;
  late int _creatorIndex;
  int _storyIndex = 0;

  late final AnimationController _progress;
  final _reply = TextEditingController();
  final _replyFocus = FocusNode();

  bool _holding = false;
  bool _dragging = false;

  /// Another page, such as the creator's profile, is on top of the viewer.
  bool _covered = false;
  double _dragOffset = 0;
  bool _closed = false;

  StoryCreator get _creator => _row[_creatorIndex];
  StoryItem get _story => _creator.stories[_storyIndex];

  StoryReelNotifier get _reel =>
      ref.read(storyReelProvider(widget.storyKey).notifier);

  @override
  void initState() {
    super.initState();
    _creatorIndex = widget.reel.startIndex;
    _progress = AnimationController(vsync: this, duration: widget.storyDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _next();
      });
    _replyFocus.addListener(_syncPlayback);
    _progress.forward();
    _reel.markViewed(_story.id);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _covered = !(ModalRoute.isCurrentOf(context) ?? true);
    _syncPlayback();
    _precacheUpcoming();
  }

  @override
  void dispose() {
    _progress.dispose();
    _replyFocus.dispose();
    _reply.dispose();
    super.dispose();
  }

  bool get _paused => _holding || _dragging || _covered || _replyFocus.hasFocus;

  void _syncPlayback() {
    if (_closed) return;
    if (_paused) {
      _progress.stop();
    } else if (!_progress.isAnimating) {
      _progress.forward();
    }
  }

  void _show(int creatorIndex, int storyIndex) {
    setState(() {
      _creatorIndex = creatorIndex;
      _storyIndex = storyIndex;
    });
    _progress.value = 0;
    _syncPlayback();
    _precacheUpcoming();
    _reel.markViewed(_story.id);
  }

  void _next() {
    if (_storyIndex < _creator.stories.length - 1) {
      _show(_creatorIndex, _storyIndex + 1);
    } else if (_creatorIndex < _row.length - 1) {
      _show(_creatorIndex + 1, 0);
    } else {
      _close();
    }
  }

  void _previous() {
    if (_storyIndex > 0) {
      _show(_creatorIndex, _storyIndex - 1);
    } else if (_creatorIndex > 0) {
      _show(_creatorIndex - 1, 0);
    } else {
      _show(_creatorIndex, 0);
    }
  }

  void _precacheUpcoming() {
    final upcoming = <StoryItem>[
      _story,
      if (_storyIndex < _creator.stories.length - 1)
        _creator.stories[_storyIndex + 1]
      else if (_creatorIndex < _row.length - 1)
        _row[_creatorIndex + 1].stories.first,
    ];
    for (final story in upcoming) {
      final image = story.mediaUrl;
      if (image != null && image.isNotEmpty) {
        precacheImage(starImageProvider(image), context, onError: (_, _) {});
      }
    }
  }

  void _close() {
    if (_closed) return;
    _closed = true;
    _progress.stop();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _onTapUp(TapUpDetails details, double width) {
    if (_replyFocus.hasFocus) {
      _replyFocus.unfocus();
      return;
    }
    // The design's "Tap / Previous" zone is the left 120 of 393px.
    if (details.localPosition.dx < width * 120 / 393) {
      _previous();
    } else {
      _next();
    }
  }

  void _setHolding(bool holding) {
    _holding = holding;
    _syncPlayback();
  }

  void _onDragStart(DragStartDetails _) {
    _dragging = true;
    _syncPlayback();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() => _dragOffset = math.max(0, _dragOffset + details.delta.dy));
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragOffset > 120 || (details.primaryVelocity ?? 0) > 700) {
      _close();
      return;
    }
    setState(() => _dragOffset = 0);
    _dragging = false;
    _syncPlayback();
  }

  /// Sends the reply; the text stays in the field if it fails.
  Future<void> _sendReply(String text) async {
    _replyFocus.unfocus();
    try {
      await _reel.reply(_story.id, text);
      _reply.clear();
      if (mounted) showStarToast(context, 'Reply sent');
    } catch (e) {
      if (mounted) showStarToast(context, describeError(e));
    }
  }

  /// Runs a star or like; the reel has already rolled back if it failed.
  Future<void> _react(Future<void> Function() change) async {
    try {
      await change();
    } catch (e) {
      if (mounted) showStarToast(context, describeError(e));
    }
  }

  void _comingSoon() => showStarToast(context, 'Coming soon');

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;
    final top = math.max(media.viewPadding.top, 24.0);
    final keyboard = media.viewInsets.bottom;
    final barBottom = math.max(
      math.max(media.viewPadding.bottom - 2, 16.0),
      keyboard + 12,
    );
    final barTop = size.height - barBottom - 48;
    final discover = widget.reel.layout == StoryLayout.discover;
    final story = _story;
    final starred = story.isStarred;

    return Transform.translate(
      offset: Offset(0, _dragOffset),
      child: Stack(
        children: [
          Positioned.fill(
            child: StoryMediaView(key: ValueKey(story.id), story: story),
          ),
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) => _onTapUp(details, size.width),
              onLongPressStart: (_) => _setHolding(true),
              onLongPressEnd: (_) => _setHolding(false),
              onLongPressCancel: () => _setHolding(false),
              onVerticalDragStart: _onDragStart,
              onVerticalDragUpdate: _onDragUpdate,
              onVerticalDragEnd: _onDragEnd,
            ),
          ),
          Positioned(
            top: top - 2,
            left: 16,
            right: discover ? 22 : 16,
            child: StoryProgressBars(
              count: _creator.stories.length,
              current: _storyIndex,
              progress: _progress,
              gap: discover ? 8 : 4,
            ),
          ),
          Positioned(
            top: top + 12,
            left: 16,
            right: 12,
            child: StoryViewerHeader(
              creator: _creator.creator,
              age: formatAge(story.createdAt),
              onCreatorTap: () => context.pushCreator(_creator.creator.id),
              onClose: _close,
            ),
          ),
          if (story.caption != null)
            Positioned(
              top: barTop - 72,
              left: 16,
              right: 16,
              child: IgnorePointer(
                child: Text(
                  story.caption!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: storyText(16, weight: FontWeight.w600),
                ),
              ),
            ),
          Positioned(
            left: 16,
            right: discover ? 14 : 13,
            bottom: barBottom,
            height: 48,
            child: Row(
              children: [
                Expanded(
                  child: StoryReplyField(
                    controller: _reply,
                    focusNode: _replyFocus,
                    onSend: _sendReply,
                  ),
                ),
                if (discover) ...[
                  const SizedBox(width: 10),
                  _LikeButton(
                    liked: story.isLiked,
                    onTap: () => _react(() => _reel.toggleLike(story.id)),
                  ),
                ] else ...[
                  const SizedBox(width: 11),
                  StoryRoundButton(
                    icon: starred ? StoryIcons.starFilled : StoryIcons.star,
                    iconSize: 22,
                    label: 'Star story',
                    selected: starred,
                    onTap: () => _react(() => _reel.toggleStar(story.id)),
                  ),
                  const SizedBox(width: 8),
                  StoryRoundButton(
                    icon: StoryIcons.comment,
                    label: 'Comment',
                    onTap: _replyFocus.requestFocus,
                  ),
                  const SizedBox(width: 8),
                  StoryRoundButton(
                    icon: StoryIcons.share,
                    label: 'Share',
                    onTap: _comingSoon,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Discover's heart: 28px outline, red when liked.
class _LikeButton extends StatelessWidget {
  const _LikeButton({required this.liked, required this.onTap});

  final bool liked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Like story',
      selected: liked,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox.square(
          dimension: 48,
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: SvgPicture.asset(
                liked ? StoryIcons.heartFilled : StoryIcons.heart,
                key: ValueKey(liked),
                width: 28.12,
                height: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
