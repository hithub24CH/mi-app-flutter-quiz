//==============================================================================
// === IMPORTACIONES ESENCIALES ===
//==============================================================================
import 'dart:async'; // Necesario para usar 'Timer', el temporizador de cada pregunta.
import 'package:flutter/foundation.dart'; // Para 'ChangeNotifier' y 'debugPrint'.
import 'package:audioplayers/audioplayers.dart'; // Para reproducir los sonidos de acierto/error.
import '../models/quiz_model.dart'; // Importa el molde de lo que es un 'Quiz'.
import '../models/question_model.dart'; // Importa el molde de lo que es una 'Question'.

//==============================================================================
// === DEFINICIÓN DE LA CLASE ===
//==============================================================================
// QuizProvider "extiende" ChangeNotifier. Esto le da la habilidad de
// "notificar" a los widgets que lo están escuchando (como QuizScreen)
// cuando alguno de sus datos internos ha cambiado.
class QuizProvider extends ChangeNotifier {
  //============================================================================
  // === ESTADO INTERNO DEL JUEGO (Las variables que controlan todo) ===
  //============================================================================

  // El objeto 'Quiz' completo que se está jugando. Contiene el título y la lista original de preguntas.
  // Es 'final' porque no cambiará durante la sesión de juego.
  final Quiz quiz;

  // Una copia de las preguntas del quiz. La usamos para poder barajarlas sin modificar el 'quiz' original.
  final List<Question> questions;

  // Almacena las respuestas del usuario. Es una lista de enteros (el índice de la opción elegida).
  // Puede contener 'null' si el usuario no responde a tiempo.
  final List<int?> userAnswers = [];

  // Puntero que indica en qué pregunta de la lista 'questions' nos encontramos.
  int currentQuestionIndex = 0;

  // Contador de respuestas correctas.
  int score = 0;

  // Guarda el índice de la opción que el usuario seleccionó. Es 'null' antes de responder.
  // Su estado (null o no) nos ayuda a saber si la pregunta ya fue respondida.
  int? selectedOptionIndex;

  // Bandera que se vuelve 'true' cuando se responden todas las preguntas.
  // Será la señal para navegar a la pantalla de resultados.
  bool _quizCompleted = false;

  // El temporizador y sus variables de control.
  static const int tiempoPorPregunta =
      20; // Tiempo fijo en segundos para cada pregunta.
  Timer? _timer; // El objeto Timer que descuenta el tiempo.
  int _tiempoRestante = tiempoPorPregunta; // El contador de segundos actual.

  //============================================================================
  // === CONSTRUCTOR (Lo que se ejecuta al crear un QuizProvider) ===
  //============================================================================
  // Cuando se crea un QuizProvider (desde QuizScreen), recibe el 'quiz' seleccionado.
  QuizProvider({required this.quiz})
      // Lista de inicialización: Antes de que el cuerpo del constructor se ejecute...
      // 1. Se crea una copia de las preguntas del quiz para poder manipularla.
      : questions = List.from(quiz.questions) {
    // Cuerpo del constructor:
    // 2. Baraja aleatoriamente el orden de las preguntas para que cada juego sea diferente.
    questions.shuffle();
    // 3. Inicia el temporizador para la primera pregunta.
    _iniciarTemporizador();
  }

  //============================================================================
  // === GETTERS (Propiedades calculadas para facilitar el acceso desde la UI) ===
  //============================================================================
  // La UI (QuizScreen) no necesita acceder directamente a '_tiempoRestante',
  // puede usar este getter que es más limpio y seguro.
  int get tiempoRestante => _tiempoRestante;

  // Calcula el progreso del temporizador como un valor entre 0.0 y 1.0.
  // Perfecto para usarlo en un 'LinearProgressIndicator'.
  double get timerProgress =>
      _tiempoRestante > 0 ? _tiempoRestante / tiempoPorPregunta : 0;

  // Permite a la UI (QuizScreen) saber si el quiz ha terminado.
  bool get quizCompleted => _quizCompleted;

  // Devuelve el objeto 'Question' actual basado en el 'currentQuestionIndex'.
  Question get currentQuestion => questions[currentQuestionIndex];

  // Devuelve el número total de preguntas en este quiz.
  int get totalQuestions => questions.length;

