//==============================================================================
// === IMPORTACIONES ===
// Objetivo: Traer las herramientas y "planos" necesarios para esta pantalla.
//==============================================================================
import 'package:flutter/material.dart'; // Importa los widgets básicos de Material Design (Scaffold, AppBar, Text, etc.).
import '../models/quiz_model.dart'; // Importa el "molde" de lo que es un Quiz, para saber cómo manejar los datos.
import '../services/quiz_loader_service.dart'; // Importa el "chef" que sabe cómo leer y preparar los quizzes desde el JSON.
import 'quiz_screen.dart'; // Importa la pantalla de juego, que es el destino al que navegaremos.

//==============================================================================
// === DEFINICIÓN DEL WIDGET ===
// Objetivo: Crear la estructura base de la pantalla de bienvenida.
//==============================================================================
// Se usa un 'StatefulWidget' porque el estado de esta pantalla depende de una
// operación que toma tiempo (cargar los quizzes). Necesitamos "recordar" el
// estado de esa carga (cargando, completado, error).
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
  // --- ESTADO PRINCIPAL ---
  // Esta variable contendrá el "futuro" de nuestra operación de carga.
  // No contiene la lista de quizzes directamente, sino el estado de la
  // operación que EVENTUALMENTE nos dará esa lista.
  // La palabra 'late' nos permite declararla aquí e inicializarla en 'initState'.
  late Future<List<Quiz>> _quizzesFuture;

  // --- CICLO DE VIDA: initState ---
  // Se ejecuta UNA SOLA VEZ cuando el widget se monta en la pantalla.
  // Es el lugar perfecto para iniciar operaciones de carga de datos.
  @override
  void initState() {
    super.initState();
    // ¡ACCIÓN INICIAL! Aquí se da la orden de empezar a cargar.
    // Creamos una instancia de nuestro servicio y llamamos al método que
    // lee el JSON. El 'Future' que devuelve esta operación se asigna a nuestra
    // variable de estado. A partir de ahora, 'FutureBuilder' observará esta variable.
    _quizzesFuture = QuizLoaderService().loadQuizzes();
  }

  // --- MÉTODOS DE LÓGICA Y NAVEGACIÓN ---

  // Método de ayuda para navegar a la pantalla de juego.
  // Recibe el objeto 'quiz' que el usuario ha seleccionado.
  void _navigateToQuiz(Quiz quiz) {
    // La función 'Navigator.of(context).push' añade una nueva pantalla a la pila.
    Navigator.of(context).push(
      MaterialPageRoute(
        // Le decimos que la nueva pantalla a construir es 'QuizScreen'.
        // ¡CONEXIÓN CLAVE! Pasamos el 'quiz' seleccionado al constructor
        // de QuizScreen, dándole así todos los datos que necesita para funcionar.
        builder: (_) => QuizScreen(quiz: quiz),
      ),
    );
  }

  // Método que crea un quiz especial combinando las preguntas de todos los demás.
  Quiz _createMegaQuiz(List<Quiz> allQuizzes) {
    // 'expand' es una función potente: toma una lista de quizzes, y para cada
    // quiz, extrae su lista de preguntas. El resultado es una sola lista "plana"
    // con TODAS las preguntas de todos los quizzes.
    final allQuestions = allQuizzes.expand((quiz) => quiz.questions).toList();
    allQuestions.shuffle(); // Baraja la lista gigante de preguntas.

    // Crea y devuelve un nuevo objeto Quiz con datos personalizados.
    return Quiz(
      id: 'mega_quiz',
      title: 'Mega Cuestionario',
      category: 'Todas las categorías',
      description: 'Un desafío con preguntas de todos los cuestionarios.',
      questions: allQuestions,
    );
  }

  // --- CONSTRUCCIÓN DE LA INTERFAZ DE USUARIO ---
  // Este método se ejecuta para dibujar la pantalla. En nuestro caso,
  // se volverá a ejecutar a medida que el 'Future' cambie de estado.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selecciona un Cuestionario')),
      // ¡EL WIDGET ESTRELLA PARA OPERACIONES ASÍNCRONAS!
      // FutureBuilder está conectado a nuestro '_quizzesFuture' y reconstruirá
      // su 'builder' cada vez que el estado del Future cambie.
      body: FutureBuilder<List<Quiz>>(
        // 1. Le indicamos qué Future debe "observar".
        future: _quizzesFuture,
        // 2. Le damos la función 'builder' que decide qué dibujar.
        //    'snapshot' es una "foto" del estado actual del Future.
        builder: (context, snapshot) {
          // CASO 1: Cargando. El Future todavía no se ha completado.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // CASO 2: Error. El Future terminó con un fallo (ej: archivo no encontrado).
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar: ${snapshot.error}'));
          }
          // CASO 3: Éxito pero sin datos. El Future terminó bien, pero la lista está vacía o nula.
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No se encontraron cuestionarios.'));
          }

          // CASO 4: ¡ÉXITO TOTAL! El Future se completó y tenemos datos.
          // Accedemos a los datos con 'snapshot.data!'. El '!' es una aserción
          // de que sabemos que los datos no son nulos en este punto.
          final quizzes = snapshot.data!;

          // Ahora que tenemos la lista 'quizzes', construimos la UI principal.
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                //--- Botón para el Mega Cuestionario ---
                ElevatedButton.icon(
                  icon: const Icon(Icons.all_inclusive),
                  label: const Text('Iniciar Mega Cuestionario'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    // Al pulsar, creamos el mega quiz usando la lista ya cargada.
                    final megaQuiz = _createMegaQuiz(quizzes);
                    // Y navegamos a la pantalla de juego con este quiz especial.
                    _navigateToQuiz(megaQuiz);
                  },
                ),
                //--- Otros botones de acción (ej: resetear progreso) ---
                const SizedBox(height: 10),
                TextButton.icon(
                  icon: const Icon(Icons.delete_sweep, color: Colors.red),
                  label: const Text('Resetear Progreso Guardado',
                      style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    // Esta funcionalidad está pendiente, pero muestra un mensaje al usuario.
                    // Aquí es donde en el futuro llamarías a tu QuizStateService.clearQuizState().
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Progreso reseteado (funcionalidad pendiente).')),
                    );
                  },
                ),
                const SizedBox(height: 20),
                //--- Lista de Cuestionarios Individuales ---
                Expanded(
                  // ListView.builder es eficiente: solo construye los elementos que son visibles en pantalla.
                  child: ListView.builder(
                    itemCount: quizzes.length, // El número de tarjetas a crear.
                    itemBuilder: (context, index) {
                      // Para cada índice, obtenemos el quiz correspondiente.
                      final quiz = quizzes[index];
                      // Y construimos una tarjeta para él.
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(quiz.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              '${quiz.questions.length} preguntas'), // Mostramos información útil.
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // ¡ACCIÓN DEL USUARIO! Al tocar la tarjeta, se inicia la navegación
                            // hacia la pantalla de juego, pasando el quiz específico que se tocó.
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
