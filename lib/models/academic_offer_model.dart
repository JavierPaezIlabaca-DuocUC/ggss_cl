// ============================================================
// academic_offer_model.dart
// Modelo de oferta académica de GGSS.cl.
// ============================================================

/// Modelo de oferta académica (cursos, capacitaciones)
class AcademicOfferModel {
  final String id;
  final String title;
  final String description;
  final String institution;
  final String? url;
  final String? imageUrl;
  final String userId;
  final DateTime createdAt;

  const AcademicOfferModel({
    required this.id,
    required this.title,
    required this.description,
    required this.institution,
    this.url,
    this.imageUrl,
    required this.userId,
    required this.createdAt,
  });

  factory AcademicOfferModel.fromMap(Map<String, dynamic> map) {
    return AcademicOfferModel(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      institution: map['institution'] as String? ?? '',
      url: map['url'] as String?,
      imageUrl: map['image_url'] as String?,
      userId: map['user_id'] as String? ?? '',
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'institution': institution,
      'url': url,
      'image_url': imageUrl,
      'user_id': userId,
    };
  }
}
