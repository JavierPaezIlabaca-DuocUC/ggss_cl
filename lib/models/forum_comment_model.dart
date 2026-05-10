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

  /// Primer nombre del autor para visualización pública
  final String? authorFirstName;

  // DEPRECATED: alias system - kept for potential future use
  // final String? authorAlias;

  /// URL del avatar del autor
  final String? authorAvatarUrl;

  final DateTime createdAt;

  const ForumCommentModel({
    required this.id,
    required this.postId,
    required this.content,
    required this.userId,
    this.authorName,
    this.authorFirstName,
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
      authorFirstName: _buildAuthorName(profiles),
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
