// ============================================================
// profile_repository.dart
// Repositorio de perfil de usuario.
// Intermediario entre la capa de UI/providers y ProfileService.
// ============================================================

import '../../models/profile_model.dart';
import '../services/profile_service.dart';

/// Repositorio de perfil de usuario de GGSS.cl
class ProfileRepository {
  final ProfileService _profileService;

  ProfileRepository({ProfileService? profileService})
      : _profileService = profileService ?? ProfileService();

  // ----------------------------------------------------------
  // Perfil
  // ----------------------------------------------------------

  /// Retorna el perfil del usuario con [userId], o null si no existe.
  Future<ProfileModel?> getProfile(String userId) {
    return _profileService.getProfile(userId);
  }

  /// Actualiza el nombre completo del usuario con [userId].
  Future<void> updateProfile(String userId, String fullName) {
    return _profileService.updateProfile(userId, fullName);
  }

  /// Actualiza los campos de nombre separados del usuario con [userId].
  Future<void> updateNameFields(
    String userId, {
    required String firstName,
    String? lastNamePaternal,
    String? lastNameMaternal,
  }) {
    return _profileService.updateNameFields(
      userId,
      firstName: firstName,
      lastNamePaternal: lastNamePaternal,
      lastNameMaternal: lastNameMaternal,
    );
  }

  /// Actualiza el teléfono del usuario con [userId].
  Future<void> updatePhone(String userId, String? phone) {
    return _profileService.updatePhone(userId, phone);
  }

  /// Actualiza la configuración de privacidad del usuario con [userId].
  Future<void> updatePrivacySettings(
    String userId, {
    required bool showFullName,
    required bool showEmail,
    required bool showPhone,
    required bool showPosts,
    required bool showFullNameInPosts,
  }) {
    return _profileService.updatePrivacySettings(
      userId,
      showFullName: showFullName,
      showEmail: showEmail,
      showPhone: showPhone,
      showPosts: showPosts,
      showFullNameInPosts: showFullNameInPosts,
    );
  }

  /// Inserta el perfil si aún no existe.
  /// Acepta [email] y [firstName] para completar el perfil con datos disponibles.
  Future<void> createProfileIfNotExists(
    String userId,
    String fullName,
    String rut, {
    String? email,
    String? firstName,
  }) {
    return _profileService.createProfileIfNotExists(
      userId,
      fullName,
      rut,
      email: email,
      firstName: firstName,
    );
  }

  // ----------------------------------------------------------
  // Estadísticas
  // ----------------------------------------------------------

  /// Retorna las estadísticas de publicaciones del usuario con [userId].
  Future<ProfileStats> getStats(String userId) {
    return _profileService.fetchStats(userId);
  }
}
