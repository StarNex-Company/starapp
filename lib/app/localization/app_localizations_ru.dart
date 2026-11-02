import 'app_localizations.dart';
// ignore_for_file: type=lint

/// Russian (`ru`)
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'StarApp';
  @override
  String get welcome => 'Добро пожаловать в StarApp';
  @override
  String get signIn => 'Войти';
  @override
  String get signOut => 'Выйти';
  @override
  String get chooseYourLanguage => 'Выберите язык';
  @override
  String get chooseYourLanguageDescription =>
      'Выберите предпочитаемый язык для работы с приложением.';
  @override
  String get searchLanguageHint => 'Поиск языка...';
  @override
  String get cancel => 'Отмена';
  @override
  String get done => 'Готово';
  @override
  String get english => 'Английский';
  @override
  String get spanish => 'Испанский';
  @override
  String greeting(Object name) => 'Привет $name!';
}
