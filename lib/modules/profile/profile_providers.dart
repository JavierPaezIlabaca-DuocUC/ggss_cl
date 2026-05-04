// ============================================================
// profile_providers.dart
// Proveedores Riverpod del módulo de perfil de usuario.
//
// Contiene:
//   - profileRepositoryProvider: proveedor del repositorio
//   - ProfileNotifier: AsyncNotifier para el perfil del usuario actual
//   - profileNotifierProvider: proveedor del notifier de perfil
//   - profileStatsProvider: FutureProvider para estadísticas del usuario
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

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
// FutureProvider: estadísticas de publicaciones del usuario
// ----------------------------------------------------------

/// Proveedor de estadísticas de publicaciones del usuario autenticado.
/// Se recalcula automáticamente cuando cambia el usuario actual.
final profileStatsProvider = FutureProvider.autoDispose<ProfileStats>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return ProfileStats.empty;
  return ref.read(profileRepositoryProvider).getStats(user.id);
});
