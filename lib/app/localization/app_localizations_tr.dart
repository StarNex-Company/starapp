import 'app_localizations.dart';
// ignore_for_file: type=lint

/// Turkish (`tr`)
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'StarApp';
  @override
  String get welcome => "StarApp'e Hoş Geldiniz";
  @override
  String get signIn => 'Giriş Yap';
  @override
  String get signOut => 'Çıkış Yap';
  @override
  String get chooseYourLanguage => 'Dilinizi Seçin';
  @override
  String get chooseYourLanguageDescription =>
      'Uygulama deneyimi için tercih ettiğiniz dili seçin.';
  @override
  String get searchLanguageHint => 'Dil ara...';
  @override
  String get cancel => 'İptal';
  @override
  String get done => 'Bitti';
  @override
  String get english => 'İngilizce';
  @override
  String get spanish => 'İspanyolca';
  @override
  String greeting(Object name) => 'Merhaba $name!';
}
