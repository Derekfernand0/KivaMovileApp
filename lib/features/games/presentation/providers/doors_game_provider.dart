import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/firebase_score_repository.dart';

// --- MODELO DE LA PREGUNTA ---
class DoorQuestion {
  final String text;
  final List<String> options;
  final int correctIndex;

  DoorQuestion(this.text, this.options, this.correctIndex);
}

// --- BANCO DE PREGUNTAS (Basado en tu código JS) ---
final List<DoorQuestion> _questionsBank = [
  DoorQuestion("¿Si alguien me pega debo decírselo a mi Mamá, Papá o Tutor?", [
    "Sí",
    "No",
  ], 0),
  DoorQuestion("¿Mi cuerpo es solo mío y nadie debe tocarlo si no quiero?", [
    "Falso",
    "Verdadero",
  ], 1),
  DoorQuestion(
    "¿Los secretos que me hacen sentir triste o asustado se deben guardar?",
    ["Sí", "No"],
    1,
  ),
  DoorQuestion("Si un adulto me pide fotos sin ropa, ¿qué debo hacer?", [
    "Enviarlas para no enojarlo",
    "Contarle a un adulto de confianza",
  ], 1),
  DoorQuestion("¿Es culpa mía si alguien mayor me hace daño?", [
    "Nunca es tu culpa",
    "A veces sí",
  ], 0),
  DoorQuestion(
    "Si alguien me hace sentir incómodo con sus palabras, ¿tengo derecho a alejarme?",
    ["Sí", "No, por respeto"],
    0,
  ),
  // Nota: Reduje la lista aquí por brevedad, pero puedes pegar las 30 completas.
];

// --- ESTADO DEL JUEGO ---
class DoorsGameState {
  final int currentQuestionIndex;
  final int lives;
  final int score;
  final int timeLeft;
  final bool isGameOver;
  final bool isVictory;
  final bool isAnimating; // Controla cuando la puerta se está abriendo
  final int? selectedDoorIndex; // Qué puerta se tocó

  DoorsGameState({
    this.currentQuestionIndex = 0,
    this.lives = 5,
    this.score = 0,
    this.timeLeft = 15,
    this.isGameOver = false,
    this.isVictory = false,
    this.isAnimating = false,
    this.selectedDoorIndex,
  });

  DoorsGameState copyWith({
    int? currentQuestionIndex,
    int? lives,
    int? score,
    int? timeLeft,
    bool? isGameOver,
    bool? isVictory,
    bool? isAnimating,
    int? selectedDoorIndex,
    bool clearSelectedDoor = false,
  }) {
    return DoorsGameState(
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      lives: lives ?? this.lives,
      score: score ?? this.score,
      timeLeft: timeLeft ?? this.timeLeft,
      isGameOver: isGameOver ?? this.isGameOver,
      isVictory: isVictory ?? this.isVictory,
      isAnimating: isAnimating ?? this.isAnimating,
      selectedDoorIndex: clearSelectedDoor
          ? null
          : (selectedDoorIndex ?? this.selectedDoorIndex),
    );
  }

  DoorQuestion get currentQuestion => _questionsBank[currentQuestionIndex];
}

// --- EL CONTROLADOR (La lógica) ---
final doorsGameProvider =
    StateNotifierProvider<DoorsGameNotifier, DoorsGameState>((ref) {
      return DoorsGameNotifier(ref);
    });

class DoorsGameNotifier extends StateNotifier<DoorsGameState> {
  final Ref _ref;
  Timer? _timer;
  bool _scoreSaved = false;

  DoorsGameNotifier(this._ref) : super(DoorsGameState()) {
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.isGameOver || state.isAnimating) return;

      if (state.timeLeft > 0) {
        state = state.copyWith(timeLeft: state.timeLeft - 1);
      } else {
        // Se acabó el tiempo = respuesta incorrecta automática (-1)
        selectDoor(-1);
      }
    });
  }

  void selectDoor(int index) async {
    if (state.isAnimating || state.isGameOver) {
      return; // Bloquea toques múltiples
    }

    final isCorrect = (index == state.currentQuestion.correctIndex);

    // Calcula nueva puntuación y vidas
    int newScore = state.score;
    int newLives = state.lives;

    if (isCorrect) {
      newScore += 10;
      // if (newLives < 5) newLives++; // Descomenta si quieres que recuperen vidas
    } else {
      newLives -= 1;
    }

    // Inicia la animación de mostrar el resultado
    state = state.copyWith(
      isAnimating: true,
      selectedDoorIndex: index,
      score: newScore,
      lives: newLives,
    );

    await Future.delayed(
      const Duration(milliseconds: 1200),
    ); // Espera a que se vea la puerta abierta

    // Evalúa si perdió o ganó el juego total
    if (newLives <= 0) {
      await _endGame(false);
      return;
    }

    if (state.currentQuestionIndex >= _questionsBank.length - 1) {
      await _endGame(true);
      return;
    }

    // Avanza a la siguiente pregunta
    state = state.copyWith(
      currentQuestionIndex: state.currentQuestionIndex + 1,
      timeLeft: 15,
      isAnimating: false,
      clearSelectedDoor: true,
    );
  }

  Future<void> _endGame(bool victory) async {
    if (state.isGameOver) return;

    _timer?.cancel();
    state = state.copyWith(
      isGameOver: true,
      isVictory: victory,
      isAnimating: false,
    );

    await _saveGameScoreIfPossible();
  }

  Future<void> _saveGameScoreIfPossible() async {
    if (_scoreSaved) return;

    final currentUser = _ref.read(authStateProvider).value;
    if (currentUser == null) return;

    try {
      await _ref
          .read(scoreRepositoryProvider)
          .saveGameScore(
            userId: currentUser.uid,
            gameId: 'puertas',
            gameName: 'Las Puertas de la Prevención',
            score: state.score,
          );
      _scoreSaved = true;
    } catch (_) {
      // No bloqueamos el flujo del juego si falla el guardado.
    }
  }

  void resetGame() {
    state = DoorsGameState();
    _scoreSaved = false;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
