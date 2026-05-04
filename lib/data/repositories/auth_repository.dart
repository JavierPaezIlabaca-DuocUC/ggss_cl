// ============================================================
// auth_repository.dart
// Repositorio de autenticación: intermediario entre la UI
// y AuthService. Encapsula la lógica de negocio de auth.
// ============================================================

import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';

/// Repositorio de autenticación de GGSS.cl
class AuthRepository {
  final AuthService _authService;

  AuthRepository({AuthService? authService})
      : _authService = authService ?? AuthService();

  // ----------------------------------------------------------
  // Estado de sesión
  // ----------------------------------------------------------

  /// Usuario actualmente autenticado (null si no hay sesión)
  User? get currentUser => _authService.currentUser;

  /// Método explícito para obtener el usuario actual
  User? getCurrentUser() => _authService.getCurrentUser();

  /// Stream de cambios en el estado de autenticación
  Stream<AuthState> get authStateChanges => _authService.onAuthStateChange;

  /// Indica si hay un usuario con sesión activa
  bool get isAuthenticated => currentUser != null;

  // ----------------------------------------------------------
  // Operaciones de auth
  // ----------------------------------------------------------

  /// Inicia sesión con correo y contraseña
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Registra un nuevo usuario con nombre completo y RUT chileno
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String rut,
  }) async {
    return await _authService.signUpWithEmailAndPassword(
      email: email,
      password: password,
      fullName: fullName,
      rut: rut,
    );
  }

  /// Envía correo de recuperación de contraseña
  Future<void> sendPasswordReset({required String email}) async {
    await _authService.sendPasswordResetEmail(email: email);
  }

  /// Cierra la sesión del usuario
  Future<void> signOut() async {
    await _authService.signOut();
  }
}
