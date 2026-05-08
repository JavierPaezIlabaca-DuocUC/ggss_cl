// ============================================================
// os10_providers.dart
// Proveedores Riverpod del módulo del Simulador OS10.
//
// Contiene:
//   - Os10StatsData: modelo de estadísticas del simulador
//   - Os10StatsNotifier: AsyncNotifier que carga desde SharedPreferences
//   - os10StatsProvider: proveedor principal del módulo
//
// Al completar un examen, Os10ResultsScreen invalida este proveedor
// mediante refresh(), lo que hace que Os10Screen recargue los datos
// actualizados de forma inmediata.
// ============================================================

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/os10_repository.dart';

// Claves de SharedPreferences (deben coincidir con os10_results_screen.dart)
const String _keyBestScore = 'os10_best_score_percent';
const String _keyHistory = 'os10_exam_history';

// ============================================================
// Modelo de estadísticas del simulador OS10
// ============================================================

/// Datos de estadísticas del simulador OS10 leídos de SharedPreferences
class Os10StatsData {
  /// Mejor puntaje obtenido (porcentaje). Null si nunca se ha hecho un examen.
  final int? bestScorePercent;

  /// Historial de intentos ordenado del más antiguo al más reciente
  final List<Map<String, dynamic>> history;

  /// Total de preguntas disponibles en Supabase
  final int totalQuestions;

  const Os10StatsData({
    required this.bestScorePercent,
    required this.history,
    required this.totalQuestions,
  });
}

// ============================================================
// AsyncNotifier: carga y refresca las estadísticas OS10
// ============================================================

/// Notifier que mantiene las estadísticas del simulador OS10.
/// Se invalida desde Os10ResultsScreen al terminar un examen.
class Os10StatsNotifier extends AsyncNotifier<Os10StatsData> {
  @override
  Future<Os10StatsData> build() => _fetchStats();

  // ----------------------------------------------------------
  // Carga estadísticas desde SharedPreferences y conteo de Supabase
  // ----------------------------------------------------------

  Future<Os10StatsData> _fetchStats() async {
    final prefs = await SharedPreferences.getInstance();

    // Leer mejor puntaje
    final bestScore = prefs.getInt(_keyBestScore);

    // Leer historial de intentos
    final historyJson = prefs.getString(_keyHistory);
    List<Map<String, dynamic>> history = [];
    if (historyJson != null) {
      try {
        final decoded = jsonDecode(historyJson) as List;
        history = decoded.cast<Map<String, dynamic>>();
      } catch (_) {
        // Historial corrupto: ignorar
      }
    }

    // Obtener total de preguntas disponibles en Supabase
    int totalQuestions = 0;
    try {
      final questions = await Os10Repository().getAllQuestions();
      totalQuestions = questions.length;
    } catch (_) {
      // Sin conexión o tabla vacía: continuar con 0
    }

    return Os10StatsData(
      bestScorePercent: bestScore,
      history: history,
      totalQuestions: totalQuestions,
    );
  }

  // ----------------------------------------------------------
  // Refresca las estadísticas (llamado tras completar un examen)
  // ----------------------------------------------------------

  /// Recarga las estadísticas desde SharedPreferences.
  /// Llamado por Os10ResultsScreen después de guardar los resultados.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchStats);
  }
}

/// Proveedor principal de estadísticas del Simulador OS10
final os10StatsProvider =
    AsyncNotifierProvider<Os10StatsNotifier, Os10StatsData>(
  Os10StatsNotifier.new,
);
