// ============================================================
// os10_question_screen.dart
// Pantalla de examen del Simulador OS10.
// Muestra una pregunta a la vez con timer de 30 segundos,
// feedback inmediato de respuesta y avance secuencial.
// ============================================================

import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../data/repositories/os10_repository.dart';
import '../../models/os10_question_model.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'os10_results_screen.dart';

/// Duración del timer por pregunta en segundos
const int _timerSeconds = 30;

/// Pantalla del examen OS10 (pushed sobre el shell)
class Os10QuestionScreen extends StatefulWidget {
  const Os10QuestionScreen({super.key});

  @override
  State<Os10QuestionScreen> createState() => _Os10QuestionScreenState();
}

class _Os10QuestionScreenState extends State<Os10QuestionScreen> {
  // ----------------------------------------------------------
  // Estado de carga
  // ----------------------------------------------------------
  List<Os10QuestionModel>? _questions;
  bool _loading = true;
  bool _hasError = false;

  // ----------------------------------------------------------
  // Estado del examen
  // ----------------------------------------------------------
  int _currentIndex = 0;

  /// Respuestas del usuario: null = sin responder / tiempo agotado
  late List<String?> _selectedAnswers;

  /// true cuando el usuario respondió o el tiempo se agotó
  bool _showFeedback = false;

  // ----------------------------------------------------------
  // Estado del timer
  // ----------------------------------------------------------
  Timer? _timer;
  int _secondsLeft = _timerSeconds;

  // ----------------------------------------------------------
  // Ciclo de vida
  // ----------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ----------------------------------------------------------
  // Carga y mezcla las preguntas desde Supabase
  // ----------------------------------------------------------

