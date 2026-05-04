// ============================================================
// forum_providers.dart
// Proveedores Riverpod del módulo del foro comunitario.
//
// Contiene:
//   - forumRepositoryProvider: proveedor del repositorio
//   - ForumPostsNotifier: AsyncNotifier para la lista de posts
//   - forumPostsNotifierProvider: proveedor del notifier de posts
//   - ForumCommentsNotifier: FamilyAsyncNotifier para comentarios de un post
//   - forumCommentsNotifierProvider: proveedor de comentarios (family por postId)
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/forum_repository.dart';
import '../../models/forum_comment_model.dart';
import '../../models/forum_post_model.dart';

// ----------------------------------------------------------
// Proveedor del repositorio
// ----------------------------------------------------------

/// Proveedor del repositorio del foro
final forumRepositoryProvider = Provider<ForumRepository>((ref) {
  return ForumRepository();
});

// ----------------------------------------------------------
// AsyncNotifier: gestiona la lista de posts del foro
// ----------------------------------------------------------

/// Notifier que mantiene y actualiza la lista de publicaciones del foro
class ForumPostsNotifier extends AsyncNotifier<List<ForumPostModel>> {
  @override
  Future<List<ForumPostModel>> build() {
    return ref.read(forumRepositoryProvider).getAllPosts();
  }

  // ----------------------------------------------------------
  // Recarga la lista de posts desde Supabase
  // ----------------------------------------------------------

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(forumRepositoryProvider).getAllPosts(),
    );
  }

  // ----------------------------------------------------------
  // Crea un nuevo post y recarga la lista
  // ----------------------------------------------------------

  Future<void> createPost(ForumPostModel post) async {
    await ref.read(forumRepositoryProvider).createPost(post);
    await refresh();
  }

  // ----------------------------------------------------------
  // Elimina un post y recarga la lista
  // ----------------------------------------------------------

  Future<void> deletePost(String id) async {
    await ref.read(forumRepositoryProvider).deletePost(id);
    await refresh();
  }
}

/// Proveedor principal de la lista de publicaciones del foro
final forumPostsNotifierProvider =
    AsyncNotifierProvider<ForumPostsNotifier, List<ForumPostModel>>(
  ForumPostsNotifier.new,
);

// ----------------------------------------------------------
// FamilyAsyncNotifier: gestiona los comentarios de un post
// ----------------------------------------------------------

/// Notifier que mantiene y actualiza los comentarios de un post específico.
/// Se identifica por el [postId] pasado como argumento del family.
class ForumCommentsNotifier
    extends FamilyAsyncNotifier<List<ForumCommentModel>, String> {
  @override
  Future<List<ForumCommentModel>> build(String postId) {
    return ref.read(forumRepositoryProvider).getCommentsByPostId(postId);
  }

  // ----------------------------------------------------------
  // Recarga los comentarios del post actual
  // ----------------------------------------------------------

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(forumRepositoryProvider).getCommentsByPostId(arg),
    );
  }

  // ----------------------------------------------------------
  // Agrega un comentario y recarga la lista
  // ----------------------------------------------------------

  Future<void> addComment(ForumCommentModel comment) async {
    await ref.read(forumRepositoryProvider).createComment(comment);
    await refresh();
  }

  // ----------------------------------------------------------
  // Elimina un comentario y recarga la lista
  // ----------------------------------------------------------

  Future<void> deleteComment(String commentId) async {
    await ref.read(forumRepositoryProvider).deleteComment(commentId);
    await refresh();
  }
}

/// Proveedor de comentarios del foro, parametrizado por [postId]
final forumCommentsNotifierProvider = AsyncNotifierProvider.family<
    ForumCommentsNotifier, List<ForumCommentModel>, String>(
  ForumCommentsNotifier.new,
);
