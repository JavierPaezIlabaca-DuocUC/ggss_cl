// ============================================================
// register_screen.dart
// Pantalla de registro de nueva cuenta en GGSS.cl.
//
// Campos:
//   - Tipo de cuenta (Personal / Empresa) — tarjetas seleccionables
//   - Nombre completo
//   - RUT chileno (con validación Módulo 11)
//   - Teléfono con prefijo +569 fijo (8 dígitos, obligatorio)
//   - Correo electrónico
//   - Contraseña (con toggle de visibilidad)
//   - Confirmar contraseña (con toggle de visibilidad)
//   - Alias público (opcional)
//
// Todos los campos obligatorios se validan antes de enviar.
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
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _aliasController = TextEditingController();

  // Tipo de cuenta seleccionado: 'personal' o 'empresa'
  String _accountType = 'personal';

  // ----------------------------------------------------------
  // Ciclo de vida: liberar controladores
  // ----------------------------------------------------------
  @override
  void dispose() {
    _fullNameController.dispose();
    _rutController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _aliasController.dispose();
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

    // El teléfono se almacena con el prefijo +569
    final phoneCompleto = '+569${_phoneController.text.trim()}';

    // Delegar el registro al AuthNotifier
    await ref.read(authNotifierProvider.notifier).signUp(
          email: _emailController.text,
          password: _passwordController.text,
          fullName: _fullNameController.text,
          rut: rutFormateado,
          accountType: _accountType,
          phone: phoneCompleto,
          alias: _aliasController.text.trim().isEmpty
              ? null
              : _aliasController.text.trim(),
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
                    // --------------------------------------------------
                    // Selector de tipo de cuenta
                    // --------------------------------------------------
                    Text(
                      AppStrings.authAccountType,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spacingSm),

                    Row(
                      children: [
                        Expanded(
                          child: _AccountTypeCard(
                            type: 'personal',
                            icon: Icons.person_outlined,
                            title: AppStrings.authAccountTypePersonal,
                            description:
                                AppStrings.authAccountTypePersonalDesc,
                            isSelected: _accountType == 'personal',
                            onTap: authState.isLoading
                                ? null
                                : () => setState(
                                      () => _accountType = 'personal',
                                    ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingMd),
                        Expanded(
                          child: _AccountTypeCard(
                            type: 'empresa',
                            icon: Icons.business_outlined,
                            title: AppStrings.authAccountTypeEmpresa,
                            description: AppStrings.authAccountTypeEmpresaDesc,
                            isSelected: _accountType == 'empresa',
                            onTap: authState.isLoading
                                ? null
                                : () => setState(
                                      () => _accountType = 'empresa',
                                    ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.spacingMd),

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
                      inputFormatters: [_RutInputFormatter()],
                      validator: Validators.validateRut,
                      decoration: const InputDecoration(
                        labelText: AppStrings.authRut,
                        hintText: AppStrings.authRutHint,
                        helperText: AppStrings.authRutHelper,
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spacingMd),

                    // Campo: teléfono con prefijo +569 fijo
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(8),
                      ],
                      validator: Validators.validatePhone8Digits,
                      decoration: const InputDecoration(
                        labelText: AppStrings.authPhone,
                        hintText: AppStrings.authPhoneHint,
                        helperText: AppStrings.authPhoneHelper,
                        prefixIcon: Icon(Icons.phone_outlined),
                        prefixText: '${AppStrings.authPhonePrefix} ',
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
                      validator: (value) =>
                          Validators.validateConfirmPassword(
                        value,
                        _passwordController.text,
                      ),
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: AppDimensions.spacingMd),

                    // Campo: alias público (opcional)
                    TextFormField(
                      controller: _aliasController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      validator: Validators.validateAlias,
                      decoration: const InputDecoration(
                        labelText: AppStrings.authAlias,
                        hintText: AppStrings.authAliasHint,
                        helperText: AppStrings.authAliasHelper,
                        prefixIcon: Icon(Icons.alternate_email),
                      ),
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
// Tarjeta de selección de tipo de cuenta
// ============================================================

class _AccountTypeCard extends StatelessWidget {
  final String type;
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback? onTap;

  const _AccountTypeCard({
    required this.type,
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: isSelected ? color : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: isSelected ? color : theme.iconTheme.color),
            const SizedBox(height: AppDimensions.spacingXs),
            Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isSelected ? color : null,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: theme.textTheme.bodySmall,
            ),
          ],
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
