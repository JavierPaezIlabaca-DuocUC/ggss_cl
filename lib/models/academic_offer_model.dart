// ============================================================
// academic_offer_model.dart
// Modelo de oferta académica de GGSS.cl.
// Mapea exactamente la tabla 'academic_offers' en Supabase.
// ============================================================

/// Modelo inmutable de oferta académica (cursos, capacitaciones)
class AcademicOfferModel {
  final String id;
  final String title;
  final String institution;
  final String description;
  final String? requirements;
  final String? duration;
  final String? price;
  final String? contactWhatsapp;
  final String? url;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AcademicOfferModel({
    required this.id,
    required this.title,
    required this.institution,
    required this.description,
    this.requirements,
    this.duration,
    this.price,
    this.contactWhatsapp,
    this.url,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
  });

  /// Construye un [AcademicOfferModel] desde un mapa de Supabase
  factory AcademicOfferModel.fromMap(Map<String, dynamic> map) {
    return AcademicOfferModel(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      institution: map['institution'] as String? ?? '',
      description: map['description'] as String? ?? '',
      requirements: map['requirements'] as String?,
      duration: map['duration'] as String?,
      price: map['price'] as String?,
      contactWhatsapp: map['contact_whatsapp'] as String?,
      url: map['url'] as String?,
      createdBy: map['created_by'] as String? ?? '',
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'] as String)
          : null,
    );
  }

  /// Convierte el modelo a mapa para insertar en Supabase.
  /// No incluye 'id', 'created_at' ni 'updated_at': los genera la BD.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'institution': institution,
      'description': description,
      if (requirements != null && requirements!.isNotEmpty)
        'requirements': requirements,
      if (duration != null && duration!.isNotEmpty) 'duration': duration,
      if (price != null && price!.isNotEmpty) 'price': price,
      if (contactWhatsapp != null && contactWhatsapp!.isNotEmpty)
        'contact_whatsapp': contactWhatsapp,
      if (url != null && url!.isNotEmpty) 'url': url,
      'created_by': createdBy,
    };
  }

  /// Indica si tiene número de WhatsApp para contacto
  bool get hasWhatsapp =>
      contactWhatsapp != null && contactWhatsapp!.isNotEmpty;

  /// Indica si tiene URL de inscripción o información
  bool get hasUrl => url != null && url!.isNotEmpty;
}
