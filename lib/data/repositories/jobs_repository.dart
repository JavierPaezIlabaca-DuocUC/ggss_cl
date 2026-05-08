// ============================================================
// jobs_repository.dart
// Repositorio de ofertas laborales: convierte los datos crudos
// de Supabase en modelos tipados de la app.
// ============================================================

import '../../models/job_model.dart';
import '../services/jobs_service.dart';

/// Repositorio de ofertas laborales de GGSS.cl
class JobsRepository {
  final JobsService _jobsService;

  JobsRepository({JobsService? jobsService})
      : _jobsService = jobsService ?? JobsService();

  /// Retorna todas las ofertas laborales como lista de [JobModel]
  Future<List<JobModel>> getAllJobs() async {
    final data = await _jobsService.fetchAllJobs();
    return data.map(JobModel.fromMap).toList();
  }

  /// Retorna solo las ofertas laborales creadas por [userId]
  Future<List<JobModel>> getJobsByUser(String userId) async {
    final data = await _jobsService.fetchJobsByUser(userId);
    return data.map(JobModel.fromMap).toList();
  }

  /// Retorna una oferta laboral por su [id]
  Future<JobModel?> getJobById(String id) async {
    final data = await _jobsService.fetchJobById(id);
    return data != null ? JobModel.fromMap(data) : null;
  }

  /// Crea una nueva oferta laboral desde un [JobModel]
  Future<void> createJob(JobModel job) async {
    await _jobsService.createJob(job.toMap());
  }

  /// Actualiza una oferta laboral existente
  Future<void> updateJob(String id, JobModel job) async {
    await _jobsService.updateJob(id, job.toMap());
  }

  /// Elimina una oferta laboral por su [id]
  Future<void> deleteJob(String id) async {
    await _jobsService.deleteJob(id);
  }
}
