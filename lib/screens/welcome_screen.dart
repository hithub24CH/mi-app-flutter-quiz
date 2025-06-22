// lib/screens/welcome_screen.dart (RESTAURADO A TU ARQUITECTURA ORIGINAL Y COMENTADO)

import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../services/quiz_loader_service.dart';
import 'quiz_screen.dart';

// --- ESTRUCTURA: Pantalla de Bienvenida ---
// Carga y muestra la lista de quizzes disponibles.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  // --- ESTADO: Futuro que contendrá la lista de quizzes ---
  late Future<List<Quiz>> _quizzesFuture;

  @override
  void initState() {
    super.initState();
    // Inicia la carga de los quizzes desde el archivo JSON al crear la pantalla.
    _quizzesFuture = QuizLoaderService().loadQuizzes();
  }

  // --- ESTRUCTURA: Método de Navegación ---
  // Recibe un objeto Quiz y navega a la pantalla de juego, pasándole los datos.
  // Esta es tu arquitectura original, simple y segura.
  void _navigateToQuiz(Quiz quiz) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizScreen(quiz: quiz),
      ),
    );
  }

  // --- ESTRUCTURA: Método para crear el Mega Quiz ---
  // Combina las preguntas de todos los quizzes en uno solo.
  Quiz _createMegaQuiz(List<Quiz> allQuizzes) {
    final allQuestions = allQuizzes.expand((quiz) => quiz.questions).toList();
    allQuestions.shuffle(); // Baraja las preguntas para mayor rejugabilidad.
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
          // --- LÓGICA DE CARGA: Muestra un spinner mientras los datos cargan ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // --- LÓGICA DE ERROR: Muestra un mensaje si la carga falla ---
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar: ${snapshot.error}'));
          }
          // --- LÓGICA DE DATOS VACÍOS: Muestra un mensaje si no hay quizzes ---
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No se encontraron cuestionarios.'));
          }

          // --- CONSTRUCCIÓN DE LA UI: Muestra la pantalla principal ---
          final quizzes = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // --- ESTRUCTURA: Botón para el Mega Cuestionario ---
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
                // --- ESTRUCTURA: Botón para Resetear Progreso ---
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
                // --- ESTRUCTURA: Lista de Cuestionarios Individuales ---
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
