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
  final String? address;
  final String? url;
  final String createdBy;

  /// Nombre del autor (desde join con tabla profiles vía created_by)
  final String? authorName;

  /// Primer nombre del autor para visualización pública
  final String? authorFirstName;

  // DEPRECATED: alias system - kept for potential future use
  // final String? authorAlias;

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
    this.address,
    this.url,
    required this.createdBy,
    this.authorName,
    this.authorFirstName,
    required this.createdAt,
    this.updatedAt,
  });

  /// Construye un [AcademicOfferModel] desde un mapa de Supabase
  factory AcademicOfferModel.fromMap(Map<String, dynamic> map) {
    // Extraer nombre del autor desde join con profiles
    final profiles = map['profiles'] as Map<String, dynamic>?;

    return AcademicOfferModel(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      institution: map['institution'] as String? ?? '',
      description: map['description'] as String? ?? '',
      requirements: map['requirements'] as String?,
      duration: map['duration'] as String?,
      price: map['price'] as String?,
      contactWhatsapp: map['contact_whatsapp'] as String?,
      address: map['address'] as String?,
      url: map['url'] as String?,
      createdBy: map['created_by'] as String? ?? '',
      authorName: profiles?['full_name'] as String?,
      authorFirstName: profiles?['first_name'] as String?,
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
      if (address != null && address!.isNotEmpty) 'address': address,
      if (url != null && url!.isNotEmpty) 'url': url,
      'created_by': createdBy,
    };
  }

  /// Indica si tiene número de WhatsApp para contacto
  bool get hasWhatsapp =>
      contactWhatsapp != null && contactWhatsapp!.isNotEmpty;

  /// Indica si tiene dirección específica para mostrar en Google Maps
  bool get hasAddress => address != null && address!.isNotEmpty;

  /// Indica si tiene URL de inscripción o información
  bool get hasUrl => url != null && url!.isNotEmpty;
}