  // Un booleano muy útil que indica si la pregunta actual ya ha sido respondida.
  // La UI lo usa para deshabilitar los botones de opción después de una respuesta.
  bool get isAnswered => selectedOptionIndex != null;

  //============================================================================
  // === MÉTODOS (Las acciones y la lógica del juego) ===
  //============================================================================

  // Método privado para reproducir un sonido.
  Future<void> _playSound(String soundFile) async {
    try {
      // Crea una instancia del reproductor y le dice que toque un archivo de la carpeta 'assets/sounds/'.
      await AudioPlayer().play(AssetSource('sounds/$soundFile'));
    } catch (e) {
      // Si hay un error (ej. el archivo no existe), lo imprime en la consola de depuración.
      debugPrint("Error al reproducir el sonido: $e");
    }
  }

  // Inicia el temporizador para una pregunta.
  void _iniciarTemporizador() {
    _tiempoRestante = tiempoPorPregunta; // Resetea el contador.
    // Crea un temporizador que se ejecuta cada segundo.
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_tiempoRestante > 0) {
        _tiempoRestante--; // Si queda tiempo, lo descuenta.
      } else {
        // Si el tiempo llega a 0, llama a 'answerQuestion' con -1 para indicar "no respondida".
        answerQuestion(-1);
      }
      // ¡CLAVE! Notifica a los listeners (QuizScreen) que un dato ha cambiado.
      // Esto hará que la UI se redibuje para mostrar el nuevo tiempo restante.
      notifyListeners();
    });
  }

  // Detiene el temporizador actual. Se llama cuando el usuario responde o se acaba el tiempo.
  void _detenerTemporizador() {
    _timer
        ?.cancel(); // El '?' es un "null-check": solo cancela si _timer no es nulo.
  }

  // El método MÁS IMPORTANTE. Se llama cuando el usuario toca una opción.
  void answerQuestion(int optionIndex) {
    // Bloqueo de seguridad: si ya se respondió, no hace nada. Evita respuestas múltiples.
    if (isAnswered) return;

    _detenerTemporizador(); // Lo primero es parar el reloj.
    selectedOptionIndex =
        optionIndex; // Guarda la opción elegida por el usuario.

    // Comprueba si la respuesta es correcta.
    if (optionIndex == currentQuestion.correctAnswerIndex) {
      score++; // Aumenta la puntuación.
      _playSound('correct_answer.mp3'); // Reproduce sonido de acierto.
    } else {
      _playSound('wrong_answer.mp3'); // Reproduce sonido de error.
    }

    userAnswers.add(optionIndex); // Añade la respuesta a la lista histórica.

    // ¡CLAVE! Notifica a la UI que la pregunta ha sido respondida.
    // Esto hará que QuizScreen se redibuje y muestre los colores de correcto/incorrecto.
    notifyListeners();

    // Espera 2 segundos (para que el usuario vea el feedback) y luego pasa a la siguiente pregunta.
    Future.delayed(const Duration(seconds: 2), _nextQuestion);
  }

  // Pasa a la siguiente pregunta o finaliza el quiz.
  void _nextQuestion() {
    // Si no hemos llegado al final de la lista de preguntas...
    if (currentQuestionIndex < questions.length - 1) {
      currentQuestionIndex++; // Avanza el puntero.
      selectedOptionIndex =
          null; // Resetea la "respuesta seleccionada" para la nueva pregunta.

      // ¡CLAVE! Notifica a la UI para que se redibuje con la nueva pregunta.
      notifyListeners();
      _iniciarTemporizador(); // Inicia el temporizador para la nueva pregunta.
    } else {
      // Si era la última pregunta...
      _quizCompleted = true; // Marca el quiz como completado.
      // ¡CLAVE! Notifica a la UI. QuizScreen tiene un listener que, al ver que
      // _quizCompleted es true, navegará a la pantalla de resultados.
      notifyListeners();
    }
  }

  //============================================================================
  // === MÉTODO DE LIMPIEZA (Se llama cuando el Provider ya no se necesita) ===
  //============================================================================
  // Es una buena práctica detener cualquier proceso en segundo plano (como timers)
  // cuando el widget que lo usa se destruye para evitar fugas de memoria.
  @override
  void dispose() {
    _detenerTemporizador();
    super.dispose();
  }
}
