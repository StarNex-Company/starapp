import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/settings/presentation/widgets/edit_profile_style.dart';
import 'package:starapp/features/settings/presentation/widgets/settings_icons.dart';
import 'package:starapp/shared/widgets/star_image.dart';

const _leading = 1.21;

/// "Cover photo" field: the 120px cover with a "Change cover" pill, and the
/// size hint underneath.
class EditProfileCover extends StatelessWidget {
  const EditProfileCover({
    super.key,
    required this.image,
    required this.onChange,
  });

  /// Null shows the placeholder.
  final String? image;
  final VoidCallback onChange;

  static const _radius = BorderRadius.all(Radius.circular(16));

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        const Text(
          'Cover photo',
          style: TextStyle(
            fontSize: 13,
            height: _leading,
            letterSpacing: 0,
            fontWeight: FontWeight.w600,
            color: EditProfileColors.coverLabel,
          ),
        ),
        Semantics(
          button: true,
          label: 'Change cover',
          child: GestureDetector(
            onTap: onChange,
            child: ClipRRect(
              borderRadius: _radius,
              child: SizedBox(
                height: 120,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: StarImage(
                        image,
                        key: ValueKey(image),
                        width: double.infinity,
                        height: 120,
                      ),
                    ),
                    const ColoredBox(color: EditProfileColors.coverScrim),
                    const Positioned(
                      right: 14,
                      bottom: 10,
                      child: ExcludeSemantics(child: _ChangeCoverPill()),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Text(
          'Recommended 1500 × 500 px · JPG or PNG',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            height: _leading,
            letterSpacing: 0,
            color: EditProfileColors.hint,
          ),
        ),
      ],
    );
  }
}

class _ChangeCoverPill extends StatelessWidget {
  const _ChangeCoverPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: EditProfileColors.coverButton,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          SvgPicture.asset(SettingsIcons.cameraSmall, width: 14, height: 14),
          const Text(
            'Change cover',
            style: TextStyle(
              fontSize: 12,
              height: _leading,
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

/// 96px profile photo with a navy camera button on its lower right.
class EditProfileAvatar extends StatelessWidget {
  const EditProfileAvatar({
    super.key,
    required this.image,
    required this.onChange,
  });

  /// Empty shows the placeholder.
  final String image;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      child: Center(
        child: Semantics(
          button: true,
          label: 'Change photo',
          child: GestureDetector(
            onTap: onChange,
            child: SizedBox.square(
              dimension: 96,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  DecoratedBox(
                    decoration: const BoxDecoration(
                      color: AppColors.silverLight,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: EditProfileColors.avatarRing,
                          spreadRadius: 4,
                        ),
                        BoxShadow(
                          color: Color(0x1A000000),
                          offset: Offset(0, 4),
                          blurRadius: 6,
                          spreadRadius: -1,
                        ),
                        BoxShadow(
                          color: Color(0x1A000000),
                          offset: Offset(0, 2),
                          blurRadius: 4,
                          spreadRadius: -2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        // The photo bleeds 4.8px past the circle in the design.
                        child: Transform.scale(
                          key: ValueKey(image),
                          scale: 105.6 / 96,
                          child: StarAvatar(image, size: 96),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: EditProfileColors.brand,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            offset: Offset(0, 10),
                            blurRadius: 15,
                            spreadRadius: -3,
                          ),
                          BoxShadow(
                            color: Color(0x1A000000),
                            offset: Offset(0, 4),
                            blurRadius: 6,
                            spreadRadius: -4,
                          ),
                        ],
                      ),
                      child: SvgPicture.asset(
                        SettingsIcons.camera,
                        width: 16,
                        height: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
