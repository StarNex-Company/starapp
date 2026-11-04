import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';

/// Inter's "normal" line height, so text boxes match the design.
const messagesLeading = 1.21;

abstract final class MessagesIcons {
  static const _dir = 'assets/vectors/messages';

  static const edit = '$_dir/msg_ic_edit.svg';
  static const chevronBrand = '$_dir/msg_ic_chevron_brand.svg';
  static const starAppLogo = '$_dir/msg_starapp_logo.svg';
  static const briefcaseGold = '$_dir/msg_ic_briefcase_gold.svg';
  static const briefcasePill = '$_dir/msg_ic_briefcase_pill.svg';
  static const fileRed = '$_dir/msg_ic_file_red.svg';
  static const file = 'assets/vectors/shared/ic_file.svg';
  static const idCard = '$_dir/msg_ic_idcard.svg';
  static const flag = '$_dir/msg_ic_flag.svg';
  static const plus = '$_dir/msg_ic_plus.svg';

  // Identical files already bundled by other screens.
  static const search = 'assets/vectors/profile/connections_ic_search.svg';
  static const more = 'assets/vectors/shared/ic_more.svg';
  static const send = 'assets/vectors/shared/ic_send.svg';
  static const image = 'assets/vectors/challenges/upcoming_ic_image.svg';
  static const briefcase = 'assets/vectors/settings/privacy_ic_briefcase.svg';
  static const slash = 'assets/vectors/settings/privacy_ic_slash.svg';
  static const chevron = 'assets/vectors/shared/share_chevron.svg';
  static const chevronDanger =
      'assets/vectors/shared/ic_chevron_danger.svg';
  static const ring = 'assets/vectors/shared/avatar_ring.svg';
  static const ringGap = 'assets/vectors/shared/avatar_ring_gap.svg';
}

abstract final class MessagesColors {
  /// surface/muted/eef0f5: segmented track, day pill.
  static const track = Color(0xFFEEF0F5);


  /// surface/muted/f1f3f8: incoming bubble.
  static const bubbleIn = Color(0xFFF1F3F8);

  /// background/screen/fafbfd: behind a thread's messages.
  static const thread = Color(0xFFFAFBFD);

  /// surface/tint/fff3cc: offer pill and proposal tile.
  static const goldTint = Color(0xFFFFF3CC);

  /// Proposal bar outline: gold @ 70%.
  static const goldOutline = Color(0xB3F5C451);

  /// "Pending your response".
  static const pending = Color(0xFFB45309);

  /// "Active now", "Accepted".
  static const online = Color(0xFF15803D);

  /// Requests banner outline: brand @ 15%.
  static const bannerOutline = Color(0x26032886);

  /// text/body/3a4255: document preview paragraphs.
  static const previewBody = Color(0xFF3A4255);

  /// Failed-send note on a navy bubble.
  static const failedOnBrand = Color(0xFFFCA5A5);

  static const cardShadow = BoxShadow(
    color: Color(0x0F0B1020),
    offset: Offset(0, 4),
    blurRadius: 9,
  );

  static const buttonShadow = BoxShadow(
    color: Color(0x2E032886),
    offset: Offset(0, 6),
    blurRadius: 8,
  );

  /// Logo placeholders for companies without a logo, picked by id.
  static const companyGradients = [
    [Color(0xFFEC4899), Color(0xFF7C5CFF)],
    [Color(0xFF14B8A6), Color(0xFF3BA7FF)],
    [Color(0xFF7C5CFF), Color(0xFF3BA7FF)],
    [Color(0xFFF59E0B), Color(0xFFEF4444)],
  ];
}

/// `TextStyle` with the design's defaults: Inter's normal leading and no
/// letter spacing.
TextStyle messagesText(
  double size, {
  FontWeight weight = FontWeight.w400,
  Color color = AppColors.ink,
  double height = messagesLeading,
}) => TextStyle(
  fontSize: size,
  height: height,
  letterSpacing: 0,
  fontWeight: weight,
  color: color,
);
