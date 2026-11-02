import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/models/creator_tier.dart';
import 'package:starapp/features/challenges/presentation/widgets/board_icons.dart';
import 'package:starapp/shared/widgets/star_image.dart';

const _riseTint = Color(
  0xFFF2FCF6,
); // 22c55e @ 6% on white, opaque so rows slide over each other
const _motion = Duration(milliseconds: 600);

/// Ring colour of places 1–3 (gold, silver, bronze); null below the podium.
Color? boardMedalColor(int rank) => switch (rank) {
  1 => AppColors.gold,
  2 => AppColors.silver,
  3 => AppColors.bronze,
  _ => null,
};

const _medalGradients = {
  1: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.goldLight, AppColors.gold, AppColors.goldDeep],
    stops: [0, 0.45, 1],
  ),
  2: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.silverLight,
      AppColors.silver,
    ], // gradient/light/f1f5f9-100 → tint/cbd5e1-100
  ),
  3: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.bronzeLight, AppColors.bronze],
  ),
};

/// 26px place marker: a medal disc for 1–3, a plain grey number below.
class BoardRankBadge extends StatelessWidget {
  const BoardRankBadge({super.key, required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    final gradient = _medalGradients[rank];
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: gradient == null
          ? null
          : BoxDecoration(gradient: gradient, shape: BoxShape.circle),
      child: Text(
        '$rank',
        maxLines: 1,
        softWrap: false,
        style: gradient == null
            ? const TextStyle(
                height: 1.21,
                letterSpacing: 0,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textSubtle,
              )
            : const TextStyle(
                height: 1.21,
                letterSpacing: 0,
                fontSize: 11.7,
                fontWeight: FontWeight.w700,
                color: AppColors.inkDeep,
              ),
      ),
    );
  }
}

/// Circular photo, optionally inside a coloured ring with a gap between ring
/// and photo. Ring changes animate.
class BoardAvatar extends StatelessWidget {
  const BoardAvatar({
    super.key,
    required this.photo,
    this.size = 42,
    this.ring,
    this.ringWidth = 2,
    this.gapWidth = 2,
    this.gapColor = Colors.white,
  });

  final String? photo;
  final double size;
  final Color? ring;
  final double ringWidth;
  final double gapWidth;
  final Color gapColor;

  @override
  Widget build(BuildContext context) {
    final ringed = ring != null;
    return AnimatedContainer(
      duration: _motion,
      width: size,
      height: size,
      padding: EdgeInsets.all(ringed ? ringWidth : 0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ring ?? gapColor.withValues(alpha: 0),
      ),
      child: AnimatedContainer(
        duration: _motion,
        padding: EdgeInsets.all(ringed ? gapWidth : 0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ringed ? gapColor : gapColor.withValues(alpha: 0),
        ),
        child: ClipOval(child: StarImage(photo)),
      ),
    );
  }
}

/// Star total with the gold star, e.g. "612 ★".
class BoardStars extends StatelessWidget {
  const BoardStars({
    super.key,
    required this.label,
    this.color = AppColors.ink,
    this.small = false,
  });

  final String label;
  final Color color;

  /// 12px label with an 11px star (podium) instead of 14px / 13px.
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Text(
          label,
          maxLines: 1,
          softWrap: false,
          style: TextStyle(
            height: 1.21,
            letterSpacing: 0,
            fontSize: small ? 12 : 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        small
            ? SvgPicture.asset(BoardIcons.starSmall, width: 11, height: 11)
            : SvgPicture.asset(BoardIcons.star, width: 13, height: 13),
      ],
    );
  }
}

/// Places moved since the last update: green ▲n, red ▼n or a grey 0.
class BoardDelta extends StatelessWidget {
  const BoardDelta({super.key, required this.movement});

  final int movement;

  @override
  Widget build(BuildContext context) {
    final color = movement > 0
        ? AppColors.success
        : movement < 0
        ? AppColors.danger
        : AppColors.textFaint;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 2,
      children: [
        if (movement != 0)
          SvgPicture.asset(
            movement > 0 ? BoardIcons.upSmall : BoardIcons.downSmall,
            width: 11,
            height: 11,
          ),
        Text(
          '${movement.abs()}',
          style: TextStyle(
            height: 1.21,
            letterSpacing: 0,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Avatar ring, pill text and pill star of a tier on the boards; the pill
/// fill is 14% of it.
extension BoardTierColor on CreatorTier {
  Color get color => switch (this) {
    CreatorTier.shootingStar => const Color(0xFF9CA3AF),
    CreatorTier.risingNova => const Color(0xFF60A5FA),
    CreatorTier.stellar => const Color(0xFF8B5CF6),
    CreatorTier.superNova => const Color(0xFFEC4899),
    CreatorTier.universeIcon => const Color(0xFF14B8A6),
  };
}

/// Small tinted pill naming a creator tier, e.g. "★ Universe Icon".
class BoardTierPill extends StatelessWidget {
  const BoardTierPill({super.key, required this.tier});

  final CreatorTier tier;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: tier.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          SvgPicture.asset(
            BoardIcons.starTier,
            width: 9,
            height: 9,
            colorFilter: ColorFilter.mode(tier.color, BlendMode.srcIn),
          ),
          Text(
            tier.label,
            style: TextStyle(
              height: 1.21,
              letterSpacing: 0,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: tier.color,
            ),
          ),
        ],
      ),
    );
  }
}

/// One leaderboard line: place, avatar, name and subtitle, then a trailing
/// score column, on its own white surface. Tappable; [highlighted] tints it
/// green (just moved up).
class BoardRankRow extends StatelessWidget {
  const BoardRankRow({
    super.key,
    required this.badge,
    required this.avatar,
    required this.name,
    required this.subtitle,
    required this.score,
    required this.onTap,
    this.highlighted = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
  });

  final Widget badge;
  final Widget avatar;
  final String name;
  final String subtitle;

  /// Right-aligned column, usually [BoardStars] over a [BoardDelta] or
  /// [BoardTierPill].
  final Widget score;
  final VoidCallback onTap;
  final bool highlighted;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: highlighted ? _riseTint : Colors.white),
      duration: _motion,
      builder: (context, color, child) => Material(
        color: color,
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: Row(
            spacing: 12,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 10,
                children: [badge, avatar],
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
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
                      subtitle,
                      maxLines: 1,
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
              score,
            ],
          ),
        ),
      ),
    );
  }
}
