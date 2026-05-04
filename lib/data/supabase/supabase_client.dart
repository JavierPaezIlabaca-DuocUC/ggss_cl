// ============================================================
// supabase_client.dart
// Expone el cliente global de Supabase para toda la app.
// Se inicializa una sola vez en main.dart.
// Todos los servicios acceden a Supabase a través de este archivo.
// ============================================================

import 'package:supabase_flutter/supabase_flutter.dart';

/// Acceso directo al cliente Supabase inicializado
/// Uso: SupabaseClientProvider.client.from('tabla').select()
class SupabaseClientProvider {
  // Constructor privado: esta clase no debe instanciarse
  SupabaseClientProvider._();

  /// Instancia global del cliente Supabase
  static SupabaseClient get client => Supabase.instance.client;
}
