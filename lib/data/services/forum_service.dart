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
  /// Incluye el nombre del autor (lookup manual a 'profiles' por created_by)
  /// y el conteo de comentarios embebido desde 'forum_comments'.
  Future<List<Map<String, dynamic>>> fetchAllPosts() async {
    return _fetchPostsWithProfiles(
      await _client
          .from(_tableForumPosts)
          .select('*, forum_comments(count)')
          .order('created_at', ascending: false),
    );
  }

  /// Obtiene solo los posts creados por [userId], más reciente primero.
  /// Usado en la vista "Mis publicaciones" del perfil.
  Future<List<Map<String, dynamic>>> fetchPostsByUser(String userId) async {
    return _fetchPostsWithProfiles(
      await _client
          .from(_tableForumPosts)
          .select('*, forum_comments(count)')
          .eq('created_by', userId)
          .order('created_at', ascending: false),
    );
  }

  /// Enriquece una lista de posts con los datos de perfil de sus autores.
  /// Evita N consultas haciendo un único select por lote de IDs.
  Future<List<Map<String, dynamic>>> _fetchPostsWithProfiles(
    dynamic rawPosts,
  ) async {
    final posts = List<Map<String, dynamic>>.from(rawPosts as List);

    // IDs únicos de autores
    final userIds = posts
        .map((p) => p['created_by'] as String?)
        .whereType<String>()
        .toSet()
        .toList();

    if (userIds.isEmpty) return posts;

    // Obtener perfiles en lote (incluye alias para mostrarlo en el foro)
    final profiles = List<Map<String, dynamic>>.from(
      await _client
          .from('profiles')
          .select('id, full_name, alias')
          .inFilter('id', userIds),
    );
    final profileMap = {for (final p in profiles) p['id'] as String: p};

    // Inyectar datos del autor en cada post
    return posts.map((post) {
      final uid = post['created_by'] as String?;
      return {...post, 'profiles': uid != null ? profileMap[uid] : null};
    }).toList();
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
  /// Incluye el nombre del autor (lookup manual a 'profiles' por created_by).
  Future<List<Map<String, dynamic>>> fetchCommentsByPostId(
    String postId,
  ) async {
    // Paso 1: obtener comentarios del post
    final comments = List<Map<String, dynamic>>.from(
      await _client
          .from(_tableForumComments)
          .select('*')
          .eq('post_id', postId)
          .order('created_at', ascending: true),
    );

    // Paso 2: IDs únicos de autores
    final userIds = comments
        .map((c) => c['created_by'] as String?)
        .whereType<String>()
        .toSet()
        .toList();

    if (userIds.isEmpty) return comments;

    // Paso 3: obtener perfiles en lote (incluye alias para mostrarlo en comentarios)
    final profiles = List<Map<String, dynamic>>.from(
      await _client
          .from('profiles')
          .select('id, full_name, alias')
          .inFilter('id', userIds),
    );
    final profileMap = {for (final p in profiles) p['id'] as String: p};

    // Paso 4: inyectar datos del autor en cada comentario
    return comments.map((comment) {
      final uid = comment['created_by'] as String?;
      return {...comment, 'profiles': uid != null ? profileMap[uid] : null};
    }).toList();
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
