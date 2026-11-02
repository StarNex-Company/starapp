import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/challenges/presentation/widgets/board_icons.dart';
import 'package:starapp/features/challenges/presentation/widgets/board_rank_row.dart';

const _outline = Color(0x40032886); // 032886 @ 25%
const _update = Duration(milliseconds: 700);

/// Navy card pinning your place on the live board. Rank and stars count to
/// their new values when they change.
class BoardLiveRankCard extends StatelessWidget {
  const BoardLiveRankCard({
    super.key,
    required this.photo,
    required this.title,
    required this.rank,
    required this.stars,
    required this.note,
  });

  final String? photo;

  /// e.g. "You · Late-night vocal run".
  final String title;
  final int rank;
  final int stars;

  /// e.g. "Up 2 places · 58 to Top 10".
  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        // CSS 168deg across the card: top-left corner to bottom-right corner.
        gradient: LinearGradient(
          begin: Alignment(-0.084, -1.917),
          end: Alignment(0.084, 1.917),
          colors: [
            AppColors.navyLight,
            AppColors.brandGradStart,
            AppColors.navyDeep,
          ],
          stops: [0, 0.6, 1],
        ),
        boxShadow: [
          BoxShadow(color: _outline, offset: Offset(0, 10), blurRadius: 12),
        ],
      ),
      child: Row(
        spacing: 12,
        children: [
          _CountUp(
            value: rank,
            builder: (value) => Text(
              '#$value',
              style: const TextStyle(
                height: 1.21,
                letterSpacing: 0,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.gold,
              ),
            ),
          ),
          BoardAvatar(
            photo: photo,
            size: 44,
            ring: AppColors.gold,
            gapColor: AppColors.brandGradStart,
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    height: 1.21,
                    letterSpacing: 0,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Row(
                  spacing: 4,
                  children: [
                    SvgPicture.asset(BoardIcons.up, width: 12, height: 12),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        layoutBuilder: (current, previous) => Stack(
                          alignment: Alignment.centerLeft,
                          children: [...previous, ?current],
                        ),
                        child: Text(
                          note,
                          key: ValueKey(note),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            height: 1.21,
                            letterSpacing: 0,
                            fontSize: 12,
                            color: AppColors.onBrandSubtle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _CountUp(
            value: stars,
            builder: (value) =>
                BoardStars(label: formatGrouped(value), color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/// Light card with your all-time place, under the Hall of Fame podium.
class BoardAllTimeRankCard extends StatelessWidget {
  const BoardAllTimeRankCard({
    super.key,
    required this.rank,
    required this.photo,
    required this.note,
    required this.stars,
    this.name = 'You',
  });

  /// e.g. "#1,284".
  final String rank;
  final String? photo;
  final String name;

  /// e.g. "Top 4% in Nigeria · Rising Nova"; wraps to a second line.
  final String note;
  final String stars;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.brandTint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _outline),
      ),
      child: Row(
        spacing: 12,
        children: [
          Text(
            rank,
            style: const TextStyle(
              height: 1.21,
              letterSpacing: 0,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.brandBlue,
            ),
          ),
          BoardAvatar(photo: photo, size: 36),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    height: 1.21,
                    letterSpacing: 0,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  note,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    height: 1.21,
                    letterSpacing: 0,
                    fontSize: 12,
                    color: AppColors.textSubtle,
                  ),
                ),
              ],
            ),
          ),
          BoardStars(label: stars),
        ],
      ),
    );
  }
}

/// Rebuilds with intermediate whole numbers while [value] animates to a new
/// target.
class _CountUp extends StatelessWidget {
  const _CountUp({required this.value, required this.builder});

  final int value;
  final Widget Function(int value) builder;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value.toDouble()),
      duration: _update,
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) => builder(animated.round()),
    );
  }
}
