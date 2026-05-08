// ============================================================
// settings_service.dart
// Servicio de configuración — lee y escribe preferencias del
// usuario en SharedPreferences (almacenamiento local del dispositivo).
//
// Claves almacenadas:
//   'theme_mode'       — String: 'light' | 'dark'
//   'default_section'  — int:    0..4 (índice de la barra de navegación)
// ============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Claves usadas en SharedPreferences
const String _keyThemeMode = 'theme_mode';
const String _keyDefaultSection = 'default_section';

/// Valores para el tema almacenado
const String _valueDark = 'dark';
const String _valueLight = 'light';

/// Servicio de configuración local de GGSS.cl
class SettingsService {
  final SharedPreferences _prefs;

  const SettingsService(this._prefs);

  // ----------------------------------------------------------
  // Tema de la aplicación
  // ----------------------------------------------------------

  /// Retorna el [ThemeMode] guardado. Por defecto: [ThemeMode.light].
  ThemeMode getThemeMode() {
    final stored = _prefs.getString(_keyThemeMode);
    return stored == _valueDark ? ThemeMode.dark : ThemeMode.light;
  }

  /// Persiste el [ThemeMode] seleccionado por el usuario.
  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(
      _keyThemeMode,
      mode == ThemeMode.dark ? _valueDark : _valueLight,
    );
  }

  // ----------------------------------------------------------
  // Sección de inicio (índice de la barra de navegación inferior)
  // ----------------------------------------------------------

  /// Retorna el índice de la sección de inicio guardado. Por defecto: 0.
  int getDefaultSection() {
    return _prefs.getInt(_keyDefaultSection) ?? 0;
  }

  /// Persiste el índice de sección de inicio seleccionado por el usuario.
  Future<void> setDefaultSection(int sectionIndex) async {
    await _prefs.setInt(_keyDefaultSection, sectionIndex);
  }
}
