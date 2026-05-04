// ============================================================
// os10_results_screen.dart
// Pantalla de resultados del Simulador OS10.
// Muestra el puntaje final, mensaje de aprobación o reprobación,
// listado de preguntas con resultado, y botones de acción.
// ============================================================

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../models/os10_question_model.dart';

// Claves de almacenamiento local (deben coincidir con os10_screen.dart)
const String _keyBestScore = 'os10_best_score_percent';
const String _keyHistory = 'os10_exam_history';

/// Pantalla de resultados del examen OS10
class Os10ResultsScreen extends StatefulWidget {
  final List<Os10QuestionModel> questions;

  /// Respuestas del usuario: null = sin responder / tiempo agotado
  final List<String?> answers;

  const Os10ResultsScreen({
    super.key,
    required this.questions,
    required this.answers,
  });

  @override
  State<Os10ResultsScreen> createState() => _Os10ResultsScreenState();
}

class _Os10ResultsScreenState extends State<Os10ResultsScreen> {
  // ----------------------------------------------------------
  // Resultados calculados
  // ----------------------------------------------------------
  int _correct = 0;
  int _total = 0;
  int _percent = 0;
  bool _passed = false;

  @override
  void initState() {
    super.initState();
    _calculateAndSave();
  }

  // ----------------------------------------------------------
  // Calcula el puntaje y persiste en SharedPreferences
  // ----------------------------------------------------------

  Future<void> _calculateAndSave() async {
    final total = widget.questions.length;
    int correct = 0;
    for (int i = 0; i < total; i++) {
      if (widget.questions[i].isCorrect(widget.answers[i])) {
        correct++;
      }
    }
    final percent = total > 0 ? ((correct / total) * 100).round() : 0;
    final passed = percent >= 70;

    setState(() {
      _correct = correct;
      _total = total;
      _percent = percent;
      _passed = passed;
    });

    // Guardar en SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // Actualizar mejor puntaje si supera al anterior
    final bestScore = prefs.getInt(_keyBestScore) ?? 0;
    if (percent > bestScore) {
      await prefs.setInt(_keyBestScore, percent);
    }

    // Agregar entrada al historial
    final historyJson = prefs.getString(_keyHistory);
    List<Map<String, dynamic>> history = [];
    if (historyJson != null) {
      try {
        final decoded = jsonDecode(historyJson) as List;
        history = decoded.cast<Map<String, dynamic>>();
      } catch (_) {}
    }
    history.add({
      'percent': percent,
      'correct': correct,
      'total': total,
      'date': DateTime.now().toIso8601String(),
    });
    await prefs.setString(_keyHistory, jsonEncode(history));
  }

  // ----------------------------------------------------------
  // Acciones de navegación
  // ----------------------------------------------------------

  /// Retorna 'repeat' a Os10Screen para que inicie otro examen
  void _repeatExam() => Navigator.of(context).pop('repeat');

  /// Retorna normalmente (sin resultado) a Os10Screen
  void _goHome() => Navigator.of(context).pop();

  // ----------------------------------------------------------
  // Construcción del widget
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scoreColor = _passed ? AppColors.success : AppColors.error;
    final scoreMessage = _passed
        ? '¡Aprobado! Estás listo para el examen real.'
        : 'Necesitas seguir practicando. ¡Tú puedes!';
    final scoreIcon =
        _passed ? Icons.check_circle_rounded : Icons.cancel_rounded;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goHome();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(AppStrings.titleOs10),
        ),
        body: Column(
          children: [
            // --------------------------------------------------
            // Cabecera con resumen de puntaje
            // --------------------------------------------------
            Container(
              width: double.infinity,
              color: scoreColor.withValues(alpha: 0.08),
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.spacingLg,
                horizontal: AppDimensions.spacingMd,
              ),
              child: Column(
                children: [
                  Icon(scoreIcon, color: scoreColor, size: 56),
                  const SizedBox(height: AppDimensions.spacingSm),
                  Text(
                    '$_percent%',
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: scoreColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  Text(
                    '$_correct de $_total correctas',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                  Text(
                    scoreMessage,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scoreColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // --------------------------------------------------
            // Listado de preguntas con resultado individual
            // --------------------------------------------------
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppDimensions.spacingMd),
                // +1 para los botones de acción al final de la lista
                itemCount: widget.questions.length + 1,
                itemBuilder: (context, index) {
                  // Botones al final de la lista
                  if (index == widget.questions.length) {
                    return _ActionButtons(
                      onRepeat: _repeatExam,
                      onGoHome: _goHome,
                    );
                  }

                  final question = widget.questions[index];
                  final answer = widget.answers[index];
                  final isCorrect = question.isCorrect(answer);
                  final timedOut = answer == null;

                  return _QuestionResultTile(
                    number: index + 1,
                    question: question,
                    userAnswer: answer,
                    isCorrect: isCorrect,
                    timedOut: timedOut,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Widgets internos
// ============================================================

/// Tarjeta de resultado por pregunta individual
class _QuestionResultTile extends StatelessWidget {
  final int number;
  final Os10QuestionModel question;
  final String? userAnswer;
  final bool isCorrect;
  final bool timedOut;

  const _QuestionResultTile({
    required this.number,
    required this.question,
    required this.userAnswer,
    required this.isCorrect,
    required this.timedOut,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isCorrect ? AppColors.success : AppColors.error;
    final icon = isCorrect ? Icons.check_circle_outline : Icons.cancel_outlined;

    final String subtitle;
    if (timedOut) {
      subtitle = 'Tiempo agotado — Correcta: ${question.correctAnswer}';
    } else if (isCorrect) {
      subtitle = 'Correcta: ${question.correctAnswer}';
    } else {
      subtitle =
          'Tu respuesta: $userAnswer — Correcta: ${question.correctAnswer}';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Número de pregunta
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMd),

            // Texto de la pregunta y resultado
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.question,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.spacingSm),

            // Ícono de correcto / incorrecto
            Icon(icon, color: color, size: AppDimensions.iconSm + 4),
          ],
        ),
      ),
    );
  }
}

/// Botones de acción al final de la pantalla de resultados
class _ActionButtons extends StatelessWidget {
  final VoidCallback onRepeat;
  final VoidCallback onGoHome;

  const _ActionButtons({required this.onRepeat, required this.onGoHome});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppDimensions.spacingMd,
        bottom: AppDimensions.spacingXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            onPressed: onRepeat,
            icon: const Icon(Icons.replay_rounded),
            label: const Text('Repetir examen'),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          OutlinedButton.icon(
            onPressed: onGoHome,
            icon: const Icon(Icons.home_outlined),
            label: const Text('Volver al inicio'),
            style: OutlinedButton.styleFrom(
              minimumSize:
                  const Size(double.infinity, AppDimensions.inputHeight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
