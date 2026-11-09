// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get settings => 'Ajustes';

  @override
  String get permissions => 'Permisos';

  @override
  String get camera => 'Cámara';

  @override
  String get microphone => 'Micrófono';

  @override
  String get request => 'Pedir permiso';

  @override
  String get granted => 'Concedido';

  @override
  String get denied => 'No concedido';

  @override
  String get language => 'Idioma';

  @override
  String get theme => 'Tema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'Inglés';

  @override
  String get permissionOnlyOnUse =>
      'Los permisos solo se solicitan al pulsar el botón.';

  @override
  String get permissionUpdated => 'Permiso actualizado.';

  @override
  String get permissionError => 'No se pudo consultar el permiso.';
}
