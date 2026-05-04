// ============================================================
// news_item_model.dart
// Modelo de noticia obtenida desde Google Custom Search API.
// ============================================================

/// Modelo de noticia de GGSS.cl
class NewsItemModel {
  final String title;
  final String snippet;
  final String url;
  final String? imageUrl;
  final String source;

  const NewsItemModel({
    required this.title,
    required this.snippet,
    required this.url,
    this.imageUrl,
    required this.source,
  });

  // ----------------------------------------------------------
  // Conversión desde resultado de Google Custom Search API
  // ----------------------------------------------------------

  /// Crea un [NewsItemModel] desde el mapa de respuesta de Google Custom Search
  factory NewsItemModel.fromGoogleSearchResult(Map<String, dynamic> map) {
    // Extraer imagen si existe en pagemap
    String? imageUrl;
    final pagemap = map['pagemap'] as Map<String, dynamic>?;
    if (pagemap != null) {
      final cseImage = pagemap['cse_image'] as List<dynamic>?;
      if (cseImage != null && cseImage.isNotEmpty) {
        imageUrl = (cseImage.first as Map<String, dynamic>)['src'] as String?;
      }
    }

    // Extraer dominio del link como fuente
    final link = map['link'] as String? ?? '';
    String source = '';
    try {
      source = Uri.parse(link).host.replaceFirst('www.', '');
    } catch (_) {
      source = link;
    }

    return NewsItemModel(
      title: map['title'] as String? ?? '',
      snippet: map['snippet'] as String? ?? '',
      url: link,
      imageUrl: imageUrl,
      source: source,
    );
  }
}
