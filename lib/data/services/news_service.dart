// ============================================================
// news_service.dart
// Servicio de noticias que llama al Edge Function de Supabase
// (news-proxy) usando http.get() con el JWT anónimo legado.
//
// Por qué usar el JWT legado en lugar del anon key nuevo:
//   El runtime de Edge Functions valida el Authorization header
//   como un JWT estándar (eyJ...). El nuevo formato de Supabase
//   (sb_publishable_...) no es un JWT y es rechazado con 401.
//   La clave legada es un JWT válido que el runtime acepta.
// ============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/constants/supabase_config.dart';

/// URL del Edge Function proxy desplegado en Supabase
const _kProxyUrl =
    'https://vxbotzyieemxapqshfgq.supabase.co/functions/v1/news-proxy';

/// Término de búsqueda por defecto para noticias de seguridad privada
const _kDefaultQuery = 'seguridad privada Chile guardias';

/// Servicio de noticias de GGSS.cl
class NewsService {
  // ----------------------------------------------------------
  // Búsqueda de noticias
  // ----------------------------------------------------------

  /// Llama al Edge Function news-proxy con [query].
  /// Si [query] está vacío, usa el término por defecto.
  /// Retorna la lista de items de Google Custom Search.
  Future<List<Map<String, dynamic>>> fetchNews({String? query}) async {
    final searchQuery =
        (query?.trim().isNotEmpty == true) ? query! : _kDefaultQuery;

    final uri = Uri.parse(_kProxyUrl).replace(
      queryParameters: {'q': searchQuery},
    );

    // El Edge Function requiere el JWT legado (eyJ...) en el header
    // Authorization — el nuevo formato sb_publishable_... es rechazado.
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer ${SupabaseConfig.anonKeyLegacy}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al cargar noticias (${response.statusCode}): ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>? ?? [];

    return items.cast<Map<String, dynamic>>();
  }
}
