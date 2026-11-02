import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/discover/data/models/discover_models.dart';
import 'package:starapp/features/discover/presentation/widgets/discover_style.dart';
import 'package:starapp/shared/widgets/star_image.dart';

/// 68px "Suggested for you" row: ringed avatar, name, handle · talent and a
/// Follow / Following button.
class SuggestedCreatorRow extends StatelessWidget {
  const SuggestedCreatorRow({
    super.key,
    required this.suggestion,
    required this.following,
    required this.onFollow,
    required this.onTap,
  });

  final SuggestedCreator suggestion;
  final bool following;
  final VoidCallback onFollow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final creator = suggestion.creator;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          spacing: 12,
          children: [
            _RingedAvatar(photoUrl: creator.avatarUrl),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  Text(
                    creator.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: discoverText(15, FontWeight.w600, AppColors.ink),
                  ),
                  Text(
                    '@${creator.handle} · ${suggestion.talent}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: discoverText(
                      12,
                      FontWeight.w400,
                      AppColors.textSubtle,
                    ),
                  ),
                ],
              ),
            ),
            _FollowButton(following: following, onTap: onFollow),
          ],
        ),
      ),
    );
  }
}

/// 48px avatar: blue ring, white gap, 40px photo.
class _RingedAvatar extends StatelessWidget {
  const _RingedAvatar({required this.photoUrl});

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(DiscoverIcons.avatarRing, width: 48, height: 48),
          SvgPicture.asset(DiscoverIcons.avatarRingGap, width: 44, height: 44),
          StarAvatar(photoUrl, size: 40),
        ],
      ),
    );
  }
}

/// 86×34 follow toggle: navy gradient "Follow", grey "Following".
class _FollowButton extends StatelessWidget {
  const _FollowButton({required this.following, required this.onTap});

  static const _radius = BorderRadius.all(Radius.circular(12));

  final bool following;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: following,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 86,
        height: 34,
        decoration: BoxDecoration(
          borderRadius: _radius,
          color: following ? DiscoverColors.followingBg : null,
          gradient: following ? null : AppColors.brandGradient,
          boxShadow: const [
            BoxShadow(
              color: Color(0x2E032886),
              offset: Offset(0, 6),
              blurRadius: 8,
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: _radius,
            child: Center(
              child: Text(
                following ? 'Following' : 'Follow',
                style: discoverText(
                  13,
                  FontWeight.w600,
                  following ? DiscoverColors.followingText : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
