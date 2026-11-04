import 'package:flutter/painting.dart';

/// Inter's "normal" line height, so text boxes match the design.
const myProfileLeading = 1.21;

abstract final class MyProfileIcons {
  static const _dir = 'assets/vectors/profile';

  static const more = 'assets/vectors/shared/ic_more.svg';
  static const starStruck = 'assets/vectors/shared/ic_star_struck.svg';
  static const founderBadge = '$_dir/me_badge_cofounder.svg';
  static const verifiedBadge = '$_dir/me_badge_verified.svg';
  static const edit = '$_dir/me_ic_edit.svg';
  static const share = '$_dir/me_ic_share.svg';
  static const zap = '$_dir/me_ic_zap.svg';
  static const tierWatermark = '$_dir/me_tier_watermark.svg';
  static const music = '$_dir/me_ic_music.svg';
  static const trophy = 'assets/vectors/shared/ic_trophy_tile.svg';

  static const menuShortcuts = '$_dir/me_menu_ic_shortcuts.svg';
  static const menuSettings = '$_dir/me_menu_ic_settings.svg';
  static const menuShare = 'assets/vectors/shared/ic_share.svg';
  static const menuLogOut = '$_dir/me_menu_ic_logout.svg';
  static const menuChevronDanger = 'assets/vectors/shared/ic_chevron_danger.svg';

  // Identical files already in the app.
  static const logo = 'assets/vectors/shared/logo.svg';
  static const play = 'assets/vectors/challenges/detail_ic_play_small.svg';
  static const liveDot = 'assets/vectors/create/camera_rec_dot.svg';
  static const entryTrophy = 'assets/vectors/create/uploading_ic_trophy.svg';
  static const chevron = 'assets/vectors/shared/share_chevron.svg';
  static const chevronMuted =
      'assets/vectors/shared/ic_chevron_muted.svg';
}

abstract final class MyProfileImages {
  /// Shown until the creator sets their own cover.
  static const defaultCover = 'assets/images/profile/me_cover.jpg';
}

/// Colours of the own-profile screens that aren't app tokens yet.
abstract final class MyProfileColors {
  /// text/secondary/6b7385 — handle, stat labels.
  static const textMuted = Color(0xFF6B7385);

  /// text/body/3a4255 — bio.
  static const textBody = Color(0xFF3A4255);

  /// border/default/e9edf5 — stats card, stat dividers.
  static const borderSoft = Color(0xFFE9EDF5);

  /// border/default/e2e6ee — insights (⚡) button.
  static const borderButton = Color(0xFFE2E6EE);

  /// Shortcut tile border.
  static const borderTile = Color(0xFFE8EDF5);

  /// Shortcuts intro copy.
  static const textIntro = Color(0xFF6B7380);

  /// Edit profile button and tier card gradient start.
  static const royalBlue = Color(0xFF0B46C5);

  /// Tier card gradient end.
  static const tierNavy = Color(0xFF021A5E);

  /// Tier star on the avatar.
  static const tierStarLight = Color(0xFF60A5FA);
  static const tierStarDeep = Color(0xFF4577B4);

  /// "★" on the gold tier icon.
  static const tierIconInk = Color(0xFF3A2400);

  /// Tier progress fill end.
  static const progressGlow = Color(0xFFFFE08A);

  /// surface/tint/fff3cc — trophy tiles and "Top 10" pills.
  static const trophyTint = Color(0xFFFFF3CC);

  /// Positive change in the Stats tab.
  static const positive = Color(0xFF15803D);

  /// rgba(10, 26, 74) — base of the soft navy shadows.
  static const shadowNavy = Color(0xFF0A1A4A);
}
