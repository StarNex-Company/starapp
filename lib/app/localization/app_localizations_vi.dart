import 'app_localizations.dart';
// ignore_for_file: type=lint

/// Vietnamese (`vi`)
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'StarApp';
  @override
  String get welcome => 'Chào mừng đến với StarApp';
  @override
  String get signIn => 'Đăng nhập';
  @override
  String get signOut => 'Đăng xuất';
  @override
  String get chooseYourLanguage => 'Chọn ngôn ngữ của bạn';
  @override
  String get chooseYourLanguageDescription =>
      'Chọn ngôn ngữ ưa thích của bạn cho trải nghiệm ứng dụng.';
  @override
  String get searchLanguageHint => 'Tìm kiếm ngôn ngữ...';
  @override
  String get cancel => 'Hủy';
  @override
  String get done => 'Xong';
  @override
  String get english => 'Tiếng Anh';
  @override
  String get spanish => 'Tiếng Tây Ban Nha';
  @override
  String greeting(Object name) => 'Xin chào $name!';
}
