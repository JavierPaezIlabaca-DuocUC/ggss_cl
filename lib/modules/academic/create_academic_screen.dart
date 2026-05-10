// ============================================================
// create_academic_screen.dart
// Formulario para crear una nueva oferta académica.
// Valida los campos requeridos y guarda en Supabase.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../models/academic_offer_model.dart';
import '../../shared/formatters/phone_digits_formatter.dart';
import '../../shared/widgets/required_fields_note.dart';
import '../auth/auth_providers.dart';
import '../profile/profile_providers.dart';
import 'academic_providers.dart';

/// Selector de origen del número de WhatsApp
enum _PhoneSource { account, other }

/// Pantalla de creación de oferta académica
class CreateAcademicScreen extends ConsumerStatefulWidget {
  const CreateAcademicScreen({super.key});

  @override
  ConsumerState<CreateAcademicScreen> createState() =>
      _CreateAcademicScreenState();
}

class _CreateAcademicScreenState extends ConsumerState<CreateAcademicScreen> {
  // ----------------------------------------------------------
  // Clave del formulario y scroll controller para validación
  // ----------------------------------------------------------
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // ----------------------------------------------------------
  // Controladores de texto
  // ----------------------------------------------------------
  final _titleController = TextEditingController();
  final _institutionController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _durationController = TextEditingController();
  final _priceController = TextEditingController();
  final _addressController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _urlController = TextEditingController();

  // ----------------------------------------------------------
  // Origen del número WhatsApp: cuenta o manual
  // ----------------------------------------------------------
  _PhoneSource _phoneSource = _PhoneSource.account;

  // ----------------------------------------------------------
  // Estado de envío
  // ----------------------------------------------------------
  bool _isSubmitting = false;

  // ----------------------------------------------------------
  // Verifica si el usuario ha escrito algo (para PopScope)
  // ----------------------------------------------------------
  bool get _hasUnsavedChanges =>
      _titleController.text.isNotEmpty ||
      _institutionController.text.isNotEmpty ||
      _descriptionController.text.isNotEmpty ||
      _requirementsController.text.isNotEmpty ||
      _addressController.text.isNotEmpty ||
      _durationController.text.isNotEmpty ||
      _priceController.text.isNotEmpty ||
      _whatsappController.text.isNotEmpty ||
      _urlController.text.isNotEmpty;

  @override
  void dispose() {
    _scrollController.dispose();
    _titleController.dispose();
    _institutionController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    _whatsappController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // Validador WhatsApp opcional: 8 dígitos si se ingresa
  // ----------------------------------------------------------
  String? _validateOptionalWhatsapp(String? value) {
    final digits = value?.replaceAll(' ', '').trim() ?? '';
    if (digits.isEmpty) return null;
    return Validators.validatePhone8Digits(digits);
  }

  // ----------------------------------------------------------
  // Envío del formulario
  // ----------------------------------------------------------

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      // Scroll al inicio para mostrar los errores al usuario
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor corrige los errores antes de continuar'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    setState(() => _isSubmitting = true);

    try {
      // Determinar el número WhatsApp según el origen seleccionado
      String? whatsappNumber;
      if (_phoneSource == _PhoneSource.account) {
        final profile = ref.read(profileNotifierProvider).valueOrNull;
        whatsappNumber = profile?.phone;
      } else {
        final digits = _whatsappController.text.replaceAll(' ', '').trim();
        whatsappNumber = digits.isEmpty ? null : '+569$digits';
      }

      final offer = AcademicOfferModel(
        id: '',
        title: _titleController.text.trim(),
        institution: _institutionController.text.trim(),
        description: _descriptionController.text.trim(),
        requirements: _requirementsController.text.trim().isEmpty
            ? null
            : _requirementsController.text.trim(),
        duration: _durationController.text.trim().isEmpty
            ? null
            : _durationController.text.trim(),
        price: _priceController.text.trim().isEmpty
            ? null
            : _priceController.text.trim(),
        contactWhatsapp: whatsappNumber,
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        url: _urlController.text.trim().isEmpty
            ? null
            : _urlController.text.trim(),
        createdBy: currentUser.id,
        createdAt: DateTime.now(),
      );

      await ref.read(academicNotifierProvider.notifier).createOffer(offer);

      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(AppStrings.errorGeneral),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ----------------------------------------------------------
  // Diálogo de confirmación al salir con cambios
  // ----------------------------------------------------------

  Future<void> _confirmDiscard(BuildContext context) async {
    final navigator = Navigator.of(context);

    if (!_hasUnsavedChanges) {
      navigator.pop();
      return;
    }

    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Deseas descartar los cambios?'),
        content: const Text(
          'Perderás toda la información ingresada en el formulario.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Seguir editando'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );

    if (discard == true && mounted) navigator.pop();
  }

  // ----------------------------------------------------------
  // Construcción del formulario
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileNotifierProvider);
    final accountPhone = profileAsync.valueOrNull?.phone;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.academicCreateNew),
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(AppDimensions.spacingMd),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --------------------------------------------------
                // Indicador de campos obligatorios
                // --------------------------------------------------
                const RequiredFieldsNote(),
                const SizedBox(height: AppDimensions.spacingMd),

