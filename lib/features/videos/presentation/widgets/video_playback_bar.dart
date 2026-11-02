import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/features/videos/presentation/widgets/video_style.dart';
import 'package:starapp/features/videos/presentation/widgets/videos_icons.dart';

const _radius = BorderRadius.all(Radius.circular(16));
const _thumb = 14.0;

/// Frosted control bar: play/pause, elapsed time, scrubber, mute and a mini
/// volume slider. [progress] (0–1) drives the time and scrubber.
class VideoPlaybackBar extends StatelessWidget {
  const VideoPlaybackBar({
    super.key,
    required this.progress,
    required this.duration,
    required this.playing,
    required this.volume,
    required this.muted,
    required this.onPlayPause,
    required this.onMute,
    required this.onSeek,
    required this.onVolume,
  });

  final Animation<double> progress;

  /// Clip length in seconds.
  final int duration;
  final bool playing;

  /// 0–1; shown as 0 while [muted].
  final double volume;
  final bool muted;
  final VoidCallback onPlayPause;
  final VoidCallback onMute;
  final ValueChanged<double> onSeek;
  final ValueChanged<double> onVolume;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: _radius,
        boxShadow: [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 25),
            blurRadius: 50,
            spreadRadius: -12,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: _radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Container(
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0x8C121216),
              borderRadius: _radius,
              border: Border.all(color: const Color(0x1FFFFFFF)),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 6,
                  top: 0,
                  bottom: 0,
                  width: 32,
                  child: _IconTap(
                    tooltip: playing ? 'Pause' : 'Play',
                    icon: playing ? VideosIcons.pause : VideosIcons.play,
                    onTap: onPlayPause,
                    offsetY: 0.25,
                  ),
                ),
                Positioned(
                  left: 40,
                  top: 10,
                  child: AnimatedBuilder(
                    animation: progress,
                    builder: (context, _) => Text(
                      '${(progress.value * duration).floor()} / ${duration}s',
                      style:
                          videoText(
                            11,
                            color: videoTimeText,
                            lineHeight: 16.5,
                          ).copyWith(
                            fontFamily: 'monospace',
                            fontFamilyFallback: const [
                              'Menlo',
                              'Courier New',
                              'Courier',
                            ],
                          ),
                    ),
                  ),
                ),
                Positioned(
                  left: 102.81,
                  right: 106,
                  top: 6.25,
                  height: 24,
                  child: AnimatedBuilder(
                    animation: progress,
                    builder: (context, _) => _Slider(
                      label: 'Playback position',
                      value: progress.value,
                      onChanged: onSeek,
                    ),
                  ),
                ),
                Positioned(
                  right: 65,
                  top: 0,
                  bottom: 0,
                  width: 32,
                  child: _IconTap(
                    tooltip: muted ? 'Unmute' : 'Mute',
                    icon: muted || volume == 0
                        ? VideosIcons.volumeOff
                        : VideosIcons.volume,
                    onTap: onMute,
                    offsetY: 0.25,
                  ),
                ),
                Positioned(
                  right: 7,
                  top: 6.25,
                  width: 56,
                  height: 24,
                  child: _Slider(
                    label: 'Volume',
                    value: muted ? 0 : volume,
                    onChanged: onVolume,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconTap extends StatelessWidget {
  const _IconTap({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.offsetY = 0,
  });

  final String tooltip;
  final String icon;
  final VoidCallback onTap;
  final double offsetY;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Transform.translate(
          offset: Offset(0, offsetY),
          child: Center(child: SvgPicture.asset(icon, width: 16, height: 16)),
        ),
      ),
    );
  }
}

/// 4px track with a 14px white thumb, drawn 10px down a 24px touch strip.
class _Slider extends StatelessWidget {
  const _Slider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final travel = math.max(width - _thumb, 1.0);
        void seek(Offset local) =>
            onChanged(((local.dx - _thumb / 2) / travel).clamp(0.0, 1.0));

        return Semantics(
          slider: true,
          label: label,
          value: '${(value * 100).round()}%',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => seek(d.localPosition),
            onHorizontalDragUpdate: (d) => seek(d.localPosition),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 10,
                  height: 4,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0x40FFFFFF),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                ),
                Positioned(
                  left: value.clamp(0.0, 1.0) * travel,
                  top: 5,
                  child: Container(
                    width: _thumb,
                    height: _thumb,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Color(0x73000000), blurRadius: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
