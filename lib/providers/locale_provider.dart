import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale;
  String _locationCode;

  LocaleProvider({Locale initialLocale = const Locale('en')})
      : _locale = initialLocale,
        _locationCode = initialLocale.languageCode;

  Locale get locale => _locale;
  String get locationCode => _locationCode;

  void setLocale(Locale newLocale) async {
    if (_locale == newLocale) return;
    _locale = newLocale;
    _locationCode = newLocale.languageCode;

    debugPrint('Locale updated to: ${_locale.languageCode}');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);

    notifyListeners();
  }
}