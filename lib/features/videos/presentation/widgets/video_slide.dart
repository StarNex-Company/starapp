import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:starapp/features/videos/data/models/feed_video.dart';
import 'package:starapp/features/videos/presentation/widgets/video_action_rail.dart';
import 'package:starapp/features/videos/presentation/widgets/video_creator_info.dart';
import 'package:starapp/features/videos/presentation/widgets/video_playback_bar.dart';
import 'package:starapp/shared/widgets/star_image.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

/// Darkens the bottom of the poster under the caption and controls.
const _bottomShade = LinearGradient(
  begin: Alignment.bottomCenter,
  end: Alignment.topCenter,
  colors: [Colors.black, Color(0x00000000)],
  stops: [0.0078, 0.38],
);

/// Where the stand-in clock starts, as a fraction of the clip: the design's
/// frame shows 10 s of 12.
const _simulatedStart = 10 / 12;

/// One full-screen clip: poster, creator info, action rail and player bar.
///
/// Playback is simulated: progress advances only while the clip is [active]
/// (the page on screen) and not paused, and loops at the end. Star and save
/// state and counts come from [video].
class VideoSlide extends StatefulWidget {
  const VideoSlide({
    super.key,
    required this.video,
    required this.active,
    required this.comments,
    required this.following,
    required this.muted,
    required this.volume,
    required this.onStar,
    required this.onComments,
    required this.onShare,
    required this.onSave,
    required this.onFollow,
    required this.onCreator,
    required this.onSound,
    required this.onMute,
    required this.onVolume,
  });

  final FeedVideo video;
  final bool active;

  /// The comment count, including ones the user just posted.
  final int comments;
  final bool following;
  final bool muted;
  final double volume;
  final VoidCallback onStar;
  final VoidCallback onComments;
  final VoidCallback onShare;
  final VoidCallback onSave;
  final VoidCallback onFollow;
  final VoidCallback onCreator;
  final VoidCallback onSound;
  final VoidCallback onMute;
  final ValueChanged<double> onVolume;

  @override
  State<VideoSlide> createState() => _VideoSlideState();
}

class _VideoSlideState extends State<VideoSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress;
  bool _playing = true;

  @override
  void initState() {
    super.initState();
    final video = widget.video;
    _progress = AnimationController(
      vsync: this,
      // A clip without a known length still ticks.
      duration: video.duration > Duration.zero
          ? video.duration
          : const Duration(seconds: 1),
      value: _simulatedStart,
    );
    _sync();
  }

  @override
  void didUpdateWidget(VideoSlide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) _sync();
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  /// Runs the simulated clock only while on screen and playing.
  void _sync() {
    if (widget.active && _playing) {
      if (!_progress.isAnimating) _progress.repeat();
    } else {
      _progress.stop();
    }
  }

  void _togglePlay() {
    setState(() => _playing = !_playing);
    _sync();
    if (!_playing) showStarToast(context, 'Paused · tap again to play');
  }

  void _seek(double value) {
    _progress.value = value; // also stops the clock
    _sync();
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.video;
    final size = MediaQuery.sizeOf(context);
    // The bar sits 19px off the bottom of a 34px-inset phone.
    final barBottom = math.max(
      MediaQuery.viewPaddingOf(context).bottom - 15,
      12.0,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        StarImage(video.posterUrl, placeholderColor: Colors.black),
        const IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: _bottomShade),
          ),
        ),
        Positioned(
          left: 17,
          right: size.width / 6 + 33.5,
          bottom: barBottom + 38,
          height: 130,
          child: Align(
            alignment: Alignment.topLeft,
            child: VideoCreatorInfo(
              video: video,
              following: widget.following,
              onCreator: widget.onCreator,
              onFollow: widget.onFollow,
              onSound: widget.onSound,
            ),
          ),
        ),
        Positioned(
          right: 17,
          bottom: barBottom + 49,
          child: VideoActionRail(
            starred: video.isStarred,
            stars: video.stars,
            comments: widget.comments,
            saved: video.isSaved,
            saves: video.saves,
            onStar: widget.onStar,
            onComments: widget.onComments,
            onShare: widget.onShare,
            onSave: widget.onSave,
            onSound: widget.onSound,
          ),
        ),
        Positioned(
          left: 17,
          right: 17,
          bottom: barBottom,
          child: VideoPlaybackBar(
            progress: _progress,
            duration: video.duration.inSeconds,
            playing: _playing,
            volume: widget.volume,
            muted: widget.muted,
            onPlayPause: _togglePlay,
            onMute: widget.onMute,
            onSeek: _seek,
            onVolume: widget.onVolume,
          ),
        ),
      ],
    );
  }
}
