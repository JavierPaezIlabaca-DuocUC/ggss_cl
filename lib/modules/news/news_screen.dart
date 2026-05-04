// ============================================================
// news_screen.dart
// Pantalla principal de noticias.
// Carga artículos desde Google Custom Search API
// y los muestra en una lista de NewsCard con pull-to-refresh.
// Embebida dentro de MainShell (sin Scaffold propio).
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'news_providers.dart';
import 'widgets/news_card.dart';

/// Pantalla principal de noticias (embebida en MainShell)
class NewsScreen extends ConsumerWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsNotifierProvider);

    return newsAsync.when(
      // ----------------------------------------------------------
      // Estado de carga
      // ----------------------------------------------------------
      loading: () => const LoadingIndicator(),

      // ----------------------------------------------------------
      // Estado de error con reintento
      // ----------------------------------------------------------
      error: (error, _) => AppErrorWidget(
        message: AppStrings.errorNetwork,
        onRetry: () => ref.read(newsNotifierProvider.notifier).refresh(),
      ),

      // ----------------------------------------------------------
      // Datos cargados: lista o estado vacío
      // ----------------------------------------------------------
      data: (newsList) => RefreshIndicator(
        onRefresh: () => ref.read(newsNotifierProvider.notifier).refresh(),
        child: newsList.isEmpty
            ? _EmptyNewsList()
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: newsList.length,
                itemBuilder: (_, index) => NewsCard(news: newsList[index]),
              ),
      ),
    );
  }
}

// ============================================================
// Estado vacío scrolleable (necesario para RefreshIndicator)
// ============================================================

class _EmptyNewsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        const EmptyStateWidget(
          message: AppStrings.newsNoResults,
          icon: Icons.newspaper_outlined,
        ),
      ],
    );
  }
}
