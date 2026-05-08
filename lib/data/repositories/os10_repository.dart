// ============================================================
// os10_repository.dart
// Repositorio del simulador OS10.
// ============================================================

import '../../models/os10_question_model.dart';
import '../services/os10_service.dart';

/// Repositorio del simulador OS10 de GGSS.cl
class Os10Repository {
  final Os10Service _os10Service;

  Os10Repository({Os10Service? os10Service})
      : _os10Service = os10Service ?? Os10Service();

  /// Retorna todas las preguntas OS10
  Future<List<Os10QuestionModel>> getAllQuestions() async {
    final data = await _os10Service.fetchAllQuestions();
    return data.map(Os10QuestionModel.fromMap).toList();
  }

}
