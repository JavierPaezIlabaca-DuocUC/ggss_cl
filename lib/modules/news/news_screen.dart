// ============================================================
// news_screen.dart
// Pantalla principal de noticias.
// Placeholder — funcionalidad completa en Módulo 7.
// ============================================================

import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';

/// Pantalla principal de noticias (embebida en MainShell)
class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sin Scaffold propio: ya lo provee MainShell
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.newspaper_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.titleNews,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Próximamente — Módulo 7',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
