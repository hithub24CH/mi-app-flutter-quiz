// lib/providers/quiz_provider.dart (EL CEREBRO DEL QUIZ, COMPLETO Y COMENTADO)

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/quiz_model.dart';
import '../models/question_model.dart';

class QuizProvider extends ChangeNotifier {
  // =======================================================
  // === ESTRUCTURA: Propiedades del Estado del Quiz ===
  // =======================================================

  // --- DATOS INMUTABLES ---
  final Quiz quiz; // El quiz original que se está jugando.

  // --- ESTADO INTERNO DEL JUEGO ---
  final List<Question> questions; // La lista de preguntas, ya barajada.
  final List<int?> userAnswers =
      []; // Un registro de las respuestas del usuario.

  int currentQuestionIndex = 0; // Índice de la pregunta actual.
  int score = 0; // Puntuación acumulada.
  int? selectedOptionIndex; // La opción que el usuario acaba de seleccionar.
  bool _quizCompleted = false; // Bandera para saber si el quiz ha terminado.

  // --- ESTADO DEL TEMPORIZADOR ---
  static const int tiempoPorPregunta =
      15; // Tiempo fijo por pregunta (en segundos).
  Timer? _timer; // El objeto Timer que controla el paso del tiempo.
  int _tiempoRestante =
      tiempoPorPregunta; // Segundos restantes para la pregunta actual.

  // =======================================================
  // === ESTRUCTURA: Constructor ===
  // =======================================================

  // --- FUNCIÓN: Se ejecuta una sola vez al crear el Provider. ---
  QuizProvider({required this.quiz}) : questions = List.from(quiz.questions) {
    // 1. Copia y baraja las preguntas para que cada partida sea diferente.
    questions.shuffle();
    // 2. Inicia el temporizador para la primera pregunta.
    _iniciarTemporizador();
  }

  // =======================================================
  // === ESTRUCTURA: Getters (Atajos para la UI) ===
  // =======================================================

  // --- FUNCIÓN: Proveen acceso de solo lectura a propiedades calculadas o privadas. ---
  int get tiempoRestante => _tiempoRestante;
  double get timerProgress =>
      _tiempoRestante > 0 ? _tiempoRestante / tiempoPorPregunta : 0;
  bool get quizCompleted => _quizCompleted;
  Question get currentQuestion => questions[currentQuestionIndex];
  int get totalQuestions => questions.length;
  bool get isAnswered => selectedOptionIndex != null;

  // =======================================================
  // === ESTRUCTURA: Métodos Privados (Lógica Interna) ===
  // =======================================================

  // --- MEJORA CLAVE: Método de Sonido "A Prueba de Fallos" ---
  // Se encarga únicamente de reproducir un sonido y manejar posibles errores.
  Future<void> _playSound(String soundFile) async {
    try {
      // --- MEJORA: Usa un reproductor temporal para efectos de sonido cortos. ---
      // Es la forma más segura de evitar conflictos y problemas de caché.
      await AudioPlayer().play(AssetSource('sounds/$soundFile'));
    } catch (e) {
      // Si el archivo no se encuentra, la app no se colgará.
      // Imprime el error en la consola para que el desarrollador lo sepa.
      debugPrint(
          "Error al reproducir el sonido (ignorado para no colgar la app): $e");
    }
  }

  // --- MEJORA: Lógica del Temporizador. ---
  // Inicia un temporizador que se repite cada segundo.
  void _iniciarTemporizador() {
    _tiempoRestante = tiempoPorPregunta;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_tiempoRestante > 0) {
        _tiempoRestante--;
      } else {
        // Si el tiempo llega a 0, llama a answerQuestion como si el usuario
        // hubiera respondido una opción inválida (-1).
        answerQuestion(-1);
      }
      // Notifica a la UI que el tiempo ha cambiado para que se actualice la barra.
      notifyListeners();
    });
  }

  // Detiene el temporizador actual para que no siga corriendo.
  void _detenerTemporizador() {
    _timer?.cancel();
  }

  // Avanza a la siguiente pregunta o finaliza el quiz.
  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      currentQuestionIndex++;
      selectedOptionIndex = null;
      notifyListeners(); // Notifica a la UI que muestre la nueva pregunta.
      _iniciarTemporizador(); // Inicia el temporizador para la nueva pregunta.
    } else {
      _quizCompleted = true; // Marca el quiz como completado.
      notifyListeners(); // Notifica a QuizScreen para que navegue a la pantalla de resultados.
    }
  }

  // =======================================================
  // === ESTRUCTURA: Métodos Públicos (Acciones del Usuario) ===
  // =======================================================

  // --- FUNCIÓN: Se llama cuando el usuario toca una opción o se acaba el tiempo. ---
  void answerQuestion(int optionIndex) {
    if (isAnswered) return; // Evita que se pueda responder dos veces.

    _detenerTemporizador();
    selectedOptionIndex = optionIndex;

    // Comprueba si la respuesta es correcta y reproduce el sonido correspondiente.
    if (optionIndex == currentQuestion.correctAnswerIndex) {
      score++;
      // --- CORRECCIÓN CLAVE: Nombres y extensiones de archivo correctos ---
      _playSound('correct_answer.mp3');
    } else {
      _playSound('wrong_answer.mp3');
    }

    userAnswers.add(optionIndex); // Guarda la respuesta del usuario.
    notifyListeners(); // Notifica a la UI para que muestre el feedback (colores verde/rojo).

    // Espera 2 segundos antes de pasar a la siguiente pregunta.
    Future.delayed(const Duration(seconds: 2), _nextQuestion);
  }

  // =======================================================
  // === ESTRUCTURA: Limpieza del Provider ===
  // =======================================================

  // --- FUNCIÓN: Se llama automáticamente cuando el Provider ya no se necesita. ---
  @override
  void dispose() {
    // Es crucial detener el temporizador para evitar fugas de memoria (memory leaks).
    _detenerTemporizador();
    super.dispose();
  }
}
