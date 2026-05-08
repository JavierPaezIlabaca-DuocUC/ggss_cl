// ============================================================
// job_detail_screen.dart
// Pantalla de detalle de una oferta laboral.
// Muestra todos los campos, botones de contacto y mapa,
// y permite eliminar si el usuario es el autor.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../models/job_model.dart';
import '../../shared/widgets/external_link_dialog.dart';
import '../auth/auth_providers.dart';
import 'jobs_providers.dart';

/// Pantalla de detalle de una oferta laboral
class JobDetailScreen extends ConsumerWidget {
  final JobModel job;

  const JobDetailScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final bool isAuthor = currentUser?.id == job.createdBy;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Oferta'),
        // Botón de eliminar: visible solo para el autor
        actions: [
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
            // Título de la oferta
            // --------------------------------------------------
            Text(
              job.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),

            const SizedBox(height: AppDimensions.spacingSm),

            // --------------------------------------------------
            // Empresa
            // --------------------------------------------------
            _InfoRow(
              icon: Icons.business_outlined,
              text: job.company,
              color: Theme.of(context).colorScheme.primary,
              bold: true,
            ),

            const SizedBox(height: AppDimensions.spacingXs),

            // --------------------------------------------------
            // Ubicación
            // --------------------------------------------------
            _InfoRow(
              icon: Icons.location_on_outlined,
              text: job.location,
            ),

            // --------------------------------------------------
            // Rango salarial (opcional)
            // --------------------------------------------------
            if (job.salaryRange != null && job.salaryRange!.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.spacingXs),
              _InfoRow(
                icon: Icons.attach_money,
                text: job.salaryRange!,
                color: AppColors.success,
                bold: true,
              ),
            ],

            const SizedBox(height: AppDimensions.spacingXs),

            // --------------------------------------------------
            // Fecha de publicación
            // --------------------------------------------------
            _InfoRow(
              icon: Icons.access_time_outlined,
              text: 'Publicado ${timeago.format(job.createdAt, locale: 'es')}',
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
              job.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            // --------------------------------------------------
            // Requisitos (opcional)
            // --------------------------------------------------
            if (job.requirements != null && job.requirements!.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.spacingMd),
              Text(
                'Requisitos',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              Text(
                job.requirements!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],

            const SizedBox(height: AppDimensions.spacingXl),

            // --------------------------------------------------
            // Botón WhatsApp (si hay número de contacto)
            // --------------------------------------------------
            if (job.hasWhatsapp)
              _ActionButton(
                icon: Icons.chat_outlined,
                label: AppStrings.jobsContactWhatsApp,
                color: AppColors.success,
                onTap: () => _openWhatsApp(context),
              ),

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
      'Hola, vi tu oferta de trabajo en GGSS.cl y me interesa',
    );
    final url = 'https://wa.me/${job.contactWhatsapp}?text=$message';
    ExternalLinkOpener.open(context, url);
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
          '¿Estás seguro de que deseas eliminar esta oferta laboral? '
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
      await ref.read(jobsNotifierProvider.notifier).deleteJob(job.id);
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
