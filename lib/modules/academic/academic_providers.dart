// ============================================================
// academic_providers.dart
// Proveedores Riverpod del módulo de ofertas académicas.
//
// Contiene:
//   - academicRepositoryProvider: proveedor del repositorio
//   - AcademicNotifier: AsyncNotifier con fetch, refresh, create y delete
//   - academicNotifierProvider: proveedor del notifier (lista completa)
//   - MyAcademicNotifier: AsyncNotifier filtrado por el usuario actual
//   - myAcademicNotifierProvider: proveedor (solo mis ofertas académicas)
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/academic_repository.dart';
import '../../models/academic_offer_model.dart';
import '../auth/auth_providers.dart';

// ----------------------------------------------------------
// Proveedor del repositorio
// ----------------------------------------------------------

/// Proveedor del repositorio de ofertas académicas
final academicRepositoryProvider = Provider<AcademicRepository>((ref) {
  return AcademicRepository();
});

// ----------------------------------------------------------
// AsyncNotifier: gestiona la lista completa de ofertas académicas
// ----------------------------------------------------------

/// Notifier que mantiene y actualiza la lista de ofertas académicas
class AcademicNotifier extends AsyncNotifier<List<AcademicOfferModel>> {
  // Carga inicial al montar el proveedor
  @override
  Future<List<AcademicOfferModel>> build() {
    return ref.read(academicRepositoryProvider).getAllAcademicOffers();
  }

  // ----------------------------------------------------------
  // Recarga la lista desde Supabase
  // ----------------------------------------------------------

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(academicRepositoryProvider).getAllAcademicOffers(),
    );
  }

  // ----------------------------------------------------------
  // Crea una nueva oferta y recarga la lista
  // ----------------------------------------------------------

  Future<void> createOffer(AcademicOfferModel offer) async {
    await ref.read(academicRepositoryProvider).createAcademicOffer(offer);
    await refresh();
  }

  // ----------------------------------------------------------
  // Elimina una oferta por id y recarga la lista
  // ----------------------------------------------------------

  Future<void> deleteOffer(String id) async {
    await ref.read(academicRepositoryProvider).deleteAcademicOffer(id);
    await refresh();
  }
}

/// Proveedor principal de la lista de ofertas académicas
final academicNotifierProvider =
    AsyncNotifierProvider<AcademicNotifier, List<AcademicOfferModel>>(
  AcademicNotifier.new,
);

// ----------------------------------------------------------
// AsyncNotifier: gestiona las ofertas académicas del usuario actual
// ----------------------------------------------------------

/// Notifier que muestra solo las ofertas académicas del usuario autenticado.
/// Usado al tocar la tarjeta de estadísticas en el perfil.
class MyAcademicNotifier extends AsyncNotifier<List<AcademicOfferModel>> {
  @override
  Future<List<AcademicOfferModel>> build() {
    final user = ref.read(currentUserProvider);
    if (user == null) return Future.value([]);
    return ref.read(academicRepositoryProvider).getAcademicOffersByUser(user.id);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() {
      final user = ref.read(currentUserProvider);
      if (user == null) return Future.value([]);
      return ref
          .read(academicRepositoryProvider)
          .getAcademicOffersByUser(user.id);
    });
  }

  Future<void> deleteOffer(String id) async {
    await ref.read(academicRepositoryProvider).deleteAcademicOffer(id);
    await refresh();
  }
}

/// Proveedor de las ofertas académicas publicadas por el usuario autenticado
final myAcademicNotifierProvider =
    AsyncNotifierProvider<MyAcademicNotifier, List<AcademicOfferModel>>(
  MyAcademicNotifier.new,
);

// ----------------------------------------------------------
// FamilyAsyncNotifier: ofertas académicas de cualquier usuario por userId
// ----------------------------------------------------------

/// Notifier que muestra las ofertas académicas de un usuario específico.
/// Usado al tocar las estadísticas en el perfil público de otro usuario.
class UserAcademicNotifier
    extends FamilyAsyncNotifier<List<AcademicOfferModel>, String> {
  @override
  Future<List<AcademicOfferModel>> build(String userId) {
    return ref.read(academicRepositoryProvider).getAcademicOffersByUser(userId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(academicRepositoryProvider).getAcademicOffersByUser(arg),
    );
  }
}

/// Proveedor de ofertas académicas filtradas por cualquier [userId]
final userAcademicNotifierProvider = AsyncNotifierProvider.family<
    UserAcademicNotifier, List<AcademicOfferModel>, String>(
  UserAcademicNotifier.new,
);
