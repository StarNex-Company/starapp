import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/home/data/models/post.dart';
import 'package:starapp/features/home/presentation/widgets/feed_primitives.dart';
import 'package:starapp/features/home/presentation/widgets/home_icons.dart';
import 'package:starapp/shared/widgets/star_image.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

// "Following" state of the Toggle / Follow component.
const _followingBg = Color(0xFFF1F4F9);
const _followingInk = Color(0xFF59606D);
// Active state of the Toggle / Flag component.
const _flaggedBg = Color(0xFFFEE4E2);

/// A feed post: author row with Follow / bookmark / report toggles, text,
/// optional media and the engagement bar, whose star count toggles the
/// user's star.
///
/// The toggles show [isFollowing] and the post's own star, bookmark and
/// report flags, and report taps through the callbacks; bookmark and report
/// taps also show the design's confirmation toast.
class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    this.isFollowing = false,
    this.onAuthorTap,
    this.onFollow,
    this.onStar,
    this.onBookmark,
    this.onFlag,
  });

  final Post post;
  final bool isFollowing;

  /// Avatar or name tapped (opens the creator's profile).
  final VoidCallback? onAuthorTap;
  final VoidCallback? onFollow;
  final VoidCallback? onStar;
  final VoidCallback? onBookmark;
  final VoidCallback? onFlag;

  bool get isBookmarked => post.isBookmarked;

  /// Reported by the user.
  bool get isFlagged => post.isReported;

  void _toggleBookmark(BuildContext context) {
    if (onBookmark == null) return;
    onBookmark!();
    showStarToast(
      context,
      isBookmarked ? 'Removed from bookmarks' : 'Saved to your bookmarks',
    );
  }

  void _toggleFlag(BuildContext context) {
    if (onFlag == null) return;
    onFlag!();
    showStarToast(
      context,
      isFlagged
          ? 'Report withdrawn'
          : 'Reported · our team will review this request',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.borderDefault, width: 1.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _AuthorBlock(post: post, onTap: onAuthorTap),
              ),
              const SizedBox(width: 8),
              _FollowButton(
                isFollowing: isFollowing,
                onTap: () => onFollow?.call(),
              ),
              const SizedBox(width: 4),
              _RoundToggle(
                tooltip: isBookmarked ? 'Remove bookmark' : 'Bookmark',
                asset: isBookmarked
                    ? HomeIcons.bookmarkFilled
                    : HomeIcons.bookmarkOutline,
                selected: isBookmarked,
                onTap: () => _toggleBookmark(context),
              ),
              const SizedBox(width: 4),
              _RoundToggle(
                tooltip: isFlagged ? 'Withdraw report' : 'Report',
                asset: isFlagged ? HomeIcons.flagFilled : HomeIcons.flagFill,
                selected: isFlagged,
                background: isFlagged ? _flaggedBg : AppColors.brandNavy,
                onTap: () => _toggleFlag(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            post.text,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              height: 1.321,
              letterSpacing: 0,
              color: Colors.black,
            ),
          ),
          if (post.mediaUrls.length == 1) ...[
            const SizedBox(height: 16),
            StarImage(
              post.mediaUrls.first,
              width: double.infinity,
              height: 274,
              borderRadius: BorderRadius.circular(5),
            ),
          ] else if (post.mediaUrls.isNotEmpty) ...[
            const SizedBox(height: 16),
            _MediaGallery(media: post.mediaUrls, total: post.mediaCount),
          ],
          const SizedBox(height: 16),
          _EngagementBar(post: post, onStar: onStar),
        ],
      ),
    );
  }
}

class _AuthorBlock extends StatelessWidget {
  const _AuthorBlock({required this.post, this.onTap});

