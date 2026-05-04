// ============================================================
// profile_service.dart
// Servicio de perfil de usuario — operaciones CRUD contra
// la tabla 'profiles' en Supabase (sincronizada con auth.users).
// ============================================================

import '../supabase/supabase_client.dart';

/// Nombre de la tabla de perfiles en Supabase
const String _tableProfiles = 'profiles';

/// Servicio de perfil de usuario de GGSS.cl
class ProfileService {
  final _client = SupabaseClientProvider.client;

  /// Obtiene el perfil del usuario con [userId]
  Future<Map<String, dynamic>?> fetchProfileById(String userId) async {
    final response = await _client
        .from(_tableProfiles)
        .select()
        .eq('id', userId)
        .maybeSingle();
    return response;
  }

  /// Actualiza el perfil del usuario con [userId]
  Future<void> updateProfile(
    String userId,
    Map<String, dynamic> profileData,
  ) async {
    await _client
        .from(_tableProfiles)
        .upsert({'id': userId, ...profileData});
  }
}
