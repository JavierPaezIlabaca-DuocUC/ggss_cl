// ============================================================
// terms_screen.dart
// Pantalla de Términos y Condiciones de GGSS.cl.
// Muestra el texto completo en un scroll.
// ============================================================

import 'package:flutter/material.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/terms_and_conditions.dart';

/// Pantalla con el texto completo de los Términos y Condiciones
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Términos y Condiciones'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Text(
          kTermsAndConditions,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.6,
              ),
        ),
      ),
    );
  }
}
