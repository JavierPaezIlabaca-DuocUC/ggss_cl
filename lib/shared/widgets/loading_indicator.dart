// ============================================================
// loading_indicator.dart
// Indicador de carga reutilizable en toda la app.
// Usa el color primario del tema actual.
// ============================================================

import 'package:flutter/material.dart';

/// Indicador de carga centrado con el color primario del tema
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
