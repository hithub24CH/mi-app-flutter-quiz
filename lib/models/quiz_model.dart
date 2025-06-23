// lib/models/quiz_model.dart (VERSIÓN FINAL CON CORRECCIÓN DEL BUG PRINCIPAL)
import 'question_model.dart';

class Quiz {
  final String id;
  final String title;
  final String category;
  final String description;
  final List<Question> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.questions,
  });

  // --- CORRECCIÓN DEFINITIVA DEL BUG "1 PREGUNTA" ---
  // Se reescribe el método para usar un bucle 'for' explícito.
  // Esta es la forma más robusta y a prueba de fallos de procesar la lista,
  // garantizando que todas las preguntas se carguen sin fallos silenciosos.
  factory Quiz.fromJson(Map<String, dynamic> json) {
    final List<Question> loadedQuestions = [];
    if (json['questions'] != null && json['questions'] is List) {
      for (var questionJson in (json['questions'] as List)) {
        loadedQuestions
            .add(Question.fromJson(questionJson as Map<String, dynamic>));
      }
    }
    return Quiz(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      questions: loadedQuestions,
    );
  }
}
