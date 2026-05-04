// ============================================================
// academic_screen.dart
// Pantalla principal de ofertas académicas.
// Placeholder — funcionalidad completa en Módulo 5.
// ============================================================

import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';

/// Pantalla principal de ofertas académicas (embebida en MainShell)
class AcademicScreen extends StatelessWidget {
  const AcademicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sin Scaffold propio: ya lo provee MainShell
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.titleAcademic,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Próximamente — Módulo 5',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
