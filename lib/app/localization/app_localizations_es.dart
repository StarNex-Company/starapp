// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'StarApp';

  @override
  String get welcome => 'Bienvenido a StarApp';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get chooseYourLanguage => 'Elige tu idioma';

  @override
  String get chooseYourLanguageDescription =>
      'Selecciona tu idioma preferido para la experiencia de la aplicación.';

  @override
  String get searchLanguageHint => 'Buscar idioma...';

  @override
  String get cancel => 'Cancelar';

  @override
  String get done => 'Hecho';

  @override
  String get english => 'Inglés';

  @override
  String get spanish => 'Español';

  @override
  String greeting(Object name) {
    return '¡Hola $name!';
  }
}
