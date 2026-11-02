import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/profile/data/models/creator_profile.dart';
import 'package:starapp/features/profile/presentation/widgets/creator_style.dart';
import 'package:starapp/shared/widgets/star_image.dart';

/// "Cover & Avatar": the cover photo with the tier pill, and the photo (with
/// its story ring and tier star) overlapping the cover's bottom edge.
/// [actions] sit right of the photo, under the cover — the followed state
/// moves Following / Message there.
class CreatorHero extends StatelessWidget {
  const CreatorHero({
    super.key,
    required this.profile,
    required this.onOpenStory,
    this.actions,
  });

  final CreatorProfile profile;

  /// Tapping the photo; only used when the creator has a story.
  final VoidCallback onOpenStory;
  final Widget? actions;

  static const height = 176.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: _Cover(image: profile.coverUrl),
          ),
          Positioned(
            top: 6,
            right: 16,
            child: _TierPill(label: profile.tier.label),
          ),
          Positioned(
            top: 72,
            left: 24,
            child: _Avatar(
              profile: profile,
              onTap: profile.hasStory ? onOpenStory : null,
            ),
          ),
          if (actions != null) Positioned(top: 130, right: 24, child: actions!),
        ],
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.image});

  final String? image;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        StarImage(image),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x0007090D), AppColors.glass],
            ),
          ),
        ),
      ],
    );
  }
}

/// White "★ Super Nova" pill on the cover's top right.
class _TierPill extends StatelessWidget {
  const _TierPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: StadiumBorder(),
        shadows: [
          BoxShadow(
            color: CreatorColors.softShadow,
            offset: Offset(0, 4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          SizedBox.square(
            dimension: 14,
            child: Center(
              child: SvgPicture.asset(
                CreatorIcons.starStruck,
                width: 13.124,
                height: 13.124,
              ),
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              height: creatorLeading,
              letterSpacing: 0,
              fontWeight: FontWeight.w600,
              color: AppColors.brandBlue,
            ),
          ),
        ],
      ),
    );
  }
}

/// 96px avatar: gold-to-blue story ring (when there's a story), the framed
/// photo and the tier star.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.profile, required this.onTap});

  final CreatorProfile profile;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasStory = profile.hasStory;

    // The white frame and its shadow, with a margin for the shadow.
    Widget photo = Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: Container(
        width: 82,
        height: 82,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: CreatorColors.softShadow,
              offset: Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        padding: const EdgeInsets.all(4),
        child: StarAvatar(profile.avatarUrl, size: 74),
      ),
    );
    if (onTap != null) {
      photo = Semantics(
        button: true,
        label: "View ${profile.firstName}'s story",
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: photo,
        ),
      );
    }

    return SizedBox.square(
      dimension: 96,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (hasStory) ...[
            SvgPicture.asset(CreatorIcons.storyRing, width: 96, height: 96),
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
          Positioned(top: -1, left: -5, child: photo),
          Positioned(
            top: 65,
            left: 65,
            child: _TierStar(gradient: creatorTierGradient(profile.tier)),
          ),
        ],
      ),
    );
  }
}

/// "★" disc on the photo's lower right, coloured by tier.
class _TierStar extends StatelessWidget {
  const _TierStar({required this.gradient});

  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        gradient: gradient,
      ),
      child: const Text(
        '★',
        style: TextStyle(
          fontSize: 15,
          height: creatorLeading,
          letterSpacing: 0,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
