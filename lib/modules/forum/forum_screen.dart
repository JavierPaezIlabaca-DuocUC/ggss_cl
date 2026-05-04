// ============================================================
// forum_screen.dart
// Pantalla principal del foro comunitario.
// Muestra la lista de publicaciones desde Supabase con
// pull-to-refresh. Embebida dentro de MainShell (sin Scaffold).
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'forum_providers.dart';
import 'widgets/forum_post_card.dart';

/// Pantalla principal del foro comunitario (embebida en MainShell)
class ForumScreen extends ConsumerWidget {
  const ForumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(forumPostsNotifierProvider);

    return postsAsync.when(
      // ----------------------------------------------------------
      // Estado de carga
      // ----------------------------------------------------------
      loading: () => const LoadingIndicator(),

      // ----------------------------------------------------------
      // Estado de error con reintento
      // ----------------------------------------------------------
      error: (error, _) => AppErrorWidget(
        message: AppStrings.errorGeneral,
        onRetry: () => ref.read(forumPostsNotifierProvider.notifier).refresh(),
      ),

      // ----------------------------------------------------------
      // Datos cargados: lista o estado vacío
      // ----------------------------------------------------------
      data: (posts) => RefreshIndicator(
        onRefresh: () =>
            ref.read(forumPostsNotifierProvider.notifier).refresh(),
        child: posts.isEmpty
            ? _EmptyForumList()
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: posts.length,
                itemBuilder: (_, index) =>
                    ForumPostCard(post: posts[index]),
              ),
      ),
    );
  }
}

// ============================================================
// Estado vacío scrolleable (necesario para RefreshIndicator)
// ============================================================

class _EmptyForumList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        const EmptyStateWidget(
          message: AppStrings.forumNoPosts,
          icon: Icons.chat_bubble_outline,
        ),
      ],
    );
  }
}
