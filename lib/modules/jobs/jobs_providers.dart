// ============================================================
// jobs_providers.dart
// Proveedores Riverpod del módulo de ofertas laborales.
//
// Contiene:
//   - jobsRepositoryProvider: proveedor del repositorio
//   - JobsNotifier: AsyncNotifier con fetch, refresh, create y delete
//   - jobsNotifierProvider: proveedor del notifier (lista completa)
//   - MyJobsNotifier: AsyncNotifier filtrado por el usuario actual
//   - myJobsNotifierProvider: proveedor del notifier (solo mis ofertas)
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/jobs_repository.dart';
import '../../models/job_model.dart';
import '../auth/auth_providers.dart';

// ----------------------------------------------------------
// Proveedor del repositorio
// ----------------------------------------------------------

/// Proveedor del repositorio de ofertas laborales
final jobsRepositoryProvider = Provider<JobsRepository>((ref) {
  return JobsRepository();
});

// ----------------------------------------------------------
// AsyncNotifier: gestiona la lista completa de ofertas laborales
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

// ----------------------------------------------------------
// AsyncNotifier: gestiona las ofertas del usuario autenticado
// ----------------------------------------------------------

/// Notifier que muestra solo las ofertas laborales del usuario actual.
/// Usado al tocar la tarjeta de estadísticas en el perfil.
class MyJobsNotifier extends AsyncNotifier<List<JobModel>> {
  @override
  Future<List<JobModel>> build() {
    final user = ref.read(currentUserProvider);
    if (user == null) return Future.value([]);
    return ref.read(jobsRepositoryProvider).getJobsByUser(user.id);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() {
      final user = ref.read(currentUserProvider);
      if (user == null) return Future.value([]);
      return ref.read(jobsRepositoryProvider).getJobsByUser(user.id);
    });
  }

  Future<void> deleteJob(String id) async {
    await ref.read(jobsRepositoryProvider).deleteJob(id);
    await refresh();
  }
}

/// Proveedor de las ofertas laborales publicadas por el usuario autenticado
final myJobsNotifierProvider =
    AsyncNotifierProvider<MyJobsNotifier, List<JobModel>>(
  MyJobsNotifier.new,
);

// ----------------------------------------------------------
// FamilyAsyncNotifier: ofertas laborales de cualquier usuario por userId
// ----------------------------------------------------------

/// Notifier que muestra las ofertas laborales de un usuario específico.
/// Usado al tocar las estadísticas en el perfil público de otro usuario.
class UserJobsNotifier
    extends FamilyAsyncNotifier<List<JobModel>, String> {
  @override
  Future<List<JobModel>> build(String userId) {
    return ref.read(jobsRepositoryProvider).getJobsByUser(userId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(jobsRepositoryProvider).getJobsByUser(arg),
    );
  }
}

/// Proveedor de ofertas laborales filtradas por cualquier [userId]
final userJobsNotifierProvider =
    AsyncNotifierProvider.family<UserJobsNotifier, List<JobModel>, String>(
  UserJobsNotifier.new,
);
