// ============================================================
// password_requirements_box.dart
// Caja informativa de requisitos de contraseña.
// Compartida entre RegisterScreen y EditProfileScreen.
// ============================================================

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

/// Caja informativa que muestra los requisitos de contraseña
class PasswordRequirementsBox extends StatelessWidget {
  const PasswordRequirementsBox({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.primaryBlue,
        );

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.secondaryBlue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: AppColors.secondaryBlue.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'La contraseña debe tener:',
            style: textStyle?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text('• Mínimo 8 caracteres', style: textStyle),
          Text('• Al menos una mayúscula', style: textStyle),
          Text('• Al menos un número', style: textStyle),
        ],
      ),
    );
  }
}
