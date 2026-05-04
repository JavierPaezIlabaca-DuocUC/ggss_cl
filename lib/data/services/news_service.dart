// ============================================================
// news_service.dart
// Servicio de noticias con datos estáticos curados.
//
// La integración con Google Custom Search API fue reemplazada
// por datos locales para evitar dependencias externas en esta
// etapa del proyecto. Los datos simulan noticias reales sobre
// seguridad privada en Chile con fuentes y URLs auténticas.
// ============================================================

import '../../models/news_item_model.dart';
import '../sources/news_static_data.dart';

/// Servicio de noticias de GGSS.cl
class NewsService {
  // ----------------------------------------------------------
  // Retorna la lista estática de noticias curadas
  // ----------------------------------------------------------

  /// Retorna las noticias sobre seguridad privada en Chile.
  /// Sin llamada de red — los datos están embebidos localmente.
  List<NewsItemModel> fetchNews() {
    return kStaticNews;
  }
}
