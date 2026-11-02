import 'dart:ui' show ImageFilter;
import 'package:starapp/app/theme/app_theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/features/create/presentation/widgets/preview_icons.dart';
import 'package:starapp/shared/widgets/star_image.dart';

/// Video preview with category pill, play/pause control and duration badge.
class PreviewVideoCard extends StatelessWidget {
  const PreviewVideoCard({
    super.key,
    required this.frame,
    required this.category,
    required this.duration,
    required this.playing,
    required this.onTogglePlay,
  });

  /// The poster frame.
  final String? frame;
  final String category;
  final String duration;
  final bool playing;
  final VoidCallback onTogglePlay;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 345 / 230,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            StarImage(frame),
            const Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                widthFactor: 1,
                heightFactor: 0.5,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x0007090D), Color(0xB307090D)],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(left: 12, top: 12, child: _CategoryPill(category)),
            Positioned(right: 12, bottom: 12, child: _DurationPill(duration)),
            Center(
              child: PreviewPlayBadge(
                size: 56,
                icon: PreviewIcons.play,
                iconSize: 23.52,
                playing: playing,
                onTap: onTogglePlay,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Frosted round play button; shows a pause glyph while [playing].
class PreviewPlayBadge extends StatelessWidget {
  const PreviewPlayBadge({
    super.key,
    required this.size,
    required this.icon,
    required this.iconSize,
    this.borderColor = Colors.white,
    this.playing = false,
    this.onTap,
  });

  final double size;

  /// SVG asset path of the play glyph.
  final String icon;
  final double iconSize;
  final Color borderColor;
  final bool playing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: playing ? 'Pause' : 'Play',
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Material(
            color: AppColors.inkOverlay,
            shape: CircleBorder(side: BorderSide(color: borderColor)),
            child: InkWell(
              onTap: onTap,
              child: SizedBox.square(
                dimension: size,
                child: Center(
                  child: playing
                      ? Icon(
                          Icons.pause_rounded,
                          size: iconSize,
                          color: Colors.white,
                        )
                      : SvgPicture.asset(
                          icon,
                          width: iconSize,
                          height: iconSize,
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        color: AppColors.inkOverlay,
        borderRadius: BorderRadius.all(Radius.circular(13)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          SvgPicture.asset(PreviewIcons.music, width: 11, height: 11),
          Text(
            label,
            style: const TextStyle(
              height: 1.2,
              letterSpacing: 0,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _DurationPill extends StatelessWidget {
  const _DurationPill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: const BoxDecoration(
        color: AppColors.inkDeep,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Center(
        widthFactor: 1,
        child: Text(
          label,
          style: const TextStyle(
            height: 1.2,
            letterSpacing: 0,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
