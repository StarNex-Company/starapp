import 'app_localizations.dart';
// ignore_for_file: type=lint

/// German (`de`)
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'StarApp';
  @override
  String get welcome => 'Willkommen bei StarApp';
  @override
  String get signIn => 'Anmelden';
  @override
  String get signOut => 'Abmelden';
  @override
  String get chooseYourLanguage => 'Wähle deine Sprache';
  @override
  String get chooseYourLanguageDescription =>
      'Wähle deine bevorzugte Sprache für die App.';
  @override
  String get searchLanguageHint => 'Sprache suchen...';
  @override
  String get cancel => 'Abbrechen';
  @override
  String get done => 'Fertig';
  @override
  String get english => 'Englisch';
  @override
  String get spanish => 'Spanisch';
  @override
  String greeting(Object name) => 'Hallo $name!';
}
