// ============================================================
// create_post_screen.dart
// Pantalla para crear una nueva publicación en el foro.
// Campos: título (requerido), contenido (requerido),
// categoría (opcional con sugerencias de chips).
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../models/forum_post_model.dart';
import '../../shared/widgets/required_fields_note.dart';
import '../auth/auth_providers.dart';
import 'forum_providers.dart';

/// Categorías sugeridas para el selector de categoría
const List<String> _kCategories = [
  'Laboral',
  'Académico',
  'Consulta',
  'Experiencia',
  'General',
];

/// Pantalla de creación de publicación en el foro
class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _categoryController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // Seleccionar una categoría sugerida con chip
  // ----------------------------------------------------------

  void _selectCategory(String category) {
    setState(() {
      _categoryController.text = category;
    });
  }

  // ----------------------------------------------------------
  // Enviar nueva publicación al foro
  // ----------------------------------------------------------

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    setState(() => _isSubmitting = true);

    final post = ForumPostModel(
      id: '',
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      category: _categoryController.text.trim().isEmpty
          ? null
          : _categoryController.text.trim(),
      userId: currentUser.id,
      createdAt: DateTime.now(),
    );

    try {
      await ref
          .read(forumPostsNotifierProvider.notifier)
          .createPost(post);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.errorGeneral)),
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.forumCreatePost),
        actions: [
          // Botón publicar en la barra (alternativo al botón inferior)
          TextButton(
            onPressed: _isSubmitting ? null : _submit,
            child: const Text(AppStrings.forumPublish),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.spacingMd),
          children: [
            // --------------------------------------------------
            // Indicador de campos obligatorios
            // --------------------------------------------------
            const RequiredFieldsNote(),
            const SizedBox(height: AppDimensions.spacingMd),

            // --------------------------------------------------
            // Campo: Título (requerido)
            // --------------------------------------------------
            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: '${AppStrings.forumTitleLabel} *',
                hintText: AppStrings.forumTitleHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
              ),
              maxLength: 120,
              validator: (v) => (v?.trim().isEmpty ?? true)
                  ? 'El título es obligatorio.'
                  : null,
            ),

            const SizedBox(height: AppDimensions.spacingMd),

            // --------------------------------------------------
            // Campo: Contenido (requerido, multilínea)
            // --------------------------------------------------
            TextFormField(
              controller: _contentController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: '${AppStrings.forumContentLabel} *',
                hintText: AppStrings.forumContentHint,
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
              ),
              minLines: 5,
              maxLines: 12,
              validator: (v) => (v?.trim().isEmpty ?? true)
                  ? 'El contenido es obligatorio.'
                  : null,
            ),

            const SizedBox(height: AppDimensions.spacingMd),

            // --------------------------------------------------
            // Campo: Categoría (opcional)
            // --------------------------------------------------
            TextFormField(
              controller: _categoryController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: AppStrings.forumCategoryLabel,
                hintText: AppStrings.forumCategoryHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
              ),
              maxLength: 30,
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: AppDimensions.spacingXs),

            // Chips de sugerencias de categoría
            Wrap(
              spacing: AppDimensions.spacingSm,
              runSpacing: AppDimensions.spacingXs,
              children: _kCategories.map((category) {
                final isSelected = _categoryController.text == category;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (_) => _selectCategory(category),
                  selectedColor: AppColors.primaryBlue.withValues(alpha: 0.15),
                  labelStyle: theme.textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : theme.textTheme.labelMedium?.color,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: AppDimensions.spacingXl),

            // --------------------------------------------------
            // Botón publicar
            // --------------------------------------------------
            FilledButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_outlined),
              label: const Text(AppStrings.forumPublish),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                minimumSize:
                    const Size(double.infinity, AppDimensions.inputHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.spacingMd),
          ],
        ),
      ),
    );
  }
}
