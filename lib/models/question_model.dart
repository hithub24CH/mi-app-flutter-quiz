// Necesitamos definir cómo se estructurarán nuestras preguntas.
// lib/models/question_model.dart
class Question {
  final String id; // Útil si necesitas identificar preguntas específicas
  final String text; // El enunciado de la pregunta
  final List<String> options; // Lista de opciones de respuesta
  final int
  correctAnswerIndex; // El índice de la respuesta correcta en la lista 'options'

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
  });

  // (Opcional) Un constructor factory para crear una Question desde un Map (JSON)
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      text: json['text'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswerIndex: json['correctAnswerIndex'] as int,
    );
  }
}
