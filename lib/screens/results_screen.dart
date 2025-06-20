// lib/screens/results_screen.dart

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/quiz_model.dart';
import '../models/question_model.dart';
import '../services/quiz_state_service.dart'; // Importa el servicio
import 'welcome_screen.dart';
import 'quiz_screen.dart'; // Importa la pantalla del quiz

class ResultsScreen extends StatelessWidget {
  final Quiz quiz;
  final Map<String, int> userAnswers;

  const ResultsScreen({
    super.key,
    required this.quiz,
    required this.userAnswers,
  });

  // Función para limpiar el estado y navegar
  Future<void> _resetAndNavigate(BuildContext context, Widget screen) async {
    // Limpiamos el estado guardado
    await QuizStateService().clearQuizState();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => screen),
        (Route<dynamic> route) => false,
      );
    }
  }

  String _getFeedbackMessage(double percentage) {
    if (percentage == 1.0) return "¡Perfecto! ¡Eres un experto!";
    if (percentage >= 0.8) return "¡Excelente trabajo!";
    if (percentage >= 0.5) return "¡Nada mal, sigue así!";
    return "¡Buen intento! ¡La práctica hace al maestro!";
  }

  @override
  Widget build(BuildContext context) {
    final int totalQuestions = quiz.questions.length;
    int score = 0;

    for (var question in quiz.questions) {
      if (userAnswers.containsKey(question.id) &&
          userAnswers[question.id] == question.correctAnswerIndex) {
        score++;
      }
    }

    final double percentage = totalQuestions > 0 ? score / totalQuestions : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados Finales'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _resetAndNavigate(context, const WelcomeScreen()),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _resetAndNavigate(context, QuizScreen(quiz: quiz)),
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text('Jugar de Nuevo',
                style: TextStyle(color: Colors.white)),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 24),
            CircularPercentIndicator(
              radius: 80.0,
              lineWidth: 15.0,
              percent: percentage,
              center: Text(
                "$score/$totalQuestions",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 24.0),
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: Colors.green,
              backgroundColor: Colors.grey.shade300,
            ).animate().fade(duration: 600.ms).scale(delay: 200.ms),
            const SizedBox(height: 20),
            Text(
              _getFeedbackMessage(percentage),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ).animate().fade(delay: 400.ms),
            const SizedBox(height: 12),
            const Divider(thickness: 1, indent: 20, endIndent: 20),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: quiz.questions.length,
                itemBuilder: (context, index) {
                  final Question question = quiz.questions[index];
                  final int? userAnswerIndex = userAnswers[question.id];
                  final bool isCorrect =
                      userAnswerIndex == question.correctAnswerIndex;

                  return Card(
                    elevation: 2,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isCorrect
                            ? Colors.green.shade200
                            : Colors.red.shade200,
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${index + 1}. ${question.text}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Respuesta correcta: ${question.options[question.correctAnswerIndex]}',
                            style: TextStyle(
                                color: Colors.green[700],
                                fontStyle: FontStyle.italic),
                          ),
                          if (!isCorrect)
                            Text(
                              'Tu respuesta: ${userAnswerIndex != null ? question.options[userAnswerIndex] : "No respondida"}',
                              style: TextStyle(
                                  color: Colors.red[700],
                                  fontStyle: FontStyle.italic),
                            ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: (600 + (index * 50)).ms).slideY(
                      begin: 0.5, duration: 400.ms, curve: Curves.easeOut);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
