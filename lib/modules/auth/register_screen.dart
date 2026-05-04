// ============================================================
// register_screen.dart
// Pantalla de registro de nueva cuenta en GGSS.cl.
//
// Campos:
//   - Nombre completo
//   - RUT chileno (con validación Módulo 11)
//   - Correo electrónico
//   - Contraseña (con toggle de visibilidad)
//   - Confirmar contraseña (con toggle de visibilidad)
//
// Todos los campos se validan antes de enviar.
// Autenticación real con Supabase Auth via AuthNotifier.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../shared/widgets/password_text_field.dart';
import '../shell/main_shell.dart';
import 'auth_providers.dart';

/// Pantalla de registro de nueva cuenta de GGSS.cl
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  // ----------------------------------------------------------
  // Controladores de campos
  // ----------------------------------------------------------
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _rutController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ----------------------------------------------------------
  // Ciclo de vida: liberar controladores
  // ----------------------------------------------------------
  @override
  void dispose() {
    _fullNameController.dispose();
    _rutController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // Lógica: enviar formulario de registro
  // ----------------------------------------------------------

  /// Valida todos los campos y ejecuta el registro en Supabase
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    // Validar el formulario completo
    if (!_formKey.currentState!.validate()) return;

    // Formatear el RUT al estándar XX.XXX.XXX-Y antes de guardar
    final rutFormateado = Validators.formatRut(_rutController.text);

    // Delegar el registro al AuthNotifier
    await ref.read(authNotifierProvider.notifier).signUp(
          email: _emailController.text,
          password: _passwordController.text,
          fullName: _fullNameController.text,
          rut: rutFormateado,
        );
  }

  // ----------------------------------------------------------
  // Construcción del widget
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Escuchar el resultado del registro
    ref.listen<AuthFormState>(authNotifierProvider, (_, next) {
      if (next.isSuccess) {
        // Registro exitoso: navegar al shell principal, limpiar pila
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainShell()),
          (route) => false,
        );
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      // AppBar con botón de retroceso
      appBar: AppBar(
        title: const Text(AppStrings.authRegister),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: AppStrings.actionBack,
          onPressed:
              authState.isLoading ? null : () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingLg,
            vertical: AppDimensions.spacingLg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --------------------------------------------------
              // Subtítulo de la pantalla
              // --------------------------------------------------
              Text(
                AppStrings.authRegisterSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimensions.spacingLg),

              // --------------------------------------------------
              // Formulario de registro
              // --------------------------------------------------
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Campo: nombre completo
                    TextFormField(
                      controller: _fullNameController,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      validator: Validators.validateFullName,
                      decoration: const InputDecoration(
                        labelText: AppStrings.authFullName,
                        hintText: AppStrings.authFullNameHint,
                        prefixIcon: Icon(Icons.person_outlined),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spacingMd),

                    // Campo: RUT chileno con formato automático
                    TextFormField(
                      controller: _rutController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      // Aceptar letras (para la K del dígito verificador)
                      // y filtrar automáticamente a mayúsculas
                      inputFormatters: [
                        _RutInputFormatter(),
                      ],
                      validator: Validators.validateRut,
                      decoration: const InputDecoration(
                        labelText: AppStrings.authRut,
                        hintText: AppStrings.authRutHint,
                        helperText: AppStrings.authRutHelper,
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spacingMd),

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

                    // Campo: contraseña con toggle de visibilidad
                    PasswordTextField(
                      label: AppStrings.authPassword,
                      hint: AppStrings.authPasswordHint,
                      controller: _passwordController,
                      validator: Validators.validatePassword,
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: AppDimensions.spacingMd),

                    // Campo: confirmar contraseña con toggle de visibilidad
                    PasswordTextField(
                      label: AppStrings.authConfirmPassword,
                      hint: AppStrings.authConfirmPasswordHint,
                      controller: _confirmPasswordController,
                      // La validación verifica que coincida con la contraseña
                      validator: (value) => Validators.validateConfirmPassword(
                        value,
                        _passwordController.text,
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: _submit,
                    ),

                    const SizedBox(height: AppDimensions.spacingMd),

                    // Banner de error (visible solo cuando hay error)
                    if (authState.hasError) ...[
                      _AuthErrorBanner(message: authState.errorMessage!),
                      const SizedBox(height: AppDimensions.spacingMd),
                    ],

                    // Botón principal: Crear cuenta
                    FilledButton(
                      onPressed: authState.isLoading ? null : _submit,
                      child: authState.isLoading
                          ? const _LoadingButtonContent()
                          : const Text(AppStrings.authRegister),
                    ),

                    const SizedBox(height: AppDimensions.spacingMd),

                    // Enlace para volver al inicio de sesión
                    _LoginLink(
                      isLoading: authState.isLoading,
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
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
// Formatter de RUT: convierte a mayúsculas y filtra caracteres
// ============================================================

/// Formatea el RUT mientras el usuario escribe:
/// - Convierte a mayúsculas (para la K del dígito verificador)
/// - Solo permite dígitos, puntos, guiones y la letra K
class _RutInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Convertir a mayúsculas y filtrar caracteres no permitidos
    final filtered = newValue.text
        .toUpperCase()
        .replaceAll(RegExp(r'[^0-9.\-K]'), '');

    return newValue.copyWith(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}

// ============================================================
// Widgets privados compartidos entre pantallas de auth
// ============================================================

/// Banner de error con borde y fondo rojo claro
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

/// Spinner blanco pequeño para mostrar carga dentro de un botón
class _LoadingButtonContent extends StatelessWidget {
  const _LoadingButtonContent();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
    );
  }
}

/// Fila con enlace para volver al inicio de sesión
class _LoginLink extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _LoginLink({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(AppStrings.authHasAccount, style: theme.textTheme.bodyMedium),
        GestureDetector(
          onTap: isLoading ? null : onTap,
          child: Text(
            AppStrings.authLogin,
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
