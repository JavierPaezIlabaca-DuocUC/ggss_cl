// ============================================================
// create_academic_screen.dart
// Formulario para crear una nueva oferta académica.
// Valida los campos requeridos y guarda en Supabase.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../models/academic_offer_model.dart';
import '../../shared/widgets/required_fields_note.dart';
import '../auth/auth_providers.dart';
import 'academic_providers.dart';

/// Pantalla de creación de oferta académica
class CreateAcademicScreen extends ConsumerStatefulWidget {
  const CreateAcademicScreen({super.key});

  @override
  ConsumerState<CreateAcademicScreen> createState() =>
      _CreateAcademicScreenState();
}

class _CreateAcademicScreenState extends ConsumerState<CreateAcademicScreen> {
  // ----------------------------------------------------------
  // Clave del formulario
  // ----------------------------------------------------------
  final _formKey = GlobalKey<FormState>();

  // ----------------------------------------------------------
  // Controladores de texto
  // ----------------------------------------------------------
  final _titleController = TextEditingController();
  final _institutionController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _durationController = TextEditingController();
  final _priceController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _urlController = TextEditingController();

  // ----------------------------------------------------------
  // Estado de envío
  // ----------------------------------------------------------
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _institutionController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _durationController.dispose();
    _priceController.dispose();
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
    if (!_formKey.currentState!.validate()) return;

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    setState(() => _isSubmitting = true);

    try {
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
        contactWhatsapp: _whatsappController.text
                .replaceAll(' ', '')
                .trim()
                .isEmpty
            ? null
            : '+569${_whatsappController.text.replaceAll(' ', '').trim()}',
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
  // Construcción del formulario
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.academicCreateNew),
      ),
      body: SingleChildScrollView(
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

              // Título del curso
              _FormField(
                controller: _titleController,
                label: 'Título del curso',
                hint: 'Ej: Curso de OS10 — Operaciones de Seguridad',
                required: true,
                validator: (v) =>
                    Validators.required(v, 'El título es obligatorio'),
              ),

              const SizedBox(height: AppDimensions.spacingMd),

              // Institución
              _FormField(
                controller: _institutionController,
                label: 'Institución',
                hint: 'Ej: INACAP, Duoc UC, OTEC Seguridad',
                required: true,
                validator: (v) =>
                    Validators.required(v, 'La institución es obligatoria'),
              ),

              const SizedBox(height: AppDimensions.spacingMd),

              // Descripción
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

              const SizedBox(height: AppDimensions.spacingXl),

              // --------------------------------------------------
              // Sección: Detalles del curso (opcionales)
              // --------------------------------------------------
              _SectionTitle(text: 'Detalles del curso (opcional)'),
              const SizedBox(height: AppDimensions.spacingSm),

              // Requisitos
              _FormField(
                controller: _requirementsController,
                label: 'Requisitos',
                hint: 'Ej: OS10 vigente, nivel básico de computación...',
                maxLines: 3,
              ),

              const SizedBox(height: AppDimensions.spacingMd),

              // Duración y precio en fila
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

              // Número WhatsApp con prefijo +569 fijo
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
      inputFormatters: [_PhoneDigitsFormatter()],
      validator: validator,
      decoration: const InputDecoration(
        labelText: 'WhatsApp',
        hintText: '12 34 56 78',
        prefixText: '+569 ',
      ),
    );
  }
}

/// Formatea la entrada como 8 dígitos con espacio cada 2: "12 34 56 78"
class _PhoneDigitsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Extraer solo dígitos y limitar a 8
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited =
        digits.length > 8 ? digits.substring(0, 8) : digits;

    // Insertar espacio cada 2 dígitos: "12 34 56 78"
    final buffer = StringBuffer();
    for (int i = 0; i < limited.length; i++) {
      if (i > 0 && i % 2 == 0) buffer.write(' ');
      buffer.write(limited[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
