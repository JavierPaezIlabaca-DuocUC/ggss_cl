// ============================================================
// jobs_service.dart
// Servicio de ofertas laborales — operaciones CRUD contra
// la tabla 'job_offers' en Supabase.
// ============================================================

import '../../core/utils/post_name_preference.dart';
import '../supabase/supabase_client.dart';

/// Nombre de la tabla de ofertas laborales en Supabase
const String _tableJobOffers = 'job_offers';

/// Servicio de ofertas laborales para GGSS.cl
class JobsService {
  final _client = SupabaseClientProvider.client;

  /// Obtiene todas las ofertas laborales ordenadas por fecha (más reciente primero).
  /// Incluye nombre del autor vía join con 'profiles' (FK: created_by).
  Future<List<Map<String, dynamic>>> fetchAllJobs() async {
    final response = await _client
        .from(_tableJobOffers)
        .select('*, profiles!created_by(full_name, first_name, last_name_paternal, last_name_maternal, show_full_name_in_posts)')
        .order('created_at', ascending: false);
    return _applyCurrentUserPreference(List<Map<String, dynamic>>.from(response));
  }

  /// Obtiene solo las ofertas laborales creadas por [userId].
  /// Usado en la vista "Mis publicaciones" del perfil.
  Future<List<Map<String, dynamic>>> fetchJobsByUser(String userId) async {
    final response = await _client
        .from(_tableJobOffers)
        .select('*, profiles!created_by(full_name, first_name, last_name_paternal, last_name_maternal, show_full_name_in_posts)')
        .eq('created_by', userId)
        .order('created_at', ascending: false);
    return _applyCurrentUserPreference(List<Map<String, dynamic>>.from(response));
  }

  /// Obtiene una oferta laboral por su [id].
  /// Incluye nombre del autor vía join con 'profiles' (FK: created_by).
  Future<Map<String, dynamic>?> fetchJobById(String id) async {
    final response = await _client
        .from(_tableJobOffers)
        .select('*, profiles!created_by(full_name, first_name, last_name_paternal, last_name_maternal, show_full_name_in_posts)')
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    final list = await _applyCurrentUserPreference([response]);
    return list.first;
  }

  /// Crea una nueva oferta laboral con los datos de [jobData]
  Future<void> createJob(Map<String, dynamic> jobData) async {
    await _client.from(_tableJobOffers).insert(jobData);
  }

  /// Actualiza una oferta laboral existente con [id]
  Future<void> updateJob(String id, Map<String, dynamic> jobData) async {
    await _client.from(_tableJobOffers).update(jobData).eq('id', id);
  }

  /// Elimina la oferta laboral con [id]
  Future<void> deleteJob(String id) async {
    await _client.from(_tableJobOffers).delete().eq('id', id);
  }

  // ----------------------------------------------------------
  // Aplica la preferencia local show_full_name_in_posts para
  // las publicaciones del usuario autenticado actual.
  // Los posts de otros usuarios usan el valor de Supabase.
  // ----------------------------------------------------------

  Future<List<Map<String, dynamic>>> _applyCurrentUserPreference(
    List<Map<String, dynamic>> items,
  ) async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) return items;

    final cachedValue = await PostNamePreference.read();
    if (cachedValue == null) return items;

    return items.map((item) {
      if (item['created_by'] != currentUserId) return item;
      final profiles = item['profiles'] as Map<String, dynamic>?;
      if (profiles == null) return item;
      return {
        ...item,
        'profiles': {...profiles, 'show_full_name_in_posts': cachedValue},
      };
    }).toList();
  }
}
