// ============================================================
// supabase_config.dart
// Credenciales de conexión a Supabase.
// IMPORTANTE: En producción, mover estas constantes a variables
// de entorno usando flutter_dotenv. Por ahora se usan constantes
// para simplificar el desarrollo académico.
// ============================================================

/// Configuración de conexión al proyecto Supabase de GGSS.cl
class SupabaseConfig {
  // Constructor privado: esta clase no debe instanciarse
  SupabaseConfig._();

  /// URL pública del proyecto Supabase
  static const String projectUrl = 'https://vxbotzyieemxapqshfgq.supabase.co';

  /// Clave anónima (segura para uso en cliente) — formato nuevo de Supabase
  static const String anonKey =
      'sb_publishable_bpYzMPfOCqOnG2-AmPiJoQ_4RFCIKag';

  /// Clave anónima en formato JWT legado (eyJ...).
  /// Requerida para llamar a Edge Functions, cuyo runtime valida
  /// el Authorization header como JWT estándar y rechaza el formato nuevo.
  static const String anonKeyLegacy =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
      '.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ4Ym90enlpZWVteGFwcXNoZmdxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc4NDE0NzgsImV4cCI6MjA5MzQxNzQ3OH0'
      '.vmZUCyqtnvpUkbV7_eQgV8BuWG_bqIgGhiClQYa78_w';
}
