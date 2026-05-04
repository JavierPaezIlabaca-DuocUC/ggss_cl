// ============================================================
// news_detail_screen.dart
// Pantalla de detalle de una noticia.
// Muestra título, fuente, fecha, extracto, imagen y
// el botón para abrir el artículo completo en el navegador.
// ============================================================

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../models/news_item_model.dart';
import '../../shared/widgets/external_link_dialog.dart';

/// Pantalla de detalle de una noticia
class NewsDetailScreen extends StatelessWidget {
  final NewsItemModel news;

  const NewsDetailScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Noticia'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --------------------------------------------------
            // Imagen de portada (si está disponible)
            // --------------------------------------------------
            if (news.imageUrl != null)
              CachedNetworkImage(
                imageUrl: news.imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  height: 200,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, _, _) => Container(
                  height: 120,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.newspaper_outlined,
                    size: AppDimensions.iconLg,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --------------------------------------------------
                  // Título
                  // --------------------------------------------------
                  Text(
                    news.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacingMd),

                  // --------------------------------------------------
                  // Fila: fuente y fecha
                  // --------------------------------------------------
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
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (news.formattedDate != null) ...[
                        Icon(
                          Icons.calendar_today_outlined,
                          size: AppDimensions.iconSm,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: AppDimensions.spacingXs),
                        Text(
                          news.formattedDate!,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),

                  const Divider(height: AppDimensions.spacingXl),

                  // --------------------------------------------------
                  // Extracto del artículo
                  // --------------------------------------------------
                  Text(
                    news.snippet,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacingXl),

                  // --------------------------------------------------
                  // Botón: abrir artículo completo en el navegador
                  // --------------------------------------------------
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.open_in_new_outlined),
                      label: const Text(AppStrings.newsReadFullArticle),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        minimumSize: const Size(
                          double.infinity,
                          AppDimensions.inputHeight,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMd,
                          ),
                        ),
                      ),
                      onPressed: () => _openArticle(context),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacingMd),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // Abre el artículo completo con el diálogo de advertencia
  // ----------------------------------------------------------

  void _openArticle(BuildContext context) {
    ExternalLinkOpener.open(context, news.url);
  }
}
