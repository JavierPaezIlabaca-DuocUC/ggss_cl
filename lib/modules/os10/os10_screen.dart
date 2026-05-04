// ============================================================
// os10_screen.dart
// Pantalla de entrada al Simulador OS10.
// Muestra estadísticas del usuario y botones de acción.
// Embebida en MainShell (sin Scaffold propio).
// ============================================================

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../data/repositories/os10_repository.dart';
import 'os10_question_screen.dart';

// Claves de almacenamiento local
const String _keyBestScore = 'os10_best_score_percent';
const String _keyHistory = 'os10_exam_history';

/// Pantalla de inicio del Simulador OS10 (embebida en MainShell)
class Os10Screen extends StatefulWidget {
  const Os10Screen({super.key});

  @override
  State<Os10Screen> createState() => _Os10ScreenState();
}

class _Os10ScreenState extends State<Os10Screen> {
  // ----------------------------------------------------------
  // Estado local
  // ----------------------------------------------------------
  int? _bestScorePercent;
  List<Map<String, dynamic>> _history = [];
  int _totalQuestions = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ----------------------------------------------------------
  // Carga datos locales y total de preguntas disponibles
  // ----------------------------------------------------------

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _loading = true);

    // Leer mejor puntaje e historial de SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final bestScore = prefs.getInt(_keyBestScore);
    final historyJson = prefs.getString(_keyHistory);
    List<Map<String, dynamic>> history = [];
    if (historyJson != null) {
      try {
        final decoded = jsonDecode(historyJson) as List;
        history = decoded.cast<Map<String, dynamic>>();
      } catch (_) {}
    }

    // Obtener el total de preguntas disponibles en Supabase
    int count = 0;
    try {
      final questions = await Os10Repository().getAllQuestions();
      count = questions.length;
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _bestScorePercent = bestScore;
      _history = history;
      _totalQuestions = count;
      _loading = false;
    });
  }

  // ----------------------------------------------------------
  // Inicia el examen y espera el resultado al volver
  // ----------------------------------------------------------

  Future<void> _startExam() async {
    if (_totalQuestions == 0) return;

    // Navegar al examen y esperar retorno
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const Os10QuestionScreen()),
    );

    // Recargar estadísticas al volver (el examen pudo haber guardado un nuevo puntaje)
    await _loadData();

    // Si el usuario eligió "Repetir", iniciar otro examen de inmediato
    if (result == 'repeat' && mounted) {
      _startExam();
    }
  }

  // ----------------------------------------------------------
  // Muestra el historial de intentos en un bottom sheet
  // ----------------------------------------------------------

  void _showHistory() {
    if (_history.isEmpty) {
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
      builder: (_) => _HistoryBottomSheet(history: _history),
    );
  }

  // ----------------------------------------------------------
  // Construcción del widget
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppDimensions.spacingLg),

          // --------------------------------------------------
          // Cabecera: ícono y título del simulador
          // --------------------------------------------------
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              ),
              child: const Icon(
                Icons.assignment_outlined,
                color: Colors.white,
                size: 52,
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.spacingMd),

          Text(
            AppStrings.titleOs10,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),

          const SizedBox(height: AppDimensions.spacingSm),

          Text(
            'OS10 es la unidad de Carabineros que fiscaliza la seguridad '
            'privada en Chile. Para obtener o renovar tu credencial como '
            'guardia, debes aprobar el examen OS10 con nota 4.0 o superior.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),

          const SizedBox(height: AppDimensions.spacingXl),

          // --------------------------------------------------
          // Tarjetas de estadísticas
          // --------------------------------------------------
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.quiz_outlined,
                  label: 'Preguntas\ndisponibles',
                  value: _loading ? '—' : '$_totalQuestions',
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: _StatCard(
                  icon: Icons.emoji_events_outlined,
                  label: 'Mejor\npuntaje',
                  value: _bestScorePercent != null
                      ? '$_bestScorePercent%'
                      : '—',
                  color: _bestScorePercent != null &&
                          _bestScorePercent! >= 70
                      ? AppColors.success
                      : theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: _StatCard(
                  icon: Icons.history_outlined,
                  label: 'Intentos\nrealizados',
                  value: '${_history.length}',
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingXl),

          // --------------------------------------------------
          // Información del simulacro
          // --------------------------------------------------
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingMd),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cómo funciona el simulacro',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                const _BulletItem(
                    text: '30 segundos por pregunta — ¡administra tu tiempo!'),
                const _BulletItem(
                    text:
                        'Respuesta inmediata con explicación al contestar'),
                const _BulletItem(
                    text: '70% o más para aprobar (igual que el examen real)'),
                const _BulletItem(
                    text: 'Las preguntas se mezclan en cada intento'),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.spacingXl),

          // --------------------------------------------------
          // Botón principal: iniciar examen
          // --------------------------------------------------
          FilledButton.icon(
            onPressed: (_loading || _totalQuestions == 0) ? null : _startExam,
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(AppStrings.os10Start),
          ),

          const SizedBox(height: AppDimensions.spacingMd),

          // --------------------------------------------------
          // Botón secundario: ver historial
          // --------------------------------------------------
          OutlinedButton.icon(
            onPressed: _showHistory,
            icon: const Icon(Icons.history_rounded),
            label: const Text('Ver historial'),
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
// Widgets internos
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

/// Ítem de lista con viñeta
class _BulletItem extends StatelessWidget {
  final String text;

  const _BulletItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
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
    // Mostrar los más recientes primero
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
              final passed = percent >= 70;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: passed ? AppColors.success : AppColors.error,
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
