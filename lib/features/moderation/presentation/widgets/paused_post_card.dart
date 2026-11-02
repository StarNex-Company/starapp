import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/shared/widgets/star_image.dart';

const _pausedText = Color(0xFFB91C1C);

const _pausedDot = 'assets/vectors/moderation/paused_dot.svg';

/// Card for the flagged post: blurred thumbnail, title, meta, a "Paused"
/// chip and the reason / guideline / visibility details.
class PausedPostCard extends StatelessWidget {
  const PausedPostCard({
    super.key,
    required this.thumbnail,
    required this.title,
    required this.meta,
    required this.details,
  });

  final String? thumbnail;
  final String title;

  /// e.g. "Posted Oct 8 · 2.1K views".
  final String meta;
  final List<({String label, String value})> details;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        border: Border.fromBorderSide(BorderSide(color: AppColors.borderField)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F0B1020),
            offset: Offset(0, 4),
            blurRadius: 9,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Row(
            children: [
              _BlurredThumbnail(thumbnail),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSubtle,
                      ),
                    ),
                  ],
                ),
              ),
              // The design's title runs into the gap before the pill.
              const SizedBox(width: 3),
              const _PausedChip(),
            ],
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.borderField),
          for (final detail in details) _DetailRow(detail.label, detail.value),
        ],
      ),
    );
  }
}

class _BlurredThumbnail extends StatelessWidget {
  const _BlurredThumbnail(this.asset);

  final String? asset;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox.square(
          dimension: 64,
          child: Stack(
            fit: StackFit.expand,
            children: [
              StarImage(asset),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 32,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _PausedChip extends StatelessWidget {
  const _PausedChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: const BoxDecoration(
        color: AppColors.dangerTint,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          SvgPicture.asset(_pausedDot, width: 6, height: 6),
          const Text(
            'Paused',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _pausedText,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSubtle),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}