                // --------------------------------------------------
                // Sección: Información principal
                // --------------------------------------------------
                _SectionTitle(text: 'Información principal'),
                const SizedBox(height: AppDimensions.spacingSm),

                _FormField(
                  controller: _titleController,
                  label: 'Título del curso',
                  hint: 'Ej: Curso de OS10 — Operaciones de Seguridad',
                  required: true,
                  validator: (v) =>
                      Validators.required(v, 'El título es obligatorio'),
                ),

                const SizedBox(height: AppDimensions.spacingMd),

                _FormField(
                  controller: _institutionController,
                  label: 'Institución',
                  hint: 'Ej: INACAP, Duoc UC, OTEC Seguridad',
                  required: true,
                  validator: (v) =>
                      Validators.required(v, 'La institución es obligatoria'),
                ),

                const SizedBox(height: AppDimensions.spacingMd),

                _FormField(
                  controller: _descriptionController,
                  label: 'Descripción',
                  hint:
                      'Describe el contenido del curso, metodología, beneficios...',
                  required: true,
                  maxLines: 5,
                  validator: (v) =>
                      Validators.required(v, 'La descripción es obligatoria'),
                ),

                const SizedBox(height: AppDimensions.spacingMd),

                // Dirección específica (opcional) para Google Maps
                _FormField(
                  controller: _addressController,
                  label: 'Dirección específica (opcional)',
                  hint: 'Ej: Av. Vicuña Mackenna 4860, Santiago',
                  keyboardType: TextInputType.streetAddress,
                ),

                const SizedBox(height: AppDimensions.spacingXl),

                // --------------------------------------------------
                // Sección: Detalles del curso (opcionales)
                // --------------------------------------------------
                _SectionTitle(text: 'Detalles del curso (opcional)'),
                const SizedBox(height: AppDimensions.spacingSm),

                _FormField(
                  controller: _requirementsController,
                  label: 'Requisitos',
                  hint: 'Ej: OS10 vigente, nivel básico de computación...',
                  maxLines: 3,
                ),

                const SizedBox(height: AppDimensions.spacingMd),

