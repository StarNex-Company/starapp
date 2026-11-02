import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/models/creator_tier.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/profile/data/models/talent_passport.dart';
import 'package:starapp/features/profile/presentation/widgets/insights_style.dart';
import 'package:starapp/features/profile/presentation/widgets/passport_card.dart';
import 'package:starapp/shared/widgets/star_radio_card.dart';

const _title = TextStyle(
  fontSize: 14,
  height: insightsLeading,
  letterSpacing: 0,
  fontWeight: FontWeight.w600,
  color: AppColors.ink,
);

const _detail = TextStyle(
  fontSize: 12,
  height: insightsLeading,
  letterSpacing: 0,
  color: AppColors.textSubtle,
);

/// "Top 10 · Afro-Dance Takeover", "Entered · Afro-Beats Producer & Vocal
/// Clash".
String _challengeTitle(PassportChallenge c) => switch ((c.result, c.rank)) {
  (PassportChallengeResult.entered, _) => 'Entered · ${c.title}',
  (PassportChallengeResult.placed, final rank?) when rank > 10 =>
    '#$rank · ${c.title}',
  (PassportChallengeResult.placed, _) => 'Top 10 · ${c.title}',
};

/// "Sep 2026 · #7 of 1,248 · $600 prize", "Oct 2026 · currently #14".
String _challengeDetail(PassportChallenge c) {
  final rank = c.rank;
  final entrants = c.entrants;
  final prize = c.prize;
  return [
    DateFormat('MMM y').format(c.date),
    if (rank != null)
      switch (c.result) {
        PassportChallengeResult.entered => 'currently #$rank',
        PassportChallengeResult.placed when entrants != null =>
          '#$rank of ${formatGrouped(entrants)}',
        PassportChallengeResult.placed => '#$rank',
      },
    if (prize != null && !prize.isZero) '${prize.format()} prize',
  ].join(' · ');
}

/// "Joined · Mar 2026", "Reached · Jul 2026", "721 Stars away".
String _stepCaption(PassportTierStep step) {
  final reached = step.reachedAt;
  if (step.state == PassportTierState.next) {
    return '${formatGrouped(step.starsAway ?? 0)} Stars away';
  }
  if (reached == null) return 'Reached';
  final verb = step.tier == CreatorTier.values.first ? 'Joined' : 'Reached';
  return '$verb · ${DateFormat('MMM y').format(reached)}';
}

/// 40px rounded tile holding a 20px icon.
class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon, this.color, this.gradient});

  final String icon;
  final Color? color;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        gradient: gradient,
        borderRadius: BorderRadius.circular(10),
      ),
      child: SvgPicture.asset(icon, width: 20, height: 20),
    );
  }
}

/// "Challenge record": placings and live entries, divided by hairlines.
class PassportChallengeRecord extends StatelessWidget {
  const PassportChallengeRecord({
    super.key,
    required this.items,
    required this.onTap,
  });

  final List<PassportChallenge> items;
  final ValueChanged<PassportChallenge> onTap;

  @override
  Widget build(BuildContext context) {
    return StarDividedCard(
      children: [
        for (final item in items)
          _ChallengeRow(item: item, onTap: () => onTap(item)),
      ],
    );
  }
}

class _ChallengeRow extends StatelessWidget {
  const _ChallengeRow({required this.item, required this.onTap});

