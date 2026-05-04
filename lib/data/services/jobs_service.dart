// ============================================================
// jobs_service.dart
// Servicio de ofertas laborales — operaciones CRUD contra
// la tabla 'job_offers' en Supabase.
// ============================================================

import '../supabase/supabase_client.dart';

/// Nombre de la tabla de ofertas laborales en Supabase
const String _tableJobOffers = 'job_offers';

/// Servicio de ofertas laborales para GGSS.cl
class JobsService {
  final _client = SupabaseClientProvider.client;

  /// Obtiene todas las ofertas laborales ordenadas por fecha (más reciente primero).
  /// Incluye el nombre del autor vía join con 'profiles' (FK: created_by).
  Future<List<Map<String, dynamic>>> fetchAllJobs() async {
    final response = await _client
        .from(_tableJobOffers)
        .select('*, profiles!created_by(full_name)')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Obtiene una oferta laboral por su [id].
  /// Incluye el nombre del autor vía join con 'profiles' (FK: created_by).
  Future<Map<String, dynamic>?> fetchJobById(String id) async {
    final response = await _client
        .from(_tableJobOffers)
        .select('*, profiles!created_by(full_name)')
        .eq('id', id)
        .maybeSingle();
    return response;
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
}
