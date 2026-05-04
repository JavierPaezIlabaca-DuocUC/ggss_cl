// ============================================================
// news_service.dart
// Servicio de noticias usando Google Custom Search API.
// Busca noticias sobre seguridad privada en Chile.
// ============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Configuración de la API de Google Custom Search
class _NewsApiConfig {
  static const String apiKey = 'AIzaSyDA0VkjJbHIdMeE6i3CXajfhJPb3-LkzKc';
  static const String searchEngineId = '11d4bd3ec71264a8e';
  static const String baseUrl =
      'https://www.googleapis.com/customsearch/v1';

  /// Término de búsqueda por defecto para noticias de seguridad privada
  static const String defaultQuery =
      'guardia seguridad privada Chile OS10';
}

/// Servicio de noticias de GGSS.cl
class NewsService {
  // ----------------------------------------------------------
  // Búsqueda de noticias
  // ----------------------------------------------------------

  /// Busca noticias con [query]. Si [query] está vacío, usa el término por defecto.
  /// Retorna una lista de resultados del API de Google Custom Search.
  Future<List<Map<String, dynamic>>> fetchNews({String? query}) async {
    final searchQuery = (query?.trim().isNotEmpty == true)
        ? query!
        : _NewsApiConfig.defaultQuery;

    final uri = Uri.parse(_NewsApiConfig.baseUrl).replace(
      queryParameters: {
        'key': _NewsApiConfig.apiKey,
        'cx': _NewsApiConfig.searchEngineId,
        'q': searchQuery,
        'num': '10', // Máximo de resultados por página
        'lr': 'lang_es', // Resultados en español
        'gl': 'cl', // Geolocalización: Chile
      },
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Error al cargar noticias (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>? ?? [];

    return items.cast<Map<String, dynamic>>();
  }
}
