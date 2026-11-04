import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/home/presentation/widgets/feed_primitives.dart';

const _dir = 'assets/vectors/home';

/// Fixed, transparent home top bar (logo, search, notifications). It sits on
/// the page's navy fade and pads itself below the status bar.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.onSearch,
    required this.onNotifications,
  });

  final VoidCallback onSearch;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    Widget bar({required bool interactive}) => Row(
      children: [
        Semantics(
          label: 'StarApp',
          image: true,
          child: SvgPicture.asset(
            'assets/vectors/shared/logo.svg',
            width: 28,
            height: 24,
          ),
        ),
        const Spacer(),
        _CircleOutlineButton(
          icon: SvgPicture.asset(
            '$_dir/header_ic_search.svg',
            width: 18,
            height: 18,
          ),
          borderColor: AppColors.voidBlack,
          borderWidth: 1,
          tooltip: interactive ? 'Search' : null,
          onTap: onSearch,
        ),
        const SizedBox(width: 12),
        _CircleOutlineButton(
          icon: SvgPicture.asset(
            '$_dir/header_ic_notifications.svg',
            width: 16,
            height: 15,
          ),
          borderColor: Colors.white,
          borderWidth: 1.5,
          tooltip: interactive ? 'Notifications' : null,
          onTap: onNotifications,
        ),
      ],
    );

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 1 + 8, 24, 8),
        // The design drops a soft shadow (0 4 2, black 25%) under the bar's
        // contents rather than under a box, so paint a blurred silhouette.
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              top: 4,
              bottom: -4,
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: ImageFiltered(
                    imageFilter: ui.ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                        Color(0x40000000),
                        BlendMode.srcIn,
                      ),
                      child: bar(interactive: false),
                    ),
                  ),
                ),
              ),
            ),
            bar(interactive: true),
          ],
        ),
      ),
    );
  }
}

/// Avatar, greeting and the create button; the first item of the home feed.
class GreetingCard extends StatelessWidget {
  const GreetingCard({
    super.key,
    required this.greeting,
    required this.userName,
    required this.avatarUrl,
    required this.onCreate,
  });

  /// e.g. "Good Morning".
  final String greeting;
  final String userName;

  /// The user's photo; null shows the placeholder.
  final String? avatarUrl;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      child: Row(
        children: [
          RoundAvatar(url: avatarUrl, size: 44),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text.rich(
                  TextSpan(
                    text: '$greeting,',
                    children: [
                      TextSpan(
                        text: ' $userName 👋',
                        style: const TextStyle(color: AppColors.brandNavy),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    height: feedLeading,
                    letterSpacing: 0,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.voidBlack,
                  ),
                ),
                const Text(
                  'Ready to share your next talent?',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    height: feedLeading,
                    letterSpacing: 0,
                    fontSize: 13,
                    color: AppColors.voidBlack,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Tooltip(
            message: 'Create',
            child: Material(
              color: AppColors.brandNavy,
              borderRadius: BorderRadius.circular(6),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onCreate,
                child: SizedBox.square(
                  dimension: 37,
                  child: Center(
                    child: SvgPicture.asset(
                      '$_dir/nav_ic_create.svg',
                      width: 22,
                      height: 22,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleOutlineButton extends StatelessWidget {
  const _CircleOutlineButton({
    required this.icon,
    required this.borderColor,
    required this.borderWidth,
    required this.tooltip,
    required this.onTap,
  });

  final Widget icon;
  final Color borderColor;
  final double borderWidth;

  /// Null for the decorative shadow copy.
  final String? tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      type: MaterialType.transparency,
      shape: CircleBorder(
        side: BorderSide(color: borderColor, width: borderWidth),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox.square(dimension: 31, child: Center(child: icon)),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }
}
