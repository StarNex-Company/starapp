import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/home/presentation/widgets/home_icons.dart';
import 'package:starapp/shared/widgets/star_image.dart';

/// Inter's "normal" line height, so text boxes match the design.
const feedLeading = 1.21;

/// The feed's counts keep one decimal and a lowercase "k", as designed
/// (`formatCompact` would show 108200 as "108K").
extension CompactCount on int {
  /// 108200 → `108.2k`, 12000 → `12k`, 260 → `260`.
  String get compact {
    if (this < 1000) return '$this';
    final (value, suffix) = this < 1000000
        ? (this / 1000, 'k')
        : (this / 1000000, 'M');
    final text = value.toStringAsFixed(1);
    return '${text.endsWith('.0') ? text.substring(0, text.length - 2) : text}$suffix';
  }
}

/// The design's post time: "14:00" today, "Yesterday - 13:45", then
/// "Sep 14 - 09:30" (with the year once it's not this year's).
String formatPostedAt(DateTime time, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final today = DateTime(current.year, current.month, current.day);
  final day = DateTime(time.year, time.month, time.day);
  final clock = DateFormat('HH:mm').format(time);
  // Rounded, so a daylight-saving day still counts as one.
  final days = (today.difference(day).inHours / 24).round();
  if (days <= 0) return clock;
  if (days == 1) return 'Yesterday - $clock';
  final date = time.year == current.year
      ? DateFormat('MMM d').format(time)
      : DateFormat('MMM d, y').format(time);
  return '$date - $clock';
}

/// Circular avatar, optionally wrapped in the brand "has story" ring.
class RoundAvatar extends StatelessWidget {
  const RoundAvatar({
    super.key,
    required this.url,
    required this.size,
    this.ringWidth = 0,
    this.ringGap = 0,
  });

  final String? url;

  /// Outer size, ring included.
  final double size;
  final double ringWidth;
  final double ringGap;

  @override
  Widget build(BuildContext context) {
    final inner = size - 2 * (ringWidth + ringGap);
    final photo = StarAvatar(url, size: inner);
    if (ringWidth == 0) return SizedBox.square(dimension: size, child: photo);

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(ringGap),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.brandNavy, width: ringWidth),
      ),
      child: photo,
    );
  }
}

/// Overlapping 18px avatar bubbles ("Starred by", "Followed by"), optionally
/// ending in a black "+" bubble.
class AvatarPile extends StatelessWidget {
  const AvatarPile({
    super.key,
    required this.avatarUrls,
    this.overlap = 7,
    this.showMore = false,
  });

  final List<String?> avatarUrls;
  final double overlap;
  final bool showMore;

  static const _size = 18.0;

  Widget _bubble({required Color color, required Widget child}) => Container(
    width: _size,
    height: _size,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white),
    ),
    child: ClipOval(child: child),
  );

  @override
  Widget build(BuildContext context) {
    final shown = avatarUrls.take(3).toList();
    final count = shown.length + (showMore ? 1 : 0);
    final step = _size - overlap;

    return SizedBox(
      width: count == 0 ? 0 : step * (count - 1) + _size,
      height: _size,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: step * i,
              child: _bubble(
                color: AppColors.avatarFallback,
                child: StarAvatar(shown[i], size: _size - 2),
              ),
            ),
          if (showMore)
            Positioned(
              left: step * shown.length,
              child: _bubble(
                color: Colors.black,
                child: Center(
                  child: SvgPicture.asset(
                    HomeIcons.addRoundedSmall,
                    width: 12,
                    height: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The faded "View all →" card that ends a horizontal row (stories, trending).
class FeedViewAllCard extends StatelessWidget {
  const FeedViewAllCard({
    super.key,
    required this.background,
    required this.height,
    required this.labelTop,
    this.onTap,
  });

  /// Pre-shaped card artwork, 65px wide.
  final String background;
  final double height;

  /// Offset of the label block from the card's top.
  final double labelTop;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'View all',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 65,
          height: height,
          child: Stack(
            children: [
              SvgPicture.asset(background, width: 65, height: height),
              Positioned(
                left: 15,
                top: labelTop,
                width: 41,
                child: Column(
                  children: [
                    const Text(
                      'View all',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        height: 10 / 11,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w500,
                        color: AppColors.brandNavy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox.square(
                      dimension: 17,
                      child: RotatedBox(
                        quarterTurns: 1,
                        child: Center(
                          child: SvgPicture.asset(
                            HomeIcons.arrowUp,
                            width: 11.9167,
                            height: 14.75,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
