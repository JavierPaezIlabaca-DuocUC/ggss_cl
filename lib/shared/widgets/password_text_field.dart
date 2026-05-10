// ============================================================
// password_text_field.dart
// Campo de contraseña reutilizable con botón de visibilidad.
//
// Ícono de visibilidad:
//   - Ojo abierto (Icons.visibility) → muestra el texto plano
//   - Ojo cerrado dibujado a mano (CustomPaint) → oculta como asteriscos
//
// Se usa el ojo cerrado dibujado con CustomPainter para evitar
// el ícono Icons.visibility_off que tiene una línea diagonal
// tachando el ojo (variante no deseada según especificaciones).
// ============================================================

import 'package:flutter/material.dart';

/// Campo de texto para contraseñas con toggle de visibilidad.
///
/// Uso:
/// ```dart
/// PasswordTextField(
///   label: 'Contraseña',
///   controller: _passwordController,
///   validator: Validators.validatePassword,
/// )
/// ```
class PasswordTextField extends StatefulWidget {
  /// Etiqueta del campo (label)
  final String label;

  /// Texto de ayuda dentro del campo (hint)
  final String? hint;

  /// Controlador del campo de texto
  final TextEditingController controller;

  /// Función de validación (retorna null si es válido, String si hay error)
  final String? Function(String?)? validator;

  /// Si es true, el campo no se puede editar
  final bool readOnly;

  /// Acción del teclado al presionar Enter/Next
  final TextInputAction textInputAction;

  /// Callback al presionar el botón de enviar del teclado
  final VoidCallback? onSubmitted;

  /// Si es false, el campo aparece deshabilitado (no editable ni tappeable)
  final bool enabled;

  const PasswordTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.readOnly = false,
    this.enabled = true,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  // Cuando _obscureText es true: el texto se oculta (asteriscos)
  // Cuando es false: el texto se muestra en claro
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      onFieldSubmitted:
          widget.onSubmitted != null ? (_) => widget.onSubmitted!() : null,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        // ----------------------------------------------------------
        // Botón de visibilidad a la derecha del campo
        // ----------------------------------------------------------
        suffixIcon: IconButton(
          // Tooltip accesible para lectores de pantalla
          tooltip: _obscureText ? 'Mostrar contraseña' : 'Ocultar contraseña',
          onPressed: _toggleVisibility,
          icon: _obscureText
              // Ojo cerrado: dibujado a mano, sin línea diagonal
              ? _ClosedEyeIcon(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )
              // Ojo abierto: ícono estándar de Material
              : Icon(
                  Icons.visibility,
                  color: Theme.of(context).colorScheme.primary,
                ),
        ),
      ),
    );
  }

  /// Alterna entre mostrar y ocultar la contraseña
  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
}

// ============================================================
// Ícono de ojo cerrado dibujado con CustomPainter
// Representa un ojo dormido/cerrado SIN línea diagonal tachando.
// La forma es: arco superior del ojo + curva inferior (párpado)
// + 3 pequeñas pestañas inferiores.
// ============================================================

/// Ícono de ojo cerrado pintado a mano (sin strikethrough)
class _ClosedEyeIcon extends StatelessWidget {
  final Color color;

  const _ClosedEyeIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(
        painter: _ClosedEyePainter(color: color),
      ),
    );
  }
}

/// Painter que dibuja un ojo cerrado con forma de luna creciente
class _ClosedEyePainter extends CustomPainter {
  final Color color;

  _ClosedEyePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // ----------------------------------------------------------
    // Arco superior: contorno de la parte superior del ojo
    // Forma una curva convexa hacia arriba (ceja)
    // ----------------------------------------------------------
    final topPath = Path()
      ..moveTo(w * 0.08, h * 0.52)
      ..cubicTo(
        w * 0.25, h * 0.22, // control 1: curvatura izquierda
        w * 0.75, h * 0.22, // control 2: curvatura derecha
        w * 0.92, h * 0.52, // punto final derecho
      );
    canvas.drawPath(topPath, paint);

    // ----------------------------------------------------------
    // Arco inferior: párpado cerrado
    // Forma una curva convexa hacia abajo (párpado inferior)
    // ----------------------------------------------------------
    final bottomPath = Path()
      ..moveTo(w * 0.08, h * 0.52)
      ..cubicTo(
        w * 0.25, h * 0.72, // control 1
        w * 0.75, h * 0.72, // control 2
        w * 0.92, h * 0.52, // punto final derecho
      );
    canvas.drawPath(bottomPath, paint);

    // ----------------------------------------------------------
    // Pestañas: 3 líneas cortas hacia abajo en la parte inferior
    // Indican visualmente que el ojo está cerrado/dormido
    // ----------------------------------------------------------
    // Pestaña izquierda
    canvas.drawLine(
      Offset(w * 0.28, h * 0.68),
      Offset(w * 0.22, h * 0.82),
      paint,
    );
    // Pestaña central
    canvas.drawLine(
      Offset(w * 0.50, h * 0.73),
      Offset(w * 0.50, h * 0.88),
      paint,
    );
    // Pestaña derecha
    canvas.drawLine(
      Offset(w * 0.72, h * 0.68),
      Offset(w * 0.78, h * 0.82),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ClosedEyePainter oldDelegate) =>
      color != oldDelegate.color;
}
