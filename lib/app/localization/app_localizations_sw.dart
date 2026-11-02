import 'app_localizations.dart';
// ignore_for_file: type=lint

/// Swahili (`sw`)
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get appTitle => 'StarApp';
  @override
  String get welcome => 'Karibu StarApp';
  @override
  String get signIn => 'Ingia';
  @override
  String get signOut => 'Toka';
  @override
  String get chooseYourLanguage => 'Chagua Lugha Yako';
  @override
  String get chooseYourLanguageDescription =>
      'Chagua lugha unayoipendelea kwa uzoefu wa programu.';
  @override
  String get searchLanguageHint => 'Tafuta lugha...';
  @override
  String get cancel => 'Ghairi';
  @override
  String get done => 'Imekamilika';
  @override
  String get english => 'Kiingereza';
  @override
  String get spanish => 'Kihispania';
  @override
  String greeting(Object name) => 'Habari $name!';
}
