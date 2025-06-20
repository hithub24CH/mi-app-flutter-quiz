// lib/main.dart

import 'package:flutter/material.dart';
import 'package:quiz_app_flutter/screens/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz App',

      // --- TEMA GLOBAL DE LA APLICACIÓN ---
      theme: ThemeData(
        // Paleta de colores principal basada en un color "semilla".
        // Flutter generará tonos claros y oscuros a partir de este color.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          // Opcional: puedes definir colores de fondo más claros si quieres.
          // background: Colors.grey[100],
        ),

        // Habilita el diseño más moderno de Material 3.
        useMaterial3: true,

        // =======================================================
        // === AQUÍ APLICAMOS LA NUEVA FUENTE A TODA LA APP ===
        // =======================================================
        fontFamily: 'Poppins',

        // --- Personalización de componentes específicos ---
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          // El estilo del texto de la AppBar también usará 'Poppins' por defecto,
          // pero podemos ser más específicos si queremos.
          titleTextStyle: TextStyle(
            fontFamily: 'Poppins', // Redundante pero explícito
            fontSize: 20,
            fontWeight:
                FontWeight.w600, // Usamos SemiBold para títulos de AppBar
          ),
        ),

        // Opcional: puedes definir estilos de texto para reutilizarlos.
        // textTheme: const TextTheme(
        //   displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
        //   titleLarge: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
        //   bodyMedium: TextStyle(fontSize: 16.0, fontFamily: 'Poppins'),
        // ),
      ),

      // La pantalla de inicio de la aplicación.
      home: const WelcomeScreen(),
    );
  }
}
