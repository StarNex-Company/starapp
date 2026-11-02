import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/challenges/presentation/widgets/tier_celebration_style.dart';

const _checkIcon = 'assets/vectors/challenges/tier_ic_check.svg';
const _markBg = Color(0x408B5CF6); // 8b5cf6 @ 25%

/// Tinted card listing what a tier unlocks, one violet check per perk.
class TierPerksCard extends StatelessWidget {
  const TierPerksCard({super.key, required this.perks});

  final List<String> perks;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CelebrationColors.brandWashSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CelebrationColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          for (final perk in perks)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: _markBg,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(_checkIcon, width: 13, height: 13),
                ),
                Expanded(
                  child: Text(
                    perk,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 20 / 14,
                      letterSpacing: 0,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
