// modelo de cusestionario
// lib/models/quiz_model.dart
import 'question_model.dart';

class Quiz {
  final String id;
  final String
      title; // Título del cuestionario (ej: "Historia Universal", "Texto sobre IA")
  final String category; // <-- AÑADIR ESTA LÍNEA
  final String description; // Descripción del cuestionario
  final List<Question> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.questions,
  });

  // (Opcional) Factory para JSON
  factory Quiz.fromJson(Map<String, dynamic> json) {
    var questionsList = json['questions'] as List;
    List<Question> parsedQuestions =
        questionsList.map((qJson) => Question.fromJson(qJson)).toList();

    return Quiz(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String, // <-- AÑADIR ESTA LÍNEA
      description: json['description'] as String,
      questions: parsedQuestions,
    );
  }
}
