// ============================================================
// academic_service.dart
// Servicio de ofertas académicas — operaciones CRUD contra
// la tabla 'academic_offers' en Supabase.
// ============================================================

import '../supabase/supabase_client.dart';

/// Nombre de la tabla de ofertas académicas en Supabase
const String _tableAcademicOffers = 'academic_offers';

/// Servicio de ofertas académicas para GGSS.cl
class AcademicService {
  final _client = SupabaseClientProvider.client;

  /// Obtiene todas las ofertas académicas ordenadas por fecha (más reciente primero).
  /// Incluye el nombre del autor vía join con 'profiles' (FK: created_by).
  Future<List<Map<String, dynamic>>> fetchAllAcademicOffers() async {
    final response = await _client
        .from(_tableAcademicOffers)
        .select('*, profiles!created_by(full_name)')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Obtiene una oferta académica por su [id].
  /// Incluye el nombre del autor vía join con 'profiles' (FK: created_by).
  Future<Map<String, dynamic>?> fetchAcademicOfferById(String id) async {
    final response = await _client
        .from(_tableAcademicOffers)
        .select('*, profiles!created_by(full_name)')
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  /// Crea una nueva oferta académica con los datos de [offerData]
  Future<void> createAcademicOffer(Map<String, dynamic> offerData) async {
    await _client.from(_tableAcademicOffers).insert(offerData);
  }

  /// Actualiza una oferta académica existente con [id]
  Future<void> updateAcademicOffer(
    String id,
    Map<String, dynamic> offerData,
  ) async {
    await _client.from(_tableAcademicOffers).update(offerData).eq('id', id);
  }

  /// Elimina la oferta académica con [id]
  Future<void> deleteAcademicOffer(String id) async {
    await _client.from(_tableAcademicOffers).delete().eq('id', id);
  }
}
