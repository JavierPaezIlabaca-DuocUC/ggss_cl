// ============================================================
// auth_service.dart
// Servicio de autenticación usando Supabase Auth.
// Responsabilidades: login, registro, logout, recuperación de
// contraseña y manejo del estado de sesión.
//
// PUNTOS DE EXTENSIÓN (no implementar ahora — versión futura):
// - Google Sign-In: ver método scaffoldGoogleSignIn()
// - Apple Sign-In:  ver método scaffoldAppleSignIn()
// ============================================================

import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase/supabase_client.dart';

/// Servicio de autenticación de GGSS.cl
class AuthService {
  // Cliente Supabase compartido de la app
  final _client = SupabaseClientProvider.client;

  // ----------------------------------------------------------
  // Estado de sesión actual
  // ----------------------------------------------------------

  /// Retorna el usuario actualmente autenticado, o null si no hay sesión activa
  User? get currentUser => _client.auth.currentUser;

  /// Método explícito para obtener el usuario actual (alias del getter)
  User? getCurrentUser() => _client.auth.currentUser;

  /// Retorna la sesión activa, o null si el usuario no ha iniciado sesión
  Session? getCurrentSession() => _client.auth.currentSession;

  /// Stream que emite eventos de cambio en el estado de autenticación.
  /// Emite: SIGNED_IN, SIGNED_OUT, TOKEN_REFRESHED, USER_UPDATED, etc.
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  // ----------------------------------------------------------
  // Inicio de sesión con correo y contraseña
  // ----------------------------------------------------------

  /// Inicia sesión con [email] y [password].
  /// Lanza [AuthException] si las credenciales son inválidas.
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

  /// Registra un nuevo usuario con [email], [password], [fullName] y [rut].
  /// Guarda el nombre completo y el RUT en los metadatos del usuario de Supabase.
  Future<AuthResponse> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String rut,
  }) async {
    return await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'full_name': fullName.trim(),
        'rut': rut.trim(),
      },
      // URL de redirección tras confirmar el correo.
      // Android intercepta ggss://app con el intent-filter del Manifest.
      emailRedirectTo: 'ggss://app',
    );
  }

  // ----------------------------------------------------------
  // Recuperación de contraseña
  // ----------------------------------------------------------

  /// Envía un correo de recuperación de contraseña a [email].
  /// Supabase envía un enlace válido por 1 hora.
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _client.auth.resetPasswordForEmail(email.trim());
  }

  // ----------------------------------------------------------
  // Reenvío del correo de confirmación de cuenta
  // ----------------------------------------------------------

  /// Reenvía el correo de confirmación de cuenta a [email].
  /// Útil cuando el usuario no recibió o no encontró el correo original.
  Future<void> resendConfirmationEmail({required String email}) async {
    await _client.auth.resend(
      type: OtpType.signup,
      email: email.trim(),
    );
  }

  // ----------------------------------------------------------
  // Refresco de sesión (actualiza emailConfirmedAt)
  // ----------------------------------------------------------

  /// Refresca la sesión activa para obtener datos actualizados del usuario.
  /// Después de confirmar el correo, este método actualiza emailConfirmedAt.
  Future<AuthResponse> refreshSession() async {
    return await _client.auth.refreshSession();
  }

  // ----------------------------------------------------------
  // Cierre de sesión
  // ----------------------------------------------------------

  /// Cierra la sesión del usuario actual e invalida el token local.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ----------------------------------------------------------
  // Utilidad: traduce mensajes de error de Supabase al español
  // ----------------------------------------------------------

  /// Convierte el mensaje de error en inglés de Supabase a un mensaje
  /// amigable en español para mostrar al usuario.
  static String translateAuthError(String englishMessage) {
    final msg = englishMessage.toLowerCase();

    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid email or password') ||
        msg.contains('wrong password')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (msg.contains('user already registered') ||
        msg.contains('already been registered') ||
        msg.contains('email address is already taken')) {
      return 'Este correo ya está registrado. Intenta iniciar sesión.';
    }
    if (msg.contains('email not confirmed') ||
        msg.contains('email link is invalid or has expired')) {
      return 'Debes confirmar tu correo antes de iniciar sesión.';
    }
    if (msg.contains('password should be at least') ||
        msg.contains('weak password')) {
      return 'La contraseña es muy débil. Usa al menos 6 caracteres.';
    }
    if (msg.contains('too many requests') || msg.contains('rate limit')) {
      return 'Demasiados intentos. Espera unos minutos antes de reintentar.';
    }
    if (msg.contains('network') || msg.contains('connection')) {
      return 'Sin conexión. Verifica tu red e intenta nuevamente.';
    }
    if (msg.contains('user not found')) {
      return 'No existe una cuenta con ese correo.';
    }

    // Mensaje genérico si no se reconoce el error específico
    return 'Ocurrió un error. Por favor intenta nuevamente.';
  }

  // ----------------------------------------------------------
  // PUNTO DE EXTENSIÓN: Google Sign-In (versión futura)
  // ----------------------------------------------------------

  /// [FUTURO] Inicio de sesión con Google.
  /// No implementado. Se implementará en una versión posterior.
  ///
  /// Pasos para implementar:
  ///   1. Agregar: google_sign_in: ^6.x.x en pubspec.yaml
  ///   2. Configurar OAuth provider "Google" en Supabase Dashboard
  ///   3. Registrar SHA-1 en Google Cloud Console (Android)
  ///   4. Agregar GoogleService-Info.plist en iOS Runner
  Future<void> scaffoldGoogleSignIn() async {
    // TODO(future): implementar Google Sign-In con Supabase OAuth
    throw UnimplementedError(
      'Google Sign-In no está disponible en esta versión.',
    );
  }

  // ----------------------------------------------------------
  // PUNTO DE EXTENSIÓN: Apple Sign-In (versión futura)
  // ----------------------------------------------------------

  /// [FUTURO] Inicio de sesión con Apple.
  /// No implementado. Se implementará en una versión posterior.
  ///
  /// Pasos para implementar:
  ///   1. Agregar: sign_in_with_apple: ^6.x.x en pubspec.yaml
  ///   2. Activar "Sign in with Apple" en Apple Developer Console
  ///   3. Configurar OAuth provider "Apple" en Supabase Dashboard
  ///   4. Solo disponible en iOS 13+ y macOS 10.15+
  Future<void> scaffoldAppleSignIn() async {
    // TODO(future): implementar Apple Sign-In con Supabase OAuth
    throw UnimplementedError(
      'Apple Sign-In no está disponible en esta versión.',
    );
  }
}
