// ============================================================
// create_job_screen.dart
// Formulario para crear una nueva oferta laboral.
// Valida los campos requeridos y guarda en Supabase.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../models/job_model.dart';
import '../auth/auth_providers.dart';
import 'jobs_providers.dart';

/// Pantalla de creación de oferta laboral
class CreateJobScreen extends ConsumerStatefulWidget {
  const CreateJobScreen({super.key});

  @override
  ConsumerState<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends ConsumerState<CreateJobScreen> {
  // ----------------------------------------------------------
  // Clave del formulario para validación
  // ----------------------------------------------------------
  final _formKey = GlobalKey<FormState>();

  // ----------------------------------------------------------
  // Controladores de texto para cada campo
  // ----------------------------------------------------------
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _salaryRangeController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  // ----------------------------------------------------------
  // Estado de envío
  // ----------------------------------------------------------
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _salaryRangeController.dispose();
    _whatsappController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // Envío del formulario
  // ----------------------------------------------------------

  Future<void> _submit() async {
    // Cerrar teclado
    FocusScope.of(context).unfocus();

    // Validar campos requeridos
    if (!_formKey.currentState!.validate()) return;

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    setState(() => _isSubmitting = true);

    try {
      final job = JobModel(
        id: '', // Supabase genera el UUID automáticamente
        title: _titleController.text.trim(),
        company: _companyController.text.trim(),
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        requirements: _requirementsController.text.trim().isEmpty
            ? null
            : _requirementsController.text.trim(),
        salaryRange: _salaryRangeController.text.trim().isEmpty
            ? null
            : _salaryRangeController.text.trim(),
        contactWhatsapp: _whatsappController.text.trim().isEmpty
            ? null
            : _whatsappController.text.trim(),
        latitude: double.tryParse(_latController.text.trim()),
        longitude: double.tryParse(_lngController.text.trim()),
        createdBy: currentUser.id,
        createdAt: DateTime.now(),
      );

      // Crear oferta y refrescar la lista en JobsScreen
      await ref.read(jobsNotifierProvider.notifier).createJob(job);

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
        title: const Text(AppStrings.jobsCreateNew),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --------------------------------------------------
              // Sección: Información principal
              // --------------------------------------------------
              _SectionTitle(text: 'Información principal'),
              const SizedBox(height: AppDimensions.spacingSm),

              // Título de la oferta
              _FormField(
                controller: _titleController,
                label: 'Título del cargo',
                hint: 'Ej: Guardia de seguridad diurno',
                required: true,
                validator: (v) =>
                    Validators.required(v, 'El título es obligatorio'),
              ),

              const SizedBox(height: AppDimensions.spacingMd),

              // Empresa
              _FormField(
                controller: _companyController,
                label: 'Empresa',
                hint: 'Ej: Seguridad Total S.A.',
                required: true,
                validator: (v) =>
                    Validators.required(v, 'La empresa es obligatoria'),
              ),

              const SizedBox(height: AppDimensions.spacingMd),

              // Ubicación
              _FormField(
                controller: _locationController,
                label: 'Ubicación',
                hint: 'Ej: Santiago, Región Metropolitana',
                required: true,
                validator: (v) =>
                    Validators.required(v, 'La ubicación es obligatoria'),
              ),

              const SizedBox(height: AppDimensions.spacingMd),

              // Descripción
              _FormField(
                controller: _descriptionController,
                label: 'Descripción',
                hint:
                    'Describe las funciones del cargo, horarios, condiciones...',
                required: true,
                maxLines: 5,
                validator: (v) =>
                    Validators.required(v, 'La descripción es obligatoria'),
              ),

              const SizedBox(height: AppDimensions.spacingXl),

              // --------------------------------------------------
              // Sección: Detalles adicionales (opcionales)
              // --------------------------------------------------
              _SectionTitle(text: 'Detalles adicionales (opcional)'),
              const SizedBox(height: AppDimensions.spacingSm),

              // Requisitos
              _FormField(
                controller: _requirementsController,
                label: 'Requisitos',
                hint: 'OS10 vigente, experiencia mínima, estudios...',
                maxLines: 3,
              ),

              const SizedBox(height: AppDimensions.spacingMd),

              // Rango salarial
              _FormField(
                controller: _salaryRangeController,
                label: 'Rango salarial',
                hint: 'Ej: \$450.000 — \$550.000 líquido',
              ),

              const SizedBox(height: AppDimensions.spacingXl),

              // --------------------------------------------------
              // Sección: Contacto y ubicación GPS (opcionales)
              // --------------------------------------------------
              _SectionTitle(text: 'Contacto y ubicación GPS (opcional)'),
              const SizedBox(height: AppDimensions.spacingSm),

              // Número WhatsApp
              _FormField(
                controller: _whatsappController,
                label: 'Número WhatsApp',
                hint: 'Ej: 56912345678 (sin + ni espacios)',
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),

              const SizedBox(height: AppDimensions.spacingMd),

              // Coordenadas GPS: latitud y longitud en fila
              Row(
                children: [
                  Expanded(
                    child: _FormField(
                      controller: _latController,
                      label: 'Latitud',
                      hint: 'Ej: -33.4569',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      validator: _validateCoordinate,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingMd),
                  Expanded(
                    child: _FormField(
                      controller: _lngController,
                      label: 'Longitud',
                      hint: 'Ej: -70.6483',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      validator: _validateCoordinate,
                    ),
                  ),
                ],
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
                    : const Text('Publicar oferta'),
              ),

              const SizedBox(height: AppDimensions.spacingXl),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // Validador de coordenadas GPS (acepta vacío — campo opcional)
  // ----------------------------------------------------------

  String? _validateCoordinate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (double.tryParse(value.trim()) == null) {
      return 'Número inválido';
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
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _FormField({
    required this.controller,
    required this.label,
    this.hint,
    this.required = false,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }
}
