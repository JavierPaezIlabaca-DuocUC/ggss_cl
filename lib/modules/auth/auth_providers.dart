// ============================================================
// auth_providers.dart
// Proveedores Riverpod del módulo de autenticación.
//
// Contiene:
//   - AuthFormStatus: enum de estados posibles del formulario
//   - AuthFormState: modelo de estado del formulario
//   - AuthNotifier: StateNotifier que maneja login/registro/logout
//   - authRepositoryProvider: proveedor del repositorio
//   - authNotifierProvider: proveedor del notifier de formulario
//   - authStateChangesProvider: StreamProvider para el estado global
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/services/auth_service.dart';

// ----------------------------------------------------------
// Estados posibles del formulario de autenticación
// ----------------------------------------------------------

/// Estado del formulario de auth: inactivo, cargando, éxito o error
enum AuthFormStatus {
  /// Estado inicial, sin acción en curso
  idle,

  /// Llamada al servidor en progreso (mostrar spinner)
  loading,

  /// Operación completada con éxito
  success,

  /// Operación fallida (mostrar mensaje de error)
  error,
}

// ----------------------------------------------------------
// Modelo de estado del formulario de autenticación
// ----------------------------------------------------------

/// Estado inmutable del formulario de autenticación
class AuthFormState {
  final AuthFormStatus status;

  /// Mensaje de error en español para mostrar al usuario (null si no hay error)
  final String? errorMessage;

  const AuthFormState({
    this.status = AuthFormStatus.idle,
    this.errorMessage,
  });

  /// Retorna true si el formulario está en proceso de envío
  bool get isLoading => status == AuthFormStatus.loading;

  /// Retorna true si la operación fue exitosa
  bool get isSuccess => status == AuthFormStatus.success;

  /// Retorna true si hubo un error
  bool get hasError => status == AuthFormStatus.error;

  /// Crea una copia del estado con los campos modificados
  AuthFormState copyWith({
    AuthFormStatus? status,
    String? errorMessage,
  }) {
    return AuthFormState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}

// ----------------------------------------------------------
// StateNotifier: maneja todas las operaciones de autenticación
// ----------------------------------------------------------

/// Notifier que ejecuta operaciones de auth y actualiza el estado del formulario
class AuthNotifier extends StateNotifier<AuthFormState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthFormState());

  // ----------------------------------------------------------
  // Inicio de sesión
  // ----------------------------------------------------------

  /// Inicia sesión con [email] y [password].
  /// Actualiza el estado a loading, luego success o error.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    // Marcar como cargando para mostrar el spinner en la UI
    state = const AuthFormState(status: AuthFormStatus.loading);

    try {
      await _repository.signIn(email: email, password: password);
      // Éxito: el StreamProvider de authStateChanges manejará la navegación
      state = const AuthFormState(status: AuthFormStatus.success);
    } on AuthException catch (e) {
      // Error de autenticación de Supabase: traducir al español
      state = AuthFormState(
        status: AuthFormStatus.error,
        errorMessage: AuthService.translateAuthError(e.message),
      );
    } catch (_) {
      // Error genérico de red u otro
      state = const AuthFormState(
        status: AuthFormStatus.error,
        errorMessage: 'Sin conexión. Verifica tu red e intenta nuevamente.',
      );
    }
  }

  // ----------------------------------------------------------
  // Registro
  // ----------------------------------------------------------

  /// Registra un nuevo usuario con [email], [password], [fullName] y [rut].
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String rut,
  }) async {
    state = const AuthFormState(status: AuthFormStatus.loading);

    try {
      await _repository.signUp(
        email: email,
        password: password,
        fullName: fullName,
        rut: rut,
      );
      state = const AuthFormState(status: AuthFormStatus.success);
    } on AuthException catch (e) {
      state = AuthFormState(
        status: AuthFormStatus.error,
        errorMessage: AuthService.translateAuthError(e.message),
      );
    } catch (_) {
      state = const AuthFormState(
        status: AuthFormStatus.error,
        errorMessage: 'Sin conexión. Verifica tu red e intenta nuevamente.',
      );
    }
  }

  // ----------------------------------------------------------
  // Cierre de sesión
  // ----------------------------------------------------------

  /// Cierra la sesión del usuario actual.
  Future<void> signOut() async {
    state = const AuthFormState(status: AuthFormStatus.loading);
    try {
      await _repository.signOut();
      state = const AuthFormState(status: AuthFormStatus.idle);
    } catch (_) {
      state = const AuthFormState(
        status: AuthFormStatus.error,
        errorMessage: 'No se pudo cerrar sesión. Intenta nuevamente.',
      );
    }
  }

  // ----------------------------------------------------------
  // Recuperación de contraseña
  // ----------------------------------------------------------

  /// Envía el correo de recuperación de contraseña a [email].
  Future<void> sendPasswordReset({required String email}) async {
    state = const AuthFormState(status: AuthFormStatus.loading);
    try {
      await _repository.sendPasswordReset(email: email);
      state = const AuthFormState(status: AuthFormStatus.success);
    } on AuthException catch (e) {
      state = AuthFormState(
        status: AuthFormStatus.error,
        errorMessage: AuthService.translateAuthError(e.message),
      );
    } catch (_) {
      state = const AuthFormState(
        status: AuthFormStatus.error,
        errorMessage: 'Sin conexión. Verifica tu red e intenta nuevamente.',
      );
    }
  }

  // ----------------------------------------------------------
  // Reiniciar estado
  // ----------------------------------------------------------

  /// Vuelve el formulario al estado inicial (idle, sin errores).
  /// Útil al navegar entre pantallas de auth.
  void reset() {
    state = const AuthFormState();
  }
}

// ----------------------------------------------------------
// Proveedores Riverpod
// ----------------------------------------------------------

/// Proveedor del repositorio de autenticación
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Proveedor del notifier del formulario de autenticación
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthFormState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

/// StreamProvider que escucha cambios en el estado de autenticación de Supabase.
/// Se usa en main.dart para redirigir entre LoginScreen y MainShell.
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});
