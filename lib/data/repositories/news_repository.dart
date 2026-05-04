// ============================================================
// news_repository.dart
// Repositorio de noticias: devuelve la lista curada de noticias
// estáticas sobre seguridad privada en Chile.
// ============================================================

import '../../models/news_item_model.dart';
import '../services/news_service.dart';

/// Repositorio de noticias de GGSS.cl
class NewsRepository {
  final NewsService _newsService;

  NewsRepository({NewsService? newsService})
      : _newsService = newsService ?? NewsService();

  /// Retorna la lista de noticias curadas como [NewsItemModel]
  Future<List<NewsItemModel>> getNews() async {
    return _newsService.fetchNews();
  }
}
