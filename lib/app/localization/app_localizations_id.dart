import 'app_localizations.dart';
// ignore_for_file: type=lint

/// Indonesian (`id`)
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'StarApp';
  @override
  String get welcome => 'Selamat datang di StarApp';
  @override
  String get signIn => 'Masuk';
  @override
  String get signOut => 'Keluar';
  @override
  String get chooseYourLanguage => 'Pilih Bahasa Anda';
  @override
  String get chooseYourLanguageDescription =>
      'Pilih bahasa pilihan Anda untuk pengalaman aplikasi.';
  @override
  String get searchLanguageHint => 'Cari bahasa...';
  @override
  String get cancel => 'Batal';
  @override
  String get done => 'Selesai';
  @override
  String get english => 'Inggris';
  @override
  String get spanish => 'Spanyol';
  @override
  String greeting(Object name) => 'Halo $name!';
}
