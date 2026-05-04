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

  /// Clave anónima (segura para uso en cliente)
  static const String anonKey =
      'sb_publishable_bpYzMPfOCqOnG2-AmPiJoQ_4RFCIKag';
}
