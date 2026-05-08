// ============================================================
// os10_screen.dart
// Pantalla de entrada al Simulador OS10.
//
// Muestra:
//   - Banner de reanudación si hay un examen guardado/pausado
//   - Estadísticas del usuario (mejor puntaje, intentos, preguntas)
//   - Dos tarjetas de modalidad: Tradicional (50Q/60min) y
//     Express (25Q/30min)
//   - Botón para ver el historial de intentos
//
// Los datos provienen de os10StatsProvider (Riverpod + SharedPreferences).
// Al completar o pausar un examen, el proveedor se invalida y esta
// pantalla se reconstruye automáticamente con datos frescos.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import 'os10_providers.dart';
import 'os10_question_screen.dart';

/// Umbral de aprobación: 60%
const int _kPassPercent = 60;

/// Pantalla de inicio del Simulador OS10 (embebida en MainShell)
class Os10Screen extends ConsumerWidget {
  const Os10Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(os10StatsProvider);

    return statsAsync.when(
      // ----------------------------------------------------------
      // Cargando estadísticas
      // ----------------------------------------------------------
      loading: () => const Center(child: CircularProgressIndicator()),

      // ----------------------------------------------------------
      // Error al cargar (mostrar contenido parcial sin datos)
      // ----------------------------------------------------------
      error: (err, _) => _Os10Content(
        stats: const Os10StatsData(
          bestScorePercent: null,
          history: [],
          totalQuestions: 0,
          hasSavedExam: false,
        ),
        onStartExam: (ctx, count, seconds) =>
            _startExam(ctx, ref, count, seconds),
        onResumeExam: (ctx) => _resumeExam(ctx, ref),
        onShowHistory: (ctx) => _showHistory(
          ctx,
          const Os10StatsData(
            bestScorePercent: null,
            history: [],
            totalQuestions: 0,
            hasSavedExam: false,
          ),
        ),
      ),

      // ----------------------------------------------------------
      // Datos cargados correctamente
      // ----------------------------------------------------------
      data: (stats) => _Os10Content(
        stats: stats,
        onStartExam: (ctx, count, seconds) =>
            _startExam(ctx, ref, count, seconds),
        onResumeExam: (ctx) => _resumeExam(ctx, ref),
        onShowHistory: (ctx) => _showHistory(ctx, stats),
      ),
    );
  }

  // ----------------------------------------------------------
  // Inicia un examen nuevo con la modalidad elegida
  // ----------------------------------------------------------

  Future<void> _startExam(
    BuildContext context,
    WidgetRef ref,
    int questionCount,
    int timeLimitSeconds,
  ) async {
    if (!context.mounted) return;

    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => Os10QuestionScreen(
          questionCount: questionCount,
          timeLimitSeconds: timeLimitSeconds,
          resumeFromSaved: false,
        ),
      ),
    );

    // Si el usuario eligió "Repetir", volver al inicio (elige modalidad de nuevo)
    // No se inicia automáticamente — el usuario elige la modalidad
    if (result == 'repeat' && context.mounted) {
      // Regresar a la pantalla ya reconstruida (el provider fue invalidado)
    }
  }

  // ----------------------------------------------------------
  // Retoma el examen guardado/pausado
  // ----------------------------------------------------------

  Future<void> _resumeExam(BuildContext context, WidgetRef ref) async {
    if (!context.mounted) return;

    await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const Os10QuestionScreen(
          resumeFromSaved: true,
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // Muestra el historial de intentos en un bottom sheet
  // ----------------------------------------------------------

  void _showHistory(BuildContext context, Os10StatsData stats) {
    if (stats.history.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aún no tienes intentos registrados.'),
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLg),
        ),
      ),
      builder: (_) => _HistoryBottomSheet(history: stats.history),
    );
  }
}

// ============================================================
// Widget interno: contenido principal de Os10Screen
// ============================================================

class _Os10Content extends StatelessWidget {
  final Os10StatsData stats;
  final void Function(BuildContext, int questionCount, int timeLimitSeconds)
      onStartExam;
  final void Function(BuildContext) onResumeExam;
  final void Function(BuildContext) onShowHistory;

