import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/notifications/data/models/app_notification.dart';
import 'package:starapp/shared/widgets/star_image.dart';

/// Inter's "normal" line height, so text boxes match the design.
const notificationsLeading = 1.21;

abstract final class NotificationIcons {
  static const _dir = 'assets/vectors/notifications';

  static const star = '$_dir/notif_badge_star.svg';
  static const comment = '$_dir/notif_badge_comment.svg';
  static const follow = '$_dir/notif_badge_follow.svg';
}

abstract final class NotificationColors {
  /// surface/brand-tint/ebf3fe — unread card.
  static const unreadCard = Color(0xFFEBF3FE);

  /// surface/brand-tint/e5edff — "2 new" pill.
  static const countPill = Color(0xFFE5EDFF);

  /// Timestamp grey (slate 500).
  static const time = Color(0xFF64748B);

  /// White 80% ring around the avatar.
  static const avatarRing = Color(0xCCFFFFFF);

  /// rgba(219, 234, 254, 0.6) halo around the unread dot.
  static const dotHalo = Color(0x99DBEAFE);
}

/// "Article - Notification Card": avatar with a kind badge, message, time
/// and, while unread, a navy dot on a tinted card.
class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    required this.unread,
    required this.onTap,
  });

  final AppNotification notification;
  final bool unread;
  final VoidCallback onTap;

  static const _radius = BorderRadius.all(Radius.circular(8));

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: unread ? 'Unread' : null,
      child: Material(
        color: unread ? NotificationColors.unreadCard : AppColors.iconButtonBg,
        borderRadius: _radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 61,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _Avatar(image: notification.image, kind: notification.kind),
                  const SizedBox(width: 10),
                  // The design's message column is 237px of the 261 left
                  // beside the dot.
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              height: 18.56 / 12.5,
                              letterSpacing: 0,
                              fontWeight: FontWeight.w500,
                              color: AppColors.voidBlack,
                            ),
                          ),
                          Text(
                            formatAgo(notification.createdAt),
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 12,
                              height: 16 / 12,
                              letterSpacing: 0,
                              fontWeight: FontWeight.w500,
                              color: NotificationColors.time,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox.square(
                    dimension: 10,
                    child: AnimatedOpacity(
                      opacity: unread ? 1 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.brandNavy,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: NotificationColors.dotHalo,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
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

class _Avatar extends StatelessWidget {
  const _Avatar({required this.image, required this.kind});

  final String? image;
  final NotificationKind kind;

  @override
  Widget build(BuildContext context) {
    final (icon, size) = switch (kind) {
      NotificationKind.star ||
      NotificationKind.tier => (NotificationIcons.star, 8.0),
      NotificationKind.comment => (NotificationIcons.comment, 9.0),
      NotificationKind.follow => (NotificationIcons.follow, 9.0),
    };

    return SizedBox.square(
      dimension: 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: NotificationColors.avatarRing,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: StarAvatar(image, size: 40),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 13,
              height: 13,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.brandNavy,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white),
              ),
              child: SvgPicture.asset(icon, width: size, height: size),
            ),
          ),
        ],
      ),
    );
  }
}
