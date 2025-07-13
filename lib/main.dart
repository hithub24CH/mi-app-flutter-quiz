// lib/main.dart

import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //========================================================================
    // === NUEVA PALETA DE COLORES: "VIBRANT VIOLET & GOLD" ===
    //========================================================================

    // --- Colores para el MODO CLARO ---
    final lightColorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: const Color.fromARGB(
          255, 171, 83, 254), // Violeta vibrante (BlueViolet)
      onPrimary: Colors.white,
      secondary: const Color(0xFFFFC107), // Dorado/ámbar como acento
      onSecondary: Colors.black,
      error: Colors.red.shade700,
      onError: Colors.white,
      background: Colors.grey.shade200,
      onBackground: Colors.black87,
      surface: Colors.white,
      onSurface: Colors.black87,
    );

    // --- Colores para el MODO OSCURO ---
    final darkColorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: const Color.fromARGB(
          255, 155, 101, 255), // Un violeta más claro (Lavanda) para resaltar
      onPrimary: Colors.black,
      secondary: const Color(0xFFFFD54F),
      onSecondary: Colors.black,
      error: Colors.red.shade400,
      onError: Colors.black,
      background: const Color(0xFF121212), // Fondo casi negro
      onBackground: Colors.white.withOpacity(0.9),
      surface: const Color(0xFF1E1E1E), // Tarjetas de un gris muy oscuro
      onSurface: Colors.white.withOpacity(0.9),
    );

    return MaterialApp(
      title: 'Quiz App Flutter',
      debugShowCheckedModeBanner: false,

      //========================================================================
      // === TEMA PARA EL MODO CLARO (THEME) ===
      //========================================================================
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
        scaffoldBackgroundColor: lightColorScheme.background,
        appBarTheme: AppBarTheme(
          backgroundColor: lightColorScheme.primary,
          foregroundColor: lightColorScheme.onPrimary,
          elevation: 4, // Añadimos una sombra sutil
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: lightColorScheme.surface,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: lightColorScheme.primary,
            foregroundColor: lightColorScheme.onPrimary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),

      //========================================================================
      // === TEMA PARA EL MODO OSCURO (DARKTHEME) - ¡CON MEJORAS! ===
      //========================================================================
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        scaffoldBackgroundColor: darkColorScheme.background,

        //----------------------------------------------------------------------
        // MEJORA 1: Diferenciar el AppBar del fondo
        // Le damos al AppBar el color de las tarjetas (`surface`) en lugar del
        // color de fondo (`background`). Esto crea una separación visual clara.
        //----------------------------------------------------------------------
        appBarTheme: AppBarTheme(
          backgroundColor:
              darkColorScheme.surface, // ANTES: darkColorScheme.background
          foregroundColor: darkColorScheme.onSurface,
          elevation: 0, // Quitamos la sombra para un look más plano y moderno
        ),

        //----------------------------------------------------------------------
        // MEJORA 2: Añadir un borde sutil a las tarjetas para más definición
        //----------------------------------------------------------------------
        cardTheme: CardThemeData(
          elevation:
              0, // Quitamos la sombra para que el borde sea el protagonista
          shape: RoundedRectangleBorder(
            // Añadimos un borde del color del texto pero con muy poca opacidad
            side: BorderSide(
                color: darkColorScheme.onSurface.withOpacity(0.2), width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          color: darkColorScheme.surface,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: darkColorScheme.primary,
            foregroundColor: darkColorScheme.onPrimary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),

      themeMode: ThemeMode.system,

      home: const WelcomeScreen(),
    );
  }
}
