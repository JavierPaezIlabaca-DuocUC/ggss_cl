// ============================================================
// edit_profile_screen.dart
// Pantalla para editar el perfil del usuario.
//
// Secciones independientes, cada una con su propio botón:
//   1. Nombre (primer nombre, apellido paterno, materno)
//   2. Contraseña (nueva contraseña + confirmación)
//   3. Correo electrónico (con aviso de confirmación)
//   4. Teléfono
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../models/profile_model.dart';
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

  late final TextEditingController _emailController;
  bool _isSavingEmail = false;
  String? _emailError;
  String? _emailSuccess;
  final _emailFormKey = GlobalKey<FormState>();

  // ----------------------------------------------------------
  // Controladores: Teléfono
  // ----------------------------------------------------------

  late final TextEditingController _phoneController;
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
    _emailController = TextEditingController(
      text: Supabase.instance.client.auth.currentUser?.email ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.profile.phone ?? '',
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNamePaternalController.dispose();
    _lastNameMaternalController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // Helpers: calcular iniciales del nombre actual
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
        backgroundColor: success
            ? null
            : Theme.of(context).colorScheme.error,
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
    setState(() => _isSavingEmail = true);

    try {
      await ref
          .read(profileNotifierProvider.notifier)
          .updateEmail(_emailController.text.trim());
      if (!mounted) return;
      setState(() {
        _emailSuccess =
            'Revisa tu nuevo correo para confirmar el cambio.';
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _emailError = e.message);
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

    final success = await ref
        .read(profileNotifierProvider.notifier)
        .updatePhone(_phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim());

    if (!mounted) return;
    setState(() => _isSavingPhone = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? AppStrings.profileUpdateSuccess
              : AppStrings.profileUpdateError,
        ),
        backgroundColor: success
            ? null
            : Theme.of(context).colorScheme.error,
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
                          hintText: 'Mínimo 6 caracteres',
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
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Ingresa la nueva contraseña.';
                          }
                          if (v.length < 6) {
                            return 'La contraseña debe tener al menos 6 caracteres.';
                          }
                          return null;
                        },
                      ),

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
                              () =>
                                  _showConfirmPassword = !_showConfirmPassword,
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

                      // Mensaje de error si las contraseñas no coinciden
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
                      TextFormField(
                        controller: _emailController,
                        enabled: !_isSavingEmail,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Nuevo correo',
                          hintText: 'correo@ejemplo.com',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Ingresa un correo electrónico.';
                          }
                          if (!v.contains('@')) {
                            return 'Ingresa un correo válido.';
                          }
                          return null;
                        },
                      ),

                      // Mensajes de error o éxito del cambio de correo
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

                      // Aviso: el cambio de correo requiere confirmación
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
                      TextFormField(
                        controller: _phoneController,
                        enabled: !_isSavingPhone,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Número de teléfono (opcional)',
                          hintText: '+56912345678',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
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
            // Encabezado de sección
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
