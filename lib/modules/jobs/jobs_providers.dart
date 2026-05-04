// ============================================================
// jobs_providers.dart
// Proveedores Riverpod del módulo de ofertas laborales.
//
// Contiene:
//   - jobsRepositoryProvider: proveedor del repositorio
//   - JobsNotifier: AsyncNotifier con fetch, refresh, create y delete
//   - jobsNotifierProvider: proveedor del notifier
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/jobs_repository.dart';
import '../../models/job_model.dart';

// ----------------------------------------------------------
// Proveedor del repositorio
// ----------------------------------------------------------

/// Proveedor del repositorio de ofertas laborales
final jobsRepositoryProvider = Provider<JobsRepository>((ref) {
  return JobsRepository();
});

// ----------------------------------------------------------
// AsyncNotifier: gestiona la lista de ofertas laborales
// ----------------------------------------------------------

/// Notifier que mantiene y actualiza la lista de ofertas laborales
class JobsNotifier extends AsyncNotifier<List<JobModel>> {
  // Carga inicial al montar el proveedor
  @override
  Future<List<JobModel>> build() {
    return ref.read(jobsRepositoryProvider).getAllJobs();
  }

  // ----------------------------------------------------------
  // Recarga la lista desde Supabase
  // ----------------------------------------------------------

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(jobsRepositoryProvider).getAllJobs(),
    );
  }

  // ----------------------------------------------------------
  // Crea una nueva oferta y recarga la lista
  // ----------------------------------------------------------

  Future<void> createJob(JobModel job) async {
    await ref.read(jobsRepositoryProvider).createJob(job);
    await refresh();
  }

  // ----------------------------------------------------------
  // Elimina una oferta por id y recarga la lista
  // ----------------------------------------------------------

  Future<void> deleteJob(String id) async {
    await ref.read(jobsRepositoryProvider).deleteJob(id);
    await refresh();
  }
}

/// Proveedor principal de la lista de ofertas laborales
final jobsNotifierProvider =
    AsyncNotifierProvider<JobsNotifier, List<JobModel>>(
  JobsNotifier.new,
);
