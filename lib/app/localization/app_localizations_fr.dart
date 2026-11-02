import 'app_localizations.dart';
// ignore_for_file: type=lint

/// French (`fr`)
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'StarApp';
  @override
  String get welcome => 'Bienvenue sur StarApp';
  @override
  String get signIn => 'Se connecter';
  @override
  String get signOut => 'Se déconnecter';
  @override
  String get chooseYourLanguage => 'Choisissez votre langue';
  @override
  String get chooseYourLanguageDescription =>
      "Sélectionnez votre langue préférée pour l'application.";
  @override
  String get searchLanguageHint => 'Rechercher une langue...';
  @override
  String get cancel => 'Annuler';
  @override
  String get done => 'Terminé';
  @override
  String get english => 'Anglais';
  @override
  String get spanish => 'Espagnol';
  @override
  String greeting(Object name) => 'Bonjour $name!';
}
