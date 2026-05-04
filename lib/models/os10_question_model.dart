// ============================================================
// os10_question_model.dart
// Modelo de pregunta del simulador OS10.
// Mapea exactamente la tabla 'os10_questions' en Supabase.
// NOTA: "OS10" siempre sin guión.
// ============================================================

/// Modelo de pregunta del simulador OS10
class Os10QuestionModel {
  final String id;

  /// Texto de la pregunta (columna 'question' en Supabase)
  final String question;

  /// Las cuatro alternativas: [A, B, C, D]
  final List<String> options;

  /// Letra de la respuesta correcta: "A", "B", "C" o "D"
  final String correctAnswer;

  /// Categoría temática de la pregunta (Legislación, Funciones, etc.)
  final String? category;

  /// Explicación de la respuesta correcta
  final String? explanation;

  const Os10QuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.category,
    this.explanation,
  });

  /// Construye un [Os10QuestionModel] desde un mapa de Supabase
  factory Os10QuestionModel.fromMap(Map<String, dynamic> map) {
    return Os10QuestionModel(
      id: map['id'] as String,
      question: map['question'] as String? ?? '',
      options: [
        map['option_a'] as String? ?? '',
        map['option_b'] as String? ?? '',
        map['option_c'] as String? ?? '',
        map['option_d'] as String? ?? '',
      ],
      correctAnswer: map['correct_answer'] as String? ?? 'A',
      category: map['category'] as String?,
      explanation: map['explanation'] as String?,
    );
  }

  /// Índice (0-3) de la respuesta correcta derivado de la letra
  int get correctOptionIndex {
    switch (correctAnswer.toUpperCase()) {
      case 'B':
        return 1;
      case 'C':
        return 2;
      case 'D':
        return 3;
      default:
        return 0;
    }
  }

  /// Retorna true si [answer] es la letra correcta
  bool isCorrect(String? answer) =>
      answer?.toUpperCase() == correctAnswer.toUpperCase();
}
