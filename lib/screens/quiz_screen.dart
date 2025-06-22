// lib/screens/quiz_screen.dart (MEJORAS VISUALES Y DE LAYOUT)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/quiz_model.dart';
import '../providers/quiz_provider.dart';
import 'results_screen.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _quizProvider.addListener(_onQuizStateChanged);
    });
  }

  void _onQuizStateChanged() {
    if (_quizProvider.quizCompleted) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ResultsScreen(
              quiz: _quizProvider.quiz,
              userAnswers: _quizProvider.userAnswers,
            ),
          ),
        );
      }
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

    if (provider.isLoading) {
      return Scaffold(
          appBar: AppBar(title: Text(provider.quiz.title)),
          body: const Center(child: CircularProgressIndicator()));
    }

    if (provider.questions.isEmpty) {
      return Scaffold(
          appBar: AppBar(title: Text(provider.quiz.title)),
          body: const Center(
              child: Text('Este cuestionario no tiene preguntas.')));
    }

    final currentQuestion = provider.currentQuestion;

    return Scaffold(
      appBar: AppBar(
        title: Text(provider.quiz.title),
        automaticallyImplyLeading: !provider.isAnswered,
      ),
      // <-- CAMBIO 1: USAMOS UNA COLUMN COMO WIDGET PRINCIPAL
      body: Column(
        children: [
          // <-- CAMBIO 1: LA BARRA DE PROGRESO AHORA ESTÁ AQUÍ, FUERA DEL SCROLL
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: provider.progress,
                minHeight: 12, // <-- CAMBIO: BARRA MÁS DELGADA
                backgroundColor: Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
          ),
          // <-- CAMBIO 1: EL CUSTOMSCROLLVIEW AHORA OCUPA EL RESTO DEL ESPACIO
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Pregunta ${provider.currentQuestionIndex + 1}/${provider.totalQuestions}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.blueGrey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3)),
                            ],
                          ),
                          child: Text(
                            currentQuestion.text,
                            // <-- CAMBIO 2: TEXTO MÁS PEQUEÑO Y EN NEGRITA
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ).animate(key: ValueKey(currentQuestion.id)).flipH(
                              duration: 400.ms,
                              curve: Curves.easeOut,
                            ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverList.builder(
                    itemCount: currentQuestion.options.length,
                    itemBuilder: (ctx, index) {
                      final optionColor = _getOptionColor(provider, index);
                      final optionIcon = _getOptionIcon(provider, index);
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6.0),
                        color: optionColor,
                        child: InkWell(
                          onTap: provider.isAnswered
                              ? null
                              : () => provider.answerQuestion(index),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(
                                  optionIcon,
                                  color: (optionColor == Colors.grey[300]!)
                                      ? Colors.grey
                                      : Colors.white,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    currentQuestion.options[index],
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: (optionColor == Colors.grey[300]!)
                                          ? Colors.black87
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                          .animate(
                              key: ValueKey('${currentQuestion.id}_$index'))
                          .fadeIn(duration: 300.ms, delay: (150 * index).ms)
                          .slideX(
                              begin: 0.2,
                              duration: 300.ms,
                              curve: Curves.easeOut);
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      'Puntuación: ${provider.score}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge,
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

  Color _getOptionColor(QuizProvider provider, int optionIndex) {
    if (!provider.isAnswered) return Colors.grey[300]!;
    final currentQuestion = provider.currentQuestion;
    if (optionIndex == currentQuestion.correctAnswerIndex)
      return Colors.green.withOpacity(0.7);
    if (optionIndex == provider.selectedOptionIndex)
      return Colors.red.withOpacity(0.7);
    return Colors.grey[300]!;
  }

  IconData _getOptionIcon(QuizProvider provider, int optionIndex) {
    if (!provider.isAnswered) return Icons.radio_button_unchecked;
    final currentQuestion = provider.currentQuestion;
    if (optionIndex == currentQuestion.correctAnswerIndex)
      return Icons.check_circle;
    if (optionIndex == provider.selectedOptionIndex) return Icons.cancel;
    return Icons.radio_button_unchecked;
  }
}
