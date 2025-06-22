// lib/screens/quiz_screen.dart (VERSIÓN FINAL, COMPLETA Y COMENTADA)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/quiz_model.dart';
import '../providers/quiz_provider.dart';
import 'results_screen.dart';

// =======================================================
// === ESTRUCTURA: Widget de Entrada (Stateless) ===
// =======================================================
// Su única responsabilidad es recibir el 'quiz' desde WelcomeScreen
// y crear el Provider para la sesión de juego.
class QuizScreen extends StatelessWidget {
  final Quiz quiz;
  const QuizScreen({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    // --- ESTRUCTURA: Creación del Provider ---
    // El Provider se crea y vive únicamente mientras esta pantalla exista.
    // Esta es tu arquitectura original, que es simple y segura para este caso.
    return ChangeNotifierProvider(
      create: (_) => QuizProvider(quiz: quiz),
      child:
          const _QuizScreenView(), // Llama a la vista interna que tiene el estado.
    );
  }
}

// =======================================================
// === ESTRUCTURA: Widget de la Vista (Stateful) ===
// =======================================================
// Necesita ser StatefulWidget para poder usar initState y dispose,
// que son cruciales para manejar el listener del Provider de forma segura y evitar cuelgues.
class _QuizScreenView extends StatefulWidget {
  const _QuizScreenView();
  @override
  State<_QuizScreenView> createState() => _QuizScreenViewState();
}

class _QuizScreenViewState extends State<_QuizScreenView> {
  // --- CORRECCIÓN ANTI-CUELGUE (1/3): Referencia Segura al Provider ---
  // Se declara una variable final que guardará la instancia del provider
  // para poder usarla en dispose() sin depender del 'context'.
  late final QuizProvider _quizProvider;

  @override
  void initState() {
    super.initState();
    // --- CORRECCIÓN ANTI-CUELGUE (2/3): Inicialización Segura ---
    // Obtenemos la referencia al provider UNA SOLA VEZ, usando listen: false.
    // Esto se hace ANTES de que el widget pueda ser destruido, por lo que es seguro.
    _quizProvider = Provider.of<QuizProvider>(context, listen: false);
    // Se añade el listener usando la referencia segura que acabamos de obtener.
    _quizProvider.addListener(_onQuizStateChanged);
  }

  // --- ESTRUCTURA: Controlador de Finalización del Quiz ---
  // Este método es llamado por el listener cuando el quiz termina.
  void _onQuizStateChanged() {
    // --- CORRECCIÓN CLAVE: Navegación Manual de Datos ---
    // Cuando el quiz se completa, pasamos los resultados a la siguiente pantalla
    // a través de su constructor. Esto evita el ProviderNotFoundException.
    // 'mounted' confirma que el widget todavía está en el árbol visual antes de navegar.
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
    // --- CORRECCIÓN ANTI-CUELGUE (3/3): Limpieza Segura ---
    // Se quita el listener usando la referencia _quizProvider.
    // Esto NO usa 'context' y es la forma 100% segura de evitar el cuelgue.
    _quizProvider.removeListener(_onQuizStateChanged);
    super.dispose();
  }

  // =======================================================
  // === ESTRUCTURA: Construcción de la Interfaz de Usuario ===
  // =======================================================
  @override
  Widget build(BuildContext context) {
    // 'context.watch' se suscribe a los cambios del provider para reconstruir la UI.
    final provider = context.watch<QuizProvider>();
    final theme = Theme.of(context);
    final currentQuestion = provider.currentQuestion;

    return Scaffold(
      appBar: AppBar(
        title: Text(provider.quiz.title),
        automaticallyImplyLeading: !provider.isAnswered,
      ),
      // --- ESTRUCTURA: Layout Principal (Fijo + Desplazable) ---
      // Una Column permite tener una parte fija arriba (el timer) y una parte
      // que ocupa el resto del espacio (la lista de preguntas).
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                // --- ESTRUCTURA: Barra de Progreso del Temporizador ---
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
          // --- ESTRUCTURA: Cuerpo Desplazable del Quiz ---
          // Expanded asegura que el CustomScrollView ocupe todo el espacio restante.
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
                          style: theme.textTheme.titleMedium
                              ?.copyWith(color: Colors.blueGrey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        // --- ESTRUCTURA: Contenedor de la Pregunta ---
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
                            // --- MEJORA: Tamaño de fuente de la pregunta ajustado ---
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
                // --- ESTRUCTURA: Lista de Opciones (SliverList) ---
                // Se usa SliverList porque es la forma eficiente de tener una lista
                // dentro de un CustomScrollView.
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
                                    // --- MEJORA: Tamaño de fuente de las opciones ajustado ---
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 16,
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
                      );
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

  // =======================================================
  // === ESTRUCTURA: Métodos Helper para la UI ===
  // =======================================================
  // Estos métodos determinan el color y el icono de cada opción de respuesta
  // basándose en si el usuario ya ha respondido o no.
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
