import 'package:flutter/material.dart';

class LocaleController extends ChangeNotifier {
  Locale _locale;

  LocaleController({Locale initialLocale = const Locale('es')})
      : _locale = initialLocale;

  Locale get locale => _locale;
  bool get isEnglish => _locale.languageCode == 'en';

  void setLocale(Locale locale) {
    if (locale.languageCode == _locale.languageCode) return;
    _locale = locale;
    notifyListeners();
  }

  void toggleLocale() {
    setLocale(Locale(isEnglish ? 'es' : 'en'));
  }
}
