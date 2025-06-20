// lib/providers/quiz_provider.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/quiz_model.dart';
import '../models/question_model.dart';
import '../services/quiz_state_service.dart';

class QuizProvider with ChangeNotifier {
  final QuizStateService _stateService = QuizStateService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  final Quiz quiz;
  List<Question> _shuffledQuestions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  Map<String, int> _userAnswers = {};
  bool _answered = false;
  int? _selectedOptionIndex;
  bool _isLoading = true;
  bool quizCompleted = false;

  static const int _questionTimeInSeconds = 20;
  Timer? _timer;
  double _progress = 1.0;

  Question get currentQuestion => _shuffledQuestions[_currentQuestionIndex];
  int get currentQuestionIndex => _currentQuestionIndex;
  int get totalQuestions => _shuffledQuestions.length;
  int get score => _score;
  bool get isAnswered => _answered;
  int? get selectedOptionIndex => _selectedOptionIndex;
  bool get isLoading => _isLoading;
  double get progress => _progress;
  Map<String, int> get userAnswers => _userAnswers;
  List<Question> get questions => _shuffledQuestions;

  QuizProvider({required this.quiz}) {
    _initialize();
  }

  void _initialize() async {
    _isLoading = true;
    notifyListeners();

    _shuffledQuestions = List.of(quiz.questions)..shuffle(Random());
    await _loadState();

    _isLoading = false;
    notifyListeners();

    if (!_isLoading && _shuffledQuestions.isNotEmpty) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _progress = 1.0;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!isDisposed) {
        _progress -= (100 / (_questionTimeInSeconds * 1000));
        if (_progress <= 0) {
          timer.cancel();
          answerQuestion(-1);
        }
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _loadState() async {
    final savedState = await _stateService.loadQuizState();
    if (savedState != null && savedState['quizId'] == quiz.id) {
      _currentQuestionIndex = savedState['currentQuestionIndex'];
      _score = savedState['score'];
      _userAnswers = Map<String, int>.from(savedState['userAnswers']);
    } else {
      await _stateService.clearQuizState();
    }
  }

  Future<void> answerQuestion(int selectedIndex) async {
    if (_answered) return;
    _timer?.cancel();
    _answered = true;

    final isCorrect = selectedIndex == currentQuestion.correctAnswerIndex;
    if (isCorrect) {
      _audioPlayer.play(AssetSource('sounds/correct_answer.mp3'));
      _score++;
    } else {
      _audioPlayer.play(AssetSource('sounds/wrong_answer.mp3'));
    }

    if (selectedIndex != -1) _userAnswers[currentQuestion.id] = selectedIndex;
    _selectedOptionIndex = selectedIndex;
    notifyListeners();

    await _stateService.saveQuizState(
      quizId: quiz.id,
      currentQuestionIndex: _currentQuestionIndex,
      score: _score,
      userAnswers: _userAnswers,
    );

    Future.delayed(const Duration(seconds: 1), _prepareNextQuestion);
  }

  void _prepareNextQuestion() {
    final bool isLast = _currentQuestionIndex >= _shuffledQuestions.length - 1;
    if (!isLast) {
      _currentQuestionIndex++;
      _answered = false;
      _selectedOptionIndex = null;
      _startTimer();
    } else {
      quizCompleted = true;
    }
    notifyListeners();
  }

  bool _isDisposed = false;
  bool get isDisposed => _isDisposed;

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
