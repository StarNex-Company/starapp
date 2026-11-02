import 'app_localizations.dart';
// ignore_for_file: type=lint

/// Malay (`ms`)
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String get appTitle => 'StarApp';
  @override
  String get welcome => 'Selamat datang ke StarApp';
  @override
  String get signIn => 'Log masuk';
  @override
  String get signOut => 'Log keluar';
  @override
  String get chooseYourLanguage => 'Pilih Bahasa Anda';
  @override
  String get chooseYourLanguageDescription =>
      'Pilih bahasa pilihan anda untuk pengalaman aplikasi.';
  @override
  String get searchLanguageHint => 'Cari bahasa...';
  @override
  String get cancel => 'Batal';
  @override
  String get done => 'Selesai';
  @override
  String get english => 'Bahasa Inggeris';
  @override
  String get spanish => 'Bahasa Sepanyol';
  @override
  String greeting(Object name) => 'Helo $name!';
}
