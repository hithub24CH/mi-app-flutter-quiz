// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart'; // Importa tu pantalla de bienvenida

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.indigo, // Puedes cambiar el color primario
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.grey[100], // Un color de fondo suave
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor:
              Colors.white, // Color del texto y los iconos en la AppBar
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber[700], // Color de los botones elevados
            foregroundColor:
                Colors.white, // Color del texto de los botones elevados
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
      ),
      home: const WelcomeScreen(), // Nuestra pantalla de inicio
      // (Más adelante podríamos definir rutas aquí para una navegación más compleja)
      // routes: {
      //   WelcomeScreen.routeName: (ctx) => WelcomeScreen(),
      //   QuizScreen.routeName: (ctx) => QuizScreen(),
      //   ResultsScreen.routeName: (ctx) => ResultsScreen(),
      // },
    );
  }
}
