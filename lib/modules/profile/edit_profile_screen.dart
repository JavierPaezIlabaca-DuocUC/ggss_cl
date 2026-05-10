// ============================================================
// edit_profile_screen.dart
// Pantalla para editar el perfil del usuario.
//
// Secciones independientes, cada una con su propio botón:
//   1. Nombre (RUT solo lectura + primer nombre, apellido paterno, materno)
//   2. Contraseña (nueva contraseña + confirmación + requisitos)
//   3. Correo electrónico (actual solo lectura, nuevo, confirmación)
//   4. Teléfono (actual solo lectura + nuevo con prefijo +569)
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../models/profile_model.dart';
import '../../shared/formatters/phone_digits_formatter.dart';
import '../../shared/widgets/password_requirements_box.dart';
import 'profile_providers.dart';

/// Pantalla de edición del perfil del usuario autenticado
class EditProfileScreen extends ConsumerStatefulWidget {
  /// Perfil actual del usuario (usado para pre-rellenar el formulario)
  final ProfileModel profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  // ----------------------------------------------------------
  // Controladores: Nombre
  // ----------------------------------------------------------

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNamePaternalController;
  late final TextEditingController _lastNameMaternalController;
  bool _isSavingName = false;
  final _nameFormKey = GlobalKey<FormState>();

  // ----------------------------------------------------------
  // Controladores: Contraseña
  // ----------------------------------------------------------

  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSavingPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  String? _passwordError;
  final _passwordFormKey = GlobalKey<FormState>();

  // ----------------------------------------------------------
  // Controladores: Correo electrónico
  // ----------------------------------------------------------

  late String _currentEmail;
  final _newEmailController = TextEditingController();
  final _confirmEmailController = TextEditingController();
  bool _isSavingEmail = false;
  String? _emailError;
  String? _emailSuccess;
  final _emailFormKey = GlobalKey<FormState>();

  // ----------------------------------------------------------
  // Controladores: Teléfono
  // ----------------------------------------------------------

  late String _currentPhone;
  final _newPhoneController = TextEditingController();
  bool _isSavingPhone = false;
  final _phoneFormKey = GlobalKey<FormState>();

