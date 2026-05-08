// ============================================================
// settings_providers.dart
// Proveedores Riverpod del módulo de configuración.
//
// Contiene:
//   - SettingsState: modelo inmutable de las preferencias
//   - sharedPreferencesProvider: Provider<SharedPreferences>
//     sobreescrito en main() con la instancia ya inicializada
//   - settingsServiceProvider: Provider<SettingsService>
//   - SettingsNotifier: StateNotifier que expone y actualiza
//     el tema y la sección de inicio
//   - settingsNotifierProvider: proveedor principal del módulo
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/services/settings_service.dart';

// ----------------------------------------------------------
// Estado inmutable de las preferencias
// ----------------------------------------------------------

/// Estado de configuración de la app (tema activo + sección de inicio)
class SettingsState {
  /// Tema activo: claro u oscuro
  final ThemeMode themeMode;

  /// Índice de la sección que se muestra al iniciar la app (0–4)
  final int defaultSectionIndex;

  const SettingsState({
    this.themeMode = ThemeMode.light,
    this.defaultSectionIndex = 0,
  });

  /// Crea una copia del estado con los campos modificados
  SettingsState copyWith({ThemeMode? themeMode, int? defaultSectionIndex}) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      defaultSectionIndex: defaultSectionIndex ?? this.defaultSectionIndex,
    );
  }
}

// ----------------------------------------------------------
// Provider de SharedPreferences
// (sobreescrito en main() con la instancia real)
// ----------------------------------------------------------

/// Proveedor de la instancia de SharedPreferences.
/// Debe sobreescribirse en main() antes de runApp():
///   sharedPreferencesProvider.overrideWithValue(prefs)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  // Nunca se llama: siempre sobreescrito antes de runApp
  throw UnimplementedError(
    'sharedPreferencesProvider debe sobreescribirse en main()',
  );
});

// ----------------------------------------------------------
// Provider del servicio de configuración
// ----------------------------------------------------------

/// Proveedor del servicio de configuración local
final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService(ref.watch(sharedPreferencesProvider));
});

// ----------------------------------------------------------
// StateNotifier: gestiona el tema y la sección de inicio
// ----------------------------------------------------------

/// Notifier que mantiene y persiste las preferencias del usuario.
/// Se inicializa sincrónicamente con los valores guardados en SharedPreferences.
class SettingsNotifier extends StateNotifier<SettingsState> {
  final SettingsService _service;

  SettingsNotifier(this._service)
      : super(
          // Cargar valores persistidos al instanciar el notifier
          SettingsState(
            themeMode: _service.getThemeMode(),
            defaultSectionIndex: _service.getDefaultSection(),
          ),
        );

  // ----------------------------------------------------------
  // Cambiar el tema de la app
  // ----------------------------------------------------------

  /// Cambia el tema activo y lo persiste en SharedPreferences.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _service.setThemeMode(mode);
  }

  // ----------------------------------------------------------
  // Cambiar la sección de inicio
  // ----------------------------------------------------------

  /// Cambia la sección de inicio y la persiste en SharedPreferences.
  Future<void> setDefaultSection(int index) async {
    state = state.copyWith(defaultSectionIndex: index);
    await _service.setDefaultSection(index);
  }
}

/// Proveedor principal de las preferencias del usuario
final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref.watch(settingsServiceProvider));
});
