// ============================================================
// news_card.dart
// Tarjeta de resumen de noticia para la lista principal.
// Al tocarla navega a NewsDetailScreen.
// ============================================================

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../models/news_item_model.dart';
import '../news_detail_screen.dart';

/// Tarjeta de noticia para mostrar en la lista
class NewsCard extends StatelessWidget {
  final NewsItemModel news;

  const NewsCard({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        onTap: () => _openDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.cardPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --------------------------------------------------
              // Contenido textual (título, snippet, fuente y fecha)
              // --------------------------------------------------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título de la noticia
                    Text(
                      news.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: AppDimensions.spacingXs),

                    // Extracto de la noticia
                    Text(
                      news.snippet,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.75),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: AppDimensions.spacingSm),

                    // Fila inferior: fuente y fecha
                    Row(
                      children: [
                        Icon(
                          Icons.public_outlined,
                          size: AppDimensions.iconSm,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: AppDimensions.spacingXs),
                        Expanded(
                          child: Text(
                            news.source,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Fecha si está disponible
                        if (news.formattedDate != null) ...[
                          const SizedBox(width: AppDimensions.spacingXs),
                          Text(
                            news.formattedDate!,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // --------------------------------------------------
              // Miniatura de la noticia (opcional)
              // --------------------------------------------------
              if (news.imageUrl != null) ...[
                const SizedBox(width: AppDimensions.spacingMd),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  child: CachedNetworkImage(
                    imageUrl: news.imageUrl!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    // Indicador de carga mientras descarga la imagen
                    placeholder: (_, _) => Container(
                      width: 80,
                      height: 80,
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                    // Si la imagen falla, mostrar ícono genérico
                    errorWidget: (_, _, _) => Container(
                      width: 80,
                      height: 80,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.newspaper_outlined,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => NewsDetailScreen(news: news)),
    );
  }
}
