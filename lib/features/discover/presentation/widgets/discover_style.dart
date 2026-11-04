import 'package:flutter/material.dart';

// Inter's "normal" line height, so text boxes match the design.
const discoverLeading = 1.21;

/// Discover colours that have no `AppColors` token yet.
abstract final class DiscoverColors {
  static const brand = Color(0xFF042987); // text|surface/brand/042987
  static const searchHint = Color(0xFF5D5D5D); // text/secondary/5d5d5d
  static const body = Color(0xFF444652); // text/body/444652
  static const heading = Color(0xFF191C1E); // text/body/191c1e
  static const addStoryRing = Color(0xFFE6E8EA); // surface/muted/e6e8ea
  static const seenStoryRing = Color(0xFFE0E3E5); // surface/muted/e0e3e5
  static const starGold = Color(0xFFF3B936); // star-gold
  static const cardBorder = Color(0x4DC5C5D4); // c5c5d4 @ 30%
  static const followingBg = Color(0xFFF1F4F9);
  static const followingText = Color(0xFF59606D);

  // Featured challenge banners.
  static const arenaGoldBg = Color(0xFF362702);
  static const arenaNavyBg = Color(0xFF101E39);
  static const arenaPill = Color(0x8AF4A202); // f4a202 @ 54%
  static const arenaPillText = Color(0xFFFFF2D4);
  static const arenaMuted = Color(0xFFB9C6E9);
  static const enterText = Color(0xFF271900);
  static const glass10 = Color(0x1AFFFFFF);
  static const glass15 = Color(0x26FFFFFF);
}

/// Card shadow used by the pills, story badges and creator cards.
const discoverHairShadow = [
  BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 1),
];

abstract final class DiscoverIcons {
  static const _dir = 'assets/vectors/discover';

  static const logo = 'assets/vectors/shared/logo.svg';
  static const filter = 'assets/vectors/shared/ic_filters.svg';
  static const search = 'assets/vectors/shared/ic_search.svg';
  static const follow = 'assets/vectors/shared/ic_follow.svg';
  static const dismiss = 'assets/vectors/shared/ic_dismiss.svg';
  static const avatarRing = 'assets/vectors/shared/avatar_ring.svg';
  static const avatarRingGap = 'assets/vectors/shared/avatar_ring_gap.svg';

  static const storyAdd = '$_dir/story_badge_add.svg';
  static const storyStar = '$_dir/story_badge_star.svg';
  static const storyDance = '$_dir/story_badge_dance.svg';
  static const storyTrophy = '$_dir/story_badge_trophy.svg';
  static const storyMic = '$_dir/story_badge_mic.svg';

  static const chipAll = '$_dir/chip_all.svg';
  static const chipMusic = '$_dir/chip_music.svg';
  static const chipDance = '$_dir/chip_dance.svg';
  static const chipVisualArts = '$_dir/chip_visual_arts.svg';
  static const chipActing = '$_dir/chip_acting.svg';
  static const chipFashion = '$_dir/chip_fashion.svg';
  static const chipSports = '$_dir/chip_sports.svg';

  /// The pill icon for a category id; null for categories the app has no
  /// icon for yet, which show their name alone.
  static String? category(String id) => switch (id) {
    'music' => chipMusic,
    'dance' => chipDance,
    'visual-arts' => chipVisualArts,
    'acting' => chipActing,
    'fashion' => chipFashion,
    'sports' => chipSports,
    _ => null,
  };

  static const arenaLight = '$_dir/challenge_ic_arena_light.svg';
  static const arenaGold = '$_dir/challenge_ic_arena_gold.svg';
  static const clock = '$_dir/challenge_ic_clock.svg';
  static const prize = '$_dir/challenge_ic_prize.svg';
  static const submissions = '$_dir/challenge_ic_submissions.svg';
  static const enter = '$_dir/challenge_ic_enter.svg';

  static const verified = '$_dir/video_ic_verified.svg';
  static const bookmark = '$_dir/video_ic_bookmark.svg';
  static const bookmarkFill = '$_dir/video_ic_bookmark_fill.svg';
}

/// Inter text style with the design's leading and no Material tracking.
TextStyle discoverText(
  double size,
  FontWeight weight,
  Color color, {
  double? lineHeight,
  double letterSpacing = 0,
}) {
  return TextStyle(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: lineHeight == null ? discoverLeading : lineHeight / size,
    letterSpacing: letterSpacing,
  );
}
