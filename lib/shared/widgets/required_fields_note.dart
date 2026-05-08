// ============================================================
// required_fields_note.dart
// Nota informativa que aparece al inicio de cada formulario
// de creación para indicar qué campos son obligatorios.
// ============================================================

import 'package:flutter/material.dart';

/// Texto "* Los campos marcados con asterisco son obligatorios"
/// Se muestra en la parte superior de los formularios de creación.
class RequiredFieldsNote extends StatelessWidget {
  const RequiredFieldsNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      '* Los campos marcados con asterisco son obligatorios',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }
}
