// lib/screens/results_screen.dart (VERSIÓN FINAL Y SIMPLIFICADA)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../widgets/result_question_card.dart';

class ResultsScreen extends StatelessWidget {
  // --- MEJORA ARQUITECTÓNICA: Constructor Simple ---
  // Ya no necesita recibir datos, los tomará del Provider.
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- MEJORA ARQUITECTÓNICA: Lectura Directa del Provider ---
    // Usamos context.read porque esta pantalla solo necesita leer el estado final.
    final provider = context.read<QuizProvider>();
    final score = provider.score;
    final totalQuestions = provider.totalQuestions;

    return Scaffold(
      appBar: AppBar(
        title: Text('Resultados de "${provider.quiz.title}"'),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '¡Obtuviste $score de $totalQuestions respuestas correctas!',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: provider.questions.length,
              itemBuilder: (context, index) {
                final question = provider.questions[index];
                final userAnswerIndex = provider.userAnswers[index];
                final bool isCorrect =
                    userAnswerIndex == question.correctAnswerIndex;
                final int questionNumber = index + 1;

                // --- CORRECCIÓN CLAVE: Llamada Correcta al Widget ---
                // Se pasan todos los parámetros que tu ResultQuestionCard espera.
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
