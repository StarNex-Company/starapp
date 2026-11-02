import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/profile/data/models/connections.dart';
import 'package:starapp/core/models/creator_tier.dart';
import 'package:starapp/features/profile/presentation/widgets/connections_style.dart';
import 'package:starapp/shared/widgets/star_image.dart';

/// "Follower" row: tier-ringed avatar, name, "@handle · tier" and a
/// Follow / Following toggle.
class ConnectionsPersonRow extends StatelessWidget {
  const ConnectionsPersonRow({
    super.key,
    required this.person,
    required this.following,
    required this.onTap,
    required this.onFollowTap,
  });

  final Connection person;
  final bool following;
  final VoidCallback onTap;
  final VoidCallback onFollowTap;

  @override
  Widget build(BuildContext context) {
    final creator = person.creator;
    final tier = creator.tier;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            spacing: 12,
            children: [
              _RingedAvatar(image: creator.avatarUrl, tier: tier),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    Text(
                      creator.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        height: connectionsLeading,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      tier == null
                          ? '@${creator.handle}'
                          : '@${creator.handle} · ${tier.label}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        height: connectionsLeading,
                        letterSpacing: 0,
                        color: AppColors.textSubtle,
                      ),
                    ),
                  ],
                ),
              ),
              ConnectionsFollowButton(following: following, onTap: onFollowTap),
            ],
          ),
        ),
      ),
    );
  }
}

/// 48px avatar: tier-coloured ring, 2px white gap, 40px photo.
class _RingedAvatar extends StatelessWidget {
  const _RingedAvatar({required this.image, required this.tier});

  final String? image;
  final CreatorTier? tier;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(ConnectionsIcons.ring(tier), width: 48, height: 48),
          SvgPicture.asset(ConnectionsIcons.ringGap, width: 44, height: 44),
          StarAvatar(image, size: 40),
        ],
      ),
    );
  }
}

/// "Toggle Follow": navy gradient "Follow", soft grey "Following".
class ConnectionsFollowButton extends StatelessWidget {
  const ConnectionsFollowButton({
    super.key,
    required this.following,
    required this.onTap,
  });

  final bool following;
  final VoidCallback onTap;

  static const _radius = BorderRadius.all(Radius.circular(12));

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: following,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 86,
        constraints: const BoxConstraints(minHeight: 34),
        decoration: BoxDecoration(
          gradient: following ? null : AppColors.brandGradient,
          color: following ? ConnectionsColors.followingFill : null,
          borderRadius: _radius,
          boxShadow: [
            BoxShadow(
              color: following
                  ? Colors.transparent
                  : ConnectionsColors.followShadow,
              offset: const Offset(0, 6),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    following ? 'Following' : 'Follow',
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 13,
                      height: connectionsLeading,
                      letterSpacing: 0,
                      fontWeight: FontWeight.w600,
                      color: following
                          ? AppColors.authTextSecondary
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
