// ============================================================
// profile_service.dart
// Servicio de perfil de usuario — operaciones CRUD contra
// la tabla 'profiles' en Supabase.
// ============================================================

import '../../models/profile_model.dart';
import '../supabase/supabase_client.dart';

const String _tableProfiles = 'profiles';

/// Servicio de perfil de usuario de GGSS.cl
class ProfileService {
  final _client = SupabaseClientProvider.client;

  // ----------------------------------------------------------
  // Obtener perfil
  // ----------------------------------------------------------

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
  // Crear perfil si no existe (llamado tras registro exitoso)
  // ----------------------------------------------------------

  Future<void> createProfileIfNotExists(
    String userId,
    String fullName,
    String rut, {
    String accountType = 'personal',
    String? phone,
    String? email,
    // DEPRECATED: alias - kept for potential future use
    // String? alias,
    String? firstName,
    String? lastNamePaternal,
    String? lastNameMaternal,
  }) async {
    await _client.from(_tableProfiles).upsert(
      {
        'id': userId,
        'full_name': fullName.trim(),
        'rut': rut.trim(),
        'account_type': accountType,
        if (phone != null && phone.isNotEmpty) 'phone': phone.trim(),
        if (email != null && email.isNotEmpty) 'email': email.trim(),
        if (firstName != null && firstName.isNotEmpty)
          'first_name': firstName.trim(),
        if (lastNamePaternal != null && lastNamePaternal.isNotEmpty)
          'last_name_paternal': lastNamePaternal.trim(),
        if (lastNameMaternal != null && lastNameMaternal.isNotEmpty)
          'last_name_maternal': lastNameMaternal.trim(),
      },
      ignoreDuplicates: true,
    );
  }

  // ----------------------------------------------------------
  // Actualizar campos de nombre
  // ----------------------------------------------------------

  Future<void> updateNameFields(
    String userId, {
    required String firstName,
    String? lastNamePaternal,
    String? lastNameMaternal,
  }) async {
    final fullName = [
      firstName,
      if (lastNamePaternal != null && lastNamePaternal.isNotEmpty)
        lastNamePaternal,
      if (lastNameMaternal != null && lastNameMaternal.isNotEmpty)
        lastNameMaternal,
    ].join(' ').trim();

    await _client.from(_tableProfiles).update({
      'first_name': firstName.trim(),
      'last_name_paternal': (lastNamePaternal != null &&
              lastNamePaternal.isNotEmpty)
          ? lastNamePaternal.trim()
          : null,
      'last_name_maternal':
          (lastNameMaternal != null && lastNameMaternal.isNotEmpty)
              ? lastNameMaternal.trim()
              : null,
      'full_name': fullName, // keep in sync for backward compat
    }).eq('id', userId);
  }

  // ----------------------------------------------------------
  // Actualizar teléfono
  // ----------------------------------------------------------

  Future<void> updatePhone(String userId, String? phone) async {
    await _client.from(_tableProfiles).update({
      'phone': (phone != null && phone.isNotEmpty) ? phone.trim() : null,
    }).eq('id', userId);
  }

  // ----------------------------------------------------------
  // Actualizar configuración de privacidad
  // ----------------------------------------------------------

  Future<void> updatePrivacySettings(
    String userId, {
    required bool showFullName,
    required bool showEmail,
    required bool showPhone,
    required bool showPosts,
    required bool showFullNameInPosts,
  }) async {
    await _client.from(_tableProfiles).update({
      'show_full_name': showFullName,
      'show_email': showEmail,
      'show_phone': showPhone,
      'show_posts': showPosts,
      'show_full_name_in_posts': showFullNameInPosts,
    }).eq('id', userId);
  }

  // ----------------------------------------------------------
  // updateProfile: mantenido para compatibilidad hacia atrás
  // ----------------------------------------------------------

  Future<void> updateProfile(String userId, String fullName) async {
    await _client.from(_tableProfiles).update({
      'full_name': fullName.trim(),
    }).eq('id', userId);
  }

  // ----------------------------------------------------------
  // Estadísticas de publicaciones del usuario
  // ----------------------------------------------------------

  Future<int> countJobOffers(String userId) async {
    final rows = await _client
        .from('job_offers')
        .select('id')
        .eq('created_by', userId);
    return (rows as List).length;
  }

  Future<int> countAcademicOffers(String userId) async {
    final rows = await _client
        .from('academic_offers')
        .select('id')
        .eq('created_by', userId);
    return (rows as List).length;
  }

  Future<int> countForumPosts(String userId) async {
    final rows = await _client
        .from('forum_posts')
        .select('id')
        .eq('created_by', userId);
    return (rows as List).length;
  }

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
