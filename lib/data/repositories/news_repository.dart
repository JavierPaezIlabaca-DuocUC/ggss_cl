// ============================================================
// news_repository.dart
// Repositorio de noticias: delega en NewsService para obtener
// artículos desde la Edge Function news-proxy (Google News RSS)
// con fallback a datos estáticos curados.
// ============================================================

import '../../models/news_item_model.dart';
import '../services/news_service.dart';

/// Repositorio de noticias de GGSS.cl
class NewsRepository {
  final NewsService _newsService;

  NewsRepository({NewsService? newsService})
      : _newsService = newsService ?? NewsService();

  /// Retorna noticias en tiempo real desde Google News (vía Edge Function)
  /// o datos estáticos curados como fallback si la red no está disponible.
  Future<List<NewsItemModel>> getNews() async {
    return _newsService.fetchNews();
  }
}
