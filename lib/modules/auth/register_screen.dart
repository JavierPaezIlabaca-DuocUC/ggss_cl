// ============================================================
// register_screen.dart
// Pantalla de registro de nueva cuenta en GGSS.cl.
//
// Campos:
//   - Tipo de cuenta (Personal / Empresa) — tarjetas seleccionables
//   - Primer nombre, Apellido paterno, Apellido materno
//   - RUT chileno (con validación Módulo 11)
//   - Teléfono con prefijo +569 fijo (8 dígitos, obligatorio)
//   - Correo electrónico
//   - Contraseña (con toggle de visibilidad)
//   - Confirmar contraseña (con toggle de visibilidad)
//
// Todos los campos obligatorios se validan antes de enviar.
// Autenticación real con Supabase Auth via AuthNotifier.
// ============================================================

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../shared/formatters/phone_digits_formatter.dart';
import '../../shared/widgets/password_text_field.dart';
import '../settings/terms_screen.dart';
import '../shell/main_shell.dart';
import 'auth_providers.dart';
import 'forgot_password_screen.dart';

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

  // Nombre: tres campos separados
  final _firstNameController = TextEditingController();
  final _lastNamePaternalController = TextEditingController();
  final _lastNameMaternalController = TextEditingController();

  final _rutController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _confirmEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // DEPRECATED: alias system - kept for potential future use
  // final _aliasController = TextEditingController();

  // Tipo de cuenta seleccionado: 'personal' o 'empresa'
  String _accountType = 'personal';

  // Estado del checkbox de términos y condiciones
  bool _termsAccepted = false;
  bool _termsErrorVisible = false;

  // ----------------------------------------------------------
  // Ciclo de vida: liberar controladores
  // ----------------------------------------------------------
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNamePaternalController.dispose();
    _lastNameMaternalController.dispose();
    _rutController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _confirmEmailController.dispose();
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

    // Validar que se aceptaron los términos y condiciones
    if (!_termsAccepted) {
      setState(() => _termsErrorVisible = true);
      return;
    }

    // Formatear el RUT al estándar XX.XXX.XXX-Y antes de guardar
    final rutFormateado = Validators.formatRut(_rutController.text);

    // El teléfono se almacena con el prefijo +569 (sin los espacios del formatter)
    final phoneCompleto =
        '+569${_phoneController.text.replaceAll(' ', '').trim()}';

    // Nombre completo: primer nombre + apellido paterno + materno
    final firstName = _firstNameController.text.trim();
    final lastNamePaternal = _lastNamePaternalController.text.trim();
    final lastNameMaternal = _lastNameMaternalController.text.trim();
    final fullName = [
      firstName,
      if (lastNamePaternal.isNotEmpty) lastNamePaternal,
      if (lastNameMaternal.isNotEmpty) lastNameMaternal,
    ].join(' ');

    // Delegar el registro al AuthNotifier
    await ref.read(authNotifierProvider.notifier).signUp(
          email: _emailController.text,
          password: _passwordController.text,
          fullName: fullName,
          rut: rutFormateado,
          accountType: _accountType,
          phone: phoneCompleto,
          firstName: firstName,
          lastNamePaternal: lastNamePaternal.isEmpty ? null : lastNamePaternal,
          lastNameMaternal: lastNameMaternal.isEmpty ? null : lastNameMaternal,
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

                    // Campo: primer nombre
                    TextFormField(
                      controller: _firstNameController,
                      enabled: !authState.isLoading,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El primer nombre es requerido.';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Primer nombre *',
                        hintText: 'Ej: Juan',
                        prefixIcon: Icon(Icons.person_outlined),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Texto informativo debajo del campo de primer nombre
                    Text(
                      'Solo tu primer nombre será visible públicamente.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.6),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spacingMd),

                    // Campo: apellido paterno
                    TextFormField(
                      controller: _lastNamePaternalController,
                      enabled: !authState.isLoading,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El apellido paterno es requerido.';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Apellido paterno *',
                        hintText: 'Ej: Pérez',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spacingMd),

                    // Campo: apellido materno (opcional)
                    TextFormField(
                      controller: _lastNameMaternalController,
                      enabled: !authState.isLoading,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Apellido materno (opcional)',
                        hintText: 'Ej: González',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spacingMd),

                    // Campo: RUT chileno con formato automático en tiempo real
                    TextFormField(
                      controller: _rutController,
                      enabled: !authState.isLoading,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [_RutInputFormatter()],
                      validator: Validators.validateRut,
                      decoration: const InputDecoration(
                        labelText: AppStrings.authRut,
                        hintText: '12.345.678-9',
                        helperText: AppStrings.authRutHelper,
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spacingMd),

                    // Campo: teléfono con prefijo +569 fijo y formato automático
                    TextFormField(
                      controller: _phoneController,
                      enabled: !authState.isLoading,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [PhoneDigitsFormatter()],
                      validator: (value) => Validators.validatePhone8Digits(
                        value?.replaceAll(' ', ''),
                      ),
                      decoration: const InputDecoration(
                        labelText: AppStrings.authPhone,
                        hintText: '12 34 56 78',
                        helperText: AppStrings.authPhoneHelper,
                        prefixIcon: Icon(Icons.phone_outlined),
                        prefixText: '+569 ',
                        prefixStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spacingMd),

                    // Campo: correo electrónico
                    TextFormField(
                      controller: _emailController,
                      enabled: !authState.isLoading,
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

                    // Campo: confirmar correo electrónico
                    TextFormField(
                      controller: _confirmEmailController,
                      enabled: !authState.isLoading,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      enableSuggestions: false,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Debes confirmar tu correo electrónico.';
                        }
                        if (value.trim() != _emailController.text.trim()) {
                          return 'Los correos electrónicos no coinciden.';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Confirmar correo electrónico',
                        hintText: AppStrings.authEmailHint,
                        prefixIcon: Icon(Icons.mark_email_read_outlined),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spacingMd),

                    // Campo: contraseña con toggle de visibilidad
                    PasswordTextField(
                      label: AppStrings.authPassword,
                      hint: AppStrings.authPasswordHint,
                      controller: _passwordController,
                      enabled: !authState.isLoading,
                      validator: Validators.validateStrongPassword,
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: AppDimensions.spacingSm),

                    // Caja informativa de requisitos de contraseña (siempre visible)
                    const _PasswordRequirementsBox(),

                    const SizedBox(height: AppDimensions.spacingMd),

                    // Campo: confirmar contraseña con toggle de visibilidad
                    PasswordTextField(
                      label: AppStrings.authConfirmPassword,
                      hint: AppStrings.authConfirmPasswordHint,
                      controller: _confirmPasswordController,
                      enabled: !authState.isLoading,
                      validator: (value) =>
                          Validators.validateConfirmPassword(
                        value,
                        _passwordController.text,
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: _submit,
                    ),

                    const SizedBox(height: AppDimensions.spacingMd),

                    // Banner de error (visible solo cuando hay error)
                    if (authState.hasError) ...[
                      if (authState.errorCode ==
                          AuthErrorCode.rutAlreadyExists)
                        _RutExistsErrorBanner(
                          message: authState.errorMessage!,
                        )
                      else if (authState.errorCode ==
                          AuthErrorCode.emailAlreadyExists)
                        _EmailExistsErrorBanner(
                          message: authState.errorMessage!,
                          email: _emailController.text,
                        )
                      else
                        _AuthErrorBanner(message: authState.errorMessage!),
                      const SizedBox(height: AppDimensions.spacingMd),
                    ],

                    // Checkbox: aceptar términos y condiciones
                    _TermsCheckbox(
                      value: _termsAccepted,
                      enabled: !authState.isLoading,
                      onChanged: (value) => setState(() {
                        _termsAccepted = value ?? false;
                        if (_termsAccepted) _termsErrorVisible = false;
                      }),
                    ),

                    if (_termsErrorVisible) ...[
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text(
                          'Debes aceptar los términos y condiciones para continuar.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: AppDimensions.spacingMd),

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
// Formatter de RUT: aplica puntos y guión en tiempo real
// Formato: X.XXX.XXX-X o XX.XXX.XXX-X (máx 9 chars significativos)
// ============================================================

/// Formatea el RUT mientras el usuario escribe aplicando puntos y guión.
class _RutInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Limpiar: solo dígitos y K en mayúscula
    final raw = newValue.text.toUpperCase().replaceAll(RegExp(r'[^0-9K]'), '');

    if (raw.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Limitar a 9 caracteres significativos (8 dígitos + 1 DV)
    final limited = raw.length > 9 ? raw.substring(0, 9) : raw;

    // Separar cuerpo (todos menos el último) y DV (último)
    final body = limited.length > 1
        ? limited.substring(0, limited.length - 1)
        : limited;
    final dv = limited.length > 1 ? limited[limited.length - 1] : '';

    // Insertar puntos cada 3 dígitos desde la derecha del cuerpo
    final buffer = StringBuffer();
    for (int i = 0; i < body.length; i++) {
      if (i > 0 && (body.length - i) % 3 == 0) buffer.write('.');
      buffer.write(body[i]);
    }

    final result = dv.isEmpty ? buffer.toString() : '${buffer.toString()}-$dv';

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}

// ============================================================
// Widgets privados compartidos entre pantallas de auth
// ============================================================

/// Caja informativa de requisitos de contraseña (siempre visible)
class _PasswordRequirementsBox extends StatelessWidget {
  const _PasswordRequirementsBox();

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.primaryBlue,
        );

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.secondaryBlue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: AppColors.secondaryBlue.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'La contraseña debe tener:',
            style: textStyle?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text('• Mínimo 8 caracteres', style: textStyle),
          Text('• Al menos una mayúscula', style: textStyle),
          Text('• Al menos un número', style: textStyle),
        ],
      ),
    );
  }
}

/// Banner para cuando el RUT ya está registrado — incluye enlace a soporte
class _RutExistsErrorBanner extends StatelessWidget {
  final String message;
  const _RutExistsErrorBanner({required this.message});

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                      ),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    text: '¿Su RUT está siendo utilizado por otro usuario? '
                        'Escríbanos a ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.error,
                        ),
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: GestureDetector(
                          onTap: () => launchUrl(
                            Uri.parse('mailto:soporte@ggss.cl'),
                          ),
                          child: Text(
                            'soporte@ggss.cl',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.primaryBlue,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.primaryBlue,
                                    ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Banner para cuando el correo ya está registrado — incluye enlace a reset
class _EmailExistsErrorBanner extends StatelessWidget {
  final String message;
  final String email;
  const _EmailExistsErrorBanner({required this.message, required this.email});

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                      ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ForgotPasswordScreen(initialEmail: email),
                    ),
                  ),
                  child: Text(
                    'Restablecer contraseña',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primaryBlue,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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

// ============================================================
// Checkbox de términos y condiciones
// Fix 2: texto uniforme usando TextSpan + TapGestureRecognizer
// para evitar inconsistencias de tamaño con WidgetSpan.
// ============================================================

/// Fila con checkbox y texto de términos (con enlace) en tamaño uniforme
class _TermsCheckbox extends StatelessWidget {
  final bool value;
  final bool enabled;
  final ValueChanged<bool?> onChanged;

  const _TermsCheckbox({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = theme.textTheme.bodySmall;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: value,
          onChanged: enabled ? onChanged : null,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: 'Acepto los ',
              style: baseStyle,
              children: [
                TextSpan(
                  text: 'términos y condiciones',
                  style: baseStyle?.copyWith(
                    color: AppColors.primaryBlue,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TermsScreen(),
                          ),
                        ),
                ),
                TextSpan(text: ' de GGSS.cl', style: baseStyle),
              ],
            ),
          ),
        ),
      ],
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
