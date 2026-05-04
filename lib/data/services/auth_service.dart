// ============================================================
// auth_service.dart
// Servicio de autenticación usando Supabase Auth.
// Maneja: login, registro, logout y recuperación de contraseña.
//
// PUNTOS DE EXTENSIÓN (implementar en versión futura):
// - Google Sign-In (ver método scaffoldGoogleSignIn)
// - Apple Sign-In  (ver método scaffoldAppleSignIn)
// ============================================================

import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase/supabase_client.dart';

/// Servicio de autenticación de GGSS.cl
class AuthService {
  // Acceso al cliente Supabase
  final _client = SupabaseClientProvider.client;

  // ----------------------------------------------------------
  // Estado de sesión actual
  // ----------------------------------------------------------

  /// Retorna el usuario actualmente autenticado, o null si no hay sesión
  User? get currentUser => _client.auth.currentUser;

  /// Stream que emite cambios en el estado de autenticación
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ----------------------------------------------------------
  // Inicio de sesión con correo y contraseña
  // ----------------------------------------------------------

  /// Inicia sesión con [email] y [password].
  /// Lanza una excepción [AuthException] si las credenciales son inválidas.
  Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ----------------------------------------------------------
  // Registro de nueva cuenta
  // ----------------------------------------------------------

  /// Registra un nuevo usuario con [email], [password] y [fullName].
  /// Guarda el nombre completo en los metadatos del usuario.
  Future<AuthResponse> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    return await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'full_name': fullName.trim()},
    );
  }

  // ----------------------------------------------------------
  // Recuperación de contraseña
  // ----------------------------------------------------------

  /// Envía un correo de recuperación de contraseña a [email].
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _client.auth.resetPasswordForEmail(email.trim());
  }

  // ----------------------------------------------------------
  // Cierre de sesión
  // ----------------------------------------------------------

  /// Cierra la sesión del usuario actual
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ----------------------------------------------------------
  // PUNTO DE EXTENSIÓN: Google Sign-In (versión futura)
  // ----------------------------------------------------------

  /// [FUTURO] Inicio de sesión con Google.
  /// No implementado: se agregará en una versión posterior.
  /// Para implementar: instalar google_sign_in y configurar OAuth en Supabase.
  Future<void> scaffoldGoogleSignIn() async {
    // TODO(future): implementar Google Sign-In
    // Pasos pendientes:
    // 1. Agregar dependencia: google_sign_in: ^6.x.x
    // 2. Configurar OAuth provider en Supabase Dashboard
    // 3. Registrar SHA-1 en Google Console (Android)
    // 4. Agregar GoogleService-Info.plist (iOS)
    throw UnimplementedError(
      'Google Sign-In no está disponible en esta versión.',
    );
  }

  // ----------------------------------------------------------
  // PUNTO DE EXTENSIÓN: Apple Sign-In (versión futura)
  // ----------------------------------------------------------

  /// [FUTURO] Inicio de sesión con Apple.
  /// No implementado: se agregará en una versión posterior.
  /// Para implementar: instalar sign_in_with_apple y configurar en Supabase.
  Future<void> scaffoldAppleSignIn() async {
    // TODO(future): implementar Apple Sign-In
    // Pasos pendientes:
    // 1. Agregar dependencia: sign_in_with_apple: ^6.x.x
    // 2. Configurar Sign in with Apple en Apple Developer Console
    // 3. Configurar OAuth provider en Supabase Dashboard
    // 4. Solo disponible en iOS 13+ y macOS 10.15+
    throw UnimplementedError(
      'Apple Sign-In no está disponible en esta versión.',
    );
  }
}
