// lib/models/quiz_model.dart (VERSIÓN FINAL, EXPLÍCITA Y COMENTADA)

import 'question_model.dart';

// =======================================================
// === ESTRUCTURA: Clase Principal del Modelo 'Quiz' ===
// =======================================================
class Quiz {
  final String id;
  final String title;
  final String category;
  final String description;
  final List<Question> questions; // Una lista de objetos 'Question'.

  Quiz({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.questions,
  });

  // =======================================================
  // === CORRECCIÓN CLAVE: Lógica de Conversión de JSON a Objeto (Reescrita) ===
  // =======================================================
  // Este constructor ahora es explícito y a prueba de fallos para garantizar
  // que TODAS las preguntas se carguen correctamente.
  factory Quiz.fromJson(Map<String, dynamic> json) {
    // 1. Se crea una lista vacía para almacenar las preguntas convertidas.
    final List<Question> loadedQuestions = [];

    // 2. Se verifica que la clave 'questions' exista y sea una lista.
    if (json['questions'] != null && json['questions'] is List) {
      // 3. Se usa un bucle 'for' para recorrer cada elemento de la lista del JSON.
      //    Esta es la forma más directa y clara de procesar la lista.
      for (var questionJson in (json['questions'] as List)) {
        // 4. Por cada elemento, se convierte a un objeto Question y se añade a nuestra lista.
        loadedQuestions
            .add(Question.fromJson(questionJson as Map<String, dynamic>));
      }
    }

    // 5. Se crea y devuelve el objeto Quiz con la lista de preguntas completa.
    return Quiz(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      questions: loadedQuestions, // Se asigna la lista que hemos llenado.
    );
  }
}
