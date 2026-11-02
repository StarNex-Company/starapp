import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/profile/presentation/widgets/my_profile_style.dart';
import 'package:starapp/shared/widgets/star_image.dart';

/// "Profile Hero": cover photo with the tier pill, and the avatar with its
/// tier star overlapping the cover's bottom edge.
class MyProfileHero extends StatelessWidget {
  const MyProfileHero({
    super.key,
    required this.coverUrl,
    required this.avatarUrl,
    required this.tier,
  });

  final String? coverUrl;

  /// Null shows the placeholder glyph.
  final String? avatarUrl;

  /// Tier name, e.g. "Rising Nova".
  final String tier;

  static const height = 226.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 4,
            left: 0,
            right: 0,
            height: 150,
            child: _Cover(image: coverUrl, tier: tier),
          ),
          Positioned(
            top: 114,
            left: 0,
            right: 0,
            child: Center(child: _Avatar(image: avatarUrl)),
          ),
        ],
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.image, required this.tier});

  final String? image;
  final String tier;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x290A1A4A), // 0a1a4a @ 16%
            offset: Offset(0, 10),
            blurRadius: 28,
          ),
        ],
      ),
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            StarImage(image),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00032886), Color(0x8C021A5E)],
                ),
              ),
            ),
            Positioned(top: 6, right: 16, child: _TierPill(tier: tier)),
          ],
        ),
      ),
    );
  }
}

/// White "😎 Rising Nova" pill on the cover.
class _TierPill extends StatelessWidget {
  const _TierPill({required this.tier});

  final String tier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(99)),
        boxShadow: [
          BoxShadow(
            color: Color(0x2E0A1A4A), // 0a1a4a @ 18%
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
                MyProfileIcons.starStruck,
                width: 13.12,
                height: 13.12,
              ),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              tier,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                height: myProfileLeading,
                letterSpacing: 0,
                fontWeight: FontWeight.w600,
                color: AppColors.brandBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.image});

  final String? image;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 100,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 100,
            height: 100,
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x3D0A1A4A), // 0a1a4a @ 24%
                  offset: Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: StarAvatar(image, size: 92),
          ),
          const Positioned(left: 76, top: 74, child: _TierStar()),
        ],
      ),
    );
  }
}

/// Blue "★" disc on the avatar's lower right.
class _TierStar extends StatelessWidget {
  const _TierStar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [MyProfileColors.tierStarLight, MyProfileColors.tierStarDeep],
          stops: [0, 0.714],
        ),
      ),
      child: const Text(
        '★',
        style: TextStyle(
          fontSize: 15,
          height: myProfileLeading,
          letterSpacing: 0,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
