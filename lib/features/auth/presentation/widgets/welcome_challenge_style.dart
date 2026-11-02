import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';

/// Assets, colours and text styles of the Welcome Challenge screen (Figma
/// "Welcome Challenge — 1 Intro / 2 Revealed / 3 Idle", Completion Pass).
abstract final class WelcomeChallengeAssets {
  /// 118px star; the file's 178.2×173.4 canvas keeps a 30.1px margin for the
  /// glow, which flutter_svg can't render, so the stage paints it in code.
  static const heroStar = 'assets/vectors/auth_welcome_challenge_hero_star.svg';

  /// "✦" outlined from the Figma export (Inter has no U+2726, so the design
  /// shows a fallback glyph). 16.9px for a 22px font size.
  static const sparkle = 'assets/vectors/auth_welcome_challenge_sparkle.svg';
  static const trophy =
      'assets/vectors/auth_welcome_challenge_trophy.svg'; // 26, #2A1C00
  static const arrowRight =
      'assets/vectors/auth_welcome_challenge_arrow_right.svg'; // 18, white
}

/// Colours that aren't in [AppColors].
abstract final class WelcomeChallengeColors {
  static const backgroundStart = Color(0xFF0B46C5);
  static const backgroundEnd = Color(0xFF010F3D);
  static const planetBlue = Color(0xFF8FB4FF);
  static const goldInk = Color(0xFF2A1C00); // chip "+50 ★", challenge title
  static const goldLabel = Color(0xFF8A5A00); // "YOUR WELCOME CHALLENGE"
  static const goldBody = Color(0xFF6B4A00); // "Earn +50 Stars…"
  static const tileStart = Color(0xFFFFF6DC);
  static const tileEnd = Color(0xFFFFE9A8);
  static const stepTint = Color(0xFFDAE4FF); // surface/brand-tint/dae4ff
  static const stepArrow = Color(0xFF9AA6C2);
  static const glassFill = Color(0x24FFFFFF); // white @ 14%
  static const glassStroke = Color(0x40FFFFFF); // white @ 25%
}

/// Text styles of the screen. Every style sets `height` and `letterSpacing: 0`.
abstract final class WelcomeChallengeText {
  static const _inter = 'Inter';

  /// Glass chip label: 12 Bold, white (15 high).
  static const chip = TextStyle(
    fontFamily: _inter,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 15 / 12,
    letterSpacing: 0,
    color: Colors.white,
  );

  /// Card title: 24 Bold, line height 30, black.
  static const title = TextStyle(
    fontFamily: _inter,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 30 / 24,
    letterSpacing: 0,
    color: Colors.black,
  );

  /// Card subtitle: 14 Medium, line height 21, #7D7D7D.
  static const subtitle = TextStyle(
    fontFamily: _inter,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 21 / 14,
    letterSpacing: 0,
    color: AppColors.textSecondary,
  );

  /// "YOUR WELCOME CHALLENGE": 10 ExtraBold #8A5A00 (12 high).
  static const tileLabel = TextStyle(
    fontFamily: _inter,
    fontSize: 10,
    fontWeight: FontWeight.w800,
    height: 12 / 10,
    letterSpacing: 0,
    color: WelcomeChallengeColors.goldLabel,
  );

  /// Challenge title: 15 Bold, line height 20, #2A1C00.
  static const tileTitle = TextStyle(
    fontFamily: _inter,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 20 / 15,
    letterSpacing: 0,
    color: WelcomeChallengeColors.goldInk,
  );

  /// Challenge reward: 12 Medium #6B4A00 (15 high).
  static const tileBody = TextStyle(
    fontFamily: _inter,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 15 / 12,
    letterSpacing: 0,
    color: WelcomeChallengeColors.goldBody,
  );

  /// Step number: 10 Bold white (12 high).
  static const stepNumber = TextStyle(
    fontFamily: _inter,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 12 / 10,
    letterSpacing: 0,
    color: Colors.white,
  );

  /// Step label: 12 SemiBold #001F6E (15 high).
  static const stepLabel = TextStyle(
    fontFamily: _inter,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 15 / 12,
    letterSpacing: 0,
    color: AppColors.brandNavy,
  );

  /// Arrow between steps: 12 Bold #9AA6C2 (15 high).
  static const stepArrow = TextStyle(
    fontFamily: _inter,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 15 / 12,
    letterSpacing: 0,
    color: WelcomeChallengeColors.stepArrow,
  );

  /// Primary button label: 16 Bold white (19 high).
  static const button = TextStyle(
    fontFamily: _inter,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 19 / 16,
    letterSpacing: 0,
    color: Colors.white,
  );

  /// "Skip for now": 14 SemiBold #7D7D7D (17 high).
  static const skip = TextStyle(
    fontFamily: _inter,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 17 / 14,
    letterSpacing: 0,
    color: AppColors.textSecondary,
  );
}

/// The design's diagonal fill (Figma gradient transform
/// `[[0.4, 0.9, 0], [-0.9, 0.4, 0.5]]`, used by the screen background, the
/// challenge tile and its badge) for a box of [size].
///
/// Figma defines the gradient in the box's normalised space, so its handles
/// depend on the aspect ratio: it starts at the top-left corner and its colour
/// lines stay perpendicular to (0.4 / width, 0.9 / height).
LinearGradient welcomeChallengeDiagonalGradient(
  Size size, {
  required List<Color> colors,
  List<double>? stops,
}) {
  if (size.isEmpty) return LinearGradient(colors: colors, stops: stops);
  final gx = 0.4 / size.width;
  final gy = 0.9 / size.height;
  final k = 1 / (gx * gx + gy * gy);
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment(2 * gx * k / size.width - 1, 2 * gy * k / size.height - 1),
    colors: colors,
    stops: stops,
  );
}
