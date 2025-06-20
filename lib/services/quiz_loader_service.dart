// lib/services/quiz_loader_service.dart

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/quiz_model.dart';

class QuizLoaderService {
  // Esta función es asíncrona porque leer un archivo toma tiempo.
  // Devuelve un Future que eventualmente contendrá una lista de Quizzes.
  Future<List<Quiz>> loadQuizzes() async {
    try {
      // 1. Carga el contenido del archivo JSON como un string.
      final String response =
          await rootBundle.loadString('assets/quizzes.json');

      // 2. Decodifica el string JSON a una estructura de datos de Dart (en este caso, una Lista de Mapas).
      final List<dynamic> data = json.decode(response) as List<dynamic>;

      // 3. Mapea cada elemento de la lista a un objeto Quiz usando el constructor .fromJson que creamos.
      return data
          .map((quizJson) => Quiz.fromJson(quizJson as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Si algo sale mal (el archivo no existe, el JSON está mal formateado, etc.),
      // imprime el error en la consola y lanza una excepción para que FutureBuilder la maneje.
      print('Error al cargar los cuestionarios desde JSON: $e');
      throw Exception('No se pudo cargar el archivo de cuestionarios: $e');
    }
  }
}