  final PassportChallenge item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final placed = item.result == PassportChallengeResult.placed;

    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            spacing: 12,
            children: [
              _IconTile(
                icon: placed ? PassportIcons.trophy : PassportIcons.music,
                color: placed ? InsightsColors.trophyTint : AppColors.brandTint,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    Text(
                      _challengeTitle(item),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _title,
                    ),
                    Text(
                      _challengeDetail(item),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _detail,
                    ),
                  ],
                ),
              ),
              if (item.isLive) const _LivePill(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LivePill extends StatelessWidget {
  const _LivePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: const ShapeDecoration(
        color: AppColors.danger,
        shape: StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          SvgPicture.asset(PassportIcons.liveDot, width: 6, height: 6),
          const Text(
            'Live',
            style: TextStyle(
              fontSize: 10,
              height: insightsLeading,
              letterSpacing: 0,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// "Tier journey": reached tiers in grey, the current one in blue and the
/// next one outlined in violet with a preview link.
class PassportTierJourney extends StatelessWidget {
  const PassportTierJourney({
    super.key,
    required this.steps,
    required this.onNextTap,
  });

  final List<PassportTierStep> steps;
  final VoidCallback onNextTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: StarDividedCard.decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < steps.length; i++)
            _JourneyRow(
              step: steps[i],
              last: i == steps.length - 1,
              onTap: steps[i].state == PassportTierState.next
                  ? onNextTap
                  : null,
            ),
        ],
      ),
    );
  }
}

class _JourneyRow extends StatelessWidget {
  const _JourneyRow({required this.step, required this.last, this.onTap});

  final PassportTierStep step;
  final bool last;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (dotFill, dotBorder, star, line) = switch (step.state) {
      PassportTierState.reached => (
        AppColors.textFaint,
        AppColors.textFaint,
        PassportIcons.starWhite,
        AppColors.textFaint,
      ),
      PassportTierState.current => (
        InsightsColors.tierBlue,
        InsightsColors.tierBlue,
        PassportIcons.starWhite,
        AppColors.borderField,
      ),
      PassportTierState.next => (
        Colors.white,
        InsightsColors.journeyViolet,
        PassportIcons.starViolet,
        AppColors.borderField,
      ),
    };
    final next = step.state == PassportTierState.next;

    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        SizedBox(
          width: 24,
          child: Column(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: dotFill,
                  shape: BoxShape.circle,
                  border: Border.all(color: dotBorder, width: 2),
                ),
                child: SvgPicture.asset(star, width: 12, height: 12),
              ),
              if (!last)
                Container(
                  width: 2,
                  height: 26,
                  decoration: BoxDecoration(
                    color: line,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(
                step.tier.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: next
                    ? _title.copyWith(color: AppColors.textSubtle)
                    : _title,
              ),
              Text(
                _stepCaption(step),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _detail,
              ),
              if (next)
                Text(
                  'Preview your ${step.tier.label} unlock ✨',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _detail.copyWith(color: AppColors.brandBlue),
                ),
            ],
          ),
        ),
      ],
    );

    if (onTap == null) return row;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: row,
      ),
    );
  }
}

/// A company's review: who, the role, a 5-star rating and the quote.
class PassportReviewCard extends StatelessWidget {
  const PassportReviewCard({super.key, required this.review});

  final PassportReview review;

  // 135deg #7C5CFF → #3BA7FF on a square tile.
  static const _tile = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [InsightsColors.violet, InsightsColors.sky],
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: StarDividedCard.decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Row(
            spacing: 12,
            children: [
              const _IconTile(icon: PassportIcons.briefcase, gradient: _tile),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    Text(
                      review.company.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _title,
                    ),
                    Text(
                      _reviewLine(review),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _detail,
                    ),
                  ],
                ),
              ),
              Semantics(
                label: 'Rated ${review.rating} out of 5',
                excludeSemantics: true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 2,
                  children: [
                    for (var i = 0; i < 5; i++)
                      Opacity(
                        opacity: i < review.rating ? 1 : 0.25,
                        child: SvgPicture.asset(
                          PassportIcons.starGold,
                          width: 13,
                          height: 13,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          Text(
            '"${review.quote}"',
            style: const TextStyle(
              fontSize: 14,
              height: 21 / 14,
              letterSpacing: 0,
              fontStyle: FontStyle.italic,
              color: AppColors.textBody,
            ),
          ),
        ],
      ),
    );
  }
}

/// "Featured dancer · Aug 2026".
String _reviewLine(PassportReview review) {
  final date = DateFormat('MMM y').format(review.date);
  return review.role.isEmpty ? date : '${review.role} · $date';
}
