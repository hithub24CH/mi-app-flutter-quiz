// lib/screens/welcome_screen.dart (TU UI ORIGINAL CON ARQUITECTURA MEJORADA)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz_model.dart';
import '../providers/quiz_provider.dart';
import '../services/quiz_loader_service.dart';
import 'quiz_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late Future<List<Quiz>> _quizzesFuture;

  @override
  void initState() {
    super.initState();
    _quizzesFuture = QuizLoaderService().loadQuizzes();
  }

  // --- MEJORA CLAVE: Método Centralizado de Navegación ---
  // Crea la "sesión de juego" con el Provider antes de navegar.
  // Esta es la solución a los cuelgues y errores de Provider.
  void _navigateToQuiz(Quiz quiz) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => QuizProvider(quiz: quiz),
          child: const QuizScreen(),
        ),
      ),
    );
  }

  // --- ESTRUCTURA: Creación del Mega Cuestionario ---
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
    return Scaffold(
      appBar: AppBar(title: const Text('Selecciona un Cuestionario')),
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
                // --- ESTRUCTURA: Botón Mega Cuestionario (Usa la nueva navegación) ---
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
                // --- ESTRUCTURA: Botón Resetear Progreso ---
                TextButton.icon(
                  icon: const Icon(Icons.delete_sweep, color: Colors.red),
                  label: const Text(
                    'Resetear Progreso Guardado',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Progreso reseteado (funcionalidad pendiente).')),
                    );
                  },
                ),
                const SizedBox(height: 20),
                // --- ESTRUCTURA: Lista de Cuestionarios (Usa la nueva navegación) ---
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
