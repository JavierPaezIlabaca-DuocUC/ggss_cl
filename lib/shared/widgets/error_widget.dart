// ============================================================
// error_widget.dart
// Widget de error reutilizable con mensaje y botón de reintento.
// ============================================================

import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/app_dimensions.dart';

/// Widget de estado de error con opción de reintento
class AppErrorWidget extends StatelessWidget {
  /// Mensaje de error a mostrar. Si es null usa el mensaje genérico.
  final String? message;

  /// Callback opcional para reintentar la acción que falló
  final VoidCallback? onRetry;

  const AppErrorWidget({
    super.key,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícono de error
            const Icon(
              Icons.error_outline,
              size: AppDimensions.iconLg,
              color: Colors.red,
            ),

            const SizedBox(height: AppDimensions.spacingMd),

            // Mensaje de error
            Text(
              message ?? AppStrings.errorGeneral,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            // Botón de reintento (solo si se proporcionó callback)
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.spacingMd),
              TextButton(
                onPressed: onRetry,
                child: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