                Row(
                  children: [
                    Expanded(
                      child: _FormField(
                        controller: _durationController,
                        label: 'Duración',
                        hint: 'Ej: 40 horas',
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingMd),
                    Expanded(
                      child: _FormField(
                        controller: _priceController,
                        label: 'Precio',
                        hint: 'Ej: Gratuito / \$50.000',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.spacingXl),

                // --------------------------------------------------
                // Sección: Contacto e inscripción (opcionales)
                // --------------------------------------------------
                _SectionTitle(text: 'Contacto e inscripción (opcional)'),
                const SizedBox(height: AppDimensions.spacingSm),

                // Selector de origen del número de WhatsApp
                SegmentedButton<_PhoneSource>(
                  segments: const [
                    ButtonSegment(
                      value: _PhoneSource.account,
                      label: Text('Usar mi número de cuenta'),
                      icon: Icon(Icons.person_outline),
                    ),
                    ButtonSegment(
                      value: _PhoneSource.other,
                      label: Text('Usar otro número'),
                      icon: Icon(Icons.edit_outlined),
                    ),
                  ],
                  // Si no hay teléfono en perfil, forzar selección "otro"
                  selected: {
                    accountPhone == null
                        ? _PhoneSource.other
                        : _phoneSource,
                  },
                  onSelectionChanged: (selection) {
                    if (selection.first == _PhoneSource.account &&
                        accountPhone == null) {
                      return;
                    }
                    setState(() => _phoneSource = selection.first);
                  },
                  showSelectedIcon: false,
                  style: ButtonStyle(
                    minimumSize: WidgetStateProperty.all(
                      const Size(double.infinity, AppDimensions.inputHeight),
                    ),
                  ),
                ),

                // Mensaje cuando no hay teléfono en el perfil
                if (accountPhone == null) ...[
                  const SizedBox(height: AppDimensions.spacingXs),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'No tienes teléfono registrado en tu perfil.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: AppDimensions.spacingMd),

                // Campo WhatsApp: solo lectura (cuenta) o editable (otro)
                if (accountPhone != null &&
                    _phoneSource == _PhoneSource.account)
                  _ReadOnlyWhatsAppField(phone: accountPhone)
                else
                  _WhatsAppField(
                    controller: _whatsappController,
                    validator: _validateOptionalWhatsapp,
                  ),

                const SizedBox(height: AppDimensions.spacingMd),

                // URL de información
                _FormField(
                  controller: _urlController,
                  label: 'URL de información o inscripción',
                  hint: 'https://...',
                  keyboardType: TextInputType.url,
                  validator: _validateUrl,
                ),

                const SizedBox(height: AppDimensions.spacingXl),

                // --------------------------------------------------
                // Botón de publicar
                // --------------------------------------------------
                FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(
                      double.infinity,
                      AppDimensions.inputHeight,
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Publicar oferta académica'),
                ),

                const SizedBox(height: AppDimensions.spacingXl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // Validador de URL (acepta vacío — campo opcional)
  // ----------------------------------------------------------

  String? _validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme) {
      return 'Ingresa una URL válida (debe comenzar con https://)';
    }
    return null;
  }
}

// ============================================================
// Widgets internos de apoyo
// ============================================================

/// Título de sección dentro del formulario
class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

/// Campo de formulario reutilizable con validación
class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool required;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _FormField({
    required this.controller,
    required this.label,
    this.hint,
    this.required = false,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }
}

/// Campo de WhatsApp con prefijo "+569" no editable y formato automático
class _WhatsAppField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const _WhatsAppField({required this.controller, this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [PhoneDigitsFormatter()],
      validator: validator,
      decoration: const InputDecoration(
        labelText: 'WhatsApp',
        hintText: '12 34 56 78',
        prefixText: '+569 ',
        prefixStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }
}

/// Campo de WhatsApp de solo lectura que muestra el número de la cuenta
class _ReadOnlyWhatsAppField extends StatelessWidget {
  final String phone;

  const _ReadOnlyWhatsAppField({required this.phone});

  // Formatea "+56912345678" como "+569 12 34 56 78"
  String _format(String raw) {
    const prefix = '+569';
    if (!raw.startsWith(prefix)) return raw;
    final digits = raw.substring(prefix.length);
    final buf = StringBuffer('+569 ');
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 2 == 0) buf.write(' ');
      buf.write(digits[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: _format(phone),
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'WhatsApp',
        prefixIcon: const Icon(Icons.lock_outline, size: 18),
        filled: true,
        fillColor: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.5),
      ),
    );
  }
}

