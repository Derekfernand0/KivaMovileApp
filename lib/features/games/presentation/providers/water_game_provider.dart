import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/firebase_score_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// --- MODELO DE LA PREGUNTA ---
class WaterQuestion {
  final String text;
  final List<String> options;
  final int correctIndex;

  WaterQuestion(this.text, this.options, this.correctIndex);
}

// --- BANCO DE PREGUNTAS (Basado en tu juego.js) ---
final List<WaterQuestion> _waterQuestionsBank = [
  WaterQuestion("¿Qué significan las siglas KIVA?", [
    "Kids International Video",
    "Kid’s Integrity, Voz y Apoyo",
    "Kids In Veracruz",
  ], 1),
  WaterQuestion("¿Cuál es el mensaje de la sección 'Aprende'?", [
    "Jugar videojuegos",
    "Que el abuso es tu culpa",
    "Conocer tu cuerpo y derechos",
  ], 2),
  WaterQuestion("¿Es verdad que el abuso solo pasa con desconocidos?", [
    "Sí, siempre son extraños.",
    "No, puede ser alguien cercano.",
    "Sí, la familia siempre protege.",
  ], 1),
  WaterQuestion(
    "¿Qué debes hacer si alguien te confía que ha sido lastimado?",
    [
      "Escuchar, creer y buscar ayuda.",
      "Ignorarlo.",
      "Decirle que es mentira.",
    ],
    0,
  ),
  WaterQuestion("Si estás en peligro inmediato, ¿a qué número llamas?", [
    "089",
    "911",
    "112",
  ], 1),
  WaterQuestion("¿Cuál es el primer paso antes de denunciar?", [
    "Comprar una cámara.",
    "Guardar silencio.",
    "Buscar seguridad en un adulto.",
  ], 2),
  // Puedes agregar el resto de las 30 preguntas aquí...
];

// --- ESTADO DEL JUEGO ---
class WaterGameState {
  final int currentQuestionIndex;
  final int playerBlocks;
  final int waterBlocks;
  final int timeLeft;
  final bool isGameOver;
  final bool isVictory;

  WaterGameState({
    this.currentQuestionIndex = 0,
    this.playerBlocks =
        3, // El jugador inicia con 3 bloques de ventaja según tu JS
    this.waterBlocks = 0,
    this.timeLeft = 10, // 10 segundos para responder
    this.isGameOver = false,
    this.isVictory = false,
  });

  WaterGameState copyWith({
    int? currentQuestionIndex,
    int? playerBlocks,
    int? waterBlocks,
    int? timeLeft,
    bool? isGameOver,
    bool? isVictory,
  }) {
    return WaterGameState(
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      playerBlocks: playerBlocks ?? this.playerBlocks,
      waterBlocks: waterBlocks ?? this.waterBlocks,
      timeLeft: timeLeft ?? this.timeLeft,
      isGameOver: isGameOver ?? this.isGameOver,
      isVictory: isVictory ?? this.isVictory,
    );
  }

  WaterQuestion get currentQuestion =>
      _waterQuestionsBank[currentQuestionIndex];
}

// --- EL CONTROLADOR ---
final waterGameProvider =
    StateNotifierProvider<WaterGameNotifier, WaterGameState>((ref) {
      return WaterGameNotifier(ref);
    });

class WaterGameNotifier extends StateNotifier<WaterGameState> {
  final Ref ref;
  Timer? _timer;

  WaterGameNotifier(this.ref) : super(WaterGameState()) {
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.isGameOver) {
        timer.cancel();
        return;
      }

      if (state.timeLeft > 0) {
        state = state.copyWith(timeLeft: state.timeLeft - 1);
      } else {
        // Se acabó el tiempo = respuesta incorrecta automática
        answerQuestion(-1);
      }
    });
  }

  void answerQuestion(int selectedIndex) async {
    if (state.isGameOver) return;
    _timer?.cancel();

    int newPlayerBlocks = state.playerBlocks;
    int newWaterBlocks =
        state.waterBlocks + 5; // El agua siempre sube 5 bloques

    // Si respondió correctamente
    if (selectedIndex == state.currentQuestion.correctIndex) {
      // Gana bloques según el tiempo restante (Mínimo 1)
      int gainedBlocks = max(1, state.timeLeft);
      newPlayerBlocks += gainedBlocks;
    }

    // Verificar si el agua lo alcanzó (Derrota)
    if (newWaterBlocks > newPlayerBlocks) {
      state = state.copyWith(
        playerBlocks: newPlayerBlocks,
        waterBlocks: newWaterBlocks,
        isGameOver: true,
        isVictory: false,
      );
      _saveScoreToDatabase();
      return;
    }

    // Verificar si ganó el juego (Respondió todo)
    if (state.currentQuestionIndex >= _waterQuestionsBank.length - 1) {
      state = state.copyWith(
        playerBlocks: newPlayerBlocks,
        waterBlocks: newWaterBlocks,
        isGameOver: true,
        isVictory: true,
      );
      _saveScoreToDatabase();
      return;
    }

    // Avanzar a la siguiente pregunta
    state = state.copyWith(
      currentQuestionIndex: state.currentQuestionIndex + 1,
      playerBlocks: newPlayerBlocks,
      waterBlocks: newWaterBlocks,
      timeLeft: 10,
    );
    _startTimer();
  }

  // Llama al repositorio genérico que creamos en el paso anterior para guardar en Firebase
  Future<void> _saveScoreToDatabase() async {
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      await ref
          .read(scoreRepositoryProvider)
          .saveGameScore(
            userId: user.uid,
            gameId: 'torre',
            gameName: 'La Gran Torre de Isla',
            score:
                state.playerBlocks *
                5, // Puntos escalados por bloque para que sea mas justo
          );
    }
  }

  void resetGame() {
    state = WaterGameState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
