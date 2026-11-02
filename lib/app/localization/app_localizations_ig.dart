import 'app_localizations.dart';
// ignore_for_file: type=lint

/// Igbo (`ig`)
class AppLocalizationsIg extends AppLocalizations {
  AppLocalizationsIg([String locale = 'ig']) : super(locale);

  @override
  String get appTitle => 'StarApp';
  @override
  String get welcome => 'Nnọọ na StarApp';
  @override
  String get signIn => 'Banye';
  @override
  String get signOut => 'Pụọ';
  @override
  String get chooseYourLanguage => 'Họrọ Asụsụ Gị';
  @override
  String get chooseYourLanguageDescription =>
      'Họrọ asụsụ ọ masịrị gị maka ahụmahụ ngwa.';
  @override
  String get searchLanguageHint => 'Chọọ asụsụ...';
  @override
  String get cancel => 'Kagbuo';
  @override
  String get done => 'Mechaa';
  @override
  String get english => 'Bekee';
  @override
  String get spanish => 'Spen';
  @override
  String greeting(Object name) => 'Nnọọ $name!';
}
