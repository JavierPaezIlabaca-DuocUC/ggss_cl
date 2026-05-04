// ============================================================
// forgot_password_screen.dart
// Pantalla de recuperación de contraseña de GGSS.cl.
//
// Flujo de dos estados:
//   Estado 1 (formulario): campo de correo + botón "Enviar"
//   Estado 2 (confirmación): mensaje de éxito con instrucciones
//
// Supabase envía un correo con enlace para restablecer la contraseña.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import 'auth_providers.dart';

/// Pantalla de recuperación de contraseña de GGSS.cl
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  // ----------------------------------------------------------
  // Controladores y clave de formulario
  // ----------------------------------------------------------
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  // ----------------------------------------------------------
  // Ciclo de vida
  // ----------------------------------------------------------
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // Lógica: enviar solicitud de recuperación
  // ----------------------------------------------------------

  /// Valida el campo de correo y envía la solicitud a Supabase
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authNotifierProvider.notifier).sendPasswordReset(
          email: _emailController.text,
        );
  }

  // ----------------------------------------------------------
  // Construcción del widget
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.authRecoverPassword),
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
            vertical: AppDimensions.spacingXl,
          ),
          // Mostrar formulario o confirmación según el estado
          child: authState.isSuccess
              ? _buildSuccessState(theme)
              : _buildFormState(theme, authState),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // Estado 1: formulario para ingresar el correo
  // ----------------------------------------------------------

  Widget _buildFormState(ThemeData theme, AuthFormState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Ícono ilustrativo
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_reset,
              size: 40,
              color: AppColors.primaryBlue,
            ),
          ),
        ),

        const SizedBox(height: AppDimensions.spacingLg),

        // Título
        Text(
          AppStrings.authForgotPasswordTitle,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppDimensions.spacingSm),

        // Descripción del proceso
        Text(
          AppStrings.authForgotPasswordSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppDimensions.spacingXl),

        // Formulario con campo de correo
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Campo: correo electrónico
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autocorrect: false,
                enableSuggestions: false,
                validator: Validators.validateEmail,
                onFieldSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  labelText: AppStrings.authEmail,
                  hintText: AppStrings.authEmailHint,
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingMd),

              // Mensaje de error (visible solo si hay error)
              if (authState.hasError) ...[
                _AuthErrorBanner(message: authState.errorMessage!),
                const SizedBox(height: AppDimensions.spacingMd),
              ],

              // Botón: Enviar correo de recuperación
              FilledButton(
                onPressed: authState.isLoading ? null : _submit,
                child: authState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(AppStrings.actionSend),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // Estado 2: confirmación de correo enviado
  // ----------------------------------------------------------

  Widget _buildSuccessState(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppDimensions.spacingXl),

        // Ícono de éxito (sobre de correo con check)
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              size: 52,
              color: AppColors.success,
            ),
          ),
        ),

        const SizedBox(height: AppDimensions.spacingLg),

        // Título de confirmación
        Text(
          AppStrings.authRecoverySuccessTitle,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.success,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppDimensions.spacingMd),

        // Correo al que se envió (para confirmar al usuario)
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
            vertical: AppDimensions.spacingSm,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Text(
            _emailController.text,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: AppDimensions.spacingMd),

        // Instrucciones detalladas
        Text(
          AppStrings.authRecoverySuccessBody,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppDimensions.spacingXl),

        // Botón para volver al inicio de sesión
        OutlinedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          label: const Text(AppStrings.authBackToLogin),
        ),
      ],
    );
  }
}

// ============================================================
// Widget privado: banner de error
// ============================================================

/// Banner de error con fondo y borde rojo claro
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
