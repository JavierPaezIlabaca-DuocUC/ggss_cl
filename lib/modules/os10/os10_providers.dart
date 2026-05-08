// ============================================================
// os10_providers.dart
// Proveedores Riverpod del módulo del Simulador OS10.
//
// Contiene:
//   - Constantes de SharedPreferences (compartidas con otros archivos OS10)
//   - Os10StatsData: modelo de estadísticas + estado de examen guardado
//   - Os10StatsNotifier: AsyncNotifier que carga desde SharedPreferences
//   - os10StatsProvider: proveedor principal del módulo
//
// Al completar o pausar un examen, este proveedor se invalida
// mediante refresh() para que Os10Screen muestre datos actualizados.
// ============================================================

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/os10_repository.dart';

// ============================================================
// Claves de SharedPreferences (compartidas con results y question screens)
// ============================================================

/// Clave para el mejor puntaje obtenido (porcentaje entero)
const String kOs10KeyBestScore = 'os10_best_score_percent';

/// Clave para el historial de intentos (JSON de lista)
const String kOs10KeyHistory = 'os10_exam_history';

/// Clave para el estado del examen guardado/pausado (JSON de objeto)
const String kOs10KeySavedExam = 'os10_saved_exam_data';

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

  /// true si hay un examen pausado pendiente de retomar
  final bool hasSavedExam;

  const Os10StatsData({
    required this.bestScorePercent,
    required this.history,
    required this.totalQuestions,
    required this.hasSavedExam,
  });
}

// ============================================================
// AsyncNotifier: carga y refresca las estadísticas OS10
// ============================================================

/// Notifier que mantiene las estadísticas del simulador OS10.
/// Se invalida desde Os10ResultsScreen o Os10QuestionScreen al pausar.
class Os10StatsNotifier extends AsyncNotifier<Os10StatsData> {
  @override
  Future<Os10StatsData> build() => _fetchStats();

  // ----------------------------------------------------------
  // Carga estadísticas desde SharedPreferences y conteo de Supabase
  // ----------------------------------------------------------

  Future<Os10StatsData> _fetchStats() async {
    final prefs = await SharedPreferences.getInstance();

    // Leer mejor puntaje
    final bestScore = prefs.getInt(kOs10KeyBestScore);

    // Leer historial de intentos
    final historyJson = prefs.getString(kOs10KeyHistory);
    List<Map<String, dynamic>> history = [];
    if (historyJson != null) {
      try {
        final decoded = jsonDecode(historyJson) as List;
        history = decoded.cast<Map<String, dynamic>>();
      } catch (_) {
        // Historial corrupto: ignorar
      }
    }

    // Verificar si hay un examen guardado/pausado pendiente
    final savedExamJson = prefs.getString(kOs10KeySavedExam);
    final hasSavedExam = savedExamJson != null && savedExamJson.isNotEmpty;

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
      hasSavedExam: hasSavedExam,
    );
  }

  // ----------------------------------------------------------
  // Refresca las estadísticas (llamado tras completar o pausar un examen)
  // ----------------------------------------------------------

  /// Recarga las estadísticas desde SharedPreferences.
  /// Llamado por Os10ResultsScreen (al guardar resultados) y
  /// Os10QuestionScreen (al pausar/guardar el examen).
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
