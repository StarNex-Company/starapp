import 'app_localizations.dart';
// ignore_for_file: type=lint

/// Hindi (`hi`)
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'StarApp';
  @override
  String get welcome => 'StarApp में आपका स्वागत है';
  @override
  String get signIn => 'साइन इन करें';
  @override
  String get signOut => 'साइन आउट करें';
  @override
  String get chooseYourLanguage => 'अपनी भाषा चुनें';
  @override
  String get chooseYourLanguageDescription =>
      'ऐप अनुभव के लिए अपनी पसंदीदा भाषा चुनें।';
  @override
  String get searchLanguageHint => 'भाषा खोजें...';
  @override
  String get cancel => 'रद्द करें';
  @override
  String get done => 'हो गया';
  @override
  String get english => 'अंग्रेज़ी';
  @override
  String get spanish => 'स्पेनिश';
  @override
  String greeting(Object name) => 'नमस्ते $name!';
}
