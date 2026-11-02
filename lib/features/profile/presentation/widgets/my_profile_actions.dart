import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/profile/presentation/widgets/my_profile_style.dart';

/// "Profile Actions": Edit profile, Share profile and the ⚡ insights button.
class MyProfileActions extends StatelessWidget {
  const MyProfileActions({
    super.key,
    required this.onEdit,
    required this.onShare,
    required this.onInsights,
  });

  final VoidCallback onEdit;
  final VoidCallback onShare;
  final VoidCallback onInsights;

  static const _radius = BorderRadius.all(Radius.circular(14));

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        Expanded(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              borderRadius: _radius,
              gradient: LinearGradient(
                begin: Alignment(-0.09, -1),
                end: Alignment(0.09, 1),
                colors: [MyProfileColors.royalBlue, AppColors.brandBlue],
                stops: [0, 0.714],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x40032886), // 032886 @ 25%
                  offset: Offset(0, 8),
                  blurRadius: 9,
                ),
              ],
            ),
            child: _ActionButton(
              label: 'Edit profile',
              icon: MyProfileIcons.edit,
              color: Colors.white,
              onTap: onEdit,
            ),
          ),
        ),
        Expanded(
          child: Material(
            color: AppColors.brandTint,
            borderRadius: _radius,
            clipBehavior: Clip.antiAlias,
            child: _ActionButton(
              label: 'Share profile',
              icon: MyProfileIcons.share,
              color: AppColors.brandBlue,
              onTap: onShare,
            ),
          ),
        ),
        Tooltip(
          message: 'Star Insights',
          child: Material(
            color: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: _radius,
              side: BorderSide(color: MyProfileColors.borderButton),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onInsights,
              child: SizedBox.square(
                dimension: 46,
                child: Center(
                  child: SvgPicture.asset(
                    MyProfileIcons.zap,
                    width: 18,
                    height: 18,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      borderRadius: MyProfileActions._radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 46,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8,
              children: [
                SvgPicture.asset(icon, width: 16, height: 16),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      height: myProfileLeading,
                      letterSpacing: 0,
                      fontWeight: FontWeight.w600,
                      color: color,
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
