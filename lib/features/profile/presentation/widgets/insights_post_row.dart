import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/profile/data/models/insights.dart';
import 'package:starapp/features/profile/presentation/widgets/insights_style.dart';
import 'package:starapp/shared/widgets/star_image.dart';

/// A post with its views, Stars and growth (Top performing, Top posts).
class InsightsPostRow extends StatelessWidget {
  const InsightsPostRow({super.key, required this.post, required this.onTap});

  final TopPost post;
  final VoidCallback onTap;

  static const _radius = BorderRadius.all(Radius.circular(14));

  @override
  Widget build(BuildContext context) {
    final stats =
        '${formatCompact(post.views)} views · ${formatGrouped(post.stars)} Stars';

    return Semantics(
      button: true,
      label: '${post.title}, $stats, ${formatChange(post.growthPercent)}',
      excludeSemantics: true,
      child: Material(
        color: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: _radius,
          side: BorderSide(color: AppColors.borderField),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            // 1px border + the design's 12/10 padding.
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            child: Row(
              spacing: 12,
              children: [
                _Thumbnail(image: post.thumbnailUrl),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 3,
                    children: [
                      Text(
                        post.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          height: insightsLeading,
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
                          height: insightsLeading,
                          letterSpacing: 0,
                          color: AppColors.textSubtle,
                        ),
                      ),
                    ],
                  ),
                ),
                InsightsPill(
                  icon: InsightsIcons.trendUp,
                  iconWidth: 12.68,
                  label: formatChange(post.growthPercent),
                  color: AppColors.success,
                  background: InsightsColors.growthPillSoft,
                  height: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.image});

  final String? image;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox.square(
        dimension: 56,
        child: Stack(
          fit: StackFit.expand,
          children: [
            StarImage(image),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 28,
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
          ],
        ),
      ),
    );
  }
}

/// Tinted notice for an active Stars multiplier.
class InsightsBoostNotice extends StatelessWidget {
  const InsightsBoostNotice({super.key, required this.boost});

  final InsightsBoost boost;

  @override
  Widget build(BuildContext context) {
    // 1.2 → "1.2", 2.0 → "2".
    final multiplier = boost.multiplier
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'\.?0+$'), '');
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: InsightsColors.boostTint,
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          SvgPicture.asset(InsightsIcons.zap, width: 20, height: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Text(
                  'Growth boost active · ×$multiplier',
                  style: const TextStyle(
                    fontSize: 14,
                    height: insightsLeading,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.goldText,
                  ),
                ),
                Text(
                  'Your followers grew ${boost.followerGrowthPercent}% this '
                  'week, so Stars you earn this week get a $multiplier× '
                  'multiplier.',
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 18 / 12.5,
                    letterSpacing: 0,
                    color: AppColors.textBody,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
