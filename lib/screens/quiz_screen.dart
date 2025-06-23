//==============================================================================
// === IMPORTACIONES ===
// Objetivo: Traer las herramientas y "planos" necesarios para esta pantalla.
//==============================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/quiz_model.dart';
import '../providers/quiz_provider.dart';
import 'results_screen.dart';

//==============================================================================
// === WIDGET DE ENTRADA (Wrapper) ===
// Objetivo: Preparar el entorno para la pantalla de juego.
//==============================================================================
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

//==============================================================================
// === WIDGET DE LA VISTA (El que dibuja y tiene lógica de ciclo de vida) ===
// Objetivo: Dibujar la UI y reaccionar a eventos del ciclo de vida.
//==============================================================================
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

  // --- CONSTRUCCIÓN DE LA INTERFAZ DE USUARIO ---
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuizProvider>();
    final theme = Theme.of(context);
    final currentQuestion = provider.currentQuestion;

    return Scaffold(
      appBar: AppBar(
        title: Text(provider.quiz.title),
        automaticallyImplyLeading: !provider.isAnswered,
      ),
      body: Column(
        children: [
          //--- SECCIÓN DEL TEMPORIZADOR ---
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
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      provider.timerProgress > 0.5
                          ? Colors.green
                          : provider.timerProgress > 0.2
                              ? Colors.orange
                              : Colors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tiempo: ${provider.tiempoRestante}s',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          //--- SECCIÓN PRINCIPAL CON SCROLL ---
          Expanded(
            child: CustomScrollView(
              slivers: [
                //--- Widget para el texto de la pregunta ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Pregunta ${provider.currentQuestionIndex + 1}/${provider.totalQuestions}',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(color: Colors.blueGrey),
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
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
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
                //--- Widget para la lista de opciones ---
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
                                  // El widget que contiene el texto de la opción.
                                  child: Text(
                                    currentQuestion.options[index],
                                    // El estilo se aplica aquí.
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 16,
                                      // El color del texto es reactivo para garantizar la legibilidad.
                                      // Si el fondo es gris claro (sin responder), el texto es negro.
                                      // Si el fondo tiene color (verde/rojo), el texto es blanco.
                                      color: (optionColor == Colors.grey[300]!)
                                          ? Colors.black87
                                          : Colors.white,
                                    ),
                                  ),
                                ), // Cierre del Expanded
                              ], // Cierre de la lista de children del Row
                            ), // Cierre del Padding
                          ), // Cierre del InkWell
                        ), // Cierre del Card
                      ); // Cierre del return del itemBuilder
                    }, // Cierre del itemBuilder
                  ), // Cierre del SliverList.builder
                ), // Cierre del SliverPadding
                //--- Widget para la puntuación ---
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
              ], // Cierre de la lista de slivers
            ), // Cierre del CustomScrollView
          ), // Cierre del Expanded
        ], // Cierre de la lista de children de Column
      ), // Cierre del Scaffold
    ); // Cierre del return del build
  }

  //============================================================================
  // === MÉTODOS DE AYUDA (Helper Methods) para la UI ===
  //============================================================================
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
