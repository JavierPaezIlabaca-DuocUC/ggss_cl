// ============================================================
// os10_service.dart
// Servicio del Simulador OS10 — obtiene preguntas desde
// la tabla 'os10_questions' en Supabase.
// NOTA: el módulo se escribe siempre como "OS10" (sin guión).
// ============================================================

import '../supabase/supabase_client.dart';

/// Nombre de la tabla de preguntas OS10 en Supabase
const String _tableOs10Questions = 'os10_questions';

/// Servicio del simulador OS10 para GGSS.cl
class Os10Service {
  final _client = SupabaseClientProvider.client;

  /// Obtiene todas las preguntas del simulador OS10
  Future<List<Map<String, dynamic>>> fetchAllQuestions() async {
    final response = await _client
        .from(_tableOs10Questions)
        .select()
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Obtiene [count] preguntas aleatorias para un simulacro
  Future<List<Map<String, dynamic>>> fetchRandomQuestions(int count) async {
    // Supabase no tiene orden aleatorio nativo: se usa la función random()
    final response = await _client
        .from(_tableOs10Questions)
        .select()
        .limit(count);
    return List<Map<String, dynamic>>.from(response);
  }
}
