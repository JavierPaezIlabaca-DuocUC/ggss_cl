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
import '../../shared/widgets/required_fields_note.dart';
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

  // Salario: campo único (fijo) o dos campos (rango)
  final _salaryAmountController = TextEditingController();
  final _salaryMinController = TextEditingController();
  final _salaryMaxController = TextEditingController();

  // Contacto WhatsApp
  final _whatsappController = TextEditingController();

  // ----------------------------------------------------------
  // Tipo de salario seleccionado: 'fijo' | 'rango'
  // ----------------------------------------------------------
  String _salaryType = 'fijo';

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
    _salaryAmountController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // Formatea un número como peso chileno: $1.234.567
  // ----------------------------------------------------------
  String _formatPeso(String digits) {
    final clean = digits.replaceAll(RegExp(r'\D'), '');
    if (clean.isEmpty) return '';
    final n = int.tryParse(clean) ?? 0;
    final s = n.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return '\$${buffer.toString()}';
  }

  // ----------------------------------------------------------
  // Construye el texto de salario según el tipo seleccionado
  // ----------------------------------------------------------
  String _buildSalaryRange() {
    if (_salaryType == 'fijo') {
      return _formatPeso(_salaryAmountController.text);
    }
    final min = _formatPeso(_salaryMinController.text);
    final max = _formatPeso(_salaryMaxController.text);
    return '$min - $max';
  }

  // ----------------------------------------------------------
  // Validador: monto máximo debe ser mayor al mínimo
  // ----------------------------------------------------------
  String? _validateSalaryMax(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El monto máximo es obligatorio';
    }
    final minDigits = _salaryMinController.text.replaceAll(RegExp(r'\D'), '');
    final maxDigits = value.replaceAll(RegExp(r'\D'), '');
    final min = int.tryParse(minDigits);
    final max = int.tryParse(maxDigits);
    if (min != null && max != null && max <= min) {
      return 'El máximo debe ser mayor al mínimo';
    }
    return null;
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
      final whatsappDigits =
          _whatsappController.text.replaceAll(' ', '').trim();

      final job = JobModel(
        id: '',
        title: _titleController.text.trim(),
        company: _companyController.text.trim(),
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        requirements: _requirementsController.text.trim().isEmpty
            ? null
            : _requirementsController.text.trim(),
        salaryRange: _buildSalaryRange(),
        contactWhatsapp:
            whatsappDigits.isEmpty ? null : '+569$whatsappDigits',
        createdBy: currentUser.id,
        createdAt: DateTime.now(),
      );

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
                label: 'Título del cargo',
                hint: 'Ej: Guardia de seguridad diurno',
                required: true,
                validator: (v) =>
                    Validators.required(v, 'El título es obligatorio'),
              ),

              const SizedBox(height: AppDimensions.spacingMd),

              _FormField(
                controller: _companyController,
                label: 'Empresa',
                hint: 'Ej: Seguridad Total S.A.',
                required: true,
                validator: (v) =>
                    Validators.required(v, 'La empresa es obligatoria'),
              ),

              const SizedBox(height: AppDimensions.spacingMd),

              _FormField(
                controller: _locationController,
                label: 'Ubicación',
                hint: 'Ej: Santiago, Región Metropolitana',
                required: true,
                validator: (v) =>
                    Validators.required(v, 'La ubicación es obligatoria'),
              ),

              const SizedBox(height: AppDimensions.spacingMd),

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
              // Sección: Salario (obligatorio)
              // --------------------------------------------------
              _SectionTitle(text: 'Salario *'),
              const SizedBox(height: AppDimensions.spacingSm),

              // Selector segmentado: Sueldo fijo / Rango salarial
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'fijo',
                    label: Text('Sueldo fijo'),
                  ),
                  ButtonSegment(
                    value: 'rango',
                    label: Text('Rango salarial'),
                  ),
                ],
                selected: {_salaryType},
                onSelectionChanged: (selection) {
                  setState(() => _salaryType = selection.first);
                },
                showSelectedIcon: false,
                style: ButtonStyle(
                  minimumSize: WidgetStateProperty.all(
                    const Size(double.infinity, AppDimensions.inputHeight),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingMd),

              // Campo condicional según tipo de salario
              if (_salaryType == 'fijo') ...[
                // Sueldo fijo: un único campo de monto
                _FormField(
                  controller: _salaryAmountController,
                  label: 'Monto (\$)',
                  hint: 'Ej: 850000',
                  required: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) =>
                      Validators.required(v, 'El salario es obligatorio'),
                ),
              ] else ...[
                // Rango salarial: mínimo y máximo lado a lado
                Row(
                  children: [
                    Expanded(
                      child: _FormField(
                        controller: _salaryMinController,
                        label: 'Mínimo (\$)',
                        hint: 'Ej: 850000',
                        required: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (v) =>
                            Validators.required(v, 'El mínimo es obligatorio'),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingMd),
                    Expanded(
                      child: _FormField(
                        controller: _salaryMaxController,
                        label: 'Máximo (\$)',
                        hint: 'Ej: 1200000',
                        required: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: _validateSalaryMax,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: AppDimensions.spacingXl),

              // --------------------------------------------------
              // Sección: Detalles adicionales (opcionales)
              // --------------------------------------------------
              _SectionTitle(text: 'Detalles adicionales (opcional)'),
              const SizedBox(height: AppDimensions.spacingSm),

              _FormField(
                controller: _requirementsController,
                label: 'Requisitos',
                hint: 'OS10 vigente, experiencia mínima, estudios...',
                maxLines: 3,
              ),

              const SizedBox(height: AppDimensions.spacingXl),

              // --------------------------------------------------
              // Sección: Contacto (opcional)
              // --------------------------------------------------
              _SectionTitle(text: 'Contacto (opcional)'),
              const SizedBox(height: AppDimensions.spacingSm),

              // Número WhatsApp con prefijo +569 fijo
              _WhatsAppField(
                controller: _whatsappController,
                validator: _validateOptionalWhatsapp,
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
                    : const Text('Publicar oferta'),
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
