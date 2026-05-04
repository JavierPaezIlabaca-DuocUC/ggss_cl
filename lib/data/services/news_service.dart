// ============================================================
// news_service.dart
// Servicio de noticias que llama al Edge Function de Supabase
// (news-proxy) usando el cliente oficial supabase_flutter.
//
// Por qué usar functions.invoke() en lugar de http.get():
//   El Edge Function requiere un JWT válido en Authorization.
//   El cliente de Supabase Flutter inyecta automáticamente el JWT
//   de la sesión activa del usuario, que sí es un JWT válido.
//   Una llamada raw con el anon key nuevo (sb_publishable_...) falla
//   porque ese formato no es un JWT — el runtime lo rechaza con 401.
// ============================================================

import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase/supabase_client.dart';

/// Nombre del Edge Function proxy desplegado en Supabase
const _kFunctionName = 'news-proxy';

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

    // Llamar al Edge Function usando el cliente Supabase.
    // El SDK inyecta automáticamente el JWT de la sesión activa,
    // que es el token válido que el Edge Function requiere.
    final FunctionResponse response =
        await SupabaseClientProvider.client.functions.invoke(
      _kFunctionName,
      method: HttpMethod.get,
      queryParameters: {'q': searchQuery},
    );

    // response.data ya viene parseado como Map<String, dynamic>
    final data = response.data as Map<String, dynamic>? ?? {};
    final items = data['items'] as List<dynamic>? ?? [];

    return items.cast<Map<String, dynamic>>();
  }
}
