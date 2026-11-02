import 'app_localizations.dart';
// ignore_for_file: type=lint

/// Bengali (`bn`)
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'StarApp';
  @override
  String get welcome => 'StarApp-এ স্বাগতম';
  @override
  String get signIn => 'সাইন ইন করুন';
  @override
  String get signOut => 'সাইন আউট করুন';
  @override
  String get chooseYourLanguage => 'আপনার ভাষা বেছে নিন';
  @override
  String get chooseYourLanguageDescription =>
      'অ্যাপ অভিজ্ঞতার জন্য আপনার পছন্দের ভাষা নির্বাচন করুন।';
  @override
  String get searchLanguageHint => 'ভাষা অনুসন্ধান করুন...';
  @override
  String get cancel => 'বাতিল';
  @override
  String get done => 'সম্পন্ন';
  @override
  String get english => 'ইংরেজি';
  @override
  String get spanish => 'স্পেনিশ';
  @override
  String greeting(Object name) => 'হ্যালো $name!';
}
