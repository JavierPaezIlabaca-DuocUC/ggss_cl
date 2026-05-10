// ============================================================
// email_verification_screen.dart
// Pantalla de verificación de credenciales.
//
// Se muestra cuando el usuario se registra pero aún no ha
// confirmado su correo. Permite reenviar el enlace de verificación
// y verificar si ya lo confirmó, además de cerrar sesión.
//
// El enlace de verificación apunta a la Edge Function auth-confirm,
// que funciona desde cualquier dispositivo o navegador.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../auth/auth_providers.dart';
import '../auth/login_screen.dart';
import '../shell/main_shell.dart';

/// Pantalla que se muestra cuando el usuario registrado aún no confirmó su correo
class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen>
    with WidgetsBindingObserver {
  // ----------------------------------------------------------
  // Ciclo de vida: WidgetsBindingObserver para detectar foreground
  // ----------------------------------------------------------

  @override
  void initState() {
    super.initState();
    // Registrar observer para detectar cuando la app vuelve al primer plano.
    // Esto permite verificar automáticamente si el correo fue confirmado
    // cuando el usuario llega a la app desde el enlace de verificación
    // (deep link ggss://app redirigido por la Edge Function auth-confirm).
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Cuando la app vuelve al primer plano (ej. tras abrir el enlace de
    // verificación en el navegador y ser redirigida vía deep link),
    // verificar automáticamente si el correo ya fue confirmado.
    if (state == AppLifecycleState.resumed && mounted) {
      _checkVerification();
    }
  }

  // ----------------------------------------------------------
  // Estado local
  // ----------------------------------------------------------
  bool _isResending = false;
  bool _isChecking = false;
  String? _feedbackMessage;
  bool _feedbackIsSuccess = false;

  // ----------------------------------------------------------
  // Obtener el correo del usuario actual
  // ----------------------------------------------------------

  String get _userEmail {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.email ?? '';
  }

  // ----------------------------------------------------------
  // Reenviar correo de verificación
  // ----------------------------------------------------------

  Future<void> _resendEmail() async {
    if (_userEmail.isEmpty) return;

    setState(() {
      _isResending = true;
      _feedbackMessage = null;
    });

    try {
      await ref
          .read(authRepositoryProvider)
          .resendConfirmationEmail(email: _userEmail);

      if (mounted) {
        setState(() {
          _feedbackMessage = AppStrings.emailVerifResendSuccess;
          _feedbackIsSuccess = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _feedbackMessage = AppStrings.emailVerifResendError;
          _feedbackIsSuccess = false;
        });
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  // ----------------------------------------------------------
  // Verificar si el correo ya fue confirmado
  // ----------------------------------------------------------

  Future<void> _checkVerification() async {
    setState(() {
      _isChecking = true;
      _feedbackMessage = null;
    });

    try {
      // Refrescar sesión para obtener emailConfirmedAt actualizado
      await ref.read(authRepositoryProvider).refreshSession();

      final user = Supabase.instance.client.auth.currentUser;

      if (user?.emailConfirmedAt != null) {
        // Correo confirmado: el StreamProvider de authStateChanges en main.dart
        // detectará el cambio y navegará automáticamente al MainShell.
        // Navegamos también de forma explícita para respuesta inmediata.
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainShell()),
            (route) => false,
          );
        }
      } else {
        // Aún no confirmado
        if (mounted) {
          setState(() {
            _feedbackMessage = AppStrings.emailVerifNotYet;
            _feedbackIsSuccess = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _feedbackMessage = AppStrings.emailVerifCheckError;
          _feedbackIsSuccess = false;
        });
      }
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  // ----------------------------------------------------------
  // Cerrar sesión y volver al login
  // ----------------------------------------------------------

  Future<void> _signOut() async {
    await ref.read(authNotifierProvider.notifier).signOut();
    // Limpiar la pila de navegación y mostrar la pantalla de inicio de sesión
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  // ----------------------------------------------------------
  // Construcción del widget
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // ----------------------------------------------------------
    // Listener: navegación automática al confirmar correo por deep link
    //
    // Cuando el usuario toca el enlace de verificación en su correo,
    // la Edge Function auth-confirm redirige a ggss://app. Supabase
    // procesa el PKCE y emite SIGNED_IN con emailConfirmedAt != null.
    //
    // Sin este listener, GgssApp.build() actualizaría home: MainShell()
    // pero el Navigator (ya inicializado) no navegaría automáticamente.
    // Este listener maneja la navegación imperativa para ese caso.
    // ----------------------------------------------------------
    ref.listen<AsyncValue<AuthState>>(authStateChangesProvider, (_, next) {
      next.whenData((authState) {
        if (!mounted) return;
        if (authState.session?.user.emailConfirmedAt != null) {
          // Correo confirmado: ir al shell principal
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainShell()),
            (route) => false,
          );
        } else if (authState.session == null) {
          // Sesión cerrada externamente: volver al login
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      });
    });
    final theme = Theme.of(context);
    final bool isLoading = _isResending || _isChecking;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingLg,
            vertical: AppDimensions.spacingXl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --------------------------------------------------
              // Ícono ilustrativo del correo
              // --------------------------------------------------
              const SizedBox(height: AppDimensions.spacingXl),
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_outlined,
                    color: AppColors.primaryBlue,
                    size: 52,
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingLg),

              // --------------------------------------------------
              // Título
              // --------------------------------------------------
              Text(
                AppStrings.emailVerifTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: AppDimensions.spacingSm),

              Text(
                AppStrings.emailVerifWaiting,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: AppDimensions.spacingMd),

              // --------------------------------------------------
              // Descripción con el correo del usuario
              // --------------------------------------------------
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(
                      text: AppStrings.emailVerifSubtitlePre,
                    ),
                    TextSpan(
                      text: _userEmail,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const TextSpan(
                      text: AppStrings.emailVerifSubtitlePost,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spacingXl),

              // --------------------------------------------------
              // Banner de feedback (éxito o error)
              // --------------------------------------------------
              if (_feedbackMessage != null) ...[
                _FeedbackBanner(
                  message: _feedbackMessage!,
                  isSuccess: _feedbackIsSuccess,
                ),
                const SizedBox(height: AppDimensions.spacingMd),
              ],

              // --------------------------------------------------
              // Botón: Ya verifiqué mi correo
              // --------------------------------------------------
              FilledButton.icon(
                onPressed: isLoading ? null : _checkVerification,
                icon: _isChecking
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: const Text(AppStrings.emailVerifAlreadyDone),
                style: FilledButton.styleFrom(
                  minimumSize:
                      const Size(double.infinity, AppDimensions.inputHeight),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingMd),

              // --------------------------------------------------
              // Botón: Reenviar correo de verificación
              // --------------------------------------------------
              OutlinedButton.icon(
                onPressed: isLoading ? null : _resendEmail,
                icon: _isResending
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send_outlined),
                label: const Text(AppStrings.emailVerifResend),
                style: OutlinedButton.styleFrom(
                  minimumSize:
                      const Size(double.infinity, AppDimensions.inputHeight),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingLg),

              const Divider(),

              const SizedBox(height: AppDimensions.spacingMd),

              // --------------------------------------------------
              // Botón: Cerrar sesión
              // --------------------------------------------------
              TextButton.icon(
                onPressed: isLoading ? null : _signOut,
                icon: const Icon(Icons.logout, size: 18),
                label: const Text(AppStrings.authLogout),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Widgets internos
// ============================================================

/// Banner de retroalimentación (verde para éxito, rojo para error)
class _FeedbackBanner extends StatelessWidget {
  final String message;
  final bool isSuccess;

  const _FeedbackBanner({required this.message, required this.isSuccess});

  @override
  Widget build(BuildContext context) {
    final color = isSuccess ? AppColors.success : AppColors.error;
    final icon = isSuccess ? Icons.check_circle_outline : Icons.error_outline;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: AppDimensions.spacingSm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

