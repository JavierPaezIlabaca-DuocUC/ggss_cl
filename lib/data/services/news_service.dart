// ============================================================
// news_service.dart
// Servicio de noticias de GGSS.cl.
//
// Flujo principal:
//   1. Llama a la Edge Function `news-proxy` (Supabase) que
//      obtiene y parsea el feed RSS de Google News en el servidor.
//   2. Mapea la respuesta JSON a [NewsItemModel] usando fromRssJson.
//   3. Si la llamada falla (sin red, error HTTP, timeout), retorna
//      los datos estáticos curados como fallback.
//
// La clave JWT legada se requiere porque el runtime de las Edge
// Functions valida el header Authorization como JWT estándar y
// rechaza el formato nuevo `sb_publishable_...`.
// ============================================================

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/supabase_config.dart';
import '../../models/news_item_model.dart';
import '../sources/news_static_data.dart';

/// Servicio de noticias de GGSS.cl
class NewsService {
  // ----------------------------------------------------------
  // Configuración de la Edge Function
  // ----------------------------------------------------------

  static const String _edgeFunctionUrl =
      '${SupabaseConfig.projectUrl}/functions/v1/news-proxy';

  /// Tiempo máximo de espera antes de usar el fallback estático
  static const Duration _timeout = Duration(seconds: 10);

  // ----------------------------------------------------------
  // Obtención de noticias desde la Edge Function
  // ----------------------------------------------------------

  /// Retorna noticias sobre seguridad privada en Chile.
  ///
  /// Intenta obtener artículos en tiempo real desde Google News
  /// a través de la Edge Function `news-proxy`. Si la llamada
  /// falla por cualquier motivo, retorna los datos estáticos
  /// curados como fallback transparente.
  Future<List<NewsItemModel>> fetchNews() async {
    try {
      final response = await http
          .get(
            Uri.parse(_edgeFunctionUrl),
            headers: {
              'Authorization': 'Bearer ${SupabaseConfig.anonKeyLegacy}',
              'apikey': SupabaseConfig.anonKeyLegacy,
            },
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        // Respuesta HTTP no exitosa — usar fallback
        return kStaticNews;
      }

      final List<dynamic> jsonList =
          jsonDecode(response.body) as List<dynamic>;

      final items = jsonList
          .whereType<Map<String, dynamic>>()
          .map((map) => NewsItemModel.fromRssJson(map))
          .where((item) => item.title.isNotEmpty)
          .toList();

      // Si la lista resultante está vacía, usar fallback
      return items.isNotEmpty ? items : kStaticNews;
    } catch (_) {
      // Error de red, timeout, parse error, etc. — usar fallback
      return kStaticNews;
    }
  }
}
