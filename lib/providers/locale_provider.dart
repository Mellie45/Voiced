import 'dart:async';
import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  String locationCode = 'en';

  Locale get locale => _locale;
  var _localeUpdateController = Completer<void>();

  void setLocationCode(value) {
    locationCode = value;
    notifyListeners();
  }

  void setLocale(Locale locale) {
    _locale = locale;
    debugPrint('Locale from inside the provider: $_locale');
    notifyListeners();
  }

  Future<void> localeUpdateFuture() {
    if (_localeUpdateController.isCompleted) {
      _localeUpdateController.complete();
    }
    return _localeUpdateController.future;
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    _localeUpdateController.complete();
    _localeUpdateController = Completer<void>();
  }
}