// lib/services/quiz_state_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class QuizStateService {
  // Es una excelente práctica tener la clave como una constante para evitar errores de tipeo.
  static const String _quizStateKey = 'quiz_state';

  // Guarda el estado actual del quiz en las preferencias del dispositivo.
  Future<void> saveQuizState({
    required String quizId,
    required int currentQuestionIndex,
    required int score,
    required Map<String, int> userAnswers,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final stateData = jsonEncode({
      'quizId': quizId,
      'currentQuestionIndex': currentQuestionIndex,
      'score': score,
      'userAnswers': userAnswers,
    });
    await prefs.setString(_quizStateKey, stateData);
  }

  // Carga el estado guardado del quiz desde las preferencias.
  Future<Map<String, dynamic>?> loadQuizState() async {
    final prefs = await SharedPreferences.getInstance();
    final stateData = prefs.getString(_quizStateKey);
    if (stateData != null) {
      return jsonDecode(stateData) as Map<String, dynamic>;
    }
    return null;
  }

  // Borra el estado guardado del quiz.
  // ESTA ES LA ÚNICA Y CORRECTA VERSIÓN DEL MÉTODO.
  Future<void> clearQuizState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_quizStateKey);
  }
}
