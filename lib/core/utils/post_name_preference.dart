// ============================================================
// post_name_preference.dart
// Cache local de la preferencia show_full_name_in_posts.
//
// Persiste en SharedPreferences para que los servicios puedan
// leer el valor actualizado inmediatamente después de un cambio
// en la pantalla de privacidad, sin esperar una recarga de la DB.
// ============================================================

import 'package:shared_preferences/shared_preferences.dart';

const String _kShowFullNameInPosts = 'show_full_name_in_posts';

/// Utilidad para leer y escribir la preferencia local de nombre en posts
class PostNamePreference {
  /// Lee la preferencia desde SharedPreferences.
  /// Retorna null si no ha sido guardada aún (usar valor de Supabase).
  static Future<bool?> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kShowFullNameInPosts);
  }

  /// Persiste el valor en SharedPreferences.
  static Future<void> write(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kShowFullNameInPosts, value);
  }
}
