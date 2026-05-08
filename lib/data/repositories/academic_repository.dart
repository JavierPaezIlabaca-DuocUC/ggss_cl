// ============================================================
// academic_repository.dart
// Repositorio de ofertas académicas: convierte los datos crudos
// de Supabase en modelos tipados de la app.
// ============================================================

import '../../models/academic_offer_model.dart';
import '../services/academic_service.dart';

/// Repositorio de ofertas académicas de GGSS.cl
class AcademicRepository {
  final AcademicService _academicService;

  AcademicRepository({AcademicService? academicService})
      : _academicService = academicService ?? AcademicService();

  /// Retorna todas las ofertas académicas como lista de [AcademicOfferModel]
  Future<List<AcademicOfferModel>> getAllAcademicOffers() async {
    final data = await _academicService.fetchAllAcademicOffers();
    return data.map(AcademicOfferModel.fromMap).toList();
  }

  /// Retorna solo las ofertas académicas creadas por [userId]
  Future<List<AcademicOfferModel>> getAcademicOffersByUser(
    String userId,
  ) async {
    final data = await _academicService.fetchAcademicOffersByUser(userId);
    return data.map(AcademicOfferModel.fromMap).toList();
  }

  /// Retorna una oferta académica por su [id]
  Future<AcademicOfferModel?> getAcademicOfferById(String id) async {
    final data = await _academicService.fetchAcademicOfferById(id);
    return data != null ? AcademicOfferModel.fromMap(data) : null;
  }

  /// Crea una nueva oferta académica desde un [AcademicOfferModel]
  Future<void> createAcademicOffer(AcademicOfferModel offer) async {
    await _academicService.createAcademicOffer(offer.toMap());
  }

  /// Actualiza una oferta académica existente
  Future<void> updateAcademicOffer(
      String id, AcademicOfferModel offer) async {
    await _academicService.updateAcademicOffer(id, offer.toMap());
  }

  /// Elimina una oferta académica por su [id]
  Future<void> deleteAcademicOffer(String id) async {
    await _academicService.deleteAcademicOffer(id);
  }
}
