// ============================================================
// academic_repository.dart
// Repositorio de ofertas académicas.
// ============================================================

import '../../models/academic_offer_model.dart';
import '../services/academic_service.dart';

/// Repositorio de ofertas académicas de GGSS.cl
class AcademicRepository {
  final AcademicService _academicService;

  AcademicRepository({AcademicService? academicService})
      : _academicService = academicService ?? AcademicService();

  /// Retorna todas las ofertas académicas
  Future<List<AcademicOfferModel>> getAllAcademicOffers() async {
    final data = await _academicService.fetchAllAcademicOffers();
    return data.map(AcademicOfferModel.fromMap).toList();
  }

  /// Retorna una oferta académica por su [id]
  Future<AcademicOfferModel?> getAcademicOfferById(String id) async {
    final data = await _academicService.fetchAcademicOfferById(id);
    return data != null ? AcademicOfferModel.fromMap(data) : null;
  }

  /// Crea una nueva oferta académica
  Future<void> createAcademicOffer(AcademicOfferModel offer) async {
    await _academicService.createAcademicOffer(offer.toMap());
  }

  /// Actualiza una oferta académica existente
  Future<void> updateAcademicOffer(String id, AcademicOfferModel offer) async {
    await _academicService.updateAcademicOffer(id, offer.toMap());
  }

  /// Elimina una oferta académica
  Future<void> deleteAcademicOffer(String id) async {
    await _academicService.deleteAcademicOffer(id);
  }
}
