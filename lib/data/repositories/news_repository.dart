// ============================================================
// news_repository.dart
// Repositorio de noticias: adapta los resultados de Google
// Custom Search al modelo NewsItemModel de la app.
// ============================================================

import '../../models/news_item_model.dart';
import '../services/news_service.dart';

/// Repositorio de noticias de GGSS.cl
class NewsRepository {
  final NewsService _newsService;

  NewsRepository({NewsService? newsService})
      : _newsService = newsService ?? NewsService();

  /// Retorna noticias como lista de [NewsItemModel]
  Future<List<NewsItemModel>> getNews({String? query}) async {
    final data = await _newsService.fetchNews(query: query);
    return data.map(NewsItemModel.fromGoogleSearchResult).toList();
  }
}
