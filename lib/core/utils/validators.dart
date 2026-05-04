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
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingresa un correo electrónico válido.';
    }
    return null;
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

  /// Valida que la confirmación de contraseña coincida con la original
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
  // Validación de RUT chileno (Módulo 11)
  // ----------------------------------------------------------

  /// Valida un RUT chileno usando el algoritmo Módulo 11.
  /// Acepta formatos: 12345678-9, 12.345.678-9, 12345678K, etc.
  /// Retorna null si es válido, o un mensaje de error si no lo es.
  static String? validateRut(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El RUT es obligatorio.';
    }

    // Limpiar el RUT: eliminar puntos, espacios y pasar a mayúsculas
    final rutLimpio = value.trim().replaceAll('.', '').replaceAll(' ', '').toUpperCase();

    // Debe tener al menos 2 caracteres (dígito + guión + dígito verificador)
    if (rutLimpio.length < 3) {
      return 'El RUT ingresado no es válido.';
    }

    // Separar cuerpo y dígito verificador
    String cuerpo;
    String digitoVerificador;

    if (rutLimpio.contains('-')) {
      // Formato con guión: 12345678-9
      final partes = rutLimpio.split('-');
      if (partes.length != 2) return 'El RUT ingresado no es válido.';
      cuerpo = partes[0];
      digitoVerificador = partes[1];
    } else {
      // Formato sin guión: 123456789 (último char es el dígito verificador)
      cuerpo = rutLimpio.substring(0, rutLimpio.length - 1);
      digitoVerificador = rutLimpio.substring(rutLimpio.length - 1);
    }

    // El cuerpo solo debe contener dígitos
    if (!RegExp(r'^\d+$').hasMatch(cuerpo)) {
      return 'El RUT ingresado no es válido.';
    }

    // El dígito verificador debe ser 0-9 o K
    if (!RegExp(r'^[0-9K]$').hasMatch(digitoVerificador)) {
      return 'El dígito verificador del RUT no es válido.';
    }

    // Calcular el dígito verificador esperado con el algoritmo Módulo 11
    final digitoEsperado = _calcularDigitoVerificadorRut(cuerpo);

    if (digitoVerificador != digitoEsperado) {
      return 'El RUT ingresado no es válido (dígito verificador incorrecto).';
    }

    return null; // RUT válido
  }

  /// Calcula el dígito verificador de un RUT usando el algoritmo Módulo 11.
  /// Recibe solo el cuerpo numérico (sin puntos, sin guión, sin dígito verificador).
  /// Retorna el dígito verificador como String ('0'-'9' o 'K').
  static String _calcularDigitoVerificadorRut(String cuerpo) {
    // Serie de multiplicadores: 2, 3, 4, 5, 6, 7, repite desde la derecha
    const multiplicadores = [2, 3, 4, 5, 6, 7];
    int suma = 0;
    int indiceMultiplicador = 0;

    // Recorrer los dígitos del cuerpo de derecha a izquierda
    for (int i = cuerpo.length - 1; i >= 0; i--) {
      final digito = int.parse(cuerpo[i]);
      suma += digito * multiplicadores[indiceMultiplicador % 6];
      indiceMultiplicador++;
    }

    // Calcular el dígito verificador
    final resto = suma % 11;
    final digitoCalculado = 11 - resto;

    if (digitoCalculado == 11) return '0';
    if (digitoCalculado == 10) return 'K';
    return digitoCalculado.toString();
  }

  /// Formatea un RUT limpio al formato estándar: XX.XXX.XXX-Y
  /// Útil para mostrar el RUT formateado al usuario.
  static String formatRut(String rutLimpio) {
    final clean = rutLimpio
        .replaceAll('.', '')
        .replaceAll('-', '')
        .replaceAll(' ', '')
        .toUpperCase();

    if (clean.length < 2) return clean;

    final cuerpo = clean.substring(0, clean.length - 1);
    final dv = clean.substring(clean.length - 1);

    // Agregar puntos cada 3 dígitos desde la derecha
    final buffer = StringBuffer();
    for (int i = 0; i < cuerpo.length; i++) {
      if (i > 0 && (cuerpo.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(cuerpo[i]);
    }

    return '${buffer.toString()}-$dv';
  }

  // ----------------------------------------------------------
  // Validación de campo genérico obligatorio
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

  /// Valida que una URL tenga formato correcto (campo opcional)
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

  /// Valida número de teléfono chileno (9 dígitos, campo opcional)
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
