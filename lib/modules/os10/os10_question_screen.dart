// ============================================================
// os10_question_screen.dart
// Pantalla de examen del Simulador OS10 — formato Verdadero/Falso.
//
// Características principales:
//   - Temporizador global (no por pregunta): cuenta regresiva MM:SS
//     visible en el AppBar. Al llegar a 0, el examen se envía
//     automáticamente con las preguntas sin responder marcadas
//     como null (incorrectas).
//   - Dos tarjetas grandes: VERDADERO (verde) y FALSO (rojo).
//     Al responder se muestra retroalimentación inmediata.
//   - Botón de pausa: guarda el estado en SharedPreferences y
//     regresa a Os10Screen mostrando el banner de reanudación.
//   - AppLifecycleObserver: pausa el timer cuando la app va al
//     fondo y lo reanuda al volver.
//   - Reanudación: si resumeFromSaved = true, carga el estado
//     guardado desde SharedPreferences.
// ============================================================

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../data/repositories/os10_repository.dart';
import '../../models/os10_question_model.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'os10_providers.dart';
import 'os10_results_screen.dart';

// ============================================================
// Constantes internas
// ============================================================

/// Modalidad Tradicional: 50 preguntas, 60 minutos
const int kOs10TraditionalCount = 50;
const int kOs10TraditionalSeconds = 60 * 60; // 3 600 segundos

/// Modalidad Express: 25 preguntas, 30 minutos
const int kOs10ExpressCount = 25;
const int kOs10ExpressSeconds = 30 * 60; // 1 800 segundos

// ============================================================
// Pantalla principal del examen OS10
// ============================================================

/// Pantalla del examen OS10 (pushed sobre el shell).
///
/// [questionCount]   — número de preguntas de la modalidad elegida.
/// [timeLimitSeconds]— tiempo total del examen en segundos.
/// [resumeFromSaved] — si true, retoma el examen pausado guardado.
class Os10QuestionScreen extends ConsumerStatefulWidget {
  final int questionCount;
  final int timeLimitSeconds;
  final bool resumeFromSaved;

  const Os10QuestionScreen({
    super.key,
    this.questionCount = kOs10TraditionalCount,
    this.timeLimitSeconds = kOs10TraditionalSeconds,
    this.resumeFromSaved = false,
  });

  @override
  ConsumerState<Os10QuestionScreen> createState() =>
      _Os10QuestionScreenState();
}

