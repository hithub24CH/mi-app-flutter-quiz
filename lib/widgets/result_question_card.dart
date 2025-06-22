// lib/widgets/result_question_card.dart (UI ORIGINAL RESTAURADA Y COMENTADA)

import 'package:flutter/material.dart';
import '../models/question_model.dart';

class ResultQuestionCard extends StatelessWidget {
  final int questionNumber;
  final Question question;
  final int? selectedAnswerIndex;
  final bool isCorrect;

  const ResultQuestionCard({
    super.key,
    required this.questionNumber,
    required this.question,
    required this.selectedAnswerIndex,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        // --- UI ORIGINAL RESTAURADA: Borde de color para feedback ---
        side: BorderSide(
            color: isCorrect ? Colors.green : Colors.red, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        // --- UI ORIGINAL RESTAURADA: Layout con Row ---
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- UI ORIGINAL RESTAURADA: El "Redondito" ---
            CircleAvatar(
              radius: 15,
              backgroundColor: isCorrect ? Colors.green : Colors.red,
              child: Text(
                questionNumber.toString(),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.text,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  // --- UI MEJORADA: Muestra la respuesta correcta siempre ---
                  Text.rich(
                    TextSpan(children: [
                      const TextSpan(
                          text: 'Respuesta correcta: ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green)),
                      TextSpan(
                          text: question.options[question.correctAnswerIndex]),
                    ]),
                    style: const TextStyle(fontSize: 14, color: Colors.green),
                  ),
                  // --- UI MEJORADA: Muestra la respuesta del usuario si fue incorrecta ---
                  if (!isCorrect) ...[
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(children: [
                        const TextSpan(
                            text: 'Tu respuesta: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red)),
                        TextSpan(
                            text: selectedAnswerIndex == -1 ||
                                    selectedAnswerIndex == null
                                ? 'No respondida'
                                : question.options[selectedAnswerIndex!]),
                      ]),
                      style: const TextStyle(fontSize: 14, color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
