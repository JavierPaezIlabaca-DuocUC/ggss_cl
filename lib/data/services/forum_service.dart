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

  /// Obtiene todos los posts del foro, más reciente primero.
  ///
  /// No se usa join con 'profiles' porque PostgREST requiere una
  /// FK declarada entre forum_posts.user_id y profiles.id para
  /// resolver el join implícito. Sin esa FK, la consulta falla con
  /// PGRST200. El nombre del autor se muestra como "Usuario" por defecto.
  Future<List<Map<String, dynamic>>> fetchAllPosts() async {
    final response = await _client
        .from(_tableForumPosts)
        .select('*')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Crea un nuevo post en el foro
  Future<void> createPost(Map<String, dynamic> postData) async {
    await _client.from(_tableForumPosts).insert(postData);
  }

  /// Elimina un post del foro (RLS garantiza que solo el autor puede hacerlo)
  Future<void> deletePost(String id) async {
    await _client.from(_tableForumPosts).delete().eq('id', id);
  }

  // ----------------------------------------------------------
  // Comentarios del foro
  // ----------------------------------------------------------

  /// Obtiene todos los comentarios de un post con [postId],
  /// ordenados del más antiguo al más reciente.
  Future<List<Map<String, dynamic>>> fetchCommentsByPostId(
    String postId,
  ) async {
    final response = await _client
        .from(_tableForumComments)
        .select('*')
        .eq('post_id', postId)
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Crea un nuevo comentario en un post
  Future<void> createComment(Map<String, dynamic> commentData) async {
    await _client.from(_tableForumComments).insert(commentData);
  }

  /// Elimina un comentario del foro (RLS garantiza que solo el autor puede hacerlo)
  Future<void> deleteComment(String id) async {
    await _client.from(_tableForumComments).delete().eq('id', id);
  }
}
