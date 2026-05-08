// ============================================================
// empty_state_widget.dart
// Widget de estado vacío reutilizable.
// Se muestra cuando una lista no tiene contenido.
// ============================================================

import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/app_dimensions.dart';

/// Widget de estado vacío con ícono, mensaje descriptivo y botón de acción opcional
class EmptyStateWidget extends StatelessWidget {
  /// Mensaje a mostrar. Si es null usa el mensaje genérico.
  final String? message;

  /// Ícono a mostrar. Por defecto: inbox
  final IconData icon;

  /// Etiqueta del botón de acción (opcional)
  final String? actionLabel;

  /// Callback del botón de acción (opcional)
  final VoidCallback? onActionTap;

  const EmptyStateWidget({
    super.key,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícono ilustrativo
            Icon(
              icon,
              size: AppDimensions.iconLg,
              color: Theme.of(context).colorScheme.secondary,
            ),

            const SizedBox(height: AppDimensions.spacingMd),

            // Mensaje descriptivo
            Text(
              message ?? AppStrings.emptyStateGeneral,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            // Botón de acción (solo si se proporcionó)
            if (onActionTap != null && actionLabel != null) ...[
              const SizedBox(height: AppDimensions.spacingLg),
              FilledButton.icon(
                onPressed: onActionTap,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
