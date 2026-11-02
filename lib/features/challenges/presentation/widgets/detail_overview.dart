import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/challenges/presentation/widgets/detail_icons.dart';
import 'package:starapp/features/challenges/presentation/widgets/detail_style.dart';

/// Gold card with the grand prize and its extra perks.
class DetailPrizeCard extends StatelessWidget {
  const DetailPrizeCard({super.key, required this.prize, required this.perks});

  /// e.g. "$10,000 Grand Prize".
  final String prize;

  /// e.g. "+ Sony Music scout review · +500 bonus Stars".
  final String perks;

  @override
  Widget build(BuildContext context) {
    return Container(
      // The perks line runs into the right padding in the design.
      padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
      decoration: const BoxDecoration(
        gradient: DetailGradients.gold,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Color(0x33E7A91A),
            offset: Offset(0, 8),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        spacing: 12,
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.inkDeep,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              DetailIcons.prizeTrophy,
              width: 22,
              height: 22,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  prize,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    height: detailLeading,
                    letterSpacing: 0,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.inkDeep,
                  ),
                ),
                Text(
                  perks,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    height: detailLeading,
                    letterSpacing: 0,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.goldInk,
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

/// Row of equal-width stat tiles, e.g. Entries / Countries / Top Stars.
class DetailStatRow extends StatelessWidget {
  const DetailStatRow({super.key, required this.stats});

  /// (value, label) pairs.
  final List<(String, String)> stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12,
      children: [
        for (final (value, label) in stats)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              decoration: BoxDecoration(
                color: AppColors.brandTintSoft,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderField),
              ),
              child: Column(
                spacing: 2,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      height: detailLeading,
                      letterSpacing: 0,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      height: detailLeading,
                      letterSpacing: 0,
                      fontSize: 12,
                      color: AppColors.textSubtle,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// "Capacity · 890 / 1,000 entries" with the fill percentage and a gold bar.
class DetailCapacityBar extends StatelessWidget {
  const DetailCapacityBar({
    super.key,
    required this.summary,
    required this.filled,
  });

  /// e.g. "Capacity · 890 / 1,000 entries".
  final String summary;

  /// 0–1.
  final double filled;

  @override
  Widget build(BuildContext context) {
    final fraction = filled.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Row(
          spacing: 6,
          children: [
            const DetailSlotIcon(DetailIcons.users, size: 15),
            Expanded(
              child: Text(
                summary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  height: detailLeading,
                  letterSpacing: 0,
                  fontSize: 13,
                  color: AppColors.textBody,
                ),
              ),
            ),
            Text(
              '${(fraction * 100).round()}% filled',
              style: const TextStyle(
                height: detailLeading,
                letterSpacing: 0,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.goldDeep,
              ),
            ),
          ],
        ),
        Container(
          height: 8,
          alignment: Alignment.centerLeft,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.track,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            widthFactor: fraction,
            heightFactor: 1,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: DetailGradients.gold,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
