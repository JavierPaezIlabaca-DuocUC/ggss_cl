// ============================================================
// external_link_dialog.dart
// Widget exportable que envuelve la lógica de LinkHandler.
// Permite abrir enlaces externos desde cualquier módulo
// con una sola llamada.
// ============================================================

import 'package:flutter/material.dart';

import '../../core/utils/link_handler.dart';

/// Utilidad para abrir un enlace externo con el diálogo de advertencia de GGSS.cl
///
/// Uso:
/// ```dart
/// ExternalLinkOpener.open(context, 'https://ejemplo.cl');
/// ```
class ExternalLinkOpener {
  // Constructor privado: no instanciar
  ExternalLinkOpener._();

  /// Abre [url] con advertencia de enlace externo (si aplica)
  static Future<void> open(BuildContext context, String url) async {
    await LinkHandler.openExternalLink(context, url);
  }
}
