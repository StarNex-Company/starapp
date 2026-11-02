import 'package:flutter/painting.dart';

/// Inter's "normal" line height, so text boxes match the design.
const verificationLeading = 1.21;

abstract final class VerificationIcons {
  static const _dir = 'assets/vectors/verification';

  static const shieldCheck = '$_dir/verification_ic_shield_check.svg';
  static const logoWatermark = '$_dir/verification_logo_watermark.svg';
  static const check = '$_dir/verification_ic_check.svg';
  static const checkSmall = '$_dir/verification_ic_check_small.svg';
  static const idCard = '$_dir/verification_ic_idcard.svg';
  static const lock = '$_dir/verification_ic_lock.svg';
  static const upload = '$_dir/verification_ic_upload.svg';

  /// Same files as the design's, already in the app.
  static const privacyLock = 'assets/vectors/settings/privacy_ic_lock.svg';
  static const submittedShield =
      'assets/vectors/moderation/appeal_submitted_shield_check.svg';
}

/// Colours the design uses that AppColors doesn't have.
abstract final class VerificationColors {
  /// text/success/15803d — met-requirement detail and the "Step 4 of 5" pill.
  static const successText = Color(0xFF15803D);

  /// Ring around the current step's number.
  static const currentRing = Color(0xFFBFD0FF);

  /// 032886 @ 45% — dashed upload outline.
  static const uploadOutline = Color(0x73032886);

  /// 032886 @ 25% — hero card shadow.
  static const heroShadow = Color(0x40032886);
}
