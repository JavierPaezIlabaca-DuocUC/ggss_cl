// ============================================================
// job_card.dart
// Tarjeta de resumen de oferta laboral para la lista principal.
// Al tocarla navega a JobDetailScreen.
// ============================================================

import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../models/job_model.dart';
import '../job_detail_screen.dart';

/// Tarjeta de oferta laboral para mostrar en la lista
class JobCard extends StatelessWidget {
  final JobModel job;

  const JobCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        onTap: () => _openDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --------------------------------------------------
              // Fila superior: título y tiempo transcurrido
              // --------------------------------------------------
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título de la oferta
                  Expanded(
                    child: Text(
                      job.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(width: AppDimensions.spacingSm),

                  // Tiempo transcurrido desde la publicación
                  Text(
                    timeago.format(job.createdAt, locale: 'es'),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.spacingXs),

              // --------------------------------------------------
              // Empresa
              // --------------------------------------------------
              Text(
                job.company,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: AppDimensions.spacingXs),

              // --------------------------------------------------
              // Ubicación
              // --------------------------------------------------
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: AppDimensions.iconSm,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: AppDimensions.spacingXs),
                  Expanded(
                    child: Text(
                      job.location,
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // --------------------------------------------------
              // Rango salarial (opcional)
              // --------------------------------------------------
              if (job.salaryRange != null && job.salaryRange!.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spacingXs),
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: AppDimensions.iconSm,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: AppDimensions.spacingXs),
                    Text(
                      job.salaryRange!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
    );
  }
}
