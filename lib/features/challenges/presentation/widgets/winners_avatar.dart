import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/shared/widgets/star_image.dart';

abstract final class _Assets {
  static const _dir = 'assets/vectors/challenges';

  static const crown = '$_dir/winners_ic_crown.svg';
  static const ring = '$_dir/winners_avatar_ring.svg';
  static const ringGap = '$_dir/winners_avatar_ring_gap.svg';
  static const check = '$_dir/winners_ic_verified_check.svg';
}

/// The winner's 132px gold-ringed photo with a crown on top and a verified
/// badge on the lower right.
class WinnersCrownedAvatar extends StatelessWidget {
  const WinnersCrownedAvatar({super.key, required this.photo});

  final String? photo;

  static const _size = 132.0;
  static const _crown = 40.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      // The crown overlaps the ring by 8px.
      height: _crown - 8 + _size,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: (_size - _crown) / 2,
            child: SvgPicture.asset(
              _Assets.crown,
              width: _crown,
              height: _crown,
            ),
          ),
          Positioned(
            top: _crown - 8,
            left: 0,
            child: SizedBox.square(
              dimension: _size,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  SvgPicture.asset(_Assets.ring, width: _size, height: _size),
                  Positioned(
                    left: 5,
                    top: 5,
                    child: SvgPicture.asset(
                      _Assets.ringGap,
                      width: 122,
                      height: 122,
                    ),
                  ),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: StarAvatar(photo, size: 112),
                  ),
                  Positioned(
                    left: 89,
                    top: 89,
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.brandBlue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: SvgPicture.asset(
                        _Assets.check,
                        width: 24.2,
                        height: 24.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
