import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/features/auth/presentation/widgets/auth_assets.dart';
import 'package:starapp/features/auth/presentation/widgets/auth_text.dart';

/// Native names of the supported app locales (shown in the language chip).
const Map<String, String> kAuthLanguageNames = {
  'en': 'English',
  'es': 'Español',
  'fr': 'Français',
  'de': 'Deutsch',
  'it': 'Italiano',
  'pt': 'Português',
  'ru': 'Русский',
  'zh': '中文',
  'ja': '日本語',
  'ko': '한국어',
  'ar': 'العربية',
  'hi': 'हिन्दी',
  'bn': 'বাংলা',
  'pa': 'ਪੰਜਾਬੀ',
  'jv': 'Basa Jawa',
  'ms': 'Bahasa Melayu',
  'id': 'Bahasa Indonesia',
  'vi': 'Tiếng Việt',
  'th': 'ไทย',
  'tr': 'Türkçe',
};

/// Native name for [locale] ("English", "Español"…), falling back to English.
String authLanguageName(Locale locale) =>
    kAuthLanguageNames[locale.languageCode] ?? kAuthLanguageNames['en']!;

/// Header language chip: #DEE6FB, radius 8, 10/6 padding, 20px globe + 4px gap
/// + current language (14 Regular #011C64). 32 high (92 wide for "English").
///
/// Shows the app's active locale (`Localizations.localeOf`, i.e. the
/// `localeProvider` choice or the device locale) and rebuilds when it changes.
/// Tapping pushes the existing Language selection screen
/// (`context.push(AppRoutes.language)`) unless [onTap] is given.
class AuthLanguageChip extends StatelessWidget {
  const AuthLanguageChip({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final name = authLanguageName(Localizations.localeOf(context));
    return Semantics(
      button: true,
      label: 'Language: $name',
      excludeSemantics: true,
      child: Material(
        color: AppColors.authChipBg,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap ?? () => context.push(AppRoutes.language),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // tabler:world — 16.5 glyph inset 1.75 in a 20 box.
                SizedBox.square(
                  dimension: 20,
                  child: Center(
                    child: SvgPicture.asset(
                      AuthAssets.globe,
                      width: 16.5,
                      height: 16.5,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(name, style: AuthTextStyles.chip),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
