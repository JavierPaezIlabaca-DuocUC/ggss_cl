// ============================================================
// academic_service.dart
// Servicio de ofertas académicas — operaciones CRUD contra
// la tabla 'academic_offers' en Supabase.
// ============================================================

import '../../core/utils/post_name_preference.dart';
import '../supabase/supabase_client.dart';

/// Nombre de la tabla de ofertas académicas en Supabase
const String _tableAcademicOffers = 'academic_offers';

/// Servicio de ofertas académicas para GGSS.cl
class AcademicService {
  final _client = SupabaseClientProvider.client;

  /// Obtiene todas las ofertas académicas ordenadas por fecha (más reciente primero).
  /// Incluye nombre del autor vía join con 'profiles' (FK: created_by).
  Future<List<Map<String, dynamic>>> fetchAllAcademicOffers() async {
    final response = await _client
        .from(_tableAcademicOffers)
        .select('*, profiles!created_by(full_name, first_name, last_name_paternal, last_name_maternal, show_full_name_in_posts)')
        .order('created_at', ascending: false);
    return _applyCurrentUserPreference(List<Map<String, dynamic>>.from(response));
  }

  /// Obtiene solo las ofertas académicas creadas por [userId].
  /// Usado en la vista "Mis publicaciones" del perfil.
  Future<List<Map<String, dynamic>>> fetchAcademicOffersByUser(
    String userId,
  ) async {
    final response = await _client
        .from(_tableAcademicOffers)
        .select('*, profiles!created_by(full_name, first_name, last_name_paternal, last_name_maternal, show_full_name_in_posts)')
        .eq('created_by', userId)
        .order('created_at', ascending: false);
    return _applyCurrentUserPreference(List<Map<String, dynamic>>.from(response));
  }

  /// Obtiene una oferta académica por su [id].
  /// Incluye nombre del autor vía join con 'profiles' (FK: created_by).
  Future<Map<String, dynamic>?> fetchAcademicOfferById(String id) async {
    final response = await _client
        .from(_tableAcademicOffers)
        .select('*, profiles!created_by(full_name, first_name, last_name_paternal, last_name_maternal, show_full_name_in_posts)')
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    final list = await _applyCurrentUserPreference([response]);
    return list.first;
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
