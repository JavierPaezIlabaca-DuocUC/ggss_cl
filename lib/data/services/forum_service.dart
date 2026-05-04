// ============================================================
// forum_service.dart
// Servicio del foro comunitario — CRUD de posts y comentarios
// contra las tablas 'forum_posts' y 'forum_comments' en Supabase.
// ============================================================

import '../supabase/supabase_client.dart';

/// Nombres de tablas del foro en Supabase
const String _tableForumPosts = 'forum_posts';
const String _tableForumComments = 'forum_comments';

/// Servicio del foro comunitario de GGSS.cl
class ForumService {
  final _client = SupabaseClientProvider.client;

  // ----------------------------------------------------------
  // Posts del foro
  // ----------------------------------------------------------

  /// Obtiene todos los posts del foro, más reciente primero
  Future<List<Map<String, dynamic>>> fetchAllPosts() async {
    final response = await _client
        .from(_tableForumPosts)
        .select('*, profiles(full_name, avatar_url)')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Obtiene un post por su [id] incluyendo comentarios
  Future<Map<String, dynamic>?> fetchPostById(String id) async {
    final response = await _client
        .from(_tableForumPosts)
        .select('*, profiles(full_name, avatar_url)')
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  /// Crea un nuevo post en el foro
  Future<void> createPost(Map<String, dynamic> postData) async {
    await _client.from(_tableForumPosts).insert(postData);
  }

  /// Elimina un post del foro (solo el autor puede eliminar)
  Future<void> deletePost(String id) async {
    await _client.from(_tableForumPosts).delete().eq('id', id);
  }

  // ----------------------------------------------------------
  // Comentarios del foro
  // ----------------------------------------------------------

  /// Obtiene todos los comentarios de un post con [postId]
  Future<List<Map<String, dynamic>>> fetchCommentsByPostId(
    String postId,
  ) async {
    final response = await _client
        .from(_tableForumComments)
        .select('*, profiles(full_name, avatar_url)')
        .eq('post_id', postId)
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Crea un nuevo comentario en un post
  Future<void> createComment(Map<String, dynamic> commentData) async {
    await _client.from(_tableForumComments).insert(commentData);
  }

  /// Elimina un comentario del foro
  Future<void> deleteComment(String id) async {
    await _client.from(_tableForumComments).delete().eq('id', id);
  }
}
