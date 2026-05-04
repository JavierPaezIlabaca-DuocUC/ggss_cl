// ============================================================
// profile_screen.dart
// Pantalla de perfil del usuario.
// Placeholder — funcionalidad completa en Módulo 9.
// ============================================================

import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';

/// Pantalla de perfil del usuario (se muestra sobre el shell)
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.titleProfile),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_outline,
              size: 64,
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.titleProfile,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Próximamente — Módulo 9',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
