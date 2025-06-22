// lib/screens/results_screen.dart (UI ORIGINAL RESTAURADA Y COMENTADA)

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../models/quiz_model.dart';
import '../widgets/result_question_card.dart';

class ResultsScreen extends StatelessWidget {
  // --- ESTRUCTURA ORIGINAL: Recibe los datos del quiz finalizado ---
  final Quiz quiz;
  final List<int?> userAnswers;

  const ResultsScreen({
    super.key,
    required this.quiz,
    required this.userAnswers,
  });

  @override
  Widget build(BuildContext context) {
    // --- LÓGICA ORIGINAL: Se calculan los resultados aquí ---
    int score = 0;
    for (int i = 0; i < quiz.questions.length; i++) {
      if (userAnswers.length > i &&
          userAnswers[i] == quiz.questions[i].correctAnswerIndex) {
        score++;
      }
    }
    final totalQuestions = quiz.questions.length;
    final double percentage =
        totalQuestions > 0 ? (score / totalQuestions) : 0.0;

    String getResultMessage() {
      if (percentage >= 0.9) return "¡Excelente trabajo!";
      if (percentage >= 0.7) return "¡Muy bien hecho!";
      if (percentage >= 0.5) return "¡Buen esfuerzo!";
      return "¡Sigue estudiando!";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Resultados de "${quiz.title}"'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            tooltip: 'Jugar de Nuevo',
          ),
        ],
      ),
      body: Column(
        children: [
          // --- UI ORIGINAL RESTAURADA: Indicador de Porcentaje Circular ---
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: CircularPercentIndicator(
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
            ),
          ),
          // --- UI ORIGINAL RESTAURADA: Mensaje de resultado ---
          Text(
            getResultMessage(),
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Divider(),
          // --- ESTRUCTURA: Lista de resultados detallados ---
          Expanded(
            child: ListView.builder(
              itemCount: quiz.questions.length,
              itemBuilder: (context, index) {
                final question = quiz.questions[index];
                // Se añade una comprobación para evitar errores si la lista de respuestas es más corta
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
              },
            ),
          ),
        ],
      ),
    );
  }
}
