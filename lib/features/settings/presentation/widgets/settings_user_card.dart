import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/session/data/models/current_user.dart';
import 'package:starapp/features/settings/presentation/widgets/settings_icons.dart';
import 'package:starapp/features/settings/presentation/widgets/settings_row.dart';
import 'package:starapp/shared/widgets/star_image.dart';

const _leading = 1.21;
const _radius = BorderRadius.all(Radius.circular(10));

/// The signed-in creator at the top of Settings: photo, name with creator and
/// verified badges, and handle. Opens their profile.
class SettingsUserCard extends StatelessWidget {
  const SettingsUserCard({super.key, required this.user, required this.onTap});

  final CurrentUser user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'View your profile',
      child: Material(
        color: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: _radius,
          side: BorderSide(
            color: AppColors.iconButtonBg,
          ), // border/default/eeeeee
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              spacing: 11,
              children: [
                StarAvatar(user.avatarUrl, size: 44),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 1,
                    children: [
                      Row(
                        spacing: 4,
                        children: [
                          Flexible(
                            child: Text(
                              user.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                height: _leading,
                                letterSpacing: 0,
                                fontWeight: FontWeight.w500,
                                color: AppColors.voidBlack,
                              ),
                            ),
                          ),
                          if (user.isCreator)
                            SvgPicture.asset(
                              SettingsIcons.creatorBadge,
                              width: 13,
                              height: 11,
                            ),
                          if (user.isVerified)
                            SvgPicture.asset(
                              SettingsIcons.verified,
                              width: 14,
                              height: 13,
                            ),
                        ],
                      ),
                      Text(
                        '@${user.handle}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          height: _leading,
                          letterSpacing: 0,
                          color: AppColors.voidBlack,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox.square(
                  dimension: 27,
                  child: Center(child: SettingsChevron()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
