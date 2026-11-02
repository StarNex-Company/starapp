import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/providers/locale_provider.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/features/auth/data/models/language_option.dart';
import 'package:starapp/features/auth/data/provider/auth_providers.dart';
import 'package:starapp/features/auth/presentation/widgets/auth_kit.dart';
import 'package:starapp/features/auth/presentation/widgets/auth_sticky_layout.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_toast.dart';
import '../../../../app/localization/app_localizations.dart';

/// Whether the app can switch to a language.
extension on LanguageOption {
  /// The locale is one of `AppLocalizations.supportedLocales` (what
  /// `localeProvider` accepts) and Flutter's Material widgets have
  /// translations for it.
  bool get isAvailable =>
      AppLocalizations.supportedLocales.any(
        (l) => l.languageCode == locale.languageCode,
      ) &&
      GlobalMaterialLocalizations.delegate.isSupported(locale);
}

/// "Choose Your Language" (Figma "Language Selction" `200:262`), pushed from
/// the header language chip (route [AppRoutes.language]).
///
/// Sticky panel with the heading and a search field that filters by native
/// name, English name or region; the list of languages (selected row grey
/// with a green check); and a sticky Cancel / Done bar. Done saves the choice
/// through `localeProvider` and closes; Cancel just closes.
///
/// The design's list comes first, then the app's other locales. Languages the
/// app can't switch to yet (no app locale, e.g. Pidgin, Hausa, Igbo, Yoruba,
/// or no Material translations, e.g. Javanese) are listed but disabled.
///
/// The rows come from `languageOptionsProvider`.
class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends ConsumerState<LanguageSelectionScreen> {
  static const _titleStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 17,
    fontWeight: FontWeight.w500,
    height: 1.21,
    letterSpacing: 0,
    color: AppColors.brandNavy,
  );

  static const _subtitleStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.21,
    letterSpacing: 0,
    color: Color(0xFF5F5F5F), // text/secondary/5f5f5f
  );

  /// Preselected: the saved choice, else the locale the app is showing when
  /// the screen opens.
  Locale? _initialLocale;

  /// Index in the language list of the row the user picked.
  int? _picked;
  String _query = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initialLocale ??=
        ref.read(localeProvider) ?? Localizations.localeOf(context);
  }

  /// Index in [languages] of the selected row: the user's pick, else the row
  /// for the initial locale.
  int _selectedIn(List<LanguageOption> languages) =>
      _picked ?? _indexFor(languages, _initialLocale!);

  /// Row of [languages] for [locale]: same language and region, else the
  /// first available row of that language, else English (USA).
  static int _indexFor(List<LanguageOption> languages, Locale locale) {
    int? sameLanguage;
    for (var i = 0; i < languages.length; i++) {
      final option = languages[i];
      if (!option.isAvailable ||
          option.locale.languageCode != locale.languageCode) {
        continue;
      }
      if (option.locale.countryCode == locale.countryCode) return i;
      sameLanguage ??= i;
    }
    return sameLanguage ??
        languages.indexWhere((o) => o.locale == const Locale('en', 'US'));
  }

  /// Indices of the rows of [languages] matching the search.
  List<int> _filtered(List<LanguageOption> languages) {
    final q = _query.trim().toLowerCase();
    return [
      for (var i = 0; i < languages.length; i++)
        if (q.isEmpty ||
            languages[i].name.toLowerCase().contains(q) ||
            languages[i].englishName.toLowerCase().contains(q) ||
            languages[i].region.toLowerCase().contains(q))
          i,
    ];
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.welcome);
    }
  }

  void _done() {
    final languages = ref.read(languageOptionsProvider).value;
    if (languages != null) {
      ref
          .read(localeProvider.notifier)
          .setLocale(languages[_selectedIn(languages)].locale);
    }
    _close();
  }

  void _select(List<LanguageOption> languages, int index) {
    final option = languages[index];
    if (!option.isAvailable) {
      showStarToast(context, '${option.englishName} is coming soon');
      return;
    }
    setState(() => _picked = index);
  }

  @override
  Widget build(BuildContext context) {
    // Only English and Spanish strings are generated today; fall back to the
    // design's English copy for any other locale.
    final strings = AppLocalizations.of(context);
    final languages = ref.watch(languageOptionsProvider);
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.lunarWhite,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: AuthStickyLayout(
          header: Padding(
            padding: EdgeInsets.only(top: topInset),
            child: AuthStickyPanel(
              children: [
                // 60 high heading block, text centred vertically (the
                // frame's 12px padding leaves the 38px of text 10.5 from the
                // top); it grows with larger text.
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 60),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.5),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 3,
                        children: [
                          Semantics(
                            header: true,
                            child: Text(
                              strings?.chooseYourLanguage ??
                                  'Choose Your Language',
                              style: _titleStyle,
                            ),
                          ),
                          Text(
                            strings?.chooseYourLanguageDescription ??
                                'Select your preferred language for the app '
                                    'experience.',
                            style: _subtitleStyle,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                AuthSearchField(
                  hint: strings?.searchLanguageHint ?? 'Search language...',
                  onChanged: (v) => setState(() => _query = v),
                ),
              ],
            ),
          ),
          body: StarAsyncView(
            value: languages,
            onRetry: () => ref.invalidate(languageOptionsProvider),
            builder: (languages) {
              final rows = _filtered(languages);
              if (rows.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                  child: Text(
                    'No languages match “${_query.trim()}”.',
                    textAlign: TextAlign.center,
                    style: AuthTextStyles.subtitle,
                  ),
                );
              }
              final selected = _selectedIn(languages);
              return ListView.builder(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                // The frame's list starts 5px below the panel and ends 7px
                // above the bar.
                padding: const EdgeInsets.only(top: 5, bottom: 7),
                itemCount: rows.length,
                itemExtent: _LanguageRow.height,
                itemBuilder: (context, i) {
                  final index = rows[i];
                  return _LanguageRow(
                    // Keyed so filtering doesn't move a row's ink to another.
                    key: ValueKey(index),
                    option: languages[index],
                    selected: index == selected,
                    onTap: () => _select(languages, index),
                  );
                },
              );
            },
          ),
          bottomBar: AuthActionBar(
            secondary: AuthSecondaryButton(
              label: strings?.cancel ?? 'Cancel',
              size: AuthButtonSize.compact,
              onPressed: _close,
            ),
            primary: AuthPrimaryButton(
              label: strings?.done ?? 'Done',
              size: AuthButtonSize.compact,
              onPressed: _done,
            ),
          ),
        ),
      ),
    );
  }
}

