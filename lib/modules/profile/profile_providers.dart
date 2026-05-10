// ============================================================
// profile_providers.dart
// Proveedores Riverpod del módulo de perfil de usuario.
//
// Contiene:
//   - profileRepositoryProvider: proveedor del repositorio
//   - ProfileNotifier: AsyncNotifier para el perfil del usuario actual
//   - profileNotifierProvider: proveedor del notifier de perfil
//   - profileStatsProvider: FutureProvider para estadísticas del usuario actual
//   - publicProfileProvider: FutureProvider.family para perfil público por userId
//   - publicProfileStatsProvider: FutureProvider.family para stats por userId
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/profile_repository.dart';
import '../../models/profile_model.dart';
import '../auth/auth_providers.dart';

// ----------------------------------------------------------
// Proveedor del repositorio
// ----------------------------------------------------------

/// Proveedor del repositorio de perfil de usuario
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

// ----------------------------------------------------------
// AsyncNotifier: gestiona el perfil del usuario actual
// ----------------------------------------------------------

/// Notifier que mantiene y actualiza el perfil del usuario autenticado
class ProfileNotifier extends AsyncNotifier<ProfileModel?> {
  @override
  Future<ProfileModel?> build() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return null;

    final repo = ref.read(profileRepositoryProvider);
    var profile = await repo.getProfile(user.id);

    // Si el perfil no existe, crearlo desde los metadatos de auth
    if (profile == null) {
      final meta = user.userMetadata ?? {};
      await repo.createProfileIfNotExists(
        user.id,
        meta['full_name'] as String? ?? '',
        meta['rut'] as String? ?? '',
      );
      profile = await repo.getProfile(user.id);
    }

    return profile;
  }

  // ----------------------------------------------------------
  // Recarga el perfil desde Supabase
  // ----------------------------------------------------------

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadProfile());
  }

  // ----------------------------------------------------------
  // Actualiza el nombre completo y recarga
  // ----------------------------------------------------------

  /// Actualiza el [fullName] del usuario actual. Retorna true si fue exitoso.
  Future<bool> updateFullName(String fullName) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return false;

    try {
      await ref.read(profileRepositoryProvider).updateProfile(user.id, fullName);
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ----------------------------------------------------------
  // Actualiza los campos de nombre (firstName, paternal, maternal)
  // ----------------------------------------------------------

  /// Actualiza el primer nombre y apellidos del usuario actual.
  /// Retorna true si fue exitoso.
  Future<bool> updateNameFields({
    required String firstName,
    String? lastNamePaternal,
    String? lastNameMaternal,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return false;

    try {
      await ref.read(profileRepositoryProvider).updateNameFields(
        user.id,
        firstName: firstName,
        lastNamePaternal: lastNamePaternal,
        lastNameMaternal: lastNameMaternal,
      );
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ----------------------------------------------------------
  // Actualiza el teléfono del usuario
  // ----------------------------------------------------------

  /// Actualiza el teléfono del usuario actual. Retorna true si fue exitoso.
  Future<bool> updatePhone(String? phone) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return false;

    try {
      await ref.read(profileRepositoryProvider).updatePhone(user.id, phone);
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ----------------------------------------------------------
  // Actualiza la contraseña vía Supabase Auth
  // ----------------------------------------------------------

  /// Actualiza la contraseña del usuario autenticado.
  /// Lanza una excepción descriptiva en caso de error.
  Future<void> updatePassword(String newPassword) async {
    await Supabase.instance.client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  // ----------------------------------------------------------
  // Actualiza el correo vía Supabase Auth
  // ----------------------------------------------------------

  /// Solicita el cambio de correo del usuario autenticado.
  /// Supabase enviará un enlace de confirmación al nuevo correo.
  /// Lanza una excepción descriptiva en caso de error.
  Future<void> updateEmail(String newEmail) async {
    await Supabase.instance.client.auth.updateUser(
      UserAttributes(email: newEmail),
    );
  }

  // ----------------------------------------------------------
  // Actualiza la configuración de privacidad y recarga
  // ----------------------------------------------------------

  /// Actualiza los ajustes de privacidad del usuario autenticado.
  Future<void> updatePrivacySettings({
    required bool showEmail,
    required bool showPhone,
    required bool showPosts,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      await ref.read(profileRepositoryProvider).updatePrivacySettings(
        user.id,
        showEmail: showEmail,
        showPhone: showPhone,
        showPosts: showPosts,
      );
      await refresh();
    } catch (_) {
      // Si falla, recargar el estado original desde Supabase
      await refresh();
    }
  }

  // ----------------------------------------------------------
  // Carga interna del perfil
  // ----------------------------------------------------------

  Future<ProfileModel?> _loadProfile() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return null;
    return ref.read(profileRepositoryProvider).getProfile(user.id);
  }
}

/// Proveedor principal del perfil del usuario autenticado
final profileNotifierProvider =
    AsyncNotifierProvider<ProfileNotifier, ProfileModel?>(
  ProfileNotifier.new,
);

// ----------------------------------------------------------
// FutureProvider: estadísticas del usuario autenticado
// ----------------------------------------------------------

/// Proveedor de estadísticas de publicaciones del usuario autenticado.
/// Se recalcula automáticamente cuando cambia el usuario actual.
final profileStatsProvider =
    FutureProvider.autoDispose<ProfileStats>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return ProfileStats.empty;
  return ref.read(profileRepositoryProvider).getStats(user.id);
});

// ----------------------------------------------------------
// FutureProvider.family: perfil público por userId
// ----------------------------------------------------------

/// Obtiene el perfil público de cualquier usuario por su [userId].
/// Usado por PublicProfileScreen para mostrar perfiles de otros usuarios.
final publicProfileProvider =
    FutureProvider.autoDispose.family<ProfileModel?, String>((ref, userId) {
  return ref.read(profileRepositoryProvider).getProfile(userId);
});

// ----------------------------------------------------------
// FutureProvider.family: estadísticas públicas por userId
// ----------------------------------------------------------

/// Obtiene las estadísticas de publicaciones de cualquier usuario por su [userId].
/// Aplicado junto con las reglas de privacidad en PublicProfileScreen.
final publicProfileStatsProvider =
    FutureProvider.autoDispose.family<ProfileStats, String>((ref, userId) {
  return ref.read(profileRepositoryProvider).getStats(userId);
});
