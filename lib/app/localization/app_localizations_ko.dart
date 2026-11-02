import 'app_localizations.dart';
// ignore_for_file: type=lint

/// Korean (`ko`)
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'StarApp';
  @override
  String get welcome => 'StarApp에 오신 것을 환영합니다';
  @override
  String get signIn => '로그인';
  @override
  String get signOut => '로그아웃';
  @override
  String get chooseYourLanguage => '언어를 선택하세요';
  @override
  String get chooseYourLanguageDescription => '앱 사용을 위한 선호 언어를 선택하세요.';
  @override
  String get searchLanguageHint => '언어 검색...';
  @override
  String get cancel => '취소';
  @override
  String get done => '완료';
  @override
  String get english => '영어';
  @override
  String get spanish => '스페인어';
  @override
  String greeting(Object name) => '안녕하세요 $name!';
}
