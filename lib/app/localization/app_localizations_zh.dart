import 'app_localizations.dart';
// ignore_for_file: type=lint

/// Chinese (`zh`)
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'StarApp';
  @override
  String get welcome => '欢迎使用 StarApp';
  @override
  String get signIn => '登录';
  @override
  String get signOut => '退出登录';
  @override
  String get chooseYourLanguage => '选择您的语言';
  @override
  String get chooseYourLanguageDescription => '选择您在应用中偏好的语言。';
  @override
  String get searchLanguageHint => '搜索语言...';
  @override
  String get cancel => '取消';
  @override
  String get done => '完成';
  @override
  String get english => '英语';
  @override
  String get spanish => '西班牙语';
  @override
  String greeting(Object name) => '你好 $name！';
}
