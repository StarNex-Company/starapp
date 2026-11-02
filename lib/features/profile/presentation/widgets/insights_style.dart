import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';

/// Inter's "normal" line height, so text boxes match the design.
const insightsLeading = 1.21;

/// Design colours missing from [AppColors], shared by Star Insights, Top
/// posts and the Talent Passport.
abstract final class InsightsColors {
  /// "TOTAL STARS" on the navy card.
  static const heroLabel = Color(0xFFAFC0F5);

  /// rgba(3, 40, 134, 0.25) under the Total Stars card.
  static const heroShadow = Color(0x40032886);

  /// White 15%: tier progress track on the navy card.
  static const heroTrack = Color(0x26FFFFFF);

  /// rgba(34, 197, 94, 0.16) / 0.12: growth pills.
  static const growthPill = Color(0x2922C55E);
  static const growthPillSoft = Color(0x1F22C55E);

  /// Tier blue (#60A5FA) and its 14% pill.
  static const tierBlue = Color(0xFF60A5FA);
  static const tierPill = Color(0x2460A5FA);

  /// surface/muted/eef0f5 — segmented control track.
  static const segmentTrack = Color(0xFFEEF0F5);

  /// rgba(11, 16, 32, 0.08) — segmented thumb and bottom bar shadows.
  static const softShadow = Color(0x140B1020);

  /// surface/tint/fff8e1 — growth boost notice.
  static const boostTint = Color(0xFFFFF8E1);

  /// Donut series that have no token.
  static const violet = Color(0xFF7C5CFF);
  static const sky = Color(0xFF3BA7FF);

  /// rgba(7, 9, 13, 0.7) at the bottom of thumbnails.
  static const thumbScrim = Color(0xB307090D);

  /// Talent Passport card gradient middle / end.
  static const passportMid = Color(0xFF111827);
  static const passportEnd = Color(0xFF1A2233);

  /// rgba(11, 16, 32, 0.3) under the passport card.
  static const passportShadow = Color(0x4D0B1020);

  /// White 14%: AI score track.
  static const scoreTrack = Color(0x24FFFFFF);

  /// White 50%: play button outline.
  static const playOutline = Color(0x80FFFFFF);

  /// surface/tint/fff3cc — trophy tile.
  static const trophyTint = Color(0xFFFFF3CC);

  /// Next tier in the journey.
  static const journeyViolet = Color(0xFF8B5CF6);
}

abstract final class InsightsIcons {
  static const _dir = 'assets/vectors/profile';

  static const calendar = '$_dir/insights_ic_calendar.svg';
  static const watermark = '$_dir/insights_logo_watermark.svg';
  static const star = '$_dir/insights_ic_star.svg';
  static const up = '$_dir/insights_ic_up.svg';
  static const tierStar = '$_dir/insights_ic_star_tier.svg';
  static const zap = '$_dir/insights_ic_zap.svg';
  static const trendUp = '$_dir/insights_ic_trend_up.svg';
}

/// Section title with an optional "See all" action ("Top performing").
class InsightsSectionHeader extends StatelessWidget {
  const InsightsSectionHeader({super.key, required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              height: insightsLeading,
              letterSpacing: 0,
              fontWeight: FontWeight.w600,
              color: AppColors.brandBlue,
            ),
          ),
        ),
        if (onSeeAll != null)
          Semantics(
            button: true,
            child: InkWell(
              onTap: onSeeAll,
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  'See all',
                  style: TextStyle(
                    fontSize: 13,
                    height: insightsLeading,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w500,
                    color: AppColors.brandBlue,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Small rounded pill: an 11px icon and a short label ("Rising Nova", "43%").
class InsightsPill extends StatelessWidget {
  const InsightsPill({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
    this.height = 22,
    this.iconWidth = 11,
  });

  /// Rising Nova tier pill.
  const InsightsPill.tier({super.key, required this.label})
    : icon = InsightsIcons.tierStar,
      color = InsightsColors.tierBlue,
      background = InsightsColors.tierPill,
      height = 22,
      iconWidth = 11;

  final String icon;
  final String label;
  final Color color;
  final Color background;
  final double height;

  /// The SVG's own width, drawn centred in an 11px slot.
  final double iconWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: ShapeDecoration(
        color: background,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          SizedBox.square(
            dimension: 11,
            child: OverflowBox(
              maxWidth: iconWidth,
              child: SvgPicture.asset(icon, width: iconWidth, height: 11),
            ),
          ),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                height: insightsLeading,
                letterSpacing: 0,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
