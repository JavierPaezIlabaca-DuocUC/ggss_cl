// ============================================================
// link_handler.dart
// Maneja la apertura de enlaces externos con advertencia
// obligatoria al usuario antes de salir de la app.
// Guarda la preferencia "no volver a mostrar" en SharedPreferences.
// ============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_strings.dart';

/// Clave usada en SharedPreferences para guardar la preferencia del usuario
const String _prefKeySkipExternalWarning = 'skip_external_link_warning';

/// Maneja la apertura de URLs externas con el diálogo de advertencia de GGSS.cl
class LinkHandler {
  // Constructor privado: esta clase no debe instanciarse
  LinkHandler._();

  // ----------------------------------------------------------
  // Método principal: abre un enlace externo con advertencia
  // ----------------------------------------------------------

  /// Abre [url] en el navegador externo.
  /// Si el usuario no ha elegido "no volver a mostrar",
  /// primero muestra el diálogo de advertencia.
  static Future<void> openExternalLink(
    BuildContext context,
    String url,
  ) async {
    // Leer preferencia guardada del usuario
    final prefs = await SharedPreferences.getInstance();
    final bool skipWarning = prefs.getBool(_prefKeySkipExternalWarning) ?? false;

    if (skipWarning) {
      // El usuario ya aceptó no ver más la advertencia: abrir directamente
      await _launchUrl(url);
      return;
    }

    // Verificar que el contexto sigue montado antes de mostrar diálogo
    if (!context.mounted) return;

    // Mostrar diálogo de advertencia
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _ExternalLinkDialog(
        url: url,
        onContinue: () async {
          Navigator.of(dialogContext).pop();
          await _launchUrl(url);
        },
        onDontShowAgain: () async {
          // Guardar preferencia: no volver a mostrar
          await prefs.setBool(_prefKeySkipExternalWarning, true);
          if (dialogContext.mounted) Navigator.of(dialogContext).pop();
          await _launchUrl(url);
        },
      ),
    );
  }

  // ----------------------------------------------------------
  // Método privado: ejecuta el lanzamiento de URL
  // ----------------------------------------------------------

  /// Intenta abrir la URL en el navegador externo del dispositivo
  static Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// ============================================================
// Widget interno del diálogo de advertencia
// No exportado: solo se usa dentro de LinkHandler
// ============================================================

class _ExternalLinkDialog extends StatelessWidget {
  const _ExternalLinkDialog({
    required this.url,
    required this.onContinue,
    required this.onDontShowAgain,
  });

  final String url;
  final VoidCallback onContinue;
  final VoidCallback onDontShowAgain;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.externalLinkTitle),
      content: const Text(AppStrings.externalLinkMessage),
      actions: [
        // Opción: no volver a mostrar (guarda en SharedPreferences)
        TextButton(
          onPressed: onDontShowAgain,
          child: const Text(AppStrings.externalLinkDontShowAgain),
        ),

        // Opción: continuar (muestra el aviso la próxima vez)
        FilledButton(
          onPressed: onContinue,
          child: const Text(AppStrings.externalLinkContinue),
        ),
      ],
    );
  }
}
