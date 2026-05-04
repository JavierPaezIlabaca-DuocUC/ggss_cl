// ============================================================
// os10_question_model.dart
// Modelo de pregunta del simulador OS10.
// NOTA: "OS10" siempre sin guión.
// ============================================================

/// Modelo de pregunta del simulador OS10
class Os10QuestionModel {
  final String id;

  /// Texto de la pregunta
  final String questionText;

  /// Lista de 4 alternativas de respuesta
  final List<String> options;

  /// Índice de la opción correcta (0-3)
  final int correctOptionIndex;

  /// Explicación de la respuesta correcta (opcional)
  final String? explanation;

  const Os10QuestionModel({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    this.explanation,
  });

  factory Os10QuestionModel.fromMap(Map<String, dynamic> map) {
    // Las opciones se guardan como columnas individuales en Supabase:
    // option_a, option_b, option_c, option_d
    final options = [
      map['option_a'] as String? ?? '',
      map['option_b'] as String? ?? '',
      map['option_c'] as String? ?? '',
      map['option_d'] as String? ?? '',
    ];

    return Os10QuestionModel(
      id: map['id'] as String,
      questionText: map['question_text'] as String? ?? '',
      options: options,
      correctOptionIndex: map['correct_option_index'] as int? ?? 0,
      explanation: map['explanation'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question_text': questionText,
      'option_a': options.isNotEmpty ? options[0] : '',
      'option_b': options.length > 1 ? options[1] : '',
      'option_c': options.length > 2 ? options[2] : '',
      'option_d': options.length > 3 ? options[3] : '',
      'correct_option_index': correctOptionIndex,
      'explanation': explanation,
    };
  }
}
