import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/challenges/data/models/challenge.dart';
import 'package:starapp/features/challenges/data/models/leaderboard.dart';
import 'package:starapp/features/challenges/presentation/widgets/challenge_format.dart';
import 'package:starapp/features/challenges/presentation/widgets/detail_icons.dart';
import 'package:starapp/features/challenges/presentation/widgets/detail_style.dart';
import 'package:starapp/shared/widgets/star_image.dart';
import 'package:starapp/shared/widgets/star_radio_card.dart';

const _thumbScrim = Color(0xB307090D); // icon/primary/07090d @ 70%
const _playBorder = Color(0x80FFFFFF); // white @ 50%

/// Navy section title with an optional link on the right ("See all").
class DetailSectionHead extends StatelessWidget {
  const DetailSectionHead({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;

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
              height: detailLeading,
              letterSpacing: 0,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.brandBlue,
            ),
          ),
        ),
        if (action != null)
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(6),
            child: Text(
              action!,
              style: const TextStyle(
                height: detailLeading,
                letterSpacing: 0,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.brandBlue,
              ),
            ),
          ),
      ],
    );
  }
}

/// Numbered rule bullets. Tapping the list opens the full rules.
class DetailRuleList extends StatelessWidget {
  const DetailRuleList({super.key, required this.rules, required this.onTap});

  final List<String> rules;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      hint: 'Show challenge rules',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            for (var i = 0; i < rules.length; i++)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.brandTint,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        height: detailLeading,
                        letterSpacing: 0,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandBlue,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      rules[i],
                      style: const TextStyle(
                        height: 20 / 14,
                        letterSpacing: 0,
                        fontSize: 14,
                        color: AppColors.textBody,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal strip of 130×180 example videos with view counts.
class DetailInspirationStrip extends StatelessWidget {
  const DetailInspirationStrip({
    super.key,
    required this.items,
    required this.onTap,
  });

  final List<ChallengeEntry> items;
  final ValueChanged<ChallengeEntry> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) =>
            _Thumbnail(item: items[i], onTap: () => onTap(items[i])),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.item, required this.onTap});

  final ChallengeEntry item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            StarImage(item.thumbnailUrl),
            const Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                widthFactor: 1,
                heightFactor: 0.5,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x0007090D), _thumbScrim],
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.inkOverlay,
                      shape: BoxShape.circle,
                      border: Border.all(color: _playBorder),
                    ),
                    child: SvgPicture.asset(
                      DetailIcons.play,
                      width: 15.12,
                      height: 15.12,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 8,
              right: 8,
              bottom: 9,
              child: Row(
                spacing: 4,
                children: [
                  SvgPicture.asset(
                    DetailIcons.playSmall,
                    width: 10,
                    height: 10,
                  ),
                  Flexible(
                    child: Text(
                      formatCompact(item.viewCount),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        height: detailLeading,
                        letterSpacing: 0,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Material(
              type: MaterialType.transparency,
              child: InkWell(onTap: onTap),
            ),
          ],
        ),
      ),
    );
  }
}

/// White card with the current top three entries.
class DetailTopThreeCard extends StatelessWidget {
  const DetailTopThreeCard({
    super.key,
    required this.rankings,
    required this.onTap,
  });

  final List<LeaderboardEntry> rankings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: StarDividedCard.decoration,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Column(
              children: [
                for (var i = 0; i < rankings.length; i++) ...[
                  if (i > 0)
                    const ColoredBox(
                      color: AppColors.borderField,
                      child: SizedBox(height: 1, width: double.infinity),
                    ),
                  _RankingRow(ranking: rankings[i]),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RankingRow extends StatelessWidget {
  const _RankingRow({required this.ranking});

  final LeaderboardEntry ranking;

  Gradient get _medal => switch (ranking.rank) {
    1 => DetailGradients.gold,
    2 => DetailGradients.silver,
    _ => DetailGradients.bronze,
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
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
                  gradient: _medal,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${ranking.rank}',
                  style: const TextStyle(
                    height: detailLeading,
                    letterSpacing: 0,
                    fontSize: 11.7,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkDeep,
                  ),
                ),
              ),
              StarAvatar(ranking.creator.avatarUrl, size: 40),
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Text(
                  ranking.creator.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    height: detailLeading,
                    letterSpacing: 0,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  joinDetails([ranking.location, ranking.entryTitle]),
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
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              Text(
                formatGrouped(ranking.stars),
                style: const TextStyle(
                  height: detailLeading,
                  letterSpacing: 0,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              SvgPicture.asset(DetailIcons.star, width: 13, height: 13),
            ],
          ),
        ],
      ),
    );
  }
}
