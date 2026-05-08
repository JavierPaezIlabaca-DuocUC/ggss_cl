// ============================================================
// profile_service.dart
// Servicio de perfil de usuario — operaciones CRUD contra
// la tabla 'profiles' en Supabase.
//
// La tabla 'profiles' tiene columnas:
//   id (UUID), full_name, rut, avatar_url, account_type,
//   phone, alias, created_at, updated_at
// ============================================================

import '../../models/profile_model.dart';
import '../supabase/supabase_client.dart';

/// Nombre de la tabla de perfiles en Supabase
const String _tableProfiles = 'profiles';

/// Servicio de perfil de usuario de GGSS.cl
class ProfileService {
  final _client = SupabaseClientProvider.client;

  // ----------------------------------------------------------
  // Obtener perfil
  // ----------------------------------------------------------

  /// Retorna el perfil del usuario con [userId], o null si no existe.
  Future<ProfileModel?> getProfile(String userId) async {
    final response = await _client
        .from(_tableProfiles)
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (response == null) return null;
    return ProfileModel.fromMap(response);
  }

  // ----------------------------------------------------------
  // Actualizar perfil
  // ----------------------------------------------------------

  /// Actualiza el nombre completo del usuario con [userId].
  Future<void> updateProfile(String userId, String fullName) async {
    await _client.from(_tableProfiles).update({
      'full_name': fullName.trim(),
    }).eq('id', userId);
  }

  // ----------------------------------------------------------
  // Crear perfil si no existe (llamado tras registro exitoso)
  // ----------------------------------------------------------

  /// Inserta un perfil si aún no existe.
  /// Usa upsert con ignoreDuplicates para evitar sobrescribir un perfil existente.
  Future<void> createProfileIfNotExists(
    String userId,
    String fullName,
    String rut, {
    String accountType = 'personal',
    String? phone,
    String? alias,
  }) async {
    await _client.from(_tableProfiles).upsert(
      {
        'id': userId,
        'full_name': fullName.trim(),
        'rut': rut.trim(),
        'account_type': accountType,
        if (phone != null && phone.isNotEmpty) 'phone': phone.trim(),
        if (alias != null && alias.trim().isNotEmpty) 'alias': alias.trim(),
      },
      ignoreDuplicates: true,
    );
  }

  // ----------------------------------------------------------
  // Estadísticas de publicaciones del usuario
  // ----------------------------------------------------------

  /// Retorna el número de ofertas laborales publicadas por [userId].
  Future<int> countJobOffers(String userId) async {
    final rows = await _client
        .from('job_offers')
        .select('id')
        .eq('created_by', userId);
    return (rows as List).length;
  }

  /// Retorna el número de ofertas académicas publicadas por [userId].
  Future<int> countAcademicOffers(String userId) async {
    final rows = await _client
        .from('academic_offers')
        .select('id')
        .eq('created_by', userId);
    return (rows as List).length;
  }

  /// Retorna el número de publicaciones del foro creadas por [userId].
  Future<int> countForumPosts(String userId) async {
    final rows = await _client
        .from('forum_posts')
        .select('id')
        .eq('created_by', userId);
    return (rows as List).length;
  }

  /// Obtiene las tres estadísticas de publicaciones del usuario en paralelo.
  Future<ProfileStats> fetchStats(String userId) async {
    final results = await Future.wait([
      countJobOffers(userId),
      countAcademicOffers(userId),
      countForumPosts(userId),
    ]);
    return ProfileStats(
      jobCount: results[0],
      academicCount: results[1],
      forumCount: results[2],
    );
  }
}
