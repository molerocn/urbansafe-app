import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio de localización que gestiona el idioma de la aplicación.
class LocalizationService extends ChangeNotifier {
  static const String _languageKey = 'app_language';
  static const String _defaultLanguage = 'es';

  Locale _currentLocale = const Locale('es');

  LocalizationService() {
    _loadLanguage();
  }

  Locale get currentLocale => _currentLocale;
  String get currentLanguageCode => _currentLocale.languageCode;

  /// Carga el idioma guardado en SharedPreferences
  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey) ?? _defaultLanguage;
      _currentLocale = Locale(savedLanguage);
    } catch (_) {
      _currentLocale = const Locale(_defaultLanguage);
    }
  }

  /// Cambia el idioma de la aplicación
  Future<void> setLanguage(String languageCode) async {
    if (languageCode == currentLanguageCode) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      _currentLocale = Locale(languageCode);
      notifyListeners();
    } catch (_) {
      // Ignorar errores
    }
  }

  /// Alterna entre español e inglés
  Future<void> toggleLanguage() async {
    final newLanguage = currentLanguageCode == 'es' ? 'en' : 'es';
    await setLanguage(newLanguage);
  }

  /// Obtiene el nombre del idioma actual en el idioma actual
  String getCurrentLanguageName() {
    return currentLanguageCode == 'es' ? 'Español' : 'English';
  }

  /// Obtiene el nombre del otro idioma
  String getOtherLanguageName() {
    return currentLanguageCode == 'es' ? 'English' : 'Español';
  }
}
