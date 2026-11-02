import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/challenges/presentation/widgets/tier_celebration_style.dart';

const _trophyIcon = 'assets/vectors/challenges/winners_ic_trophy.svg';
const _cardGlow = Color(0x59E7A91A); // e7a91a @ 35%

/// Gold card with a trophy tile, the prize headline and its extra perks.
class WinnersPrizeCard extends StatelessWidget {
  const WinnersPrizeCard({super.key, required this.title, required this.perks});

  /// e.g. "$5,000 Grand Prize".
  final String title;

  /// One line each, e.g. "+ 500 bonus Stars".
  final List<String> perks;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: celebrationGold,
        borderRadius: BorderRadius.all(Radius.circular(18)),
        boxShadow: [
          BoxShadow(color: _cardGlow, offset: Offset(0, 12), blurRadius: 24),
        ],
      ),
      child: Row(
        spacing: 14,
        children: [
          Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.inkDeep,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(_trophyIcon, width: 24, height: 24),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 19,
                    height: 1.21,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w800,
                    color: AppColors.inkDeep,
                  ),
                ),
                for (final perk in perks)
                  Text(
                    perk,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.21,
                      letterSpacing: 0,
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
