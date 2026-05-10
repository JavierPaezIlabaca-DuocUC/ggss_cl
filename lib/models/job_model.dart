// ============================================================
// job_model.dart
// Modelo de oferta laboral de GGSS.cl.
// Mapea exactamente la tabla 'job_offers' en Supabase.
// ============================================================

/// Modelo inmutable de oferta laboral
class JobModel {
  final String id;
  final String title;
  final String company;
  final String location;
  final String description;
  final String? requirements;
  final String? salaryRange;
  final String? contactWhatsapp;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String createdBy;

  /// Nombre del autor (desde join con tabla profiles vía created_by)
  final String? authorName;

  /// Alias público del autor (mostrado en lugar de authorName si está disponible)
  final String? authorAlias;

  final DateTime createdAt;
  final DateTime? updatedAt;

  const JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.description,
    this.requirements,
    this.salaryRange,
    this.contactWhatsapp,
    this.address,
    this.latitude,
    this.longitude,
    required this.createdBy,
    this.authorName,
    this.authorAlias,
    required this.createdAt,
    this.updatedAt,
  });

  /// Construye un [JobModel] desde un mapa de Supabase
  factory JobModel.fromMap(Map<String, dynamic> map) {
    // Extraer nombre del autor desde join con profiles
    final profiles = map['profiles'] as Map<String, dynamic>?;

    return JobModel(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      company: map['company'] as String? ?? '',
      location: map['location'] as String? ?? '',
      description: map['description'] as String? ?? '',
      requirements: map['requirements'] as String?,
      salaryRange: map['salary_range'] as String?,
      contactWhatsapp: map['contact_whatsapp'] as String?,
      address: map['address'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      createdBy: map['created_by'] as String? ?? '',
      authorName: profiles?['full_name'] as String?,
      authorAlias: profiles?['alias'] as String?,
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
      'company': company,
      'location': location,
      'description': description,
      if (requirements != null && requirements!.isNotEmpty)
        'requirements': requirements,
      if (salaryRange != null && salaryRange!.isNotEmpty)
        'salary_range': salaryRange,
      if (contactWhatsapp != null && contactWhatsapp!.isNotEmpty)
        'contact_whatsapp': contactWhatsapp,
      if (address != null && address!.isNotEmpty) 'address': address,
      'created_by': createdBy,
    };
  }

  /// Indica si tiene número de WhatsApp para contacto
  bool get hasWhatsapp =>
      contactWhatsapp != null && contactWhatsapp!.isNotEmpty;

  /// Indica si tiene dirección específica para mostrar en Google Maps
  bool get hasAddress => address != null && address!.isNotEmpty;
}
