import 'app_localizations.dart';
// ignore_for_file: type=lint

/// Thai (`th`)
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'StarApp';
  @override
  String get welcome => 'ยินดีต้อนรับสู่ StarApp';
  @override
  String get signIn => 'เข้าสู่ระบบ';
  @override
  String get signOut => 'ออกจากระบบ';
  @override
  String get chooseYourLanguage => 'เลือกภาษาของคุณ';
  @override
  String get chooseYourLanguageDescription =>
      'เลือกภาษาที่คุณต้องการสำหรับประสบการณ์การใช้งานแอป';
  @override
  String get searchLanguageHint => 'ค้นหาภาษา...';
  @override
  String get cancel => 'ยกเลิก';
  @override
  String get done => 'เสร็จสิ้น';
  @override
  String get english => 'อังกฤษ';
  @override
  String get spanish => 'สเปน';
  @override
  String greeting(Object name) => 'สวัสดี $name!';
}
