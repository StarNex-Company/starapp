import 'app_localizations.dart';
// ignore_for_file: type=lint

/// Yoruba (`yo`)
class AppLocalizationsYo extends AppLocalizations {
  AppLocalizationsYo([String locale = 'yo']) : super(locale);

  @override
  String get appTitle => 'StarApp';
  @override
  String get welcome => 'Ẹ káàbọ̀ sí StarApp';
  @override
  String get signIn => 'Wọlé';
  @override
  String get signOut => 'Jáde';
  @override
  String get chooseYourLanguage => 'Yan Èdè Rẹ';
  @override
  String get chooseYourLanguageDescription =>
      'Yan èdè tí o fẹ́ fún ìrírí ohun èlò.';
  @override
  String get searchLanguageHint => 'Wá èdè...';
  @override
  String get cancel => 'Fagilé';
  @override
  String get done => 'Parí';
  @override
  String get english => 'Gẹ̀ẹ́sì';
  @override
  String get spanish => 'Sípánì';
  @override
  String greeting(Object name) => 'Ẹ nlẹ $name!';
}
