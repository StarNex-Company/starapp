import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/models/creator_tier.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/profile/data/models/my_profile.dart';
import 'package:starapp/features/profile/presentation/widgets/my_profile_style.dart';

const _white75 = Color(0xBFFFFFFF);
const _white70 = Color(0xB3FFFFFF);
const _white65 = Color(0xA6FFFFFF);
const _white60 = Color(0x99FFFFFF);
const _white15 = Color(0x26FFFFFF);
const _white14 = Color(0x24FFFFFF);
const _white12 = Color(0x1FFFFFFF);
const _white8 = Color(0x14FFFFFF);
const _gold16 = Color(0x29F5C451);
const _gold50 = Color(0x80F5C451);
const _gold60 = Color(0x99F5C451);

/// "Top 4% in Nigeria"; null while unranked.
String? _rankLabel(TierProgress progress) => switch (progress.topPercent) {
  null => null,
  final top when progress.region.isEmpty => 'Top $top%',
  final top => 'Top $top% in ${progress.region}',
};

/// "Tier & Passport": navy card with the tier, progress to the next tier and
/// the AI Talent Passport score. The whole card opens the passport.
class MyProfileTierCard extends StatelessWidget {
  const MyProfileTierCard({
    super.key,
    required this.tier,
    required this.tierLevel,
    required this.progress,
    required this.passport,
    required this.onTap,
  });

  final String tier;
  final int tierLevel;
  final TierProgress progress;
  final PassportSummary passport;
  final VoidCallback onTap;

  static const _radius = BorderRadius.all(Radius.circular(24));

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label:
          'Tier $tierLevel, $tier. AI Talent Passport ${passport.score} '
          'out of 100. View passport',
      child: DecoratedBox(
        decoration: const BoxDecoration(
          borderRadius: _radius,
          gradient: LinearGradient(
            begin: Alignment(-0.62, -1),
            end: Alignment(0.62, 1),
            colors: [MyProfileColors.royalBlue, MyProfileColors.tierNavy],
            stops: [0, 0.714],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x4D032886), // 032886 @ 30%
              offset: Offset(0, 14),
              blurRadius: 30,
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: _radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                Positioned(
                  right: -35,
                  top: -10,
                  child: Opacity(
                    opacity: 0.08,
                    child: SvgPicture.asset(
                      MyProfileIcons.tierWatermark,
                      width: 150,
                      height: 128.571,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ExcludeSemantics(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 14,
                      children: [
                        _Head(
                          tier: tier,
                          level: tierLevel,
                          rank: _rankLabel(progress),
                        ),
                        if (progress.nextTier case final next?)
                          _Progress(progress: progress, nextTier: next),
                        const SizedBox(
                          height: 1,
                          child: ColoredBox(color: _white14),
                        ),
                        _Passport(score: passport.score),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 8,
                          children: [
                            for (final m in passport.metrics)
                              Expanded(child: _Metric(metric: m)),
                          ],
                        ),
                      ],
                    ),
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

class _Head extends StatelessWidget {
  const _Head({required this.tier, required this.level, required this.rank});

  final String tier;
  final int level;

  /// Null hides the rank pill.
  final String? rank;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.gold, AppColors.goldDeep],
              stops: [0, 0.714],
            ),
          ),
          child: const Text(
            '★',
            style: TextStyle(
              fontSize: 17,
              height: myProfileLeading,
              letterSpacing: 0,
              fontWeight: FontWeight.w700,
              color: MyProfileColors.tierIconInk,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 1,
            children: [
              Text(
                'TIER $level',
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 10,
                  height: myProfileLeading,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                ),
              ),
              Text(
                tier,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  height: myProfileLeading,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        if (rank case final rank?)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _gold16,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: _gold50),
              ),
              child: Text(
                rank,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  height: myProfileLeading,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.progress, required this.nextTier});

  final TierProgress progress;
  final CreatorTier nextTier;

  @override
  Widget build(BuildContext context) {
    final value = progress.progress.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: Text(
                'Progress to ${nextTier.label}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  height: myProfileLeading,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w500,
                  color: _white75,
                ),
              ),
            ),
            Text(
              '${(value * 100).toStringAsFixed(1)}%',
              maxLines: 1,
              style: const TextStyle(
                fontSize: 12,
                height: myProfileLeading,
                letterSpacing: 0,
                fontWeight: FontWeight.w700,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: _white15,
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.centerLeft,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, t, _) => FractionallySizedBox(
              widthFactor: t,
              heightFactor: 1,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  gradient: LinearGradient(
                    colors: [AppColors.gold, MyProfileColors.progressGlow],
                  ),
                  boxShadow: [BoxShadow(color: _gold60, blurRadius: 8)],
                ),
              ),
            ),
          ),
        ),
        Text(
          progress.nextPerk.isEmpty
              ? '${formatGrouped(progress.starsToNext)} Stars to unlock '
                    '${nextTier.label}'
              : '${formatGrouped(progress.starsToNext)} Stars to unlock '
                    '${nextTier.label} · next perk: ${progress.nextPerk}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            height: myProfileLeading,
            letterSpacing: 0,
            fontWeight: FontWeight.w500,
            color: _white65,
          ),
        ),
      ],
    );
  }
}

class _Passport extends StatelessWidget {
  const _Passport({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(
                'AI Talent Passport',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  height: myProfileLeading,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                'View passport →',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  height: myProfileLeading,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: 2,
          children: [
            Text(
              '$score',
              maxLines: 1,
              style: const TextStyle(
                fontSize: 26,
                height: myProfileLeading,
                letterSpacing: 0,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const Text(
              '/100',
              maxLines: 1,
              style: TextStyle(
                fontSize: 12,
                height: myProfileLeading,
                letterSpacing: 0,
                fontWeight: FontWeight.w500,
                color: _white60,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.metric});

  final PassportMetric metric;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _white8,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _white12),
      ),
      child: Column(
        spacing: 3,
        children: [
          Text(
            '${metric.percent}%',
            maxLines: 1,
            style: const TextStyle(
              fontSize: 16,
              height: myProfileLeading,
              letterSpacing: 0,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            metric.kind.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              height: myProfileLeading,
              letterSpacing: 0,
              fontWeight: FontWeight.w500,
              color: _white70,
            ),
          ),
        ],
      ),
    );
  }
}
