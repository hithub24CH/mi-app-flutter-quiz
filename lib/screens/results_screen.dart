//==============================================================================
// === IMPORTACIONES ===
//==============================================================================
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart'; // Para el indicador circular de porcentaje.
import '../models/quiz_model.dart'; // Necesita el modelo 'Quiz' para entender los datos que recibe.
import '../widgets/result_question_card.dart'; // Importa el widget reutilizable para mostrar cada pregunta/respuesta.

//==============================================================================
// === DEFINICIÓN DE LA CLASE ===
//==============================================================================
// Es un 'StatelessWidget' porque una vez que se dibuja con los datos recibidos,
// no necesita cambiar su propio estado interno.
class ResultsScreen extends StatelessWidget {
  //============================================================================
  // === DATOS DE ENTRADA (Recibidos desde QuizScreen) ===
  //============================================================================
  // El objeto Quiz original. Lo necesita para acceder al texto de las preguntas y las respuestas correctas.
  final Quiz quiz;
  // La lista de respuestas que dio el usuario.
  final List<int?> userAnswers;

  // El constructor que recibe los datos cuando se navega a esta pantalla.
  const ResultsScreen({
    super.key,
    required this.quiz,
    required this.userAnswers,
  });

  @override
  Widget build(BuildContext context) {
    //==========================================================================
    // === LÓGICA DE CÁLCULO (Se ejecuta dentro del build) ===
    //==========================================================================
    // Se calculan los resultados aquí mismo porque son datos de presentación
    // que no necesitan ser gestionados en un provider separado.
    int score = 0;
    // Itera sobre todas las preguntas del quiz original.
    for (int i = 0; i < quiz.questions.length; i++) {
      // Compara la respuesta del usuario con la respuesta correcta para esa pregunta.
      if (userAnswers.length > i && // Verificación de seguridad
          userAnswers[i] == quiz.questions[i].correctAnswerIndex) {
        score++; // Incrementa la puntuación si coinciden.
      }
    }
    final totalQuestions = quiz.questions.length;
    final double percentage =
        totalQuestions > 0 ? (score / totalQuestions) : 0.0;

    // Función local para obtener un mensaje de ánimo basado en el porcentaje.
    String getResultMessage() {
      if (percentage >= 0.9) return "¡Excelente trabajo!";
      if (percentage >= 0.7) return "¡Muy bien hecho!";
      if (percentage >= 0.5) return "¡Buen esfuerzo!";
      return "¡Sigue practicando, la práctica hace al maestro!";
    }

    //==========================================================================
    // === CONSTRUCCIÓN DE LA INTERFAZ DE USUARIO ===
    //==========================================================================
    return Scaffold(
      appBar: AppBar(
        title: Text('Resultados de "${quiz.title}"'),
        actions: [
          // Botón para reiniciar el juego.
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // ¡ACCIÓN DE NAVEGACIÓN!
              // 'popUntil' cierra todas las pantallas de la pila de navegación
              // hasta que encuentra la primera (WelcomeScreen). Es la forma más
              // limpia de volver al inicio.
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            tooltip: 'Jugar de Nuevo',
          ),
        ],
      ),
      body: Column(
        children: [
          //--- WIDGET DE INDICADOR DE PORCENTAJE ---
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: CircularPercentIndicator(
              radius: 80.0,
              lineWidth: 15.0,
              percent: percentage, // Usa el porcentaje calculado.
              center: Text(
                "$score/$totalQuestions", // Muestra la puntuación calculada.
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 24.0),
              ),
              // ... Estilos del indicador ...
            ),
          ),
          //--- MENSAJE DE RESULTADO ---
          Text(
            getResultMessage(), // Muestra el mensaje de ánimo.
            // ...
          ),
          const SizedBox(height: 10),
          const Divider(),
          //--- LISTA DETALLADA DE PREGUNTAS Y RESPUESTAS ---
          Expanded(
            child: ListView.builder(
              itemCount:
                  quiz.questions.length, // Una tarjeta por cada pregunta.
              itemBuilder: (context, index) {
                // Para cada pregunta, recopila toda la información necesaria.
                final question = quiz.questions[index];
                final userAnswerIndex =
                    userAnswers.length > index ? userAnswers[index] : -1;
                final bool isCorrect =
                    userAnswerIndex == question.correctAnswerIndex;
                final int questionNumber = index + 1;

                // ¡REUTILIZACIÓN DE WIDGETS!
                // En lugar de definir la tarjeta aquí, se usa un widget separado
                // (ResultQuestionCard) para mantener el código limpio y organizado.
                // Se le pasan todos los datos que necesita para dibujarse.
                return ResultQuestionCard(
                  questionNumber: questionNumber,
                  question: question,
                  selectedAnswerIndex: userAnswerIndex,
                  isCorrect: isCorrect,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
