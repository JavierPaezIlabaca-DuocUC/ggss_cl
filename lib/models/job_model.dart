// ============================================================
// job_model.dart
// Modelo de oferta laboral de GGSS.cl.
// ============================================================

/// Modelo de oferta laboral
class JobModel {
  final String id;
  final String title;
  final String description;
  final String company;
  final String location;
  final String? phoneWhatsApp;
  final String? mapsUrl;
  final String userId;
  final DateTime createdAt;

  const JobModel({
    required this.id,
    required this.title,
    required this.description,
    required this.company,
    required this.location,
    this.phoneWhatsApp,
    this.mapsUrl,
    required this.userId,
    required this.createdAt,
  });

  factory JobModel.fromMap(Map<String, dynamic> map) {
    return JobModel(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      company: map['company'] as String? ?? '',
      location: map['location'] as String? ?? '',
      phoneWhatsApp: map['phone_whatsapp'] as String?,
      mapsUrl: map['maps_url'] as String?,
      userId: map['user_id'] as String? ?? '',
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'company': company,
      'location': location,
      'phone_whatsapp': phoneWhatsApp,
      'maps_url': mapsUrl,
      'user_id': userId,
    };
  }
}
