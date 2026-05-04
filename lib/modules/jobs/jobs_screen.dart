// ============================================================
// jobs_screen.dart
// Pantalla principal de ofertas laborales.
// Placeholder — funcionalidad completa en Módulo 4.
// ============================================================

import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';

/// Pantalla principal de ofertas laborales (embebida en MainShell)
class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sin Scaffold propio: ya lo provee MainShell
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.work_outline,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.titleJobs,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Próximamente — Módulo 4',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
