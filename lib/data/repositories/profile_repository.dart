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

  /// Inserta el perfil si aún no existe (llamado tras registro exitoso).
  Future<void> createProfileIfNotExists(
    String userId,
    String fullName,
    String rut,
  ) {
    return _profileService.createProfileIfNotExists(userId, fullName, rut);
  }

  // ----------------------------------------------------------
  // Estadísticas
  // ----------------------------------------------------------

  /// Retorna las estadísticas de publicaciones del usuario con [userId].
  Future<ProfileStats> getStats(String userId) {
    return _profileService.fetchStats(userId);
  }
}
