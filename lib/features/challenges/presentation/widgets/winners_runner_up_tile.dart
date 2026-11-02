import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/shared/widgets/star_image.dart';
import 'package:starapp/features/challenges/presentation/widgets/tier_celebration_style.dart';

const _starIcon = 'assets/vectors/challenges/ic_star.svg';

// Medal discs behind the rank number.
const _silver = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    AppColors.silverLight,
    AppColors.silver,
  ], // gradient/light/f1f5f9 → gradient/tint/cbd5e1
);
const _bronze = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [AppColors.bronzeLight, AppColors.bronze],
);

/// Tinted row for a runner-up: medal rank, avatar, name, location / prize
/// line and the Star total.
class WinnersRunnerUpTile extends StatelessWidget {
  const WinnersRunnerUpTile({
    super.key,
    required this.rank,
    required this.photo,
    required this.name,
    required this.subtitle,
    required this.stars,
  });

  final int rank;

  final String? photo;
  final String name;

  /// e.g. "Lagos, NG · $2,000 prize".
  final String subtitle;

  /// Pre-formatted, e.g. "31.2K".
  final String stars;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
        color: CelebrationColors.brandWashSoft,
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      child: Row(
        spacing: 12,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: rank == 3 ? _bronze : _silver,
                ),
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    fontSize: 11.7,
                    height: 1.21,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkDeep,
                  ),
                ),
              ),
              StarAvatar(photo, size: 42),
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.21,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  subtitle,
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
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              Text(
                stars,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.21,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              SvgPicture.asset(_starIcon, width: 13, height: 13),
            ],
          ),
        ],
      ),
    );
  }
}
