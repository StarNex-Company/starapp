import 'app_localizations.dart';
// ignore_for_file: type=lint

/// Hausa (`ha`)
class AppLocalizationsHa extends AppLocalizations {
  AppLocalizationsHa([String locale = 'ha']) : super(locale);

  @override
  String get appTitle => 'StarApp';
  @override
  String get welcome => 'Maraba da zuwa StarApp';
  @override
  String get signIn => 'Shiga';
  @override
  String get signOut => 'Fita';
  @override
  String get chooseYourLanguage => 'Zaɓi Yarenku';
  @override
  String get chooseYourLanguageDescription =>
      'Zaɓi yaren da kuke so don ƙwarewar aikace-aikacen.';
  @override
  String get searchLanguageHint => 'Nemi harshe...';
  @override
  String get cancel => 'Soke';
  @override
  String get done => 'An gama';
  @override
  String get english => 'Turanci';
  @override
  String get spanish => 'Sifen';
  @override
  String greeting(Object name) => 'Sannu $name!';
}
