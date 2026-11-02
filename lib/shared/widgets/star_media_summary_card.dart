import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/shared/widgets/star_radio_card.dart';

/// Card summarising a post or entry: rounded thumbnail, title, subtitle and
/// an optional trailing action or pill (Your entry, appeal case).
class StarMediaSummaryCard extends StatelessWidget {
  const StarMediaSummaryCard({
    super.key,
    required this.thumbnail,
    required this.title,
    required this.subtitle,
    this.thumbnailSize = 64,
    this.thumbnailOverlay,
    this.blurThumbnail = false,
    this.titleFontSize = 15,
    this.trailing,
  });

  /// Image asset path.
  final String thumbnail;
  final String title;
  final String subtitle;
  final double thumbnailSize;

  /// Drawn centred on the thumbnail, e.g. a play badge.
  final Widget? thumbnailOverlay;

  /// Softly blurs the thumbnail (content under review).
  final bool blurThumbnail;
  final double titleFontSize;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    Widget thumb = SizedBox.square(
      dimension: thumbnailSize,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(thumbnail, fit: BoxFit.cover),
            const Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: 0.5,
                widthFactor: 1,
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
            if (thumbnailOverlay != null) Center(child: thumbnailOverlay),
          ],
        ),
      ),
    );
    if (blurThumbnail) {
      thumb = ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
        child: thumb,
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: StarDividedCard.decoration,
      child: Row(
        spacing: 12,
        children: [
          thumb,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    height: 1.2,
                    letterSpacing: 0,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    height: 1.2,
                    letterSpacing: 0,
                    fontSize: 12,
                    color: AppColors.textSubtle,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
