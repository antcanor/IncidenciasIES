import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';

class AppStrings {
  static const supportedLocales = AppLocalizations.supportedLocales;

  static String text(BuildContext context, String key) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      final english = Localizations.localeOf(context).languageCode == 'en';
      const fallback = {
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
        'permissionError': [
          'No se pudo consultar el permiso.',
          'Could not check permission.',
        ],
      };
      final pair = fallback[key];
      return pair == null ? key : pair[english ? 1 : 0];
    }
    return switch (key) {
      'settings' => localizations.settings,
      'permissions' => localizations.permissions,
      'camera' => localizations.camera,
      'microphone' => localizations.microphone,
      'request' => localizations.request,
      'granted' => localizations.granted,
      'denied' => localizations.denied,
      'language' => localizations.language,
      'theme' => localizations.theme,
      'light' => localizations.light,
      'dark' => localizations.dark,
      'spanish' => localizations.spanish,
      'english' => localizations.english,
      'permissionOnlyOnUse' => localizations.permissionOnlyOnUse,
      'permissionUpdated' => localizations.permissionUpdated,
      'permissionError' => localizations.permissionError,
      _ => key,
    };
  }
}