/// Figma "Language" `208:310`: 50 high, 24px sides; name 14 Regular #000207
/// over region 11 Italic #59606D (1px apart). Selected: #F3F3F3 background
/// and a 26px green check. Unavailable languages are dimmed.
class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    super.key,
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final LanguageOption option;
  final bool selected;
  final VoidCallback onTap;

  static const double height = 50;
  static const String _check = 'assets/vectors/auth_language_check.svg';
  static const Color _selectedBg = Color(0xFFF3F3F3); // surface/muted/f3f3f3

  static const _nameStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.21,
    letterSpacing: 0,
    color: AppColors.voidBlack,
  );

  static const _regionStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    height: 1.21,
    letterSpacing: 0,
    color: AppColors.authTextSecondary,
  );

  @override
  Widget build(BuildContext context) {
    final available = option.isAvailable;
    return Semantics(
      button: true,
      selected: selected,
      enabled: available,
      label:
          '${option.name}, ${option.region}'
          '${available ? '' : ', not available yet'}',
      excludeSemantics: true,
      child: Material(
        color: selected ? _selectedBg : AppColors.lunarWhite,
        child: InkWell(
          onTap: onTap,
          child: Opacity(
            opacity: available ? 1 : 0.4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 1,
                      children: [
                        Text(
                          option.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _nameStyle,
                        ),
                        Text(
                          option.region,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _regionStyle,
                        ),
                      ],
                    ),
                  ),
                  if (selected) SvgPicture.asset(_check, width: 26, height: 26),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