class _Os10QuestionScreenState extends ConsumerState<Os10QuestionScreen>
    with WidgetsBindingObserver {
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

  /// true cuando el usuario respondió para la pregunta actual
  bool _showFeedback = false;

  // ----------------------------------------------------------
  // Estado del temporizador global
  // ----------------------------------------------------------
  Timer? _timer;
  late int _secondsLeft;
  bool _timerRunning = false;

  // ----------------------------------------------------------
  // Ciclo de vida
  // ----------------------------------------------------------

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _secondsLeft = widget.timeLimitSeconds;
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ----------------------------------------------------------
  // AppLifecycle: pausa el timer cuando la app va al fondo
  // ----------------------------------------------------------

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _pauseTimer();
    } else if (state == AppLifecycleState.resumed && _timerRunning) {
      _resumeTimer();
    }
  }

  // ----------------------------------------------------------
  // Carga y mezcla las preguntas desde Supabase
  // ----------------------------------------------------------

  Future<void> _loadQuestions() async {
    try {
      final allQuestions = await Os10Repository().getAllQuestions();
      if (!mounted) return;

      List<Os10QuestionModel> questions = [];
      List<String?> answers = [];
      int startIndex = 0;
      int secondsLeft = widget.timeLimitSeconds;

      if (widget.resumeFromSaved) {
        // --------------------------------------------------
        // Intentar restaurar el examen pausado
        // --------------------------------------------------
        final prefs = await SharedPreferences.getInstance();
        final savedJson = prefs.getString(kOs10KeySavedExam);
        bool restored = false;

        if (savedJson != null) {
          try {
            final saved = jsonDecode(savedJson) as Map<String, dynamic>;
            final savedIds = (saved['question_ids'] as List).cast<String>();
            final savedAnswers =
                (saved['answers'] as List).cast<String?>();
            final savedIndex = saved['current_index'] as int? ?? 0;
            final savedSeconds = saved['seconds_left'] as int? ?? widget.timeLimitSeconds;

            // Reconstruir la lista de preguntas en el orden guardado
            final questionMap = {for (var q in allQuestions) q.id: q};
            final restoredQuestions = savedIds
                .map((id) => questionMap[id])
                .whereType<Os10QuestionModel>()
                .toList();

            // Validar que se recuperaron todas las preguntas
            if (restoredQuestions.length == savedIds.length &&
                savedAnswers.length == savedIds.length) {
              questions = restoredQuestions;
              answers = List<String?>.from(savedAnswers);
              startIndex = savedIndex.clamp(0, questions.length - 1);
              secondsLeft = savedSeconds.clamp(1, widget.timeLimitSeconds);
              restored = true;
            }
          } catch (_) {
            // Estado corrupto: iniciar examen nuevo
          }
        }

        if (!restored) {
          // No se pudo restaurar — iniciar examen nuevo con misma modalidad
          allQuestions.shuffle();
          questions = allQuestions.take(widget.questionCount).toList();
          answers = List.filled(questions.length, null);
        }
      } else {
        // --------------------------------------------------
        // Examen nuevo: mezclar y tomar las preguntas de la modalidad
        // --------------------------------------------------
        allQuestions.shuffle();
        questions = allQuestions.take(widget.questionCount).toList();
        answers = List.filled(questions.length, null);
      }

      if (!mounted) return;
      setState(() {
        _questions = questions;
        _selectedAnswers = answers;
        _currentIndex = startIndex;
        _secondsLeft = secondsLeft;
        _loading = false;
        // Si la pregunta actual ya fue respondida, mostrar feedback
        _showFeedback = answers[startIndex] != null;
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
  // Control del temporizador global
  // ----------------------------------------------------------

  void _startTimer() {
    _timer?.cancel();
    _timerRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        _timer?.cancel();
        _timerRunning = false;
        _onTimeUp();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _timerRunning = false;
  }

  void _resumeTimer() {
    if (_secondsLeft > 0) {
      _startTimer();
    }
  }

  /// Tiempo agotado: auto-enviar con respuestas pendientes como null
  void _onTimeUp() {
    if (!mounted) return;
    _goToResults();
  }

  // ----------------------------------------------------------
  // Formato del tiempo restante como MM:SS
  // ----------------------------------------------------------

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Color del timer según el tiempo restante (verde → naranja → rojo)
  Color _timerColor(BuildContext context) {
    final ratio = _secondsLeft / widget.timeLimitSeconds;
    if (ratio > 0.5) return AppColors.success;
    if (ratio > 0.2) return AppColors.warning;
    return AppColors.error;
  }

  // ----------------------------------------------------------
  // Selección de respuesta: V (Verdadero) o F (Falso)
  // ----------------------------------------------------------

  void _selectAnswer(String answer) {
    if (_showFeedback) return; // pregunta ya respondida
    setState(() {
      _selectedAnswers[_currentIndex] = answer;
      _showFeedback = true;
    });
  }

  // ----------------------------------------------------------
  // Avanza a la siguiente pregunta o va a resultados
  // ----------------------------------------------------------

  void _nextQuestion() {
    final questions = _questions!;
    if (_currentIndex >= questions.length - 1) {
      _goToResults();
      return;
    }
    setState(() {
      _currentIndex++;
      _showFeedback = _selectedAnswers[_currentIndex] != null;
    });
  }

  void _goToResults() {
    _timer?.cancel();
    _timerRunning = false;
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
  // Pausar el examen: guardar estado y volver a Os10Screen
  // ----------------------------------------------------------

  Future<void> _showPauseDialog() async {
    _pauseTimer();
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Pausar examen'),
        content: const Text(
          'Tu progreso se guardará. Puedes retomar el examen '
          'desde la pantalla principal cuando quieras.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Continuar examen'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Pausar y guardar'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (confirmed == true) {
      await _saveExamState();
      if (mounted) Navigator.of(context).pop();
    } else {
      // El usuario eligió continuar: reanudar el timer
      _resumeTimer();
    }
  }

  /// Guarda el estado actual del examen en SharedPreferences
  Future<void> _saveExamState() async {
    final questions = _questions;
    if (questions == null) return;

    final examData = {
      'question_ids': questions.map((q) => q.id).toList(),
      'answers': _selectedAnswers,
      'current_index': _currentIndex,
      'seconds_left': _secondsLeft,
      'question_count': widget.questionCount,
      'time_limit_seconds': widget.timeLimitSeconds,
    };

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kOs10KeySavedExam, jsonEncode(examData));

    // Notificar al proveedor para que Os10Screen muestre el banner
    if (mounted) {
      ref.read(os10StatsProvider.notifier).refresh();
    }
  }

  // ----------------------------------------------------------
  // Diálogo de confirmación para abandonar sin guardar
  // ----------------------------------------------------------

  Future<void> _confirmExit() async {
    _pauseTimer();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Abandonar examen'),
        content: const Text(
          '¿Seguro que quieres salir? Tu progreso actual se perderá.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(AppStrings.actionCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Salir sin guardar'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (confirmed == true) {
      Navigator.of(context).pop();
    } else {
      _resumeTimer();
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
    final timerColor = _timerColor(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
        appBar: AppBar(
          // Botón de salida sin guardar
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Salir sin guardar',
            onPressed: _confirmExit,
          ),
          title: Text(
            '${AppStrings.os10Question} ${_currentIndex + 1} '
            '${AppStrings.os10Of} $total',
          ),
          actions: [
            // Temporizador global MM:SS
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingSm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: timerColor.withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusSm),
                  border: Border.all(
                    color: timerColor.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: AppDimensions.iconSm,
                      color: timerColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(_secondsLeft),
                      style: TextStyle(
                        color: timerColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Botón de pausa
            IconButton(
              icon: const Icon(Icons.pause_circle_outline),
              tooltip: 'Pausar y guardar',
              onPressed: _showPauseDialog,
            ),
          ],
        ),
        body: Column(
          children: [
            // --------------------------------------------------
            // Barra de progreso del examen (pregunta X de N)
            // --------------------------------------------------
            LinearProgressIndicator(
              value: (_currentIndex + 1) / total,
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(
                Theme.of(context).colorScheme.primary,
              ),
              minHeight: 3,
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
                    // Chip de categoría (si existe)
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
                    // Enunciado de la afirmación
                    // ------------------------------------------
                    Text(
                      question.question,
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                height: 1.5,
                              ),
                    ),

                    const SizedBox(height: AppDimensions.spacingXl),

                    // ------------------------------------------
                    // Tarjetas V/F: VERDADERO y FALSO en fila
                    // ------------------------------------------
                    Row(
                      children: [
                        // Tarjeta VERDADERO
                        Expanded(
                          child: _VFCard(
                            label: 'Verdadero',
                            icon: Icons.check_circle_outline,
                            answer: 'V',
                            cardState: _showFeedback
                                ? _getCardState('V', question)
                                : _VFCardState.neutral,
                            onTap: _showFeedback
                                ? null
                                : () => _selectAnswer('V'),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingMd),
                        // Tarjeta FALSO
                        Expanded(
                          child: _VFCard(
                            label: 'Falso',
                            icon: Icons.cancel_outlined,
                            answer: 'F',
                            cardState: _showFeedback
                                ? _getCardState('F', question)
                                : _VFCardState.neutral,
                            onTap: _showFeedback
                                ? null
                                : () => _selectAnswer('F'),
                          ),
                        ),
                      ],
                    ),

                    // ------------------------------------------
                    // Feedback: correcta / incorrecta
                    // ------------------------------------------
                    if (_showFeedback) ...[
                      const SizedBox(height: AppDimensions.spacingMd),
                      _buildFeedbackRow(question),
                    ],

                    // ------------------------------------------
                    // Explicación (si existe)
                    // ------------------------------------------
                    if (_showFeedback &&
                        question.explanation != null &&
                        question.explanation!.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.spacingMd),
                      Container(
                        padding:
                            const EdgeInsets.all(AppDimensions.spacingMd),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMd),
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
                              color:
                                  Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: AppDimensions.spacingSm),
                            Expanded(
                              child: Text(
                                question.explanation!,
                                style:
                                    Theme.of(context).textTheme.bodySmall,
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
  // Determina el estado visual de cada tarjeta V/F tras responder
  // ----------------------------------------------------------

  _VFCardState _getCardState(
      String cardAnswer, Os10QuestionModel question) {
    final selected = _selectedAnswers[_currentIndex];
    final isCorrectCard = question.correctAnswer == cardAnswer;

    if (isCorrectCard) return _VFCardState.correct;
    if (cardAnswer == selected && !question.isCorrect(selected)) {
      return _VFCardState.wrong;
    }
    return _VFCardState.dimmed;
  }

  // ----------------------------------------------------------
  // Banner de feedback tras responder
  // ----------------------------------------------------------

  Widget _buildFeedbackRow(Os10QuestionModel question) {
    final answer = _selectedAnswers[_currentIndex];
    final isCorrect = question.isCorrect(answer);
    final color = isCorrect ? AppColors.success : AppColors.error;
    final icon = isCorrect ? Icons.check_circle : Icons.cancel;
    final label = isCorrect ? '¡Correcto!' : 'Incorrecto';
    final correctLabel =
        question.correctAnswer == 'V' ? 'VERDADERO' : 'FALSO';

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: AppDimensions.iconMd),
          const SizedBox(width: AppDimensions.spacingSm),
          Expanded(
            child: Text(
              isCorrect
                  ? '$label La afirmación es $correctLabel.'
                  : '$label La afirmación es $correctLabel.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Widget: Tarjeta V/F grande
// ============================================================

/// Estado visual de una tarjeta Verdadero/Falso
enum _VFCardState {
  /// Sin responder — aspecto neutro
  neutral,

  /// Esta tarjeta es la correcta (verde)
  correct,

  /// Esta tarjeta fue seleccionada y era incorrecta (rojo)
  wrong,

  /// No seleccionada y no es la correcta (opacada)
  dimmed,
}

/// Tarjeta grande de respuesta Verdadero o Falso
class _VFCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final String answer; // 'V' o 'F'
  final _VFCardState cardState;
  final VoidCallback? onTap;

  const _VFCard({
    required this.label,
    required this.icon,
    required this.answer,
    required this.cardState,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isVerdadero = answer == 'V';

    // Colores base según el tipo de tarjeta (verde=V, rojo=F)
    final baseColor = isVerdadero ? AppColors.success : AppColors.error;

    Color backgroundColor;
    Color borderColor;
    Color iconColor;
    Color labelColor;
    double opacity = 1.0;

    switch (cardState) {
      case _VFCardState.correct:
        backgroundColor = baseColor.withValues(alpha: 0.18);
        borderColor = baseColor;
        iconColor = baseColor;
        labelColor = baseColor;
      case _VFCardState.wrong:
        backgroundColor = baseColor.withValues(alpha: 0.18);
        borderColor = baseColor;
        iconColor = baseColor;
        labelColor = baseColor;
      case _VFCardState.dimmed:
        backgroundColor = Colors.transparent;
        borderColor =
            Theme.of(context).dividerTheme.color ?? AppColors.divider;
        iconColor = Theme.of(context).disabledColor;
        labelColor = Theme.of(context).disabledColor;
        opacity = 0.45;
      case _VFCardState.neutral:
        backgroundColor = baseColor.withValues(alpha: 0.06);
        borderColor = baseColor.withValues(alpha: 0.5);
        iconColor = baseColor;
        labelColor = baseColor;
    }

    return Opacity(
      opacity: opacity,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 120,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 40),
              const SizedBox(height: AppDimensions.spacingXs),
              Text(
                label,
                style: TextStyle(
                  color: labelColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              // Indicador de selección correcta/incorrecta
              if (cardState == _VFCardState.correct)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.check_circle,
                    color: baseColor,
                    size: AppDimensions.iconSm,
                  ),
                ),
              if (cardState == _VFCardState.wrong)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.cancel,
                    color: baseColor,
                    size: AppDimensions.iconSm,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
