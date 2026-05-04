// ============================================================
// academic_card.dart
// Tarjeta de resumen de oferta académica para la lista principal.
// Al tocarla navega a AcademicDetailScreen.
// ============================================================

import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../models/academic_offer_model.dart';
import '../academic_detail_screen.dart';

/// Tarjeta de oferta académica para mostrar en la lista
class AcademicCard extends StatelessWidget {
  final AcademicOfferModel offer;

  const AcademicCard({super.key, required this.offer});

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
                  Expanded(
                    child: Text(
                      offer.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingSm),
                  Text(
                    timeago.format(offer.createdAt, locale: 'es'),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.spacingXs),

              // --------------------------------------------------
              // Institución
              // --------------------------------------------------
              Row(
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: AppDimensions.iconSm,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: AppDimensions.spacingXs),
                  Expanded(
                    child: Text(
                      offer.institution,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // --------------------------------------------------
              // Fila de chips: duración y precio (opcionales)
              // --------------------------------------------------
              if (offer.duration != null || offer.price != null) ...[
                const SizedBox(height: AppDimensions.spacingSm),
                Wrap(
                  spacing: AppDimensions.spacingSm,
                  children: [
                    if (offer.duration != null && offer.duration!.isNotEmpty)
                      _InfoChip(
                        icon: Icons.access_time_outlined,
                        label: offer.duration!,
                      ),
                    if (offer.price != null && offer.price!.isNotEmpty)
                      _InfoChip(
                        icon: Icons.attach_money,
                        label: offer.price!,
                        color: AppColors.success,
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
      MaterialPageRoute(
        builder: (_) => AcademicDetailScreen(offer: offer),
      ),
    );
  }
}

// ============================================================
// Widget interno: chip de información compacto
// ============================================================

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ?? Theme.of(context).textTheme.bodySmall?.color;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppDimensions.iconSm, color: effectiveColor),
        const SizedBox(width: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: effectiveColor,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
