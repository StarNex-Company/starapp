import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/profile/presentation/widgets/creator_style.dart';

/// "Challenge Rank": gold banner with the creator's current or latest
/// challenge, e.g. "Ranked #4 in Afro-Dance Takeover".
class CreatorChallengeBanner extends StatelessWidget {
  const CreatorChallengeBanner({
    super.key,
    required this.text,
    required this.onTap,
  });

  final String text;
  final VoidCallback onTap;

  static const _radius = BorderRadius.all(Radius.circular(14));

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Material(
        color: CreatorColors.bannerFill,
        shape: const RoundedRectangleBorder(
          borderRadius: _radius,
          side: BorderSide(color: CreatorColors.bannerBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            // 1px outline + the design's 14 × 12 padding.
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            child: Row(
              spacing: 10,
              children: [
                SvgPicture.asset(CreatorIcons.trophy, width: 18, height: 18),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 14,
                      height: creatorLeading,
                      letterSpacing: 0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.goldText,
                    ),
                  ),
                ),
                SvgPicture.asset(
                  CreatorIcons.chevronGold,
                  width: 18,
                  height: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