  const _Os10Content({
    required this.stats,
    required this.onStartExam,
    required this.onResumeExam,
    required this.onShowHistory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final noQuestions = stats.totalQuestions == 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppDimensions.spacingMd),

          // --------------------------------------------------
          // Banner de reanudación (visible si hay examen guardado)
          // --------------------------------------------------
          if (stats.hasSavedExam) ...[
            _ResumeBanner(
              onResume: () => onResumeExam(context),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
          ],

          // --------------------------------------------------
          // Cabecera: ícono y título
          // --------------------------------------------------
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              ),
              child: const Icon(
                Icons.assignment_outlined,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            AppStrings.titleOs10,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            'Preguntas de Verdadero o Falso sobre legislación, '
            'procedimientos y ética del guardia de seguridad.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),

          const SizedBox(height: AppDimensions.spacingLg),

          // --------------------------------------------------
          // Tarjetas de estadísticas
          // --------------------------------------------------
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.quiz_outlined,
                  label: 'Preguntas\ndisponibles',
                  value: '${stats.totalQuestions}',
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: _StatCard(
                  icon: Icons.emoji_events_outlined,
                  label: 'Mejor\npuntaje',
                  value: stats.bestScorePercent != null
                      ? '${stats.bestScorePercent}%'
                      : '—',
                  color: stats.bestScorePercent != null &&
                          stats.bestScorePercent! >= _kPassPercent
                      ? AppColors.success
                      : theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: _StatCard(
                  icon: Icons.history_outlined,
                  label: 'Intentos\nrealizados',
                  value: '${stats.history.length}',
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingXl),

          // --------------------------------------------------
          // Sección: elegir modalidad de examen
          // --------------------------------------------------
          Text(
            'Elige una modalidad',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),

          // Tarjeta: Examen Tradicional
          _ModalityCard(
            icon: Icons.assignment_outlined,
            title: 'Examen Tradicional',
            description: '50 preguntas · 60 minutos',
            note: 'Replica las condiciones del examen OS10 real',
            color: theme.colorScheme.primary,
            enabled: !noQuestions,
            onTap: () => onStartExam(
              context,
              kOs10TraditionalCount,
              kOs10TraditionalSeconds,
            ),
          ),

          const SizedBox(height: AppDimensions.spacingMd),

          // Tarjeta: Examen Express
          _ModalityCard(
            icon: Icons.flash_on_outlined,
            title: 'Examen Express',
            description: '25 preguntas · 30 minutos',
            note: 'Repaso rápido para practicar en poco tiempo',
            color: AppColors.secondaryBlue,
            enabled: !noQuestions,
            onTap: () => onStartExam(
              context,
              kOs10ExpressCount,
              kOs10ExpressSeconds,
            ),
          ),

          const SizedBox(height: AppDimensions.spacingXl),

          // --------------------------------------------------
          // Botón secundario: ver historial
          // --------------------------------------------------
          OutlinedButton.icon(
            onPressed: () => onShowHistory(context),
            icon: const Icon(Icons.history_rounded),
            label: const Text('Ver historial de intentos'),
            style: OutlinedButton.styleFrom(
              minimumSize:
                  const Size(double.infinity, AppDimensions.inputHeight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.spacingXl),
        ],
      ),
    );
  }
}

// ============================================================
// Widget: Banner de reanudación de examen pausado
// ============================================================

class _ResumeBanner extends StatelessWidget {
  final VoidCallback onResume;

  const _ResumeBanner({required this.onResume});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.pause_circle_outline,
            color: AppColors.warning,
            size: AppDimensions.iconMd + 4,
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tienes un examen en progreso',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  'Puedes retomarlo donde lo dejaste.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          FilledButton(
            onPressed: onResume,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.warning,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMd,
                vertical: AppDimensions.spacingSm,
              ),
            ),
            child: const Text('Retomar'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Widget: Tarjeta de modalidad de examen
// ============================================================

class _ModalityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String note;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  const _ModalityCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.note,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        decoration: BoxDecoration(
          color: enabled
              ? color.withValues(alpha: 0.07)
              : theme.disabledColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: enabled
                ? color.withValues(alpha: 0.35)
                : theme.disabledColor.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Ícono de la modalidad
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: enabled
                    ? color.withValues(alpha: 0.12)
                    : theme.disabledColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: enabled ? color : theme.disabledColor,
                size: AppDimensions.iconMd + 4,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMd),

            // Textos de la modalidad
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: enabled ? color : theme.disabledColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: enabled ? null : theme.disabledColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    note,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: enabled
                          ? theme.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.7)
                          : theme.disabledColor,
                    ),
                  ),
                ],
              ),
            ),

            // Flecha de acción
            Icon(
              Icons.chevron_right_rounded,
              color: enabled ? color : theme.disabledColor,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Widgets de apoyo reutilizados de la versión anterior
// ============================================================

/// Tarjeta compacta de estadística
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerTheme.color ?? AppColors.divider,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: AppDimensions.iconMd),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Bottom sheet de historial de intentos
// ============================================================

class _HistoryBottomSheet extends StatelessWidget {
  final List<Map<String, dynamic>> history;

  const _HistoryBottomSheet({required this.history});

  @override
  Widget build(BuildContext context) {
    final reversed = history.reversed.toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: AppDimensions.spacingMd),
        Text(
          'Historial de intentos',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Divider(),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: reversed.length,
            itemBuilder: (_, i) {
              final entry = reversed[i];
              final percent = entry['percent'] as int? ?? 0;
              final correct = entry['correct'] as int? ?? 0;
              final total = entry['total'] as int? ?? 0;
              final date = entry['date'] as String? ?? '';
              final passed = percent >= _kPassPercent;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      passed ? AppColors.success : AppColors.error,
                  child: Icon(
                    passed ? Icons.check : Icons.close,
                    color: Colors.white,
                    size: AppDimensions.iconSm,
                  ),
                ),
                title: Text(
                  '$percent% — $correct de $total correctas',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                subtitle: Text(
                  passed ? 'Aprobado' : 'Reprobado',
                  style: TextStyle(
                    color: passed ? AppColors.success : AppColors.error,
                    fontSize: 12,
                  ),
                ),
                trailing: Text(
                  _formatDate(date),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
      ],
    );
  }

  /// Formatea fecha ISO a DD/MM/AAAA
  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}';
    } catch (_) {
      return '';
    }
  }
}
