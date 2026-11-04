import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:starapp/core/models/creator_tier.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/profile/data/models/creator_profile.dart';

/// Inter's "normal" line height, so text boxes match the design.
const creatorLeading = 1.21;

abstract final class CreatorIcons {
  static const _dir = 'assets/vectors/profile';

  static const share = '$_dir/creator_ic_share.svg';
  static const storyRing = '$_dir/creator_story_ring.svg';
  static const starStruck = 'assets/vectors/shared/ic_star_struck.svg';
  static const verified = '$_dir/creator_ic_verified.svg';
  static const coFounder = '$_dir/creator_ic_cofounder.svg';
  static const userPlus = '$_dir/creator_ic_user_plus.svg';
  static const userCheck = '$_dir/creator_ic_user_check.svg';

  /// Gold 18px trophy and chevron on the challenge banner.
  static const trophy = '$_dir/creator_ic_trophy.svg';
  static const chevronGold = '$_dir/creator_ic_chevron_gold.svg';

  /// Gold 20px trophy in the Challenges tab's icon tiles.
  static const trophyTile = 'assets/vectors/shared/ic_trophy_tile.svg';

  /// Identical files already in assets.
  static const play = 'assets/vectors/challenges/detail_ic_play_small.svg';
  static const entryTrophy = 'assets/vectors/create/uploading_ic_trophy.svg';
  static const chevronBrand = 'assets/vectors/shared/share_chevron.svg';
}

abstract final class CreatorColors {
  /// "Following" button fill.
  static const followingFill = Color(0xFFF1F4F9);

  /// text/secondary/59606d — "Following" label.
  static const followingInk = Color(0xFF59606D);

  /// rgba(3, 40, 134, 0.18) — "Follow" button shadow.
  static const followShadow = Color(0x2E032886);

  /// rgba(10, 26, 74, 0.18) — tier pill and photo shadow.
  static const softShadow = Color(0x2E0A1A4A);

  /// surface/tint/fff8e1 — challenge banner.
  static const bannerFill = Color(0xFFFFF8E1);

  /// rgba(245, 196, 81, 0.6) — challenge banner outline.
  static const bannerBorder = Color(0x99F5C451);

  /// surface/tint/fff3cc — Challenges tab icon tiles and pills.
  static const goldTint = Color(0xFFFFF3CC);

  /// rgba(7, 9, 13, 0.7) — bottom of a thumbnail's scrim.
  static const thumbScrim = Color(0xB307090D);

  /// border/default/e9edf5 — Stats tab cards.
  static const statCardBorder = Color(0xFFE9EDF5);

  /// text/secondary/6b7385 — Stats tab card labels.
  static const statLabel = Color(0xFF6B7385);

  /// Stats tab card notes ("+18%").
  static const statNote = Color(0xFF15803D);
}

/// The tier star's 135° fill on the photo.
LinearGradient creatorTierGradient(CreatorTier tier) {
  final (start, end) = switch (tier) {
    CreatorTier.shootingStar => (
      const Color(0xFF9CA3AF),
      const Color(0xFF70757E),
    ),
    CreatorTier.risingNova => (
      const Color(0xFF60A5FA),
      const Color(0xFF4577B4),
    ),
    CreatorTier.stellar => (const Color(0xFF8B5CF6), const Color(0xFF6442B1)),
    CreatorTier.superNova => (const Color(0xFFF59E0B), const Color(0xFFB07208)),
    // Not designed for another creator; pink, like its connection-list ring.
    CreatorTier.universeIcon => (
      const Color(0xFFEC4899),
      const Color(0xFFA8326C),
    ),
  };
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: const [0, 0.714],
    colors: [start, end],
  );
}

/// How a challenge entry reads on the profile.
extension CreatorChallengeText on CreatorChallengeEntry {
  /// Challenges tab row, e.g. "Sep 2026 · finished #4 of 1,248".
  String get subtitle {
    final month = DateFormat('MMM y').format(date);
    final detail = switch (status) {
      CreatorChallengeStatus.upcoming =>
        'opens ${DateFormat('MMM d').format(date)}',
      CreatorChallengeStatus.live => switch (rank) {
        final rank? => 'currently #$rank$_ofEntrants',
        null => 'entry submitted',
      },
      CreatorChallengeStatus.finished when isWin =>
        prize == null ? 'winner' : 'winner · ${prize!.format()} prize',
      CreatorChallengeStatus.finished => switch (rank) {
        final rank? => 'finished #$rank$_ofEntrants',
        null => 'completed',
      },
    };
    return '$month · $detail';
  }

  /// Gold pill on the row, e.g. "Top 10".
  String get badge => switch (status) {
    CreatorChallengeStatus.upcoming => 'Upcoming',
    CreatorChallengeStatus.live => rank == null ? 'Entered' : 'Live',
    CreatorChallengeStatus.finished => switch (rank) {
      null => 'Done',
      1 => 'Winner',
      <= 3 => 'Top 3',
      <= 10 => 'Top 10',
      <= 20 => 'Top 20',
      <= 50 => 'Top 50',
      _ => 'Finished',
    },
  };

  /// The banner under the actions, e.g. "Ranked #4 in Afro-Dance Takeover".
  String get headline => switch (status) {
    CreatorChallengeStatus.upcoming =>
      '$title · opens ${DateFormat('MMM d').format(date)}',
    CreatorChallengeStatus.live =>
      rank == null ? '$title · entry submitted' : 'Ranked #$rank in $title',
    CreatorChallengeStatus.finished when isWin =>
      prize == null ? 'Won $title' : 'Won $title · ${prize!.format()}',
    CreatorChallengeStatus.finished =>
      rank == null ? '$title · completed' : '$title · finished #$rank',
  };

  String get _ofEntrants =>
      entrants == null ? '' : ' of ${formatGrouped(entrants!)}';
}