  // ----------------------------------------------------------
  // Inicialización y limpieza
  // ----------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.profile.firstName,
    );
    _lastNamePaternalController = TextEditingController(
      text: widget.profile.lastNamePaternal ?? '',
    );
    _lastNameMaternalController = TextEditingController(
      text: widget.profile.lastNameMaternal ?? '',
    );
    _currentEmail = Supabase.instance.client.auth.currentUser?.email ?? '';
    _currentPhone = widget.profile.phone ?? '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNamePaternalController.dispose();
    _lastNameMaternalController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _newEmailController.dispose();
    _confirmEmailController.dispose();
    _newPhoneController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // Helpers
  // ----------------------------------------------------------

  String _getInitials() {
    final fn = _firstNameController.text.trim();
    final ln = _lastNamePaternalController.text.trim();
    if (fn.isEmpty && ln.isEmpty) return '?';
    if (fn.isEmpty) return ln[0].toUpperCase();
    if (ln.isEmpty) return fn[0].toUpperCase();
    return (fn[0] + ln[0]).toUpperCase();
  }

  // ----------------------------------------------------------
  // Guardar nombre
  // ----------------------------------------------------------

  Future<void> _onSaveName() async {
    if (!_nameFormKey.currentState!.validate()) return;
    setState(() => _isSavingName = true);

    final success = await ref
        .read(profileNotifierProvider.notifier)
        .updateNameFields(
          firstName: _firstNameController.text.trim(),
          lastNamePaternal: _lastNamePaternalController.text.trim(),
          lastNameMaternal: _lastNameMaternalController.text.trim(),
        );

    if (!mounted) return;
    setState(() => _isSavingName = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? AppStrings.profileUpdateSuccess
              : AppStrings.profileUpdateError,
        ),
        backgroundColor: success ? null : Theme.of(context).colorScheme.error,
      ),
    );

    if (success) Navigator.of(context).pop();
  }

  // ----------------------------------------------------------
  // Guardar contraseña
  // ----------------------------------------------------------

  Future<void> _onSavePassword() async {
    setState(() => _passwordError = null);
    if (!_passwordFormKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() => _passwordError = 'Las contraseñas no coinciden.');
      return;
    }

    setState(() => _isSavingPassword = true);

    try {
      await ref
          .read(profileNotifierProvider.notifier)
          .updatePassword(_newPasswordController.text);
      if (!mounted) return;
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada correctamente.')),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _passwordError = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _passwordError = AppStrings.errorGeneral);
    } finally {
      if (mounted) setState(() => _isSavingPassword = false);
    }
  }

  // ----------------------------------------------------------
  // Guardar correo electrónico
  // ----------------------------------------------------------

  Future<void> _onSaveEmail() async {
    setState(() {
      _emailError = null;
      _emailSuccess = null;
    });
    if (!_emailFormKey.currentState!.validate()) return;

    final newEmail = _newEmailController.text.trim();

    if (newEmail == _currentEmail) {
      setState(() => _emailError = 'El nuevo correo debe ser diferente al actual.');
      return;
    }

    setState(() => _isSavingEmail = true);

    try {
      await ref
          .read(profileNotifierProvider.notifier)
          .updateEmail(newEmail);
      if (!mounted) return;
      setState(() {
        _emailSuccess = 'Revisa tu nuevo correo para confirmar el cambio.';
      });
      _newEmailController.clear();
      _confirmEmailController.clear();
    } on AuthException catch (e) {
      if (!mounted) return;
      final msg = e.message.toLowerCase();
      if (msg.contains('already') ||
          msg.contains('registered') ||
          msg.contains('taken') ||
          msg.contains('email address')) {
        setState(
          () => _emailError = 'Este correo ya está registrado en otra cuenta.',
        );
      } else {
        setState(() => _emailError = e.message);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _emailError = AppStrings.errorGeneral);
    } finally {
      if (mounted) setState(() => _isSavingEmail = false);
    }
  }

  // ----------------------------------------------------------
  // Guardar teléfono
  // ----------------------------------------------------------

  Future<void> _onSavePhone() async {
    if (!_phoneFormKey.currentState!.validate()) return;
    setState(() => _isSavingPhone = true);

    final digits = _newPhoneController.text.replaceAll(' ', '').trim();
    final phoneValue = digits.isEmpty ? null : '+569$digits';

    final success = await ref
        .read(profileNotifierProvider.notifier)
        .updatePhone(phoneValue);

    if (!mounted) return;
    setState(() => _isSavingPhone = false);

    if (success) {
      setState(() {
        _currentPhone = phoneValue ?? '';
        _newPhoneController.clear();
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? AppStrings.profileUpdateSuccess
              : AppStrings.profileUpdateError,
        ),
        backgroundColor: success ? null : Theme.of(context).colorScheme.error,
      ),
    );
  }

  // ----------------------------------------------------------
  // Construcción principal
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profileEdit),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------------------------------------
              // Avatar con iniciales
              // ------------------------------------------------
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    _getInitials(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingXl),

              // ------------------------------------------------
              // Sección 1: Nombre
              // ------------------------------------------------
              _SectionCard(
                title: 'Nombre',
                icon: Icons.person_outline,
                child: Form(
                  key: _nameFormKey,
                  child: Column(
                    children: [
                      // RUT (solo lectura — identificador permanente)
                      _ReadOnlyField(
                        label: 'RUT',
                        value: widget.profile.rut,
                        icon: Icons.badge_outlined,
                        helperText:
                            'El RUT es un identificador permanente y no puede modificarse.',
                      ),

                      const SizedBox(height: AppDimensions.spacingMd),

                      // Primer nombre
                      TextFormField(
                        controller: _firstNameController,
                        enabled: !_isSavingName,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Primer nombre *',
                          hintText: 'Ej: Juan',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'El primer nombre es requerido.';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: AppDimensions.spacingMd),

                      // Apellido paterno
                      TextFormField(
                        controller: _lastNamePaternalController,
                        enabled: !_isSavingName,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Apellido paterno *',
                          hintText: 'Ej: Pérez',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'El apellido paterno es requerido.';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: AppDimensions.spacingMd),

                      // Apellido materno (opcional)
                      TextFormField(
                        controller: _lastNameMaternalController,
                        enabled: !_isSavingName,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Apellido materno (opcional)',
                          hintText: 'Ej: González',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),

                      const SizedBox(height: AppDimensions.spacingMd),

                      _SaveButton(
                        label: AppStrings.actionSave,
                        isLoading: _isSavingName,
                        onPressed: _onSaveName,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingMd),

              // ------------------------------------------------
              // Sección 2: Contraseña
              // ------------------------------------------------
              _SectionCard(
                title: 'Cambiar contraseña',
                icon: Icons.lock_outline,
                child: Form(
                  key: _passwordFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nueva contraseña
                      TextFormField(
                        controller: _newPasswordController,
                        enabled: !_isSavingPassword,
                        obscureText: !_showNewPassword,
                        decoration: InputDecoration(
                          labelText: 'Nueva contraseña',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showNewPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () => setState(
                              () => _showNewPassword = !_showNewPassword,
                            ),
                          ),
                        ),
                        validator: Validators.validateStrongPassword,
                      ),

                      const SizedBox(height: AppDimensions.spacingSm),

                      // Requisitos de contraseña (siempre visible)
                      const PasswordRequirementsBox(),

                      const SizedBox(height: AppDimensions.spacingMd),

                      // Confirmar contraseña
                      TextFormField(
                        controller: _confirmPasswordController,
                        enabled: !_isSavingPassword,
                        obscureText: !_showConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirmar contraseña',
                          hintText: 'Repite la nueva contraseña',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () => setState(
                              () => _showConfirmPassword = !_showConfirmPassword,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Confirma la nueva contraseña.';
                          }
                          return null;
                        },
                      ),

                      if (_passwordError != null) ...[
                        const SizedBox(height: AppDimensions.spacingSm),
                        Text(
                          _passwordError!,
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontSize: 13,
                          ),
                        ),
                      ],

                      const SizedBox(height: AppDimensions.spacingMd),

                      _SaveButton(
                        label: 'Cambiar contraseña',
                        isLoading: _isSavingPassword,
                        onPressed: _onSavePassword,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingMd),

              // ------------------------------------------------
              // Sección 3: Correo electrónico
              // ------------------------------------------------
              _SectionCard(
                title: 'Correo electrónico',
                icon: Icons.email_outlined,
                child: Form(
                  key: _emailFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Correo actual (solo lectura)
                      _ReadOnlyField(
                        label: 'Correo actual',
                        value: _currentEmail,
                        icon: Icons.email_outlined,
                      ),

                      const SizedBox(height: AppDimensions.spacingMd),

                      // Nuevo correo electrónico
                      TextFormField(
                        controller: _newEmailController,
                        enabled: !_isSavingEmail,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: const InputDecoration(
                          labelText: 'Nuevo correo electrónico',
                          hintText: 'correo@ejemplo.com',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: Validators.validateEmail,
                      ),

                      const SizedBox(height: AppDimensions.spacingMd),

                      // Confirmar nuevo correo
                      TextFormField(
                        controller: _confirmEmailController,
                        enabled: !_isSavingEmail,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: const InputDecoration(
                          labelText: 'Confirmar nuevo correo',
                          hintText: 'correo@ejemplo.com',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Confirma el nuevo correo.';
                          }
                          if (v.trim() != _newEmailController.text.trim()) {
                            return 'Los correos no coinciden.';
                          }
                          return null;
                        },
                      ),

                      if (_emailError != null) ...[
                        const SizedBox(height: AppDimensions.spacingSm),
                        Text(
                          _emailError!,
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      if (_emailSuccess != null) ...[
                        const SizedBox(height: AppDimensions.spacingSm),
                        Text(
                          _emailSuccess!,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 13,
                          ),
                        ),
                      ],

                      const SizedBox(height: AppDimensions.spacingXs),

                      Text(
                        'Se enviará un enlace de confirmación al nuevo correo.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.6),
                        ),
                      ),

                      const SizedBox(height: AppDimensions.spacingMd),

                      _SaveButton(
                        label: 'Cambiar correo',
                        isLoading: _isSavingEmail,
                        onPressed: _onSaveEmail,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingMd),

              // ------------------------------------------------
              // Sección 4: Teléfono
              // ------------------------------------------------
              _SectionCard(
                title: 'Teléfono',
                icon: Icons.phone_outlined,
                child: Form(
                  key: _phoneFormKey,
                  child: Column(
                    children: [
                      // Teléfono actual (solo lectura)
                      _ReadOnlyField(
                        label: 'Teléfono actual',
                        value: _currentPhone.isEmpty
                            ? 'No tienes teléfono registrado'
                            : _currentPhone,
                        icon: Icons.phone_outlined,
                      ),

                      const SizedBox(height: AppDimensions.spacingMd),

                      // Nuevo número de teléfono con prefijo +569
                      TextFormField(
                        controller: _newPhoneController,
                        enabled: !_isSavingPhone,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          PhoneDigitsFormatter(),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Nuevo número de teléfono',
                          hintText: '12 34 56 78',
                          prefixIcon: Icon(Icons.phone_outlined),
                          prefixText: '+569 ',
                          prefixStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          final digits = v.replaceAll(' ', '');
                          if (digits.length != 8) {
                            return 'Ingresa exactamente 8 dígitos.';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: AppDimensions.spacingMd),

                      _SaveButton(
                        label: AppStrings.actionSave,
                        isLoading: _isSavingPhone,
                        onPressed: _onSavePhone,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingXl),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Widget interno: campo de solo lectura con fondo gris
// ============================================================

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final String? helperText;

  const _ReadOnlyField({
    required this.label,
    required this.value,
    required this.icon,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextField(
      controller: TextEditingController(text: value),
      readOnly: true,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.05),
        helperText: helperText,
        helperMaxLines: 3,
      ),
    );
  }
}

// ============================================================
// Widget interno: tarjeta de sección con título e ícono
// ============================================================

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            child,
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Widget interno: botón de guardar con spinner
// ============================================================

class _SaveButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const _SaveButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}
