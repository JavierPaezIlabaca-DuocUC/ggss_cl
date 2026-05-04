// ============================================================
// auth_repository.dart
// Repositorio de autenticación: actúa como intermediario entre
// los módulos de UI y AuthService.
// Encapsula la lógica de negocio relacionada con autenticación.
// ============================================================

import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';

/// Repositorio de autenticación de GGSS.cl
class AuthRepository {
  final AuthService _authService;

  AuthRepository({AuthService? authService})
      : _authService = authService ?? AuthService();

  /// Usuario actualmente autenticado
  User? get currentUser => _authService.currentUser;

  /// Stream de cambios en el estado de autenticación
  Stream<AuthState> get authStateChanges => _authService.authStateChanges;

  /// Indica si hay un usuario con sesión activa
  bool get isAuthenticated => currentUser != null;

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

  /// Registra un nuevo usuario
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    return await _authService.signUpWithEmailAndPassword(
      email: email,
      password: password,
      fullName: fullName,
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
