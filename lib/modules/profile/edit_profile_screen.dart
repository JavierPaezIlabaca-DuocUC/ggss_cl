// ============================================================
// edit_profile_screen.dart
// Pantalla para editar el perfil del usuario.
// Permite modificar el nombre completo.
// El RUT se muestra como campo de solo lectura.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  // Estado del formulario
  // ----------------------------------------------------------

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  bool _isLoading = false;

  // ----------------------------------------------------------
  // Inicialización y limpieza
  // ----------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _fullNameController =
        TextEditingController(text: widget.profile.fullName);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // Acción de guardar
  // ----------------------------------------------------------

  Future<void> _onSave() async {
    // Validar el formulario antes de enviar
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await ref
        .read(profileNotifierProvider.notifier)
        .updateFullName(_fullNameController.text.trim());

    // Verificar que el widget sigue montado antes de actualizar la UI
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      // Mostrar confirmación y volver a la pantalla de perfil
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.profileUpdateSuccess)),
      );
      Navigator.of(context).pop();
    } else {
      // Mostrar error en español
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(AppStrings.profileUpdateError),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // ----------------------------------------------------------
  // Construcción del widget
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profileEdit),
        centerTitle: true,
      ),

      body: GestureDetector(
        // Cerrar teclado al tocar fuera de los campos
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --------------------------------------------------
                // Avatar con iniciales (solo vista previa, sin edición)
                // --------------------------------------------------
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      _getInitials(widget.profile.fullName),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // --------------------------------------------------
                // Campo: nombre completo (editable)
                // --------------------------------------------------
                Text(
                  AppStrings.profileFullName,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _fullNameController,
                  enabled: !_isLoading,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: AppStrings.profileFullNameHint,
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppStrings.profileFullNameRequired;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // --------------------------------------------------
                // Botón de guardar
                // --------------------------------------------------
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onSave,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(AppStrings.actionSave),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // Genera las iniciales del nombre completo (máximo 2 letras)
  // ----------------------------------------------------------

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}
