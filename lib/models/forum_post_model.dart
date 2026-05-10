// ============================================================
// forum_post_model.dart
// Modelo de publicación del foro comunitario de GGSS.cl.
// ============================================================

/// Modelo de post del foro
class ForumPostModel {
  final String id;
  final String title;
  final String content;

  /// Categoría del post (Laboral, Académico, Consulta, etc.) — opcional
  final String? category;

  /// UUID del usuario autor (columna 'created_by' en Supabase)
  final String userId;

  /// Nombre del autor (desde join con tabla profiles)
  final String? authorName;

  /// Primer nombre del autor para visualización pública
  final String? authorFirstName;

  // DEPRECATED: alias system - kept for potential future use
  // final String? authorAlias;

  /// URL del avatar del autor
  final String? authorAvatarUrl;

  final DateTime createdAt;

  /// Cantidad de comentarios (desde count embebido en la consulta)
  final int commentCount;

  const ForumPostModel({
    required this.id,
    required this.title,
    required this.content,
    this.category,
    required this.userId,
    this.authorName,
    this.authorFirstName,
    this.authorAvatarUrl,
    required this.createdAt,
    this.commentCount = 0,
  });

  // ----------------------------------------------------------
  // Conversión desde respuesta de Supabase
  // ----------------------------------------------------------

  factory ForumPostModel.fromMap(Map<String, dynamic> map) {
    // Extraer datos del autor desde el join con profiles
    final profiles = map['profiles'] as Map<String, dynamic>?;

    // Extraer el conteo de comentarios embebido en la consulta
    final commentsData = map['forum_comments'] as List<dynamic>?;
    final commentCount = commentsData != null && commentsData.isNotEmpty
        ? (commentsData.first as Map<String, dynamic>)['count'] as int? ?? 0
        : 0;

    return ForumPostModel(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      category: map['category'] as String?,
      userId: map['created_by'] as String? ?? '',
      authorName: profiles?['full_name'] as String?,
      authorFirstName: _buildAuthorName(profiles),
      authorAvatarUrl: profiles?['avatar_url'] as String?,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      commentCount: commentCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      if (category != null && category!.isNotEmpty) 'category': category,
      'created_by': userId,
    };
  }
}

String? _buildAuthorName(Map<String, dynamic>? profiles) {
  if (profiles == null) return null;
  final showFull = profiles['show_full_name_in_posts'] as bool? ?? false;
  final fn = profiles['first_name'] as String? ??
      (profiles['full_name'] as String?)?.split(' ').first;
  if (!showFull || fn == null) return fn;
  final parts = [
    fn,
    if ((profiles['last_name_paternal'] as String?)?.isNotEmpty == true)
      profiles['last_name_paternal'] as String,
    if ((profiles['last_name_maternal'] as String?)?.isNotEmpty == true)
      profiles['last_name_maternal'] as String,
  ];
  return parts.join(' ');
}
