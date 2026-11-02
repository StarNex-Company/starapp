import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/profile/presentation/widgets/creator_style.dart';

const _radius = BorderRadius.all(Radius.circular(12));
const _labelStyle = TextStyle(
  fontSize: 14,
  height: creatorLeading,
  letterSpacing: 0,
  fontWeight: FontWeight.w600,
);

/// "Actions" before the user follows: the navy Follow button and Message,
/// full width under the stats.
class CreatorActionsRow extends StatelessWidget {
  const CreatorActionsRow({
    super.key,
    required this.onFollow,
    required this.onMessage,
  });

  final VoidCallback onFollow;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        spacing: 8,
        children: [
          Expanded(child: _FollowButton(onTap: onFollow)),
          Expanded(child: _MessageButton(onTap: onMessage)),
        ],
      ),
    );
  }
}

/// The followed state's smaller Following / Message pair, shown right of the
/// photo. Tapping Following unfollows.
class CreatorCompactActions extends StatelessWidget {
  const CreatorCompactActions({
    super.key,
    required this.onUnfollow,
    required this.onMessage,
  });

  final VoidCallback onUnfollow;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        SizedBox(width: 116, child: _FollowingButton(onTap: onUnfollow)),
        SizedBox(width: 104, child: _MessageButton(onTap: onMessage)),
      ],
    );
  }
}

class _FollowButton extends StatelessWidget {
  const _FollowButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: _radius,
        boxShadow: [
          BoxShadow(
            color: CreatorColors.followShadow,
            offset: Offset(0, 6),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: _radius,
          onTap: onTap,
          child: _Content(
            icon: CreatorIcons.userPlus,
            label: 'Follow',
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _FollowingButton extends StatelessWidget {
  const _FollowingButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Material(
        color: CreatorColors.followingFill,
        borderRadius: _radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: _Content(
            icon: CreatorIcons.userCheck,
            label: 'Following',
            color: CreatorColors.followingInk,
          ),
        ),
      ),
    );
  }
}

class _MessageButton extends StatelessWidget {
  const _MessageButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Material(
        color: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: _radius,
          side: BorderSide(color: AppColors.brandBlue, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: const _Content(label: 'Message', color: AppColors.brandBlue),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.label, required this.color, this.icon});

  final String label;
  final Color color;

  /// 18.5 × 18 SVG drawn over an 18px slot, as in the design.
  final String? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: [
          if (icon != null)
            SizedBox.square(
              dimension: 18,
              child: OverflowBox(
                maxWidth: 18.5,
                child: SvgPicture.asset(icon!, width: 18.5, height: 18),
              ),
            ),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: _labelStyle.copyWith(color: color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
