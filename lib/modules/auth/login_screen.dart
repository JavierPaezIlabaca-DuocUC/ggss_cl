// ============================================================
// login_screen.dart
// Pantalla de inicio de sesión de GGSS.cl.
//
// Campos: correo electrónico + contraseña (con toggle de visibilidad)
// Acciones: iniciar sesión, ir a registro, ir a recuperar contraseña
// Autenticación real con Supabase Auth via AuthNotifier (Riverpod)
//
// PUNTOS DE EXTENSIÓN (comentados — no implementar aún):
//   - Botón "Continuar con Google"
//   - Botón "Continuar con Apple"
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../shared/widgets/password_text_field.dart';
import '../shell/main_shell.dart';
import 'auth_providers.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

/// Pantalla de inicio de sesión de GGSS.cl
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // ----------------------------------------------------------
  // Controladores y clave de formulario
  // ----------------------------------------------------------
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // ----------------------------------------------------------
  // Ciclo de vida: liberar controladores al destruir el widget
  // ----------------------------------------------------------
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // Lógica: enviar formulario de inicio de sesión
  // ----------------------------------------------------------

  /// Valida el formulario y ejecuta el inicio de sesión con Supabase
  Future<void> _submit() async {
    // Cerrar teclado antes de procesar
    FocusScope.of(context).unfocus();

    // Validar todos los campos antes de enviar
    if (!_formKey.currentState!.validate()) return;

    // Delegar la autenticación al AuthNotifier (Riverpod)
    await ref.read(authNotifierProvider.notifier).signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  // ----------------------------------------------------------
  // Navegación entre pantallas de autenticación
  // ----------------------------------------------------------

  void _navigateToRegister() {
    ref.read(authNotifierProvider.notifier).reset();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  void _navigateToForgotPassword() {
    ref.read(authNotifierProvider.notifier).reset();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
    );
  }

  // ----------------------------------------------------------
  // Construcción del widget principal
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Escuchar cambios del notifier para navegar al éxito
    ref.listen<AuthFormState>(authNotifierProvider, (_, next) {
      if (next.isSuccess) {
        // Login exitoso: reemplazar toda la pila de navegación con MainShell
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainShell()),
          (route) => false,
        );
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
              // Encabezado: ícono + nombre de la app + subtítulo
              // --------------------------------------------------
              _AppHeader(),

              const SizedBox(height: AppDimensions.spacingXl),

              // --------------------------------------------------
              // Formulario de inicio de sesión
              // --------------------------------------------------
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Campo: correo electrónico
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      enableSuggestions: false,
                      validator: Validators.validateEmail,
                      decoration: const InputDecoration(
                        labelText: AppStrings.authEmail,
                        hintText: AppStrings.authEmailHint,
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spacingMd),

                    // Campo: contraseña con ojo abierto/cerrado
                    PasswordTextField(
                      label: AppStrings.authPassword,
                      hint: AppStrings.authPasswordHint,
                      controller: _passwordController,
                      validator: Validators.validatePassword,
                      textInputAction: TextInputAction.done,
                      onSubmitted: _submit,
                    ),

                    const SizedBox(height: AppDimensions.spacingXs),

                    // Enlace: ¿Olvidaste tu contraseña?
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: authState.isLoading
                            ? null
                            : _navigateToForgotPassword,
                        child: const Text(AppStrings.authForgotPassword),
                      ),
                    ),

                    // Banner de error (visible solo cuando hay error)
                    if (authState.hasError) ...[
                      const SizedBox(height: AppDimensions.spacingSm),
                      _AuthErrorBanner(message: authState.errorMessage!),
                    ],

                    const SizedBox(height: AppDimensions.spacingMd),

                    // Botón principal: Iniciar sesión
                    FilledButton(
                      onPressed: authState.isLoading ? null : _submit,
                      child: authState.isLoading
                          ? const _LoadingButtonContent()
                          : const Text(AppStrings.authLogin),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spacingXxl),

              // --------------------------------------------------
              // PUNTO DE EXTENSIÓN: autenticación social (futura versión)
              // Descomentar cuando se implementen Google/Apple Sign-In:
              // --------------------------------------------------
              // const _SocialDivider(),
              // const SizedBox(height: AppDimensions.spacingMd),
              // _SocialButton(
              //   label: 'Continuar con Google',
              //   iconAsset: 'assets/icons/google.svg',
              //   onPressed: () => ref
              //       .read(authNotifierProvider.notifier)
              //       .scaffoldGoogleSignIn(),
              // ),
              // const SizedBox(height: AppDimensions.spacingSm),
              // _SocialButton(
              //   label: 'Continuar con Apple',
              //   iconAsset: 'assets/icons/apple.svg',
              //   onPressed: () => ref
              //       .read(authNotifierProvider.notifier)
              //       .scaffoldAppleSignIn(),
              // ),

              // --------------------------------------------------
              // Enlace para crear cuenta nueva
              // --------------------------------------------------
              _RegisterLink(
                isLoading: authState.isLoading,
                onTap: _navigateToRegister,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Widgets privados de LoginScreen
// ============================================================

/// Encabezado con ícono, nombre y subtítulo de la app
class _AppHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        // Ícono de seguridad representativo de GGSS.cl
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.security,
            color: Colors.white,
            size: 44,
          ),
        ),

        const SizedBox(height: AppDimensions.spacingMd),

        // Nombre de la app en azul primario
        Text(
          AppStrings.appName,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: AppDimensions.spacingXs),

        // Subtítulo
        Text(
          AppStrings.authLoginSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Banner de error de autenticación con borde rojo
class _AuthErrorBanner extends StatelessWidget {
  final String message;
  const _AuthErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: AppDimensions.spacingSm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Indicador de carga dentro del botón (spinner blanco pequeño)
class _LoadingButtonContent extends StatelessWidget {
  const _LoadingButtonContent();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 2.5,
      ),
    );
  }
}

/// Fila con enlace para ir a la pantalla de registro
class _RegisterLink extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _RegisterLink({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(AppStrings.authNoAccount, style: theme.textTheme.bodyMedium),
        GestureDetector(
          onTap: isLoading ? null : onTap,
          child: Text(
            AppStrings.authRegister,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primaryBlue,
            ),
          ),
        ),
      ],
    );
  }
}
