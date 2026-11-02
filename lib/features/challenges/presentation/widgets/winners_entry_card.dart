import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/shared/widgets/star_image.dart';
import 'package:starapp/features/challenges/presentation/widgets/tier_celebration_style.dart';

const _playIcon = 'assets/vectors/challenges/winners_ic_play_large.svg';
const _scrimEnd = Color(0xB3EAF0FE); // gradient/light/eaf0fe-70

const _radius = BorderRadius.all(Radius.circular(18));

/// 190px video card of the winning entry: cover frame, a frosted play button
/// and the title with view / Star counts over a light scrim.
class WinnersEntryCard extends StatelessWidget {
  const WinnersEntryCard({
    super.key,
    required this.thumbnail,
    required this.title,
    required this.stats,
    required this.onPlay,
  });

  final String? thumbnail;
  final String title;

  /// e.g. "1.2M views · 64.3K Stars".
  final String stats;
  final VoidCallback? onPlay;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 190,
      child: ClipRRect(
        borderRadius: _radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            StarImage(thumbnail),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 95,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00FFFFFF), _scrimEnd],
                  ),
                ),
              ),
            ),
            const Center(child: _PlayBadge()),
            Positioned(
              left: 14,
              right: 14,
              top: 136,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.21,
                      letterSpacing: 0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    stats,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.21,
                      letterSpacing: 0,
                      color: CelebrationColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onPlay,
                child: Semantics(button: true, label: 'Play $title'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayBadge extends StatelessWidget {
  const _PlayBadge();

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          width: 54,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.inkOverlay,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white),
          ),
          child: SvgPicture.asset(_playIcon, width: 22.68, height: 22.68),
        ),
      ),
    );
  }
}
