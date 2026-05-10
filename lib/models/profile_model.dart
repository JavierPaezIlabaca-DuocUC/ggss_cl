// ============================================================
// profile_model.dart
// Modelo del perfil de usuario de GGSS.cl.
// Representa los datos de la tabla 'profiles' en Supabase.
// ============================================================

/// Modelo de perfil de usuario guardado en la tabla 'profiles'
class ProfileModel {
  /// UUID del usuario (referencia a auth.users.id)
  final String id;

  /// Primer nombre del usuario (requerido para nuevas cuentas)
  final String firstName;

  /// Apellido paterno (requerido para nuevas cuentas)
  final String? lastNamePaternal;

  /// Apellido materno (opcional)
  final String? lastNameMaternal;

  // DEPRECATED: alias system - kept for potential future use
  // final String? alias;

  /// RUT chileno del usuario (solo lectura después del registro)
  final String rut;

  /// URL del avatar del usuario (null = mostrar iniciales)
  final String? avatarUrl;

  /// Tipo de cuenta: 'personal' o 'empresa'
  final String accountType;

  /// Teléfono de contacto con prefijo +569 (ej: +56912345678)
  final String? phone;

  /// Fecha de creación del perfil
  final DateTime createdAt;

  // ----------------------------------------------------------
  // Configuración de privacidad (cuentas personales)
  // ----------------------------------------------------------

  final bool showEmail;
  final bool showPhone;
  final bool showPosts;

  const ProfileModel({
    required this.id,
    required this.firstName,
    this.lastNamePaternal,
    this.lastNameMaternal,
    required this.rut,
    this.avatarUrl,
    this.accountType = 'personal',
    this.phone,
    required this.createdAt,
    this.showEmail = false,
    this.showPhone = false,
    this.showPosts = true,
  });

  // ----------------------------------------------------------
  // Nombre completo computado desde las partes
  // ----------------------------------------------------------

  /// Nombre completo: "Primer Apellido-Paterno Apellido-Materno"
  String get fullName {
    final parts = [
      firstName,
      if (lastNamePaternal != null && lastNamePaternal!.isNotEmpty)
        lastNamePaternal!,
      if (lastNameMaternal != null && lastNameMaternal!.isNotEmpty)
        lastNameMaternal!,
    ];
    return parts.join(' ').trim();
  }

  // ----------------------------------------------------------
  // Conversión desde mapa de Supabase
  // ----------------------------------------------------------

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    // Compatibilidad hacia atrás: perfiles creados antes de los campos de nombre
    // separados solo tienen full_name. Derivamos firstName del primer token
    // para que la app siga funcionando con perfiles antiguos.
    final storedFirstName = map['first_name'] as String?;
    final storedFullName = map['full_name'] as String? ?? '';
    final firstName = (storedFirstName != null && storedFirstName.isNotEmpty)
        ? storedFirstName
        : storedFullName.split(' ').first;

    return ProfileModel(
      id: map['id'] as String,
      firstName: firstName,
      lastNamePaternal: map['last_name_paternal'] as String?,
      lastNameMaternal: map['last_name_maternal'] as String?,
      rut: map['rut'] as String? ?? '',
      avatarUrl: map['avatar_url'] as String?,
      accountType: map['account_type'] as String? ?? 'personal',
      phone: map['phone'] as String?,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      showEmail: map['show_email'] as bool? ?? false,
      showPhone: map['show_phone'] as bool? ?? false,
      showPosts: map['show_posts'] as bool? ?? true,
    );
  }

  // ----------------------------------------------------------
  // Copia con modificaciones
  // ----------------------------------------------------------

  ProfileModel copyWith({
    String? firstName,
    String? lastNamePaternal,
    String? lastNameMaternal,
    String? avatarUrl,
    String? phone,
    bool? showEmail,
    bool? showPhone,
    bool? showPosts,
  }) {
    return ProfileModel(
      id: id,
      firstName: firstName ?? this.firstName,
      lastNamePaternal: lastNamePaternal ?? this.lastNamePaternal,
      lastNameMaternal: lastNameMaternal ?? this.lastNameMaternal,
      rut: rut,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      accountType: accountType,
      phone: phone ?? this.phone,
      createdAt: createdAt,
      showEmail: showEmail ?? this.showEmail,
      showPhone: showPhone ?? this.showPhone,
      showPosts: showPosts ?? this.showPosts,
    );
  }

  /// Indica si la cuenta es de tipo empresa
  bool get isEmpresa => accountType == 'empresa';
}

// ============================================================
// Estadísticas de publicaciones del usuario
// ============================================================

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
