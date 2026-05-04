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
  final DateTime? publishedDate;

  const NewsItemModel({
    required this.title,
    required this.snippet,
    required this.url,
    this.imageUrl,
    required this.source,
    this.publishedDate,
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

    // Extraer fecha de publicación desde metatags (varios formatos posibles)
    DateTime? publishedDate;
    if (pagemap != null) {
      final metatags = pagemap['metatags'] as List<dynamic>?;
      if (metatags != null && metatags.isNotEmpty) {
        final meta = metatags.first as Map<String, dynamic>;
        final rawDate = meta['article:published_time'] as String? ??
            meta['og:updated_time'] as String? ??
            meta['date'] as String? ??
            meta['pubdate'] as String?;
        if (rawDate != null) {
          publishedDate = DateTime.tryParse(rawDate);
        }
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
      publishedDate: publishedDate,
    );
  }

  // ----------------------------------------------------------
  // Fecha formateada en español (ej: "12 ene. 2025")
  // ----------------------------------------------------------

  /// Retorna la fecha formateada en español, o null si no está disponible
  String? get formattedDate {
    if (publishedDate == null) return null;
    const meses = [
      'ene.', 'feb.', 'mar.', 'abr.', 'may.', 'jun.',
      'jul.', 'ago.', 'sep.', 'oct.', 'nov.', 'dic.',
    ];
    final d = publishedDate!;
    return '${d.day} ${meses[d.month - 1]} ${d.year}';
  }
}
