import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:starapp/features/profile/data/models/my_post.dart';
import 'package:starapp/features/profile/presentation/widgets/my_post_action_rail.dart';
import 'package:starapp/features/profile/presentation/widgets/my_post_creator_info.dart';
import 'package:starapp/features/profile/presentation/widgets/my_post_playback_bar.dart';
import 'package:starapp/shared/widgets/star_image.dart';

/// Darkens the bottom of the poster under the caption and controls.
const _bottomShade = LinearGradient(
  begin: Alignment.bottomCenter,
  end: Alignment.topCenter,
  colors: [Colors.black, Color(0x00000000)],
  stops: [0.0078, 0.38],
);

/// The post full screen: poster, creator info, action rail and player bar.
///
/// Playback is simulated until a video plugin is added: progress runs over
/// [MyPost.duration] and loops; tapping the video or the play button
/// pauses it ([onPaused] fires).
class MyPostView extends StatefulWidget {
  const MyPostView({
    super.key,
    required this.post,
    required this.creatorName,
    required this.creatorMeta,
    required this.creatorAvatarUrl,
    required this.creatorVerified,
    required this.starred,
    required this.stars,
    required this.saved,
    required this.saves,
    required this.muted,
    required this.volume,
    required this.onProfile,
    required this.onInsights,
    required this.onStar,
    required this.onComments,
    required this.onShare,
    required this.onSave,
    required this.onSound,
    required this.onMute,
    required this.onVolume,
    required this.onPaused,
  });

  final MyPost post;
  final String creatorName;
  final String creatorMeta;
  final String? creatorAvatarUrl;
  final bool creatorVerified;
  final bool starred;
  final int stars;
  final bool saved;
  final int saves;
  final bool muted;
  final double volume;
  final VoidCallback onProfile;
  final VoidCallback onInsights;
  final VoidCallback onStar;
  final VoidCallback onComments;
  final VoidCallback onShare;
  final VoidCallback onSave;
  final VoidCallback onSound;
  final VoidCallback onMute;
  final ValueChanged<double> onVolume;
  final VoidCallback onPaused;

  @override
  State<MyPostView> createState() => _MyPostViewState();
}

class _MyPostViewState extends State<MyPostView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress;
  bool _playing = true;

  @override
  void initState() {
    super.initState();
    final post = widget.post;
    _progress = AnimationController(
      vsync: this,
      duration: post.duration > Duration.zero
          ? post.duration
          : const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() => _playing = !_playing);
    if (_playing) {
      _progress.repeat();
    } else {
      _progress.stop();
      widget.onPaused();
    }
  }

  void _seek(double value) {
    _progress.value = value; // also stops the clock
    if (_playing) _progress.repeat();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final size = MediaQuery.sizeOf(context);
    // The bar sits 19px off the bottom of a 34px-inset phone.
    final barBottom = math.max(
      MediaQuery.viewPaddingOf(context).bottom - 15,
      12.0,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        Semantics(
          label: _playing ? 'Pause video' : 'Play video',
          button: true,
          excludeSemantics: true,
          onTap: _togglePlay,
          child: GestureDetector(
            onTap: _togglePlay,
            child: StarImage(post.posterUrl),
          ),
        ),
        const IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: _bottomShade),
          ),
        ),
        // A 130px block, top-aligned; large text grows it upwards.
        Positioned(
          left: 17,
          right: size.width / 6 + 33.5,
          bottom: barBottom + 38,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 130),
            child: MyPostCreatorInfo(
              name: widget.creatorName,
              meta: widget.creatorMeta,
              avatarUrl: widget.creatorAvatarUrl,
              verified: widget.creatorVerified,
              caption: post.caption,
              hashtag: post.hashtag,
              sound: post.sound,
              onProfile: widget.onProfile,
              onInsights: widget.onInsights,
              onSound: widget.onSound,
            ),
          ),
        ),
        Positioned(
          right: 17,
          bottom: barBottom + 49,
          child: MyPostActionRail(
            starred: widget.starred,
            stars: widget.stars,
            comments: post.comments,
            saved: widget.saved,
            saves: widget.saves,
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
          child: MyPostPlaybackBar(
            progress: _progress,
            duration: post.duration.inSeconds,
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
