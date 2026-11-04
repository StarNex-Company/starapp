import 'package:flutter/material.dart';
import 'package:starapp/core/models/creator_tier.dart';

/// Inter's "normal" line height, so text boxes match the design.
const connectionsLeading = 1.21;

abstract final class ConnectionsIcons {
  static const _dir = 'assets/vectors/profile';

  static const search = '$_dir/connections_ic_search.svg';

  /// White 2px gap between the tier ring and the photo.
  static const ringGap = 'assets/vectors/shared/avatar_ring_gap.svg';

  /// The ring round a person's photo, coloured by tier; grey without one.
  static String ring(CreatorTier? tier) => switch (tier) {
    null || CreatorTier.shootingStar => '$_dir/connections_ring_gray.svg',
    CreatorTier.risingNova => 'assets/vectors/shared/avatar_ring.svg',
    CreatorTier.stellar => '$_dir/connections_ring_violet.svg',
    CreatorTier.superNova => '$_dir/connections_ring_amber.svg',
    CreatorTier.universeIcon => '$_dir/connections_ring_pink.svg',
  };
}

abstract final class ConnectionsColors {

  /// surface/muted/e2e5ec — count pill on the unselected segment.
  static const pillMuted = Color(0xFFE2E5EC);

  /// "Following" button fill.
  static const followingFill = Color(0xFFF1F4F9);

  /// rgba(11, 16, 32, 0.08) — selected segment shadow.
  static const segmentShadow = Color(0x140B1020);

  /// rgba(3, 40, 134, 0.18) — "Follow" button shadow.
  static const followShadow = Color(0x2E032886);
}
