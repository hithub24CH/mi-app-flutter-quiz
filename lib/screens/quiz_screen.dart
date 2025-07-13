// lib/screens/quiz_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/quiz_model.dart';
import '../providers/quiz_provider.dart';
import 'results_screen.dart';

// El Wrapper del Provider y la lógica de estado (initState, etc.) no cambian.
// ...

class QuizScreen extends StatelessWidget {
  final Quiz quiz;
  const QuizScreen({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QuizProvider(quiz: quiz),
      child: const _QuizScreenView(),
    );
  }
}

class _QuizScreenView extends StatefulWidget {
  const _QuizScreenView();
  @override
  State<_QuizScreenView> createState() => _QuizScreenViewState();
}

class _QuizScreenViewState extends State<_QuizScreenView> {
  late final QuizProvider _quizProvider;

  @override
  void initState() {
    super.initState();
    _quizProvider = Provider.of<QuizProvider>(context, listen: false);
    _quizProvider.addListener(_onQuizStateChanged);
  }

  void _onQuizStateChanged() {
    if (_quizProvider.quizCompleted && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultsScreen(
            quiz: _quizProvider.quiz,
            userAnswers: _quizProvider.userAnswers,
            questionsPlayed: _quizProvider.questions,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _quizProvider.removeListener(_onQuizStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuizProvider>();
    final theme = Theme.of(context);
    final currentQuestion = provider.currentQuestion;

    return Scaffold(
      appBar: AppBar(
        title: Text(provider.quiz.title, overflow: TextOverflow.ellipsis),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: provider.timerProgress,
                    minHeight: 12,
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.secondary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tiempo: ${provider.tiempoRestante}s',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 16.0),
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Pregunta ${provider.currentQuestionIndex + 1} de ${provider.totalQuestions}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimary.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          currentQuestion.text,
                          textAlign: TextAlign.center,
                          // --- CORRECCIÓN FINAL ---
                          // Se ha eliminado 'const' de aquí
                          style: TextStyle(
                            fontSize: 19,
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate(key: ValueKey(currentQuestion.id))
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.1, end: 0),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10.0),
                  sliver: SliverList.builder(
                    itemCount: currentQuestion.options.length,
                    itemBuilder: (ctx, index) {
                      final optionBgColor =
                          _getOptionColor(provider, index, theme);
                      final optionIconData = _getOptionIcon(provider, index);
                      final bool isHighlighted = provider.isAnswered &&
                          (index ==
                                  provider.currentQuestion.correctAnswerIndex ||
                              index == provider.selectedOptionIndex);
                      final contentColor = isHighlighted
                          ? Colors.white
                          : theme.colorScheme.onSurface;

                      return Card(
                        color: optionBgColor,
                        margin: const EdgeInsets.symmetric(vertical: 6.0),
                        child: InkWell(
                          onTap: provider.isAnswered
                              ? null
                              : () => provider.answerQuestion(index),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 18.0),
                            child: Row(
                              children: [
                                Icon(optionIconData,
                                    color: contentColor, size: 26),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    currentQuestion.options[index],
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: contentColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24.0, top: 16.0),
                      child: Text(
                        'Puntuación: ${provider.score}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              theme.colorScheme.onBackground.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getOptionColor(
      QuizProvider provider, int optionIndex, ThemeData theme) {
    if (!provider.isAnswered) {
      return theme.cardTheme.color!;
    }
    if (optionIndex == provider.currentQuestion.correctAnswerIndex) {
      return Colors.green.shade500;
    }
    if (optionIndex == provider.selectedOptionIndex) {
      return Colors.red.shade500;
    }
    return theme.brightness == Brightness.dark
        ? theme.cardTheme.color!.withOpacity(0.5)
        : Colors.grey.shade300;
  }

  IconData _getOptionIcon(QuizProvider provider, int optionIndex) {
    if (!provider.isAnswered) return Icons.radio_button_unchecked;
    if (optionIndex == provider.currentQuestion.correctAnswerIndex)
      return Icons.check_circle;
    if (optionIndex == provider.selectedOptionIndex) return Icons.cancel;
    return Icons.radio_button_unchecked;
  }
}
