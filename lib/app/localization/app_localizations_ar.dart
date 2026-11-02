import 'app_localizations.dart';
// ignore_for_file: type=lint

/// Arabic (`ar`)
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'StarApp';
  @override
  String get welcome => 'مرحباً بك في StarApp';
  @override
  String get signIn => 'تسجيل الدخول';
  @override
  String get signOut => 'تسجيل الخروج';
  @override
  String get chooseYourLanguage => 'اختر لغتك';
  @override
  String get chooseYourLanguageDescription =>
      'اختر لغتك المفضلة لتجربة التطبيق.';
  @override
  String get searchLanguageHint => 'البحث عن لغة...';
  @override
  String get cancel => 'إلغاء';
  @override
  String get done => 'تم';
  @override
  String get english => 'الإنجليزية';
  @override
  String get spanish => 'الإسبانية';
  @override
  String greeting(Object name) => 'مرحباً $name!';
}
