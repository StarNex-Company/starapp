import 'app_localizations.dart';
// ignore_for_file: type=lint

/// Japanese (`ja`)
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'StarApp';
  @override
  String get welcome => 'StarAppへようこそ';
  @override
  String get signIn => 'サインイン';
  @override
  String get signOut => 'サインアウト';
  @override
  String get chooseYourLanguage => '言語を選択してください';
  @override
  String get chooseYourLanguageDescription => 'アプリの使用言語を選択してください。';
  @override
  String get searchLanguageHint => '言語を検索...';
  @override
  String get cancel => 'キャンセル';
  @override
  String get done => '完了';
  @override
  String get english => '英語';
  @override
  String get spanish => 'スペイン語';
  @override
  String greeting(Object name) => 'こんにちは $name！';
}
