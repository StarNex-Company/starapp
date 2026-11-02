import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/profile/data/models/talent_passport.dart';
import 'package:starapp/features/profile/presentation/widgets/insights_style.dart';
import 'package:starapp/features/profile/presentation/widgets/passport_card.dart';
import 'package:starapp/shared/widgets/star_image.dart';

/// Three portrait thumbnails of the user's best posts with their views.
class PassportBestWork extends StatelessWidget {
  const PassportBestWork({super.key, required this.items, required this.onTap});

  final List<PassportWork> items;
  final ValueChanged<PassportWork> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        for (final item in items.take(3))
          Expanded(
            child: _Thumbnail(item: item, onTap: () => onTap(item)),
          ),
      ],
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.item, required this.onTap});

  final PassportWork item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final views = formatCompact(item.views);

    return Semantics(
      button: true,
      label: 'Play post, $views views',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                StarImage(item.thumbnailUrl),
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 75,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x0007090D), InsightsColors.thumbScrim],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  bottom: 9,
                  right: 8,
                  child: Row(
                    spacing: 4,
                    children: [
                      SvgPicture.asset(
                        PassportIcons.playSmall,
                        width: 10,
                        height: 10,
                      ),
                      Flexible(
                        child: Text(
                          views,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            height: insightsLeading,
                            letterSpacing: 0,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Center(child: _PlayButton()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 30px frosted play button.
class _PlayButton extends StatelessWidget {
  const _PlayButton();

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.inkOverlay,
            shape: BoxShape.circle,
            border: Border.all(color: InsightsColors.playOutline),
          ),
          child: SvgPicture.asset(
            PassportIcons.play,
            width: 12.6,
            height: 12.6,
          ),
        ),
      ),
    );
  }
}
