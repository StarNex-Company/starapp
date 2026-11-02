import 'package:flutter/material.dart';

class AppColors {
  static const Color btnColor = Color(0xFF042C91);
  static const Color goldGradient = Color(0xFFE8A320);
  static const Color glowGradient = Color(0xFF6B5CE7);
  static const Color cosmicGradient = Color(0xFF0A0A1A);
  static const Color textPrimary = Color(0xFF042C91);
  static const Color successColor = Color(0xFF4CAF50);

  // Home feed (Figma STAR-APP tokens)
  static const Color brandNavy = Color(0xFF001F6E);
  static const Color voidBlack = Color(0xFF000207);
  static const Color lunarWhite = Color(0xFFF7F7F8);
  static const Color textSecondary = Color(0xFF7D7D7D);
  static const Color borderDefault = Color(0xFFEFEFEF);
  static const Color surfaceMuted = Color(0xFFF1F1F1);
  static const Color chipInactive = Color(0xFFC5C5C5);
  static const Color avatarFallback = Color(0xFFA8A8A8);
  static const Color tagActing = Color(0xFF9000B1);
  static const Color tagInternship = Color(0xFFB97A00);

  // Create flow & shared chrome (Figma STAR-APP tokens)
  static const Color brandBlue = Color(0xFF032886); // text|border/brand/032886
  static const Color brandGradStart = Color(0xFF011A5E);
  static const Color brandGradEnd = Color(0xFF0A2E8F);
  static const Color ink = Color(0xFF0B1020);
  static const Color iconButtonBg = Color(0xFFEEEEEE); // surface/muted/eeeeee
  static const Color closeButtonBg = Color(0xFFF3F4F6); // surface/muted/f3f4f6
  static const Color textSubtle = Color(0xFF6B7280); // text/secondary/6b7280
  static const Color textFaint = Color(0xFF9CA3AF); // text/secondary/9ca3af
  static const Color borderField = Color(0xFFE6E8EF); // border/default/e6e8ef
  static const Color borderControl = Color(0xFFC7CBD6); // border/default/c7cbd6
  static const Color borderMuted = Color(0xFFD1D5DB); // border/default/d1d5db
  static const Color textBody = Color(0xFF3A3F4B); // text/body/3a3f4b
  static const Color inkDeep = Color(0xFF07090D); // text|icon/primary/07090d
  static const Color scrim = Color(0x8C07090D); // 07090d @ 55%
  static const Color brandTint = Color(0xFFEAF0FE); // surface/brand-tint/eaf0fe
  static const Color brandTintSoft = Color(0xFFF5F8FF); // surface/card/f5f8ff
  static const Color successTint = Color(
    0xFFEAFBF0,
  ); // surface/brand-tint/eafbf0
  static const Color dangerTint = Color(0xFFFEECEC); // surface/tint/feecec
  static const Color gold = Color(0xFFF5C451);
  static const Color goldText = Color(0xFF7A5300);

  // Challenges & celebrations
  static const Color goldLight = Color(0xFFFFF3B0); // gradient/gold light
  static const Color goldDeep = Color(0xFFE7A91A); // gradient/gold deep
  static const Color goldInk = Color(0xFF3D2E00); // text/gold
  static const Color navyLight = Color(0xFF0B2A8F); // gradient/navy light
  static const Color navyDeep = Color(0xFF020C33); // gradient/navy deep
  static const Color silverLight = Color(0xFFF1F5F9); // gradient/light/f1f5f9
  static const Color silver = Color(0xFFCBD5E1); // gradient/tint/cbd5e1
  static const Color bronzeLight = Color(0xFFE9B872);
  static const Color bronze = Color(0xFFB7791F);
  static const Color danger = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color track = Color(0xFFE5E7EB); // surface/muted/e5e7eb
  static const Color onBrandSubtle = Color(0xFFC7D2FE);
  static const Color glass = Color(0x5907090D); // 07090d @ 35%
  static const Color inkOverlay = Color(0x7307090D); // 07090d @ 45%
  static const Color brandOutline = Color(0x66032886); // 032886 @ 40%

  static const LinearGradient brandGradient = LinearGradient(
    colors: [brandGradStart, brandGradEnd],
  );

  // Auth (Figma STAR-APP auth screens). Screen bg = lunarWhite, ink = voidBlack,
  // brand text/links = brandNavy, loading dots = brandBlue.
  static const Color authNavyDeep = Color(
    0xFF00164D,
  ); // button gradient start / stroke
  static const Color authChipBg = Color(
    0xFFDEE6FB,
  ); // surface/brand-tint/dee6fb
  static const Color authChipText = Color(0xFF011C64); // text/brand/011c64
  static const Color authTextSecondary = Color(
    0xFF59606D,
  ); // text/secondary/dust-gray
  static const Color authStepActive = Color(0xFF00993B); // galaxy-green
  static const Color authStepInactive = Color(0x4000993B); // galaxy-green @ 25%
  static const Color authCheckIdle = Color(
    0xFFA3A3A3,
  ); // icon/secondary/a3a3a3 (warning, before red)
  static const Color authError = Color(
    0xFFB10003,
  ); // warning stroke / field error
  static const Color authWelcomeTint = Color(
    0xFFEDF2FF,
  ); // gradient/light/edf2ff
  static const Color authRing = Color(0xFFFEFEFF); // border/default/fefeff

  /// Primary auth button fill and secondary auth button stroke (left → right).
  static const LinearGradient authButtonGradient = LinearGradient(
    colors: [authNavyDeep, brandNavy],
  );

  /// Pressed primary auth button (the component's second variant: reversed).
  static const LinearGradient authButtonGradientPressed = LinearGradient(
    colors: [brandNavy, authNavyDeep],
  );
}

class AppTextStyles {
  // Onboarding
  static const TextStyle onboardingTitle = TextStyle(
    color: Colors.black,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle onboardingSubtitle = TextStyle(
    color: Colors.black87,
    fontSize: 14,
    height: 1.6,
  );
}

class AppTheme {
  static ThemeData get light => ThemeData(
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.btnColor,
      primary: AppColors.btnColor,
    ),
    scaffoldBackgroundColor: Colors.white,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.btnColor,
        foregroundColor: Colors.white,
        elevation: 0,
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
