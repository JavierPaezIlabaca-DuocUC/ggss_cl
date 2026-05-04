// ============================================================
// user_model.dart
// Modelo de usuario de GGSS.cl (perfil guardado en Supabase).
// Complementa el objeto User de Supabase Auth.
// ============================================================

/// Modelo de perfil de usuario de GGSS.cl
class UserModel {
  /// Identificador único del usuario (UUID de Supabase Auth)
  final String id;

  /// Correo electrónico del usuario
  final String email;

  /// Nombre completo del usuario
  final String fullName;

  /// URL del avatar del usuario (puede ser null)
  final String? avatarUrl;

  /// Fecha de creación del perfil
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    required this.createdAt,
  });

  // ----------------------------------------------------------
  // Conversión desde mapa de Supabase
  // ----------------------------------------------------------

  /// Crea un [UserModel] desde un mapa retornado por Supabase
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String? ?? '',
      fullName: map['full_name'] as String? ?? 'Usuario',
      avatarUrl: map['avatar_url'] as String?,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  // ----------------------------------------------------------
  // Conversión a mapa para Supabase
  // ----------------------------------------------------------

  /// Convierte el modelo a un mapa para guardar en Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
    };
  }

  // ----------------------------------------------------------
  // Copia con modificaciones
  // ----------------------------------------------------------

  /// Retorna una copia del modelo con los campos modificados
  UserModel copyWith({
    String? fullName,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
    );
  }
}
