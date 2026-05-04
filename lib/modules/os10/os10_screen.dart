// ============================================================
// os10_screen.dart
// Pantalla de inicio del simulador OS10.
// Placeholder — funcionalidad completa en Módulo 6.
// ============================================================

import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';

/// Pantalla de inicio del simulador OS10 (embebida en MainShell)
class Os10Screen extends StatelessWidget {
  const Os10Screen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sin Scaffold propio: ya lo provee MainShell
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.titleOs10,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Próximamente — Módulo 6',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
