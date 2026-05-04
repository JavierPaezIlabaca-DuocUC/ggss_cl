// ============================================================
// app_search_bar.dart
// Barra de búsqueda redondeada del header de GGSS.cl.
// Al tocarla navega a la pantalla de búsqueda.
// ============================================================

import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/app_dimensions.dart';

/// Barra de búsqueda del header (solo lectura — abre SearchScreen al tocar)
class AppSearchBar extends StatelessWidget {
  /// Callback que se ejecuta cuando el usuario toca la barra
  final VoidCallback onTap;

  const AppSearchBar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      // AbsorbPointer evita que el TextField capture el foco directamente
      child: AbsorbPointer(
        child: TextField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: AppStrings.searchHint,
            prefixIcon: const Icon(Icons.search),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMd,
              vertical: AppDimensions.spacingSm,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              borderSide: BorderSide(
                color: theme.colorScheme.outline,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              borderSide: BorderSide(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
