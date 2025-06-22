// lib/services/quiz_loader_service.dart (COMPLETO Y COMENTADO)

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/quiz_model.dart';

// =======================================================
// === ESTRUCTURA: Servicio de Carga de Quizzes ===
// =======================================================
// Su única responsabilidad es leer y parsear el archivo JSON.
class QuizLoaderService {
  // --- FUNCIÓN: Cargar y Convertir los Quizzes ---
  // Es un 'Future' porque leer un archivo es una operación asíncrona.
  Future<List<Quiz>> loadQuizzes() async {
    // 1. Carga el contenido del archivo JSON como un String.
    final String jsonString =
        await rootBundle.loadString('assets/quizzes.json');

    // 2. Decodifica el String JSON en una lista dinámica de Dart.
    final List<dynamic> jsonList = json.decode(jsonString);

    // 3. Usa 'map' para recorrer la lista de quizzes del JSON.
    //    Por cada uno, llama a nuestro constructor 'Quiz.fromJson' (ahora corregido)
    //    para convertirlo en un objeto Quiz.
    //    Finalmente, '.toList()' lo convierte en la lista final de objetos Quiz.
    return jsonList
        .map((jsonItem) => Quiz.fromJson(jsonItem as Map<String, dynamic>))
        .toList();
  }
}
