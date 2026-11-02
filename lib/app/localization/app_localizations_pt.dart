import 'app_localizations.dart';
// ignore_for_file: type=lint

/// Portuguese (`pt`)
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'StarApp';
  @override
  String get welcome => 'Bem-vindo ao StarApp';
  @override
  String get signIn => 'Entrar';
  @override
  String get signOut => 'Sair';
  @override
  String get chooseYourLanguage => 'Escolha o seu idioma';
  @override
  String get chooseYourLanguageDescription =>
      'Selecione o idioma preferido para a experiência do aplicativo.';
  @override
  String get searchLanguageHint => 'Pesquisar idioma...';
  @override
  String get cancel => 'Cancelar';
  @override
  String get done => 'Concluído';
  @override
  String get english => 'Inglês';
  @override
  String get spanish => 'Espanhol';
  @override
  String greeting(Object name) => 'Olá $name!';
}
