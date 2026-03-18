import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale;
  String _locationCode;

  static const List<String> supportedCodes = ['en', 'fr', 'de', 'it', 'es', 'el', 'hi', 'pa'];

  LocaleProvider({Locale initialLocale = const Locale('en')})
      : _locale = _validateLocale(initialLocale),
        _locationCode = _validateLocale(initialLocale).languageCode;

  Locale get locale => _locale;
  String get locationCode => _locationCode;

  static Locale _validateLocale(Locale locale) {
    if (supportedCodes.contains(locale.languageCode)) {
      return locale;
    }
    return const Locale('en'); // Hard fallback to English
  }

  void setLocale(Locale newLocale) async {
    final validLocale = _validateLocale(newLocale);
    if (_locale == validLocale) return;
    _locale = validLocale;
    _locationCode = validLocale.languageCode;

    debugPrint('Locale validated and updated to: ${_locale.languageCode}');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', _locale.languageCode);

    notifyListeners();
  }
}