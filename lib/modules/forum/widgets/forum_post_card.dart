// ============================================================
// forum_post_card.dart
// Tarjeta de resumen de una publicación del foro.
// Al tocarla navega a ForumPostDetailScreen.
// El nombre del autor es tappeable y navega a PublicProfileScreen.
// ============================================================

import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../models/forum_post_model.dart';
import '../../profile/public_profile_screen.dart';
import '../forum_post_detail_screen.dart';

/// Tarjeta de publicación del foro para mostrar en la lista
class ForumPostCard extends StatelessWidget {
  final ForumPostModel post;

  const ForumPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authorLabel =
        post.authorAlias ?? post.authorName ?? AppStrings.forumAnonymous;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        onTap: () => _openDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --------------------------------------------------
              // Chip de categoría (solo si está disponible)
              // --------------------------------------------------
              if (post.category != null && post.category!.isNotEmpty) ...[
                Chip(
                  label: Text(
                    post.category!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor:
                      AppColors.primaryBlue.withValues(alpha: 0.1),
                  side: BorderSide.none,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(height: AppDimensions.spacingXs),
              ],

              // --------------------------------------------------
              // Título de la publicación
              // --------------------------------------------------
              Text(
                post.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppDimensions.spacingXs),

              // --------------------------------------------------
              // Vista previa del contenido (máximo 2 líneas)
              // --------------------------------------------------
              Text(
                post.content,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color
                      ?.withValues(alpha: 0.75),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppDimensions.spacingSm),

              // --------------------------------------------------
              // Fila inferior: autor tappeable, tiempo, comentarios
              // --------------------------------------------------
              Row(
                children: [
                  // Ícono del autor
                  Icon(
                    Icons.person_outline,
                    size: AppDimensions.iconSm,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: AppDimensions.spacingXs),

                  // Nombre del autor — tap navega a PublicProfileScreen
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _openAuthorProfile(context),
                      child: Text(
                        authorLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: theme.colorScheme.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  // Tiempo transcurrido
                  Text(
                    timeago.format(post.createdAt, locale: 'es'),
                    style: theme.textTheme.bodySmall,
                  ),

                  const SizedBox(width: AppDimensions.spacingMd),

                  // Contador de comentarios
                  Icon(
                    Icons.chat_bubble_outline,
                    size: AppDimensions.iconSm,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: AppDimensions.spacingXs),
                  Text(
                    '${post.commentCount}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ForumPostDetailScreen(post: post)),
    );
  }

  void _openAuthorProfile(BuildContext context) {
    if (post.userId.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PublicProfileScreen(userId: post.userId),
      ),
    );
  }
}
