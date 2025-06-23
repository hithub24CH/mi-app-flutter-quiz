// lib/models/question_model.dart (LA SOLUCIÓN DEFINITIVA)

// =======================================================
// === ESTRUCTURA: Clase que define una Pregunta ===
// =======================================================
// Define cómo es un objeto 'Question' en nuestra aplicación.
class Question {
  // --- ESTRUCTURA: Propiedades del Modelo ---
  final String id;
  final String text;
  final List<String> options; // Una lista de strings para las opciones.
  final int correctAnswerIndex;

  // --- ESTRUCTURA: Constructor ---
  // El constructor estándar para crear un objeto 'Question' en el código.
  const Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
  });

  // =======================================================
  // === CORRECCIÓN CLAVE: Lógica de Conversión de JSON a Objeto ===
  // =======================================================
  // Este constructor convierte un mapa JSON en un objeto 'Question'.
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      text: json['text'] as String,
      // --- CORRECCIÓN DEFINITIVA Y ÚNICA: Conversión de Tipo Explícita ---
      // 'List<String>.from()' toma la lista del JSON (que es List<dynamic>)
      // y la convierte de forma segura en una List<String>, que es lo que
      // nuestro constructor espera. ESTO ARREGLA EL BUG DE "1 PREGUNTA".
      options: List<String>.from(json['options'] as List),
      correctAnswerIndex: json['correctAnswerIndex'] as int,
    );
  }
}
