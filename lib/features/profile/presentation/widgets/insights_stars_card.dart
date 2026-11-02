import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/profile/presentation/widgets/insights_style.dart';

/// Navy "Total Stars" card: all-time total, growth for the period and the
/// progress to the next tier. The card opens the Talent Passport; the
/// "721 Stars to Stellar" link opens the tier preview.
class InsightsStarsCard extends StatelessWidget {
  const InsightsStarsCard({
    super.key,
    required this.totalStars,
    required this.tier,
    required this.growthPercent,
    required this.growthLabel,
    required this.onTap,
    this.nextTier,
    this.starsToNext,
    this.progress = 0,
    this.onNextTierTap,
  });

  final int totalStars;
  final String tier;
  final int growthPercent;

  /// "+384 this month".
  final String growthLabel;
  final String? nextTier;
  final int? starsToNext;

  /// 0–1 through the current tier.
  final double progress;
  final VoidCallback onTap;
  final VoidCallback? onNextTierTap;

  static const _radius = BorderRadius.all(Radius.circular(22));

  // CSS linear-gradient(150.4deg, #0B2A8F 0%, #011A5E 60%, #020C33 100%) on
  // a 345×196 box.
  static const _gradient = LinearGradient(
    begin: Alignment(-0.488, -1.511),
    end: Alignment(0.488, 1.511),
    colors: [AppColors.navyLight, AppColors.brandGradStart, AppColors.navyDeep],
    stops: [0, 0.6, 1],
  );

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: Container(
        height: 196,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          gradient: _gradient,
          borderRadius: _radius,
          boxShadow: [
            BoxShadow(
              color: InsightsColors.heroShadow,
              offset: Offset(0, 12),
              blurRadius: 30,
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                Positioned(
                  left: 170,
                  top: 40,
                  child: SvgPicture.asset(
                    InsightsIcons.watermark,
                    width: 200,
                    height: 176,
                  ),
                ),
                Positioned(
                  left: 20,
                  top: 18,
                  right: 20,
                  child: _Totals(
                    totalStars: totalStars,
                    growthPercent: growthPercent,
                    growthLabel: growthLabel,
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  top: 136,
                  child: _TierProgress(
                    tier: tier,
                    nextTier: nextTier,
                    starsToNext: starsToNext,
                    progress: progress,
                    onNextTierTap: onNextTierTap,
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

class _Totals extends StatelessWidget {
  const _Totals({
    required this.totalStars,
    required this.growthPercent,
    required this.growthLabel,
  });

  final int totalStars;
  final int growthPercent;
  final String growthLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        const Text(
          'TOTAL STARS',
          maxLines: 1,
          style: TextStyle(
            fontSize: 11,
            height: insightsLeading,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w700,
            color: InsightsColors.heroLabel,
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              Text(
                formatGrouped(totalStars),
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 40,
                  height: insightsLeading,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              SvgPicture.asset(InsightsIcons.star, width: 28, height: 28),
            ],
          ),
        ),
        Row(
          spacing: 8,
          children: [
            InsightsPill(
              icon: InsightsIcons.up,
              label: '$growthPercent%',
              color: AppColors.success,
              background: InsightsColors.growthPill,
            ),
            Flexible(
              child: Text(
                growthLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  height: insightsLeading,
                  letterSpacing: 0,
                  color: AppColors.onBrandSubtle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TierProgress extends StatelessWidget {
  const _TierProgress({
    required this.tier,
    required this.nextTier,
    required this.starsToNext,
    required this.progress,
    required this.onNextTierTap,
  });

  final String tier;
  final String? nextTier;
  final int? starsToNext;
  final double progress;
  final VoidCallback? onNextTierTap;

  // CSS linear-gradient(177.1deg, …) on the 8px-high fill: nearly vertical.
  static const _fill = LinearGradient(
    begin: Alignment(-0.005, -2),
    end: Alignment(0.005, 2),
    colors: [AppColors.goldLight, AppColors.gold, AppColors.goldDeep],
    stops: [0, 0.45, 1],
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 8,
          children: [
            Flexible(child: InsightsPill.tier(label: tier)),
            if (nextTier != null && starsToNext != null)
              Flexible(
                child: Semantics(
                  button: true,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onNextTierTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Text(
                        '${formatGrouped(starsToNext!)} Stars to $nextTier',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          height: insightsLeading,
                          letterSpacing: 0,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: ColoredBox(
              color: InsightsColors.heroTrack,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress.clamp(0, 1)),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: _fill,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
