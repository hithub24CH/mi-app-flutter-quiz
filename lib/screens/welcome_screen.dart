// lib/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../models/question_model.dart';
import '../services/quiz_loader_service.dart';
import '../services/quiz_state_service.dart';
import 'quiz_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late Future<List<Quiz>> _quizzesFuture;
  final QuizLoaderService _loader = QuizLoaderService();
  final QuizStateService _stateService = QuizStateService();

  @override
  void initState() {
    super.initState();
    _quizzesFuture = _loader.loadQuizzes();
  }

  void _resetProgress() async {
    final bool? shouldReset = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Resetear Progreso'),
        content: const Text(
            '¿Estás seguro de que quieres borrar el progreso de cualquier cuestionario no terminado?'),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Resetear')),
        ],
      ),
    );
    if (shouldReset == true) {
      await _stateService.clearQuizState();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('¡Progreso reseteado!'),
              backgroundColor: Colors.green),
        );
      }
    }
  }

  void _startQuiz(BuildContext context, Quiz selectedQuiz) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => QuizScreen(quiz: selectedQuiz)),
    );
  }

  // --- NUEVA FUNCIÓN para agrupar los cuestionarios ---
  Map<String, List<Quiz>> _groupQuizzesByCategory(List<Quiz> quizzes) {
    final Map<String, List<Quiz>> groupedQuizzes = {};
    for (var quiz in quizzes) {
      (groupedQuizzes[quiz.category] ??= []).add(quiz);
    }
    return groupedQuizzes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona un Cuestionario'),
        // El botón de reset se mueve al cuerpo de la pantalla
      ),
      body: FutureBuilder<List<Quiz>>(
        future: _quizzesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child:
                    Text('Error al cargar cuestionarios: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No se encontraron cuestionarios.'));
          }

          final quizzes = snapshot.data!;
          final groupedQuizzes = _groupQuizzesByCategory(quizzes);
          final categories = groupedQuizzes.keys.toList();

          void startMegaQuiz() {
            List<Question> allQuestions = [];
            for (var quiz in quizzes) {
              allQuestions.addAll(quiz.questions);
            }
            final megaQuiz = Quiz(
              id: 'mega_quiz_general',
              title: 'Mega Cuestionario General',
              category: 'General',
              description: 'Una mezcla de todas las preguntas disponibles.',
              questions: allQuestions,
            );
            _startQuiz(context, megaQuiz);
          }

          // Usamos un ListView para permitir el scroll
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.all_inclusive),
                  label: const Text('Iniciar Mega Cuestionario'),
                  onPressed: startMegaQuiz,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

              // --- BOTÓN DE RESET REUBICADO ---
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: TextButton.icon(
                  icon: const Icon(Icons.delete_sweep, size: 20),
                  label: const Text('Resetear Progreso Guardado'),
                  onPressed: _resetProgress,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                  ),
                ),
              ),
              const Divider(height: 20, indent: 16, endIndent: 16),

              // --- NUEVA LISTA AGRUPADA ---
              ...categories.expand((category) {
                final quizzesInCategory = groupedQuizzes[category]!;
                return [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      category,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                  ),
                  ...quizzesInCategory.map((quiz) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 4.0),
                      child: Card(
                        elevation: 3,
                        child: ListTile(
                          title: Text(quiz.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(quiz.description),
                          onTap: () => _startQuiz(context, quiz),
                        ),
                      ),
                    );
                  }).toList(),
                ];
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
