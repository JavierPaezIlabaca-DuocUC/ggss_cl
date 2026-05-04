// ============================================================
// academic_providers.dart
// Proveedores Riverpod del módulo de ofertas académicas.
//
// Contiene:
//   - academicRepositoryProvider: proveedor del repositorio
//   - AcademicNotifier: AsyncNotifier con fetch, refresh, create y delete
//   - academicNotifierProvider: proveedor del notifier
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/academic_repository.dart';
import '../../models/academic_offer_model.dart';

// ----------------------------------------------------------
// Proveedor del repositorio
// ----------------------------------------------------------

/// Proveedor del repositorio de ofertas académicas
final academicRepositoryProvider = Provider<AcademicRepository>((ref) {
  return AcademicRepository();
});

// ----------------------------------------------------------
// AsyncNotifier: gestiona la lista de ofertas académicas
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
