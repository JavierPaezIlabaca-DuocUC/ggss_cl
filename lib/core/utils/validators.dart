// ============================================================
// validators.dart
// Funciones de validación para formularios de la app.
// Cada función retorna null si el valor es válido,
// o un mensaje de error en español si no lo es.
// ============================================================

/// Validadores de campos de formularios para GGSS.cl
class Validators {
  // Constructor privado: esta clase no debe instanciarse
  Validators._();

  // ----------------------------------------------------------
  // Validación de correo electrónico
  // ----------------------------------------------------------

  /// Valida que el correo tenga formato válido
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo es obligatorio.';
    }

    // Expresión regular básica para correos electrónicos
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingresa un correo electrónico válido.';
    }

    return null; // Válido
  }

  // ----------------------------------------------------------
  // Validación de contraseña
  // ----------------------------------------------------------

  /// Valida que la contraseña tenga al menos 6 caracteres
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria.';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    return null;
  }

  /// Valida que la confirmación de contraseña coincida
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Debes confirmar tu contraseña.';
    }
    if (value != password) {
      return 'Las contraseñas no coinciden.';
    }
    return null;
  }

  // ----------------------------------------------------------
  // Validación de nombre
  // ----------------------------------------------------------

  /// Valida que el nombre no esté vacío y tenga longitud mínima
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre es obligatorio.';
    }
    if (value.trim().length < 3) {
      return 'El nombre debe tener al menos 3 caracteres.';
    }
    return null;
  }

  // ----------------------------------------------------------
  // Validación de campo de texto genérico
  // ----------------------------------------------------------

  /// Valida que un campo de texto no esté vacío
  static String? validateRequired(String? value, {String fieldName = 'Campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es obligatorio.';
    }
    return null;
  }

  // ----------------------------------------------------------
  // Validación de URL
  // ----------------------------------------------------------

  /// Valida que una URL tenga formato correcto (opcional pero válido si se ingresa)
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Las URLs son opcionales por defecto
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}'
      r'\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_+.~#?&/=]*)$',
    );

    if (!urlRegex.hasMatch(value.trim())) {
      return 'Ingresa una URL válida (debe comenzar con http:// o https://).';
    }
    return null;
  }

  // ----------------------------------------------------------
  // Validación de teléfono (Chile)
  // ----------------------------------------------------------

  /// Valida número de teléfono chileno (9 dígitos, opcional)
  static String? validateChilePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Teléfono es opcional
    }

    // Acepta formatos: +56912345678, 912345678, 56912345678
    final phoneRegex = RegExp(r'^(\+?56)?[2-9]\d{8}$');
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Ingresa un número de teléfono válido (ej: 912345678).';
    }
    return null;
  }
}