  Future<void> _loadQuestions() async {
    try {
      final questions = await Os10Repository().getAllQuestions();
      questions.shuffle(); // orden aleatorio en cada intento
      if (!mounted) return;
      setState(() {
        _questions = questions;
        _selectedAnswers = List.filled(questions.length, null);
        _loading = false;
      });
      _startTimer();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _hasError = true;
      });
    }
  }

  // ----------------------------------------------------------
  // Timer: 30 segundos por pregunta
  // ----------------------------------------------------------

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _timerSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        _timer?.cancel();
        _onTimeUp();
      }
    });
  }

  void _onTimeUp() {
    // Sin respuesta seleccionada (null = incorrecto por tiempo)
    setState(() => _showFeedback = true);
  }

  // ----------------------------------------------------------
  // Selección de respuesta por el usuario
  // ----------------------------------------------------------

  void _selectAnswer(String letter) {
    if (_showFeedback) return; // ya respondida
    _timer?.cancel();
    setState(() {
      _selectedAnswers[_currentIndex] = letter;
      _showFeedback = true;
    });
  }

  // ----------------------------------------------------------
  // Avanza a la siguiente pregunta o va a resultados
  // ----------------------------------------------------------

  void _nextQuestion() {
    final questions = _questions!;
    if (_currentIndex >= questions.length - 1) {
      // Última pregunta: ir a resultados
      _goToResults();
      return;
    }
    setState(() {
      _currentIndex++;
      _showFeedback = false;
    });
    _startTimer();
  }

  void _goToResults() {
    _timer?.cancel();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => Os10ResultsScreen(
          questions: _questions!,
          answers: _selectedAnswers,
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // Diálogo de confirmación para abandonar el examen
  // ----------------------------------------------------------

  Future<void> _confirmExit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Abandonar examen'),
        content: const Text(
          '¿Seguro que quieres salir? Tu progreso se perderá.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(AppStrings.actionCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  // ----------------------------------------------------------
  // Construcción del widget
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Estado de carga
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.titleOs10)),
        body: const LoadingIndicator(),
      );
    }

    // Estado de error
    if (_hasError || _questions == null || _questions!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.titleOs10)),
        body: AppErrorWidget(
          message: _questions?.isEmpty == true
              ? AppStrings.os10NoQuestions
              : AppStrings.errorGeneral,
          onRetry: () {
            setState(() {
              _loading = true;
              _hasError = false;
            });
            _loadQuestions();
          },
        ),
      );
    }

    final question = _questions![_currentIndex];
    final total = _questions!.length;
    final isLastQuestion = _currentIndex == total - 1;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
        appBar: AppBar(
          // Botón de salida con confirmación
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _confirmExit,
          ),
          title: Text(
            '${AppStrings.os10Question} ${_currentIndex + 1} '
            '${AppStrings.os10Of} $total',
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(6),
            child: _TimerBar(
              secondsLeft: _secondsLeft,
              total: _timerSeconds,
            ),
          ),
        ),
        body: Column(
          children: [
            // --------------------------------------------------
            // Barra de progreso del examen
            // --------------------------------------------------
            LinearProgressIndicator(
              value: (_currentIndex + 1) / total,
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(
                Theme.of(context).colorScheme.primary,
              ),
            ),

            // --------------------------------------------------
            // Contenido scrolleable
            // --------------------------------------------------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categoría (si existe)
                    if (question.category != null) ...[
                      Chip(
                        label: Text(
                          question.category!,
                          style: const TextStyle(fontSize: 12),
                        ),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1),
                      ),
                      const SizedBox(height: AppDimensions.spacingSm),
                    ],

                    // ------------------------------------------
                    // Texto de la pregunta
                    // ------------------------------------------
                    Text(
                      question.question,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            height: 1.5,
                          ),
                    ),

                    const SizedBox(height: AppDimensions.spacingLg),

                    // ------------------------------------------
                    // Tarjetas de respuesta (A, B, C, D)
                    // ------------------------------------------
                    ...['A', 'B', 'C', 'D'].asMap().entries.map((entry) {
                      final index = entry.key;
                      final letter = entry.value;
                      final optionText = question.options[index];

                      return _AnswerCard(
                        letter: letter,
                        text: optionText,
                        state: _showFeedback
                            ? _getAnswerState(letter, question)
                            : AnswerState.neutral,
                        onTap: _showFeedback
                            ? null
                            : () => _selectAnswer(letter),
                      );
                    }),

                    // ------------------------------------------
                    // Feedback: tiempo agotado o respuesta incorrecta
                    // ------------------------------------------
                    if (_showFeedback &&
                        _selectedAnswers[_currentIndex] == null) ...[
                      const SizedBox(height: AppDimensions.spacingMd),
                      _FeedbackBanner(
                        isCorrect: false,
                        message: '⏱ Tiempo agotado — '
                            'La respuesta correcta era '
                            '${question.correctAnswer}',
                      ),
                    ],

                    // ------------------------------------------
                    // Explicación (si hay feedback y existe texto)
                    // ------------------------------------------
                    if (_showFeedback &&
                        question.explanation != null &&
                        question.explanation!.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.spacingMd),
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.spacingMd),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.06),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMd),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              size: AppDimensions.iconSm + 2,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: AppDimensions.spacingSm),
                            Expanded(
                              child: Text(
                                question.explanation!,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: AppDimensions.spacingXl),

                    // ------------------------------------------
                    // Botón "Siguiente" / "Ver resultados"
                    // ------------------------------------------
                    if (_showFeedback)
                      FilledButton(
                        onPressed: _nextQuestion,
                        child: Text(
                          isLastQuestion ? 'Ver resultados' : 'Siguiente',
                        ),
                      ),

                    const SizedBox(height: AppDimensions.spacingXl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // Determina el estado visual de cada tarjeta de respuesta
  // ----------------------------------------------------------

  AnswerState _getAnswerState(
      String letter, Os10QuestionModel question) {
    final selected = _selectedAnswers[_currentIndex];
    final isCorrect = question.isCorrect(letter);

    if (isCorrect) return AnswerState.correct;
    if (letter == selected) return AnswerState.wrong;
    return AnswerState.neutral;
  }
}

// ============================================================
// Widgets internos
// ============================================================

/// Estado visual de una tarjeta de respuesta
enum AnswerState { neutral, correct, wrong }

/// Tarjeta de opción de respuesta
class _AnswerCard extends StatelessWidget {
  final String letter;
  final String text;
  final AnswerState state;
  final VoidCallback? onTap;

  const _AnswerCard({
    required this.letter,
    required this.text,
    required this.state,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color borderColor;
    Color textColor;

    switch (state) {
      case AnswerState.correct:
        backgroundColor = AppColors.success.withValues(alpha: 0.12);
        borderColor = AppColors.success;
        textColor = AppColors.success;
      case AnswerState.wrong:
        backgroundColor = AppColors.error.withValues(alpha: 0.12);
        borderColor = AppColors.error;
        textColor = AppColors.error;
      case AnswerState.neutral:
        backgroundColor = Colors.transparent;
        borderColor = theme.dividerTheme.color ?? AppColors.divider;
        textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
            vertical: AppDimensions.spacingMd,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              // Letra de la alternativa (A, B, C, D)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: borderColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    letter,
                    style: TextStyle(
                      color: borderColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              // Texto de la alternativa
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
                ),
              ),
              // Ícono de estado
              if (state == AnswerState.correct)
                Icon(Icons.check_circle_outline,
                    color: AppColors.success,
                    size: AppDimensions.iconSm + 4),
              if (state == AnswerState.wrong)
                Icon(Icons.cancel_outlined,
                    color: AppColors.error, size: AppDimensions.iconSm + 4),
            ],
          ),
        ),
      ),
    );
  }
}

/// Banner de feedback (tiempo agotado / incorrecto sin selección)
class _FeedbackBanner extends StatelessWidget {
  final bool isCorrect;
  final String message;

  const _FeedbackBanner({required this.isCorrect, required this.message});

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        message,
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Barra de timer bajo el AppBar (varía de verde → naranja → rojo)
class _TimerBar extends StatelessWidget {
  final int secondsLeft;
  final int total;

  const _TimerBar({required this.secondsLeft, required this.total});

  @override
  Widget build(BuildContext context) {
    final ratio = secondsLeft / total;
    final Color color;
    if (ratio > 0.5) {
      color = AppColors.success;
    } else if (ratio > 0.25) {
      color = AppColors.warning;
    } else {
      color = AppColors.error;
    }

    return SizedBox(
      height: 4,
      child: LinearProgressIndicator(
        value: ratio.clamp(0.0, 1.0),
        backgroundColor: color.withValues(alpha: 0.2),
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
}
