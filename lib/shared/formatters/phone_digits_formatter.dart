// ============================================================
// phone_digits_formatter.dart
// Formateador compartido para el campo de teléfono con prefijo +569.
// Formatea 8 dígitos con un espacio cada 2: "12 34 56 78"
// ============================================================

import 'package:flutter/services.dart';

/// Formatea 8 dígitos numéricos como "12 34 56 78" en tiempo real.
/// Usado en RegisterScreen, CreateJobScreen y CreateAcademicScreen.
class PhoneDigitsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 8 ? digits.substring(0, 8) : digits;

    final buffer = StringBuffer();
    for (int i = 0; i < limited.length; i++) {
      if (i > 0 && i % 2 == 0) buffer.write(' ');
      buffer.write(limited[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
