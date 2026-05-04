// ============================================================
// forum_post_model.dart
// Modelo de publicación del foro comunitario de GGSS.cl.
// ============================================================

/// Modelo de post del foro
class ForumPostModel {
  final String id;
  final String title;
  final String content;
  final String userId;

  /// Nombre del autor (desde join con tabla profiles)
  final String? authorName;

  /// URL del avatar del autor
  final String? authorAvatarUrl;

  final DateTime createdAt;

  const ForumPostModel({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    this.authorName,
    this.authorAvatarUrl,
    required this.createdAt,
  });

  factory ForumPostModel.fromMap(Map<String, dynamic> map) {
    // Extraer datos del autor desde el join con profiles
    final profiles = map['profiles'] as Map<String, dynamic>?;

    return ForumPostModel(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      authorName: profiles?['full_name'] as String?,
      authorAvatarUrl: profiles?['avatar_url'] as String?,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'user_id': userId,
    };
  }
}
