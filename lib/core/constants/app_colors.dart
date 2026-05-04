// ============================================================
// app_colors.dart
// Paleta de colores oficial de GGSS.cl.
// Todos los colores de la app deben referenciar estas constantes,
// NUNCA usar valores hexadecimales directamente en los widgets.
// ============================================================

import 'package:flutter/material.dart';

/// Colores centralizados de GGSS.cl
class AppColors {
  // Constructor privado: esta clase no debe instanciarse
  AppColors._();

  // ----------------------------------------------------------
  // Azules primarios — identidad visual de la app
  // ----------------------------------------------------------

  /// Azul primario: botones principales, íconos activos, acentos
  static const Color primaryBlue = Color(0xFF1565C0);

  /// Azul secundario: elementos de soporte, chips, bordes destacados
  static const Color secondaryBlue = Color(0xFF42A5F5);

  // ----------------------------------------------------------
  // Fondos — modo claro
  // ----------------------------------------------------------

  /// Fondo principal en modo claro
  static const Color backgroundLight = Color(0xFFFFFFFF);

  /// Color de superficie para tarjetas en modo claro
  static const Color surfaceLight = Color(0xFFF5F5F5);

  // ----------------------------------------------------------
  // Fondos — modo oscuro
  // ----------------------------------------------------------

  /// Fondo principal en modo oscuro
  static const Color backgroundDark = Color(0xFF121212);

  /// Color de superficie para tarjetas en modo oscuro
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // ----------------------------------------------------------
  // Colores neutros y de estado
  // ----------------------------------------------------------

  /// Texto principal sobre fondo claro
  static const Color textPrimaryLight = Color(0xFF212121);

  /// Texto secundario / subtítulos en modo claro
  static const Color textSecondaryLight = Color(0xFF757575);

  /// Texto principal sobre fondo oscuro
  static const Color textPrimaryDark = Color(0xFFE0E0E0);

  /// Texto secundario / subtítulos en modo oscuro
  static const Color textSecondaryDark = Color(0xFF9E9E9E);

  /// Color de error (validaciones de formularios)
  static const Color error = Color(0xFFD32F2F);

  /// Color de éxito (confirmaciones)
  static const Color success = Color(0xFF388E3C);

  /// Color de advertencia
  static const Color warning = Color(0xFFF57C00);

  /// Divisor / separador entre elementos
  static const Color divider = Color(0xFFBDBDBD);
}
