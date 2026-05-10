// ============================================================
// forum_screen.dart
// Pantalla principal del foro comunitario.
// Muestra la lista de publicaciones desde Supabase con
// pull-to-refresh.
//
// Modos de uso:
//   - Por defecto: embebida en MainShell, muestra todos los posts.
//     Sin Scaffold propio.
//   - isOwnPosts = true: muestra solo los posts del usuario
//     autenticado. Incluye Scaffold propio con AppBar.
//   - userId != null: muestra posts de otro usuario específico.
//     Incluye Scaffold propio con AppBar.
//
// RouteAware: al regresar a esta pantalla, refetch los datos para
// reflejar cambios de privacidad (show_full_name_in_posts).
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/utils/route_observer.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'create_post_screen.dart';
import 'forum_providers.dart';
import 'widgets/forum_post_card.dart';

/// Pantalla del foro comunitario — admite vista completa, propia o de otro usuario
class ForumScreen extends ConsumerStatefulWidget {
  /// Cuando es true, muestra solo los posts del usuario autenticado
  final bool isOwnPosts;

  /// Cuando está presente, muestra posts de este usuario específico
  final String? userId;

  /// Primer nombre del usuario (para el título del AppBar cuando userId != null)
  final String? userFirstName;

  const ForumScreen({
    super.key,
    this.isOwnPosts = false,
    this.userId,
    this.userFirstName,
  });

  @override
  ConsumerState<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends ConsumerState<ForumScreen> with RouteAware {
  // ----------------------------------------------------------
  // RouteAware: suscribir/desuscribir al observer global
  // ----------------------------------------------------------

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  /// Llamado cuando el usuario regresa a esta pantalla desde otra ruta.
  /// Invalida el proveedor para que refetch con las preferencias actualizadas.
  @override
  void didPopNext() {
    if (widget.userId != null) {
      ref.invalidate(userForumPostsNotifierProvider(widget.userId!));
    } else if (widget.isOwnPosts) {
      ref.invalidate(myForumPostsNotifierProvider);
    } else {
      ref.invalidate(forumPostsNotifierProvider);
    }
  }

  // ----------------------------------------------------------
  // Construcción del widget
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Seleccionar el proveedor correcto según el modo
    final postsAsync = widget.userId != null
        ? ref.watch(userForumPostsNotifierProvider(widget.userId!))
        : widget.isOwnPosts
            ? ref.watch(myForumPostsNotifierProvider)
            : ref.watch(forumPostsNotifierProvider);

    Widget content = postsAsync.when(
      loading: () => const LoadingIndicator(),

      error: (error, _) => AppErrorWidget(
        message: AppStrings.errorGeneral,
        onRetry: () {
          if (widget.userId != null) {
            ref.read(userForumPostsNotifierProvider(widget.userId!).notifier).refresh();
          } else if (widget.isOwnPosts) {
            ref.read(myForumPostsNotifierProvider.notifier).refresh();
          } else {
            ref.read(forumPostsNotifierProvider.notifier).refresh();
          }
        },
      ),

      data: (posts) => RefreshIndicator(
        onRefresh: () async {
          if (widget.userId != null) {
            await ref
                .read(userForumPostsNotifierProvider(widget.userId!).notifier)
                .refresh();
          } else if (widget.isOwnPosts) {
            await ref.read(myForumPostsNotifierProvider.notifier).refresh();
          } else {
            await ref.read(forumPostsNotifierProvider.notifier).refresh();
          }
        },
        child: posts.isEmpty
            ? _EmptyForumList(
                isOwnPosts: widget.isOwnPosts,
                isUserFilter: widget.userId != null,
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: posts.length,
                itemBuilder: (_, index) => ForumPostCard(post: posts[index]),
              ),
      ),
    );

    // ----------------------------------------------------------
    // Modo con Scaffold: perfil propio o perfil de otro usuario
    // ----------------------------------------------------------
    if (widget.isOwnPosts || widget.userId != null) {
      final title = widget.userId != null
          ? 'Publicaciones de ${widget.userFirstName ?? 'usuario'}'
          : AppStrings.myForumTitle;

      return Scaffold(
        appBar: AppBar(
          title: Text(title),
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
  final bool isUserFilter;

  const _EmptyForumList({
    this.isOwnPosts = false,
    this.isUserFilter = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        EmptyStateWidget(
          message: isOwnPosts
              ? 'Aún no has publicado en el foro.'
              : isUserFilter
                  ? 'Este usuario no tiene publicaciones en el foro.'
                  : AppStrings.forumNoPosts,
          icon: Icons.chat_bubble_outline,
          actionLabel: isOwnPosts || isUserFilter
              ? null
              : 'Crear primera publicación',
          onActionTap: isOwnPosts || isUserFilter
              ? null
              : () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const CreatePostScreen()),
                  ),
        ),
      ],
    );
  }
}
