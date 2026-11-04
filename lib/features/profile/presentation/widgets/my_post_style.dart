import 'package:flutter/material.dart';

// Colours, icons and helpers for the full-screen "Post — My Video" view and
// its post menu. Colours missing from AppColors live here.

abstract final class MyPostIcons {
  // The player glyphs are the app's video-feed icons (identical files).
  static const _videos = 'assets/vectors/videos';
  static const back = '$_videos/ic_back.svg';
  static const star = '$_videos/ic_star.svg';
  static const starActive = '$_videos/ic_star_active.svg';
  static const comment = '$_videos/ic_comment.svg';
  static const share = '$_videos/ic_share.svg';
  static const save = '$_videos/ic_save.svg';
  static const saveActive = '$_videos/ic_save_active.svg';
  static const verified = '$_videos/ic_verified.svg';
  static const sound = '$_videos/ic_sound.svg';
  static const play = '$_videos/ic_play.svg';
  static const pause = '$_videos/ic_pause.svg';
  static const volume = '$_videos/ic_volume.svg';
  static const volumeOff = '$_videos/ic_volume_off.svg';

  // Post menu.
  static const _profile = 'assets/vectors/profile';
  static const menuInsights = '$_profile/post_ic_trend_up.svg';
  static const menuEdit = '$_profile/post_ic_edit.svg';
  static const menuShare = 'assets/vectors/shared/ic_share.svg';
  static const menuTrash = 'assets/vectors/settings/settings_ic_trash.svg';
  static const menuChevron = 'assets/vectors/shared/share_chevron.svg';
  static const menuChevronDanger =
      'assets/vectors/shared/ic_chevron_danger.svg';
}

/// Rail and back-button circles: 7d7d80 @ 52%.
const myPostGlass = Color(0x857D7D80);

/// Caption hashtag.
const myPostHashtag = Color(0xFFBACDFF);

/// Cobalt avatar ring and verified badge.
const myPostCobaltRing = Color(0xFF3B82F6);
const myPostCobalt = Color(0xFF2563EB);

/// 2424ff @ 55% — the frosted "Insights" pill.
const myPostInsightsFill = Color(0x8C2424FF);

/// Text over the video.
const myPostCaption = Color(0xFFE2E2E2);
const myPostMeta = Color(0xFFD5D5D5);
const myPostChipText = Color(0xFFE5E5E5);
const myPostTimeText = Color(0xFFD4D4D4);

/// Soft shadow the design puts under the name and caption.
const myPostTextShadows = [
  Shadow(color: Color(0x0F000000), offset: Offset(0, 1), blurRadius: 0.5),
  Shadow(color: Color(0x1A000000), offset: Offset(0, 1), blurRadius: 1),
];

/// Inter text style with the line height and tracking pinned. [lineHeight] is
/// in pixels; null means Inter's "normal" leading.
TextStyle myPostText(
  double size, {
  FontWeight weight = FontWeight.w400,
  Color color = Colors.white,
  double? lineHeight,
  double letterSpacing = 0,
  List<Shadow>? shadows,
}) {
  return TextStyle(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: lineHeight == null ? 1.21 : lineHeight / size,
    letterSpacing: letterSpacing,
    shadows: shadows,
  );
}

/// Rail counts as the design writes them: "123", "1098", "30.1k", "1.2M".
String formatMyPostCount(int n) {
  String trim(double v) {
    final s = v.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }

  if (n >= 1000000) return '${trim(n / 1000000)}M';
  if (n >= 10000) return '${trim(n / 1000)}k';
  return '$n';
}
