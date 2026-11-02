import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/core/models/creator_tier.dart';
import 'package:starapp/features/discover/data/models/discover_models.dart';
import 'package:starapp/features/discover/presentation/widgets/discover_style.dart';
import 'package:starapp/shared/widgets/star_image.dart';

const _size = 64.0;

// Unseen-story ring colours (bottom-left → top-right), warmer for higher
// tiers.
const _goldRing = [Color(0xFFFDBF47), Color(0xFF042987), Color(0xFF7D5800)];
const _navyRing = [Color(0xFF001759), Color(0xFFDDE1FF)];
const _skyRing = [Color(0xFF001F6E), Color(0xFF96B4FF)];

List<Color> _ringFor(CreatorTier? tier) => switch (tier) {
  CreatorTier.superNova || CreatorTier.universeIcon => _goldRing,
  CreatorTier.stellar => _navyRing,
  _ => _skyRing,
};

/// The badge icon and its drawn size for why a creator is rising.
(String, Size) _badgeFor(RisingReason reason) => switch (reason) {
  RisingReason.stars => (DiscoverIcons.storyStar, const Size(11.667, 11.083)),
  RisingReason.dance => (DiscoverIcons.storyDance, const Size(9.333, 11.083)),
  RisingReason.challenge => (
    DiscoverIcons.storyTrophy,
    const Size(5.833, 11.667),
  ),
  RisingReason.music => (DiscoverIcons.storyMic, const Size(8.167, 11.083)),
};

/// Full-bleed row of story circles: the user's "Your Audition" add card,
/// then rising creators with their story rings and talent badges.
class RisingCreatorsRail extends StatelessWidget {
  const RisingCreatorsRail({
    super.key,
    required this.userAvatarUrl,
    required this.creators,
    required this.onAddStory,
    required this.onOpenStory,
  });

  /// The signed-in user's photo; null shows the placeholder.
  final String? userAvatarUrl;
  final List<RisingCreator> creators;
  final VoidCallback onAddStory;
  final ValueChanged<RisingCreator> onOpenStory;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: creators.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) => i == 0
            ? _AddStoryCard(photoUrl: userAvatarUrl, onTap: onAddStory)
            : _StoryCircle(
                creator: creators[i - 1],
                onTap: () => onOpenStory(creators[i - 1]),
              ),
      ),
    );
  }
}

class _AddStoryCard extends StatelessWidget {
  const _AddStoryCard({required this.photoUrl, required this.onTap});

  final String? photoUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _RailItem(
      semanticLabel: 'Add to your audition story',
      label: 'Your Audition',
      labelWeight: FontWeight.w600,
      // The design lets this caption run a pixel past the circle on each
      // side rather than truncate it.
      labelOverflow: TextOverflow.visible,
      onTap: onTap,
      circle: Stack(
        children: [
          Container(
            width: _size,
            height: _size,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: DiscoverColors.addStoryRing,
              shape: BoxShape.circle,
              boxShadow: discoverHairShadow,
            ),
            child: ClipOval(
              child: ColoredBox(
                color: Colors.white,
                child: StarAvatar(photoUrl, size: 56),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: DiscoverColors.starGold,
                shape: BoxShape.circle,
                boxShadow: discoverHairShadow,
              ),
              child: SvgPicture.asset(DiscoverIcons.storyAdd),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryCircle extends StatelessWidget {
  const _StoryCircle({required this.creator, required this.onTap});

  final RisingCreator creator;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final person = creator.creator;
    final ring = creator.hasUnseenStory ? _ringFor(person.tier) : null;
    final (badge, badgeSize) = _badgeFor(creator.reason);

    return _RailItem(
      semanticLabel: "${person.name}'s story",
      label: person.name,
      labelWeight: FontWeight.w500,
      onTap: onTap,
      circle: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: _size,
            height: _size,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ring == null ? DiscoverColors.seenStoryRing : null,
              gradient: ring == null
                  ? null
                  : LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: ring,
                    ),
            ),
            child: StarAvatar(person.avatarUrl, size: _size - 4),
          ),
          Positioned(
            right: -2,
            bottom: -4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                boxShadow: discoverHairShadow,
              ),
              child: SvgPicture.asset(
                badge,
                width: badgeSize.width,
                height: badgeSize.height,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 64px circle above a one-line caption, tappable as a whole.
class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.circle,
    required this.label,
    required this.labelWeight,
    this.labelOverflow = TextOverflow.ellipsis,
    required this.semanticLabel,
    required this.onTap,
  });

  final Widget circle;
  final String label;
  final FontWeight labelWeight;
  final TextOverflow labelOverflow;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: _size,
          child: Column(
            spacing: 6,
            children: [
              SizedBox.square(dimension: _size, child: circle),
              Text(
                label,
                maxLines: 1,
                softWrap: false,
                overflow: labelOverflow,
                textAlign: TextAlign.center,
                style: discoverText(
                  10,
                  labelWeight,
                  DiscoverColors.heading,
                  lineHeight: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
