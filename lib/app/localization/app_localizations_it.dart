import 'app_localizations.dart';
// ignore_for_file: type=lint

/// Italian (`it`)
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'StarApp';
  @override
  String get welcome => 'Benvenuto su StarApp';
  @override
  String get signIn => 'Accedi';
  @override
  String get signOut => 'Esci';
  @override
  String get chooseYourLanguage => 'Scegli la tua lingua';
  @override
  String get chooseYourLanguageDescription =>
      "Seleziona la tua lingua preferita per l'app.";
  @override
  String get searchLanguageHint => 'Cerca lingua...';
  @override
  String get cancel => 'Annulla';
  @override
  String get done => 'Fatto';
  @override
  String get english => 'Inglese';
  @override
  String get spanish => 'Spagnolo';
  @override
  String greeting(Object name) => 'Ciao $name!';
}