  final Post post;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final author = post.author;

    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RoundAvatar(
              url: author.avatarUrl,
              size: 34,
              ringWidth: post.authorHasStory ? 1.5 : 0,
              ringGap: post.authorHasStory ? 1.5 : 0,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    // Name and badges hang from the top, as in the design.
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          author.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            height: 10 / 11,
                            letterSpacing: 0,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      // Creators carry a tier; fans don't.
                      if (author.tier != null) ...[
                        const SizedBox(width: 3),
                        SvgPicture.asset(
                          HomeIcons.creatorBadge,
                          width: 10,
                          height: 9,
                        ),
                      ],
                      if (author.isVerified) ...[
                        const SizedBox(width: 3),
                        SvgPicture.asset(
                          HomeIcons.verified,
                          width: 12,
                          height: 12,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(HomeIcons.world, width: 7, height: 7),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          'Posted ${formatPostedAt(post.createdAt)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 9,
                            height: 10 / 9,
                            letterSpacing: 0,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Toggle / Follow: outlined "Follow" ⇄ muted "Following".
class _FollowButton extends StatelessWidget {
  const _FollowButton({required this.isFollowing, required this.onTap});

  final bool isFollowing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ink = isFollowing ? _followingInk : AppColors.brandNavy;

    return Semantics(
      button: true,
      toggled: isFollowing,
      child: Material(
        color: isFollowing ? _followingBg : Colors.transparent,
        shape: StadiumBorder(
          side: isFollowing
              ? BorderSide.none
              : const BorderSide(color: AppColors.brandNavy),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          // 13px side padding gives the design's 71 / 85px widths in Inter.
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: isFollowing ? 85 : 71,
              minHeight: 20,
              maxHeight: 20,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 13),
                SizedBox.square(
                  dimension: 10,
                  child: Padding(
                    // Icon inset inside its 10px frame, per the design.
                    padding: const EdgeInsets.fromLTRB(
                      1.25,
                      0.833,
                      0.365,
                      0.078,
                    ),
                    child: SvgPicture.asset(
                      isFollowing
                          ? HomeIcons.userFollowing
                          : HomeIcons.userFollow,
                      width: 8.38519,
                      height: 9.08917,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  isFollowing ? 'Following' : 'Follow',
                  style: TextStyle(
                    fontSize: 10,
                    height: 1,
                    letterSpacing: 0,
                    color: ink,
                  ),
                ),
                const SizedBox(width: 13),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 20px round bookmark / report toggle.
class _RoundToggle extends StatelessWidget {
  const _RoundToggle({
    required this.tooltip,
    required this.asset,
    required this.selected,
    required this.onTap,
    this.background = AppColors.brandNavy,
  });

  final String tooltip;
  final String asset;
  final bool selected;
  final VoidCallback onTap;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        toggled: selected,
        child: Material(
          color: background,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox.square(
              dimension: 20,
              child: Center(
                child: SvgPicture.asset(asset, width: 12, height: 12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Up to three thumbnails, then a tilted "+N more" pile when there's more media.
class _MediaGallery extends StatelessWidget {
  const _MediaGallery({required this.media, required this.total});

  final List<String> media;
  final int total;

  static const _thumbW = 75.0;
  static const _thumbH = 99.0;
  static const _tilt = -7 * math.pi / 180;

  // Bounding box of a thumbnail rotated by [_tilt].
  static const _pileW = 86.506;
  static const _pileH = 107.402;

  Widget _thumb(String url) => StarImage(
    url,
    width: _thumbW,
    height: _thumbH,
    borderRadius: BorderRadius.circular(5),
  );

  @override
  Widget build(BuildContext context) {
    final count = math.max(total, media.length);
    final hasPile = count > 4 && media.length >= 4;
    final plain = media.take(hasPile ? 3 : 4).toList();

    final children = <Widget>[
      for (final image in plain) _thumb(image),
      if (hasPile)
        SizedBox(
          width: _pileW,
          height: _pileH,
          child: Stack(
            children: [
              Positioned.fill(
                child: Center(
                  child: Transform.rotate(
                    angle: _tilt,
                    child: _thumb(media.length > 4 ? media[4] : media[3]),
                  ),
                ),
              ),
              Positioned(
                left: 5.73,
                top: 4.44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _thumb(media[3]),
                    Container(
                      width: _thumbW,
                      height: _thumbH,
                      decoration: BoxDecoration(
                        color: const Color(0xA3000000),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // The "29" tucks 2px into the plus icon's frame.
                        SizedBox(
                          width: 17.083,
                          height: 19.083,
                          child: OverflowBox(
                            alignment: Alignment.centerLeft,
                            maxWidth: 19.083,
                            child: SvgPicture.asset(
                              HomeIcons.addRoundedWhite,
                              width: 19.083,
                              height: 19.083,
                            ),
                          ),
                        ),
                        Text(
                          '${count - 3}',
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.0911,
                            letterSpacing: 0,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    ];

    // The pile is designed to run a few px into the card's padding.
    return SizedBox(
      height: hasPile ? _pileH : _thumbH,
      child: OverflowBox(
        alignment: Alignment.centerLeft,
        minWidth: 0,
        maxWidth: double.infinity,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

class _EngagementBar extends StatelessWidget {
  const _EngagementBar({required this.post, this.onStar});

  final Post post;
  final VoidCallback? onStar;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderDefault, width: 1.05),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Tooltip(
            message: post.isStarred ? 'Remove star' : 'Star',
            child: Semantics(
              button: true,
              toggled: post.isStarred,
              child: GestureDetector(
                onTap: onStar,
                behavior: HitTestBehavior.opaque,
                child: _Stat(
                  icon: post.isStarred ? HomeIcons.starFilled : HomeIcons.star,
                  value: post.stars,
                ),
              ),
            ),
          ),
          _Stat(icon: HomeIcons.comment, value: post.comments),
          _Stat(icon: HomeIcons.repost, value: post.reposts),
          Container(
            width: 1.05,
            height: 27,
            decoration: BoxDecoration(
              color: AppColors.borderDefault,
              borderRadius: BorderRadius.circular(17),
            ),
          ),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Flexible(
                  child: Text(
                    'Starred by',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _Stat.style,
                  ),
                ),
                const SizedBox(width: 3),
                AvatarPile(
                  avatarUrls: [for (final c in post.starredBy) c.avatarUrl],
                  showMore: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value});

  final String icon;
  final int value;

  static const style = TextStyle(
    fontSize: 11,
    height: feedLeading,
    letterSpacing: 0,
    fontWeight: FontWeight.w500,
    color: AppColors.voidBlack,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(icon, width: 16, height: 16),
        const SizedBox(width: 4),
        Text(value.compact, style: style),
      ],
    );
  }
}
