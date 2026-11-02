import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';

// Shared look of the full-screen celebrations (Winners Announcement and
// Tier Level-Up).

abstract final class CelebrationColors {
  static const textSecondary = Color(0xFF59606D); // text/secondary/59606d
  static const borderSoft = Color(0xFFD5DCEA); // border/default/d5dcea
  static const brandWash = Color(0x12032886); // 032886 @ 7%
  static const brandWashSoft = Color(0x0F032886); // 032886 @ 6%
  static const goldLight = AppColors.goldLight;
  static const goldDeep = AppColors.goldDeep;
  static const goldGlow = Color(0x47E7A91A); // e7a91a @ 28%
  static const violet = Color(0xFF8B5CF6);
}

abstract final class CelebrationAssets {
  static const _dir = 'assets/vectors/challenges';

  static const close = '$_dir/tier_ic_close.svg';
  static const share = '$_dir/tier_ic_share.svg';
}

/// White → brand tint page background (gradient/light/ffffff → eaf0fe).
const celebrationBackground = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.white, AppColors.brandTint, AppColors.brandTint],
    stops: [0, 0.55, 1],
  ),
);

/// The gold sheen used on prize cards, pills and the gold buttons.
const celebrationGold = CornerGradient(
  colors: [
    CelebrationColors.goldLight,
    AppColors.gold,
    CelebrationColors.goldDeep,
  ],
  stops: [0, 0.45, 1],
);

/// Top-left → bottom-right gradient laid out like Figma's: the colour bands
/// run parallel to the other diagonal, whatever the box's aspect ratio.
/// (A plain topLeft → bottomRight [LinearGradient] tilts the bands on wide
/// boxes, so a 345×48 button would read almost horizontal.)
class CornerGradient extends LinearGradient {
  const CornerGradient({required super.colors, super.stops});

  @override
  Shader createShader(Rect rect, {TextDirection? textDirection}) {
    final w = rect.width;
    final h = rect.height;
    final d2 = w * w + h * h;
    if (d2 == 0) return super.createShader(rect, textDirection: textDirection);
    final ax = 2 * h * h / d2;
    final ay = 2 * w * w / d2;
    return LinearGradient(
      begin: Alignment(-ax, -ay),
      end: Alignment(ax, ay),
      colors: colors,
      stops: stops,
    ).createShader(rect, textDirection: textDirection);
  }
}
