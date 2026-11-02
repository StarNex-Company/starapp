import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/home/data/models/story.dart';
import 'package:starapp/features/home/presentation/widgets/feed_primitives.dart';
import 'package:starapp/features/home/presentation/widgets/home_icons.dart';
import 'package:starapp/shared/widgets/star_image.dart';

const _cardWidth = 104.0;
const _cardHeight = 157.0;
const _avatarSize = 39.0;

class StoryStrip extends StatelessWidget {
  const StoryStrip({
    super.key,
    required this.userAvatarUrl,
    required this.stories,
    this.onAddStory,
    this.onStoryTap,
    this.onViewAll,
  });

  /// The signed-in user's photo; null shows the placeholder.
  final String? userAvatarUrl;
  final List<Story> stories;
  final VoidCallback? onAddStory;
  final ValueChanged<Story>? onStoryTap;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _cardHeight + 10,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
        itemCount: stories.length + 2,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (context, i) {
          if (i == 0) {
            return _YourStoryCard(avatarUrl: userAvatarUrl, onTap: onAddStory);
          }
          if (i > stories.length) return _ViewAllCard(onTap: onViewAll);
          final story = stories[i - 1];
          return _StoryCard(
            story: story,
            onTap: onStoryTap == null ? null : () => onStoryTap!(story),
          );
        },
      ),
    );
  }
}

class _YourStoryCard extends StatelessWidget {
  const _YourStoryCard({required this.avatarUrl, this.onTap});

  final String? avatarUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: _cardWidth,
        height: _cardHeight,
        child: Stack(
          children: [
            Image.asset(
              'assets/images/home/story_you.png',
              width: _cardWidth,
              height: _cardHeight,
              fit: BoxFit.fill,
            ),
            RoundAvatar(url: avatarUrl, size: _avatarSize),
            Positioned(
              left: 0,
              right: 0,
              top: 59,
              child: Column(
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.lunarWhite,
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      HomeIcons.cardsStarOutline,
                      width: 23,
                      height: 23,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your story',
                    style: TextStyle(
                      fontSize: 12,
                      height: feedLeading,
                      letterSpacing: 0,
                      color: AppColors.lunarWhite,
                    ),
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

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.story, this.onTap});

  final Story story;
  final VoidCallback? onTap;

  static const _caption = TextStyle(
    fontSize: 8,
    height: 1.25,
    letterSpacing: 0,
    color: AppColors.lunarWhite,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: _cardWidth,
        height: _cardHeight,
        child: Stack(
          children: [
            ClipPath(
              clipper: const _NotchedCardClipper(),
              child: StarImage(
                story.coverUrl,
                width: _cardWidth,
                height: _cardHeight,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 72,
              child: Container(
                padding: const EdgeInsets.fromLTRB(7, 8, 0, 6),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(6),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black, Color(0x00999999)],
                    stops: [0.21528, 0.89583],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 77),
                          child: Text(
                            story.creator.name,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            style: _caption.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (story.creator.isVerified) ...[
                          const SizedBox(width: 1),
                          SvgPicture.asset(
                            HomeIcons.verifiedLight,
                            width: 10,
                            height: 10,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${story.followers.compact} Followers',
                      style: _caption,
                    ),
                  ],
                ),
              ),
            ),
            RoundAvatar(
              url: story.creator.avatarUrl,
              size: _avatarSize,
              ringWidth: 2,
              ringGap: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewAllCard extends StatelessWidget {
  const _ViewAllCard({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Trailing 24px matches the design's extra end inset after the last card.
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: FeedViewAllCard(
        background: HomeIcons.storyViewAllBg,
        height: _cardHeight,
        labelTop: 72,
        onTap: onTap,
      ),
    );
  }
}

/// The story card's outline: rounded corners, with a notch cut from the top
/// left where the creator's avatar sits.
class _NotchedCardClipper extends CustomClipper<Path> {
  const _NotchedCardClipper();

  /// Corner radius.
  static const _r = 6.0;

  /// Size of the square notch, and the radius of its inner corner.
  static const _notch = 41.5;
  static const _fillet = 18.0;

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    const corner = Radius.circular(_r);
    return Path()
      ..moveTo(_notch + _r, 0)
      ..lineTo(w - _r, 0)
      ..arcToPoint(Offset(w, _r), radius: corner)
      ..lineTo(w, h - _r)
      ..arcToPoint(Offset(w - _r, h), radius: corner)
      ..lineTo(_r, h)
      ..arcToPoint(Offset(0, h - _r), radius: corner)
      ..lineTo(0, _notch + _r)
      ..arcToPoint(const Offset(_r, _notch), radius: corner)
      ..lineTo(_notch - _fillet, _notch)
      ..arcToPoint(
        const Offset(_notch, _notch - _fillet),
        radius: const Radius.circular(_fillet),
        clockwise: false,
      )
      ..lineTo(_notch, _r)
      ..arcToPoint(const Offset(_notch + _r, 0), radius: corner)
      ..close();
  }

  @override
  bool shouldReclip(_NotchedCardClipper oldClipper) => false;
}
