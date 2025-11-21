
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Un servicio simple para gestionar y persistir el estado del tema (claro/oscuro).
class ThemeService {
  static const _themeKey = 'theme_mode';
  
  // Un notificador al que la UI puede suscribirse para reaccionar a los cambios de tema.
  static ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.system);

  /// Carga el tema guardado desde las preferencias del dispositivo.
  static Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Lee el índice guardado. Si no existe, usa el del sistema (índice 0).
      final themeIndex = prefs.getInt(_themeKey) ?? ThemeMode.system.index;
      themeModeNotifier.value = ThemeMode.values[themeIndex];
    } catch (_) {
      // Si falla, usar el tema del sistema por defecto.
      themeModeNotifier.value = ThemeMode.system;
    }
  }

  /// Cambia entre modo claro y oscuro y guarda la preferencia.
  static Future<void> toggleTheme() async {
    // Si el tema actual es oscuro, cámbialo a claro. Si es claro (o del sistema), cámbialo a oscuro.
    final newTheme = themeModeNotifier.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    themeModeNotifier.value = newTheme;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, newTheme.index);
    } catch (_) {
      // No hacer nada si falla el guardado. El cambio visual ya se aplicó.
    }
  }
}
