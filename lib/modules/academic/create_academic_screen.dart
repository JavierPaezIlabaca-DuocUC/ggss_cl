// ============================================================
// create_academic_screen.dart
// Pantalla para crear una nueva oferta académica.
// Placeholder — funcionalidad completa en Módulo 5.
// ============================================================

import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';

/// Pantalla de creación de oferta académica (se muestra sobre el shell)
class CreateAcademicScreen extends StatelessWidget {
  const CreateAcademicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.academicCreateNew),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.academicCreateNew,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Próximamente — Módulo 5',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
