// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'StarApp';

  @override
  String get welcome => 'Welcome to StarApp';

  @override
  String get signIn => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get chooseYourLanguage => 'Choose Your Language';

  @override
  String get chooseYourLanguageDescription =>
      'Select your preferred language for the app experience.';

  @override
  String get searchLanguageHint => 'Search language...';

  @override
  String get cancel => 'Cancel';

  @override
  String get done => 'Done';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Español';

  @override
  String greeting(Object name) {
    return 'Hello $name!';
  }
}
