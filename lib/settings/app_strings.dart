import 'package:flutter/widgets.dart';

class AppStrings {
  static const supportedLocales = [Locale('es'), Locale('en')];

  static String text(BuildContext context, String key) {
    final english = Localizations.localeOf(context).languageCode == 'en';
    const values = {
      'settings': ['Ajustes', 'Settings'],
      'permissions': ['Permisos', 'Permissions'],
      'camera': ['Cámara', 'Camera'],
      'microphone': ['Micrófono', 'Microphone'],
      'request': ['Pedir permiso', 'Request permission'],
      'granted': ['Concedido', 'Granted'],
      'denied': ['No concedido', 'Not granted'],
      'language': ['Idioma', 'Language'],
      'theme': ['Tema', 'Theme'],
      'light': ['Claro', 'Light'],
      'dark': ['Oscuro', 'Dark'],
      'spanish': ['Español', 'Spanish'],
      'english': ['Inglés', 'English'],
      'permissionOnlyOnUse': [
        'Los permisos solo se solicitan al pulsar el botón.',
        'Permissions are requested only after pressing the button.',
      ],
      'permissionUpdated': ['Permiso actualizado.', 'Permission updated.'],
      'permissionError': ['No se pudo consultar el permiso.', 'Could not check permission.'],
    };
    final pair = values[key];
    return pair == null ? key : pair[english ? 1 : 0];
  }
}
