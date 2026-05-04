// ============================================================
// news_service.dart
// Servicio de noticias que llama al Edge Function de Supabase,
// el cual actúa como proxy hacia Google Custom Search API.
//
// Razón del proxy: los navegadores bloquean peticiones directas
// a la API de Google por política CORS. El Edge Function las
// realiza server-side y devuelve la respuesta con las cabeceras
// CORS correctas.
// ============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Configuración del proxy (Supabase Edge Function)
class _NewsProxyConfig {
  /// URL del Edge Function desplegado en Supabase
  static const String proxyUrl =
      'https://vxbotzyieemxapqshfgq.supabase.co/functions/v1/news-proxy';

  /// Anon key de Supabase (requerida en el header Authorization)
  static const String anonKey =
      'sb_publishable_bpYzMPfOCqOnG2-AmPiJoQ_4RFCIKag';

  /// Término de búsqueda por defecto para noticias de seguridad privada
  static const String defaultQuery = 'seguridad privada Chile guardias';
}

/// Servicio de noticias de GGSS.cl
class NewsService {
  // ----------------------------------------------------------
  // Búsqueda de noticias
  // ----------------------------------------------------------

  /// Busca noticias con [query]. Si [query] está vacío, usa el término por defecto.
  /// Llama al Edge Function de Supabase que actúa como proxy hacia Google.
  Future<List<Map<String, dynamic>>> fetchNews({String? query}) async {
    final searchQuery = (query?.trim().isNotEmpty == true)
        ? query!
        : _NewsProxyConfig.defaultQuery;

    // Construir URL del proxy con el parámetro de búsqueda
    final uri = Uri.parse(_NewsProxyConfig.proxyUrl).replace(
      queryParameters: {'q': searchQuery},
    );

    // El Edge Function requiere el anon key en el header Authorization
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer ${_NewsProxyConfig.anonKey}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error al cargar noticias (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>? ?? [];

    return items.cast<Map<String, dynamic>>();
  }
}
