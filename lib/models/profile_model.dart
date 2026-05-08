// ============================================================
// profile_model.dart
// Modelo del perfil de usuario de GGSS.cl.
// Representa los datos de la tabla 'profiles' en Supabase,
// complementando la información de autenticación de Supabase Auth.
// ============================================================

/// Modelo de perfil de usuario guardado en la tabla 'profiles'
class ProfileModel {
  /// UUID del usuario (referencia a auth.users.id)
  final String id;

  /// Nombre completo del usuario
  final String fullName;

  /// RUT chileno del usuario (solo lectura después del registro)
  final String rut;

  /// URL del avatar del usuario (null = mostrar iniciales)
  final String? avatarUrl;

  /// Tipo de cuenta: 'personal' o 'empresa'
  final String accountType;

  /// Teléfono de contacto con prefijo +569 (ej: +56912345678)
  final String? phone;

  /// Alias público mostrado en foro y publicaciones (opcional)
  final String? alias;

  /// Fecha de creación del perfil
  final DateTime createdAt;

  const ProfileModel({
    required this.id,
    required this.fullName,
    required this.rut,
    this.avatarUrl,
    this.accountType = 'personal',
    this.phone,
    this.alias,
    required this.createdAt,
  });

  // ----------------------------------------------------------
  // Conversión desde mapa de Supabase
  // ----------------------------------------------------------

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] as String,
      fullName: map['full_name'] as String? ?? '',
      rut: map['rut'] as String? ?? '',
      avatarUrl: map['avatar_url'] as String?,
      accountType: map['account_type'] as String? ?? 'personal',
      phone: map['phone'] as String?,
      alias: map['alias'] as String?,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  // ----------------------------------------------------------
  // Copia con modificaciones
  // ----------------------------------------------------------

  ProfileModel copyWith({String? fullName, String? avatarUrl, String? alias}) {
    return ProfileModel(
      id: id,
      fullName: fullName ?? this.fullName,
      rut: rut,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      accountType: accountType,
      phone: phone,
      alias: alias ?? this.alias,
      createdAt: createdAt,
    );
  }
}

// ============================================================
// Estadísticas de publicaciones del usuario
// ============================================================

/// Contadores de publicaciones del usuario en cada módulo
class ProfileStats {
  final int jobCount;
  final int academicCount;
  final int forumCount;

  const ProfileStats({
    required this.jobCount,
    required this.academicCount,
    required this.forumCount,
  });

  static const ProfileStats empty = ProfileStats(
    jobCount: 0,
    academicCount: 0,
    forumCount: 0,
  );
}
