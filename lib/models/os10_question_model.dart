// ============================================================
// os10_question_model.dart
// Modelo de pregunta Verdadero/Falso del simulador OS10.
// Mapea la tabla 'os10_questions' en Supabase.
//
// Las preguntas son afirmaciones sobre procedimientos, legislación
// y ética del guardia de seguridad. El usuario debe responder
// si la afirmación es Verdadera ('V') o Falsa ('F').
//
// NOTA: "OS10" siempre sin guión.
// ============================================================

/// Modelo de pregunta V/F del simulador OS10
class Os10QuestionModel {
  final String id;

  /// Enunciado de la afirmación a evaluar (columna 'question' en Supabase)
  final String question;

  /// Respuesta correcta: 'V' (Verdadero) o 'F' (Falso)
  final String correctAnswer;

  /// Categoría temática (Legislación, Procedimientos, Emergencias, etc.)
  final String? category;

  /// Explicación adicional de la respuesta correcta
  final String? explanation;

  const Os10QuestionModel({
    required this.id,
    required this.question,
    required this.correctAnswer,
    this.category,
    this.explanation,
  });

  /// Construye un [Os10QuestionModel] desde un mapa de Supabase
  factory Os10QuestionModel.fromMap(Map<String, dynamic> map) {
    return Os10QuestionModel(
      id: map['id'] as String,
      question: map['question'] as String? ?? '',
      correctAnswer: map['correct_answer'] as String? ?? 'V',
      category: map['category'] as String?,
      explanation: map['explanation'] as String?,
    );
  }

  /// Retorna true si [answer] ('V' o 'F') es la respuesta correcta
  bool isCorrect(String? answer) =>
      answer?.toUpperCase() == correctAnswer.toUpperCase();
}
