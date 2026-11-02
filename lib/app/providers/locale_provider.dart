import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../localization/app_localizations.dart';

const _localePreferenceKey = 'selected_locale';

class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    _loadSavedLocale();
    return null;
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_localePreferenceKey);
    if (languageCode != null &&
        AppLocalizations.supportedLocales.any(
          (locale) => locale.languageCode == languageCode,
        )) {
      state = Locale(languageCode);
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!AppLocalizations.supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    )) {
      return;
    }
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localePreferenceKey, locale.languageCode);
  }

  Future<void> clearLocale() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localePreferenceKey);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);
