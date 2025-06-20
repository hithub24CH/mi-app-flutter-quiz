// lib/widgets/result_question_card.dart
import 'package:flutter/material.dart';
import '../models/question_model.dart';

class ResultQuestionCard extends StatelessWidget {
  final Question question;
  final int? selectedAnswerIndex;
  final bool isCorrect;
  final int questionNumber;

  const ResultQuestionCard({
    super.key,
    required this.question,
    this.selectedAnswerIndex,
    required this.isCorrect,
    required this.questionNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pregunta $questionNumber: ${question.text}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ..._buildOptions(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOptions(BuildContext context) {
    return List.generate(question.options.length, (index) {
      Color color = Theme.of(context).cardColor;
      IconData? icon;

      if (index == question.correctAnswerIndex) {
        color = Colors.green.withOpacity(0.2);
        icon = Icons.check_circle;
      }

      if (index == selectedAnswerIndex && !isCorrect) {
        color = Colors.red.withOpacity(0.2);
        icon = Icons.cancel;
      }

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: index == selectedAnswerIndex
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: (index == question.correctAnswerIndex)
                    ? Colors.green
                    : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                question.options[index],
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      );
    });
  }
}
