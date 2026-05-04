// ============================================================
// app_dimensions.dart
// Espaciados, tamaños y radios de borde estándar de GGSS.cl.
// Usar siempre estas constantes para mantener consistencia visual.
// Nunca escribir números mágicos directamente en los widgets.
// ============================================================

/// Dimensiones y espaciados centralizados de GGSS.cl
class AppDimensions {
  // Constructor privado: esta clase no debe instanciarse
  AppDimensions._();

  // ----------------------------------------------------------
  // Espaciado (padding / margin)
  // ----------------------------------------------------------

  /// Espaciado extra pequeño: 4 px
  static const double spacingXs = 4.0;

  /// Espaciado pequeño: 8 px
  static const double spacingSm = 8.0;

  /// Espaciado mediano: 16 px (uso más común)
  static const double spacingMd = 16.0;

  /// Espaciado grande: 24 px
  static const double spacingLg = 24.0;

  /// Espaciado extra grande: 32 px
  static const double spacingXl = 32.0;

  /// Espaciado doble extra grande: 48 px
  static const double spacingXxl = 48.0;

  // ----------------------------------------------------------
  // Radios de borde
  // ----------------------------------------------------------

  /// Radio pequeño para chips y badges: 4 px
  static const double radiusSm = 4.0;

  /// Radio mediano para tarjetas y campos: 12 px
  static const double radiusMd = 12.0;

  /// Radio grande para bottom sheets y modales: 20 px
  static const double radiusLg = 20.0;

  /// Radio completo para botones y avatares circulares: 100 px
  static const double radiusFull = 100.0;

  // ----------------------------------------------------------
  // Tamaños de íconos
  // ----------------------------------------------------------

  /// Ícono pequeño (dentro de chips, listas densas): 16 px
  static const double iconSm = 16.0;

  /// Ícono mediano (íconos de navegación, acciones): 24 px
  static const double iconMd = 24.0;

  /// Ícono grande (estados vacíos, ilustraciones): 48 px
  static const double iconLg = 48.0;

  // ----------------------------------------------------------
  // Header fijo de la app
  // ----------------------------------------------------------

  /// Alto total del header (dos filas): 108 px
  static const double headerHeight = 108.0;

  /// Alto de cada fila del header: 52 px
  static const double headerRowHeight = 52.0;

  /// Tamaño del avatar circular del usuario en el header: 36 px
  static const double avatarSizeHeader = 36.0;

  // ----------------------------------------------------------
  // Barra de navegación inferior
  // ----------------------------------------------------------

  /// Alto de la barra de navegación inferior: 60 px
  static const double bottomNavHeight = 60.0;

  // ----------------------------------------------------------
  // Tarjetas
  // ----------------------------------------------------------

  /// Elevación estándar de tarjetas: 2 px
  static const double cardElevation = 2.0;

  /// Padding interno de tarjetas: 16 px
  static const double cardPadding = 16.0;

  // ----------------------------------------------------------
  // Campos de formulario
  // ----------------------------------------------------------

  /// Alto mínimo de campos de texto: 56 px
  static const double inputHeight = 56.0;
}
