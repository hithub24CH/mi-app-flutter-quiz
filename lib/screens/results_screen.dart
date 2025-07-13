// lib/screens/results_screen.dart

//==============================================================================
// === IMPORTACIONES (Sin cambios) ===
//==============================================================================
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../models/quiz_model.dart';
import '../models/question_model.dart';
import '../widgets/result_question_card.dart';

//==============================================================================
// === DEFINICIÓN DE LA CLASE (Sin cambios en los parámetros) ===
//==============================================================================
class ResultsScreen extends StatelessWidget {
  final Quiz quiz;
  final List<int?> userAnswers;
  final List<Question> questionsPlayed;

  const ResultsScreen({
    super.key,
    required this.quiz,
    required this.userAnswers,
    required this.questionsPlayed,
  });

  @override
  Widget build(BuildContext context) {
    // --- Toda la lógica de cálculo de puntaje permanece igual ---
    int score = 0;
    for (int i = 0; i < questionsPlayed.length; i++) {
      if (userAnswers.length > i &&
          userAnswers[i] == questionsPlayed[i].correctAnswerIndex) {
        score++;
      }
    }

    final totalQuestions = questionsPlayed.length;
    final double percentage =
        totalQuestions > 0 ? (score / totalQuestions) : 0.0;

    String getResultMessage() {
      if (percentage >= 0.9) return "¡Excelente trabajo!";
      if (percentage >= 0.7) return "¡Muy bien hecho!";
      if (percentage >= 0.5) return "¡Buen esfuerzo!";
      return "¡Sigue practicando, la práctica hace al maestro!";
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        //======================================================================
        // ===> INICIO DE LA MODIFICACIÓN <===
        //======================================================================

        // 1. AÑADIMOS EL BOTÓN DE RETROCESO (LA FLECHA)
        // La propiedad `leading` coloca un widget al principio del AppBar.
        // Usamos un `IconButton` para crear un botón con un icono.
        leading: IconButton(
          // El icono estándar de flecha hacia atrás.
          icon: const Icon(Icons.arrow_back),
          // La acción que se ejecuta al presionar el botón.
          onPressed: () {
            // Esta es la parte clave. Usamos `popUntil` para cerrar todas las
            // pantallas (la de resultados y la del cuestionario) hasta llegar
            // a la primera pantalla de la aplicación, que es tu lista de
            // cuestionarios (`welcome_screen.dart`).
            // Esto asegura que el usuario no regrese a la pantalla del quiz
            // que acaba de terminar, sino a la lista principal.
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),

        // 2. HEMOS ELIMINADO LA LÍNEA `automaticallyImplyLeading: false`
        // Antes tenías esta línea que le decía a Flutter que no añadiera
        // una flecha de retroceso automáticamente. Al quitarla y añadir
        // nuestro propio `leading`, tomamos el control total.

        //======================================================================
        // ===> FIN DE LA MODIFICACIÓN <===
        //======================================================================

        // --- El resto del AppBar permanece sin cambios ---
        title: const Text('Resultados del Cuestionario'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        centerTitle: true,
      ),
      // El resto del widget permanece exactamente igual.
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        children: [
          // --- Parte 1: El Resumen (Círculo, Mensaje, Botón) ---
          CircularPercentIndicator(
            radius: 65.0,
            lineWidth: 12.0,
            percent: percentage,
            center: Text(
              "$score/$totalQuestions",
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: Colors.green,
            backgroundColor: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),

          Text(
            getResultMessage(),
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Jugar de Nuevo'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                // La acción de este botón es la misma que la de la nueva flecha.
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ),

          const Divider(height: 40, thickness: 1),

          // --- Parte 2: La Revisión de Respuestas ---
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Revisión de respuestas:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          ...questionsPlayed.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            final userAnswerIndex =
                userAnswers.length > index ? userAnswers[index] : -1;
            final bool isCorrect =
                userAnswerIndex == question.correctAnswerIndex;
            final int questionNumber = index + 1;

            return ResultQuestionCard(
              questionNumber: questionNumber,
              question: question,
              selectedAnswerIndex: userAnswerIndex,
              isCorrect: isCorrect,
            );
          }).toList(),
        ],
      ),
    );
  }
}
