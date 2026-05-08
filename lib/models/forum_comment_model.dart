// ============================================================
// forum_comment_model.dart
// Modelo de comentario del foro comunitario de GGSS.cl.
// ============================================================

/// Modelo de comentario en el foro
class ForumCommentModel {
  final String id;
  final String postId;
  final String content;

  /// UUID del usuario autor (columna 'created_by' en Supabase)
  final String userId;

  /// Nombre del autor del comentario
  final String? authorName;

  /// Alias público del autor (mostrado en lugar de authorName si está disponible)
  final String? authorAlias;

  /// URL del avatar del autor
  final String? authorAvatarUrl;

  final DateTime createdAt;

  const ForumCommentModel({
    required this.id,
    required this.postId,
    required this.content,
    required this.userId,
    this.authorName,
    this.authorAlias,
    this.authorAvatarUrl,
    required this.createdAt,
  });

  factory ForumCommentModel.fromMap(Map<String, dynamic> map) {
    final profiles = map['profiles'] as Map<String, dynamic>?;

    return ForumCommentModel(
      id: map['id'] as String,
      postId: map['post_id'] as String? ?? '',
      content: map['content'] as String? ?? '',
      userId: map['created_by'] as String? ?? '',
      authorName: profiles?['full_name'] as String?,
      authorAlias: profiles?['alias'] as String?,
      authorAvatarUrl: profiles?['avatar_url'] as String?,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'post_id': postId,
      'content': content,
      'created_by': userId,
    };
  }
}
