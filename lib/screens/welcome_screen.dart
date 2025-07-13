//==============================================================================
// === IMPORTACIONES ===
// Objetivo: Traer las herramientas y "planos" necesarios para esta pantalla.
//==============================================================================
import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../services/quiz_loader_service.dart';
import 'quiz_screen.dart';

//==============================================================================
// === DEFINICIÓN DEL WIDGET ===
// Objetivo: Crear la estructura base de la pantalla de bienvenida.
//==============================================================================
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

//==============================================================================
// === CLASE DE ESTADO (_WelcomeScreenState) ===
// Objetivo: Manejar los datos cambiantes y la lógica de la pantalla.
//==============================================================================
class _WelcomeScreenState extends State<WelcomeScreen> {
  late Future<List<Quiz>> _quizzesFuture;

  @override
  void initState() {
    super.initState();
    _quizzesFuture = QuizLoaderService().loadQuizzes();
  }

  void _navigateToQuiz(Quiz quiz) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizScreen(quiz: quiz),
      ),
    );
  }

  Quiz _createMegaQuiz(List<Quiz> allQuizzes) {
    final allQuestions = allQuizzes.expand((quiz) => quiz.questions).toList();
    allQuestions.shuffle();
    return Quiz(
      id: 'mega_quiz',
      title: 'Mega Cuestionario',
      category: 'Todas las categorías',
      description: 'Un desafío con preguntas de todos los cuestionarios.',
      questions: allQuestions,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el tema del contexto para usar sus colores.
    final theme = Theme.of(context);

    return Scaffold(
      //========================================================================
      // === MEJORA: APLICANDO EL COLOR DEL TEMA AL APPBAR ===
      // Le decimos explícitamente al AppBar que use los colores del tema global
      // definido en main.dart, asegurando una apariencia consistente.
      //========================================================================
      appBar: AppBar(
        title: const Text('Selecciona un Cuestionario'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Quiz>>(
        future: _quizzesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No se encontraron cuestionarios.'));
          }
          final quizzes = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.all_inclusive),
                  label: const Text('Iniciar Mega Cuestionario'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    final megaQuiz = _createMegaQuiz(quizzes);
                    _navigateToQuiz(megaQuiz);
                  },
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  icon: const Icon(Icons.delete_sweep, color: Colors.red),
                  label: const Text('Resetear Progreso Guardado',
                      style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Progreso reseteado (funcionalidad pendiente).')),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: quizzes.length,
                    itemBuilder: (context, index) {
                      final quiz = quizzes[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(quiz.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${quiz.questions.length} preguntas'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            _navigateToQuiz(quiz);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
