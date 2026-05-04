// ============================================================
// forum_repository.dart
// Repositorio del foro comunitario.
// ============================================================

import '../../models/forum_comment_model.dart';
import '../../models/forum_post_model.dart';
import '../services/forum_service.dart';

/// Repositorio del foro comunitario de GGSS.cl
class ForumRepository {
  final ForumService _forumService;

  ForumRepository({ForumService? forumService})
      : _forumService = forumService ?? ForumService();

  // ----------------------------------------------------------
  // Posts
  // ----------------------------------------------------------

  /// Retorna todos los posts del foro
  Future<List<ForumPostModel>> getAllPosts() async {
    final data = await _forumService.fetchAllPosts();
    return data.map(ForumPostModel.fromMap).toList();
  }

  /// Crea un nuevo post en el foro
  Future<void> createPost(ForumPostModel post) async {
    await _forumService.createPost(post.toMap());
  }

  /// Elimina un post del foro
  Future<void> deletePost(String id) async {
    await _forumService.deletePost(id);
  }

  // ----------------------------------------------------------
  // Comentarios
  // ----------------------------------------------------------

  /// Retorna los comentarios de un post
  Future<List<ForumCommentModel>> getCommentsByPostId(String postId) async {
    final data = await _forumService.fetchCommentsByPostId(postId);
    return data.map(ForumCommentModel.fromMap).toList();
  }

  /// Crea un comentario en un post
  Future<void> createComment(ForumCommentModel comment) async {
    await _forumService.createComment(comment.toMap());
  }

  /// Elimina un comentario del foro
  Future<void> deleteComment(String id) async {
    await _forumService.deleteComment(id);
  }
}
