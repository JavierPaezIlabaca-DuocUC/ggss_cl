// ============================================================
// auth_repository.dart
// Repositorio de autenticación: intermediario entre la UI
// y AuthService. Encapsula la lógica de negocio de auth.
// ============================================================

import 'package:supabase_flutter/supabase_flutter.dart';

import '../exceptions/app_exceptions.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';

/// Repositorio de autenticación de GGSS.cl
class AuthRepository {
  final AuthService _authService;

  /// Se usa para crear el perfil en 'profiles' tras un registro exitoso.
  final ProfileService _profileService;

  AuthRepository({AuthService? authService, ProfileService? profileService})
      : _authService = authService ?? AuthService(),
        _profileService = profileService ?? ProfileService();

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

  /// Registra un nuevo usuario con todos los campos del formulario de registro.
  /// Verifica el RUT ANTES de llamar a Supabase para evitar usuarios huérfanos.
  /// Tras el registro exitoso crea el perfil en la tabla 'profiles'.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String rut,
    String accountType = 'personal',
    String? phone,
    String? firstName,
    String? lastNamePaternal,
    String? lastNameMaternal,
    // DEPRECATED: alias - kept for potential future use
    // String? alias,
  }) async {
    // Verificar unicidad del RUT ANTES de crear el usuario en auth.users.
    // Si el RUT ya existe y se llamara a signUp primero, el usuario quedaría
    // creado en auth sin perfil correspondiente.
    final rutTaken = await _profileService.rutExists(rut);
    if (rutTaken) {
      throw const RutAlreadyExistsException();
    }

    final response = await _authService.signUpWithEmailAndPassword(
      email: email,
      password: password,
      fullName: fullName,
      rut: rut,
      accountType: accountType,
      phone: phone,
    );

    // Crear perfil en 'profiles' si el usuario fue creado correctamente.
    if (response.user != null) {
      try {
        await _profileService.createProfileIfNotExists(
          response.user!.id,
          fullName,
          rut,
          accountType: accountType,
          phone: phone,
          email: email,
          firstName: firstName,
          lastNamePaternal: lastNamePaternal,
          lastNameMaternal: lastNameMaternal,
        );
      } on PostgrestException catch (e) {
        // Violación de restricción UNIQUE en la columna phone
        if (e.code == '23505' &&
            (e.message.contains('phone') ||
                e.message.contains('profiles_phone'))) {
          throw const PhoneAlreadyExistsException();
        }
        // Otros errores de PostgREST: fallo silencioso, el perfil
        // se creará en la primera visita al módulo de perfil
      } catch (_) {
        // Fallo silencioso — el perfil se creará en la primera visita al módulo
      }
    }

    return response;
  }

  /// Envía correo de recuperación de contraseña
  Future<void> sendPasswordReset({required String email}) async {
    await _authService.sendPasswordResetEmail(email: email);
  }

  /// Reenvía el correo de confirmación de cuenta a [email]
  Future<void> resendConfirmationEmail({required String email}) async {
    await _authService.resendConfirmationEmail(email: email);
  }

  /// Refresca la sesión activa para obtener emailConfirmedAt actualizado
  Future<void> refreshSession() async {
    await _authService.refreshSession();
  }

  /// Cierra la sesión del usuario
  Future<void> signOut() async {
    await _authService.signOut();
  }
}
