// ============================================================
// academic_detail_screen.dart
// Pantalla de detalle de una oferta académica.
// Muestra todos los campos, botones de contacto y URL,
// y permite eliminar si el usuario es el autor.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../models/academic_offer_model.dart';
import '../../shared/widgets/external_link_dialog.dart';
import '../auth/auth_providers.dart';
import '../profile/public_profile_screen.dart';
import 'academic_providers.dart';

/// Pantalla de detalle de una oferta académica
class AcademicDetailScreen extends ConsumerWidget {
  final AcademicOfferModel offer;

  const AcademicDetailScreen({super.key, required this.offer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final bool isAuthor = currentUser?.id == offer.createdBy;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Curso'),
        actions: [
          // Botón eliminar: visible solo para el autor
          if (isAuthor)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: AppStrings.actionDelete,
              onPressed: () => _confirmDelete(context, ref),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --------------------------------------------------
            // Título del curso
            // --------------------------------------------------
            Text(
              offer.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),

            const SizedBox(height: AppDimensions.spacingSm),

            // --------------------------------------------------
            // Institución
            // --------------------------------------------------
            _InfoRow(
              icon: Icons.school_outlined,
              text: offer.institution,
              color: Theme.of(context).colorScheme.primary,
              bold: true,
            ),

            const SizedBox(height: AppDimensions.spacingXs),

            // --------------------------------------------------
            // Duración (opcional)
            // --------------------------------------------------
            if (offer.duration != null && offer.duration!.isNotEmpty) ...[
              _InfoRow(
                icon: Icons.access_time_outlined,
                text: offer.duration!,
              ),
              const SizedBox(height: AppDimensions.spacingXs),
            ],

            // --------------------------------------------------
            // Precio (opcional)
            // --------------------------------------------------
            if (offer.price != null && offer.price!.isNotEmpty) ...[
              _InfoRow(
                icon: Icons.attach_money,
                text: offer.price!,
                color: AppColors.success,
                bold: true,
              ),
              const SizedBox(height: AppDimensions.spacingXs),
            ],

            // --------------------------------------------------
            // Fecha de publicación
            // --------------------------------------------------
            _InfoRow(
              icon: Icons.access_time_outlined,
              text:
                  'Publicado ${timeago.format(offer.createdAt, locale: 'es')}',
            ),

            const SizedBox(height: AppDimensions.spacingXs),

            // --------------------------------------------------
            // Autor de la publicación (tappeable → perfil público)
            // --------------------------------------------------
            _AuthorRow(
              authorLabel: offer.authorFirstName ??
                  offer.authorName ??
                  AppStrings.forumAnonymous,
              userId: offer.createdBy,
            ),

            const Divider(height: AppDimensions.spacingXl),

            // --------------------------------------------------
            // Descripción
            // --------------------------------------------------
            Text(
              'Descripción',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              offer.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            // --------------------------------------------------
            // Requisitos (opcional)
            // --------------------------------------------------
            if (offer.requirements != null &&
                offer.requirements!.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.spacingMd),
              Text(
                'Requisitos',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              Text(
                offer.requirements!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],

            const SizedBox(height: AppDimensions.spacingXl),

            // --------------------------------------------------
            // Botón WhatsApp (si hay número de contacto)
            // --------------------------------------------------
            if (offer.hasWhatsapp)
              _ActionButton(
                icon: Icons.chat_outlined,
                label: 'Consultar por WhatsApp',
                color: AppColors.success,
                onTap: () => _openWhatsApp(context),
              ),

            // --------------------------------------------------
            // Botón Google Maps (si hay dirección específica)
            // --------------------------------------------------
            if (offer.hasAddress) ...[
              const SizedBox(height: AppDimensions.spacingSm),
              _ActionButton(
                icon: Icons.map_outlined,
                label: 'Ver ubicación en Google Maps',
                color: AppColors.primaryBlue,
                onTap: () => _openMaps(context),
              ),
            ],

            // --------------------------------------------------
            // Botón URL (si hay enlace de inscripción)
            // --------------------------------------------------
            if (offer.hasUrl) ...[
              const SizedBox(height: AppDimensions.spacingSm),
              _ActionButton(
                icon: Icons.open_in_new_outlined,
                label: 'Ver más información',
                color: Theme.of(context).colorScheme.primary,
                onTap: () => _openUrl(context),
              ),
            ],

            const SizedBox(height: AppDimensions.spacingXl),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // Abre WhatsApp con mensaje prefijado sobre GGSS.cl
  // ----------------------------------------------------------

  void _openWhatsApp(BuildContext context) {
    final message = Uri.encodeComponent(
      'Hola, vi tu oferta académica en GGSS.cl y me interesa',
    );
    // wa.me requires the number WITHOUT the leading + sign
    final number = offer.contactWhatsapp!.replaceAll('+', '');
    final url = 'https://wa.me/$number?text=$message';
    ExternalLinkOpener.open(context, url);
  }

  void _openMaps(BuildContext context) {
    final query = Uri.encodeComponent(offer.address!);
    final url =
        'https://www.google.com/maps/search/?api=1&query=$query';
    ExternalLinkOpener.open(context, url);
  }

  // ----------------------------------------------------------
  // Abre la URL de la oferta en el navegador
  // ----------------------------------------------------------

  void _openUrl(BuildContext context) {
    ExternalLinkOpener.open(context, offer.url!);
  }

  // ----------------------------------------------------------
  // Diálogo de confirmación antes de eliminar
  // ----------------------------------------------------------

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar oferta'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta oferta académica? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppStrings.actionCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(AppStrings.actionDelete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    try {
      await ref
          .read(academicNotifierProvider.notifier)
          .deleteOffer(offer.id);
      if (context.mounted) Navigator.of(context).pop();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.errorGeneral)),
        );
      }
    }
  }
}

// ============================================================
// Widgets internos de apoyo
// ============================================================

/// Fila del autor con nombre tappeable que navega al perfil público
class _AuthorRow extends StatelessWidget {
  final String authorLabel;
  final String userId;

  const _AuthorRow({required this.authorLabel, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.person_outline,
          size: AppDimensions.iconMd,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        const SizedBox(width: AppDimensions.spacingSm),
        GestureDetector(
          onTap: () {
            if (userId.isNotEmpty) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PublicProfileScreen(userId: userId),
                ),
              );
            }
          },
          child: Text(
            authorLabel,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
      ],
    );
  }
}

/// Fila de información con ícono y texto
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  final bool bold;

  const _InfoRow({
    required this.icon,
    required this.text,
    this.color,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ?? Theme.of(context).textTheme.bodyMedium?.color;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: AppDimensions.iconMd, color: effectiveColor),
        const SizedBox(width: AppDimensions.spacingSm),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: effectiveColor,
                  fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
                ),
          ),
        ),
      ],
    );
  }
}

/// Botón de acción de ancho completo con borde de color
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Icon(icon, color: color),
        label: Text(label, style: TextStyle(color: color)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color),
          minimumSize: const Size(double.infinity, AppDimensions.inputHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
        onPressed: onTap,
      ),
    );
  }
}
