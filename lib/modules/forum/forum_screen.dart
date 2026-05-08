// ============================================================
// forum_screen.dart
// Pantalla principal del foro comunitario.
// Muestra la lista de publicaciones desde Supabase con
// pull-to-refresh.
//
// Modos de uso:
//   - isOwnPosts = false (por defecto): embebida en MainShell,
//     muestra todos los posts. Sin Scaffold propio.
//   - isOwnPosts = true: ruta independiente empujada desde el
//     perfil del usuario. Muestra solo sus posts.
//     Incluye Scaffold propio con AppBar.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'forum_providers.dart';
import 'widgets/forum_post_card.dart';

/// Pantalla del foro comunitario — admite vista completa o filtrada por usuario
class ForumScreen extends ConsumerWidget {
  /// Cuando es true, muestra solo los posts del usuario autenticado
  final bool isOwnPosts;

  const ForumScreen({super.key, this.isOwnPosts = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Seleccionar el proveedor correcto según el modo
    final postsAsync = isOwnPosts
        ? ref.watch(myForumPostsNotifierProvider)
        : ref.watch(forumPostsNotifierProvider);

    // ----------------------------------------------------------
    // Construir el contenido de la lista
    // ----------------------------------------------------------
    Widget content = postsAsync.when(
      // Estado de carga
      loading: () => const LoadingIndicator(),

      // Estado de error con reintento
      error: (error, _) => AppErrorWidget(
        message: AppStrings.errorGeneral,
        onRetry: () => isOwnPosts
            ? ref.read(myForumPostsNotifierProvider.notifier).refresh()
            : ref.read(forumPostsNotifierProvider.notifier).refresh(),
      ),

      // Datos cargados: lista o estado vacío
      data: (posts) => RefreshIndicator(
        onRefresh: () => isOwnPosts
            ? ref.read(myForumPostsNotifierProvider.notifier).refresh()
            : ref.read(forumPostsNotifierProvider.notifier).refresh(),
        child: posts.isEmpty
            ? _EmptyForumList(isOwnPosts: isOwnPosts)
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: posts.length,
                itemBuilder: (_, index) =>
                    ForumPostCard(post: posts[index]),
              ),
      ),
    );

    // ----------------------------------------------------------
    // Modo "mis publicaciones": envolver en Scaffold con AppBar
    // ----------------------------------------------------------
    if (isOwnPosts) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.myForumTitle),
          centerTitle: true,
        ),
        body: content,
      );
    }

    // Modo normal: sin Scaffold (embebida en MainShell)
    return content;
  }
}

// ============================================================
// Estado vacío scrolleable (necesario para RefreshIndicator)
// ============================================================

class _EmptyForumList extends StatelessWidget {
  final bool isOwnPosts;

  const _EmptyForumList({this.isOwnPosts = false});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        EmptyStateWidget(
          message: isOwnPosts
              ? 'Aún no has publicado en el foro.'
              : AppStrings.forumNoPosts,
          icon: Icons.chat_bubble_outline,
        ),
      ],
    );
  }
}
