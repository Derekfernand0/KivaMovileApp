import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/firebase_score_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// --- MODELOS ---
class ShawarmaCustomer {
  final String imagePath;
  final String type;
  final String successMessage;
  final String errorMessage;
  final List<Map<String, String>> questions;

  ShawarmaCustomer({
    required this.imagePath,
    required this.type,
    required this.successMessage,
    required this.errorMessage,
    required this.questions,
  });
}

// --- BANCO DE CLIENTES EXACTO AL JS ORIGINAL ---
final List<ShawarmaCustomer> _customersBank = [
  ShawarmaCustomer(
    imagePath: 'assets/images/shawarma/ppl/pp1.png',
    type: 'bueno',
    successMessage: "",
    errorMessage:
        "Castigaste a alguien que mostraba respeto por la autonomía y los gustos de los demás.",
    questions: [
      {
        "q": "¿Viene a comer con su familia?",
        "a": "Sí, siempre les pregunto qué desean comer antes de pedir.",
      },
      {
        "q": "¿Le pongo salsa picante?",
        "a":
            "Solo a mi mitad, a mi hijo no le gusta y hay que respetar sus gustos.",
      },
      {
        "q": "Se ve que tiene buen humor hoy.",
        "a":
            "Sí, pasamos una tarde tranquila, escuchando cómo les fue en la escuela.",
      },
    ],
  ),
  ShawarmaCustomer(
    imagePath: 'assets/images/shawarma/ppl/pp2.png',
    type: 'malo',
    successMessage:
        "Bien hecho. Detectaste a alguien que busca cercanía inapropiada.",
    errorMessage:
        "Debes tener cuidado. Buscar cercanía rápida y excesiva confianza con niños desconocidos es una alerta.",
    questions: [
      {
        "q": "¿Qué tal su día?",
        "a":
            "Bien, estuve platicando con unos niños del parque. Me gusta saber todo de ellos.",
      },
      {
        "q": "¿Desea llevar algo extra?",
        "a": "Sí, unos dulces. Son perfectos para ganarme la confianza rápida.",
      },
      {
        "q": "Parece que le gustan los niños.",
        "a":
            "Claro, prefiero estar con ellos, los adultos hacen demasiadas preguntas.",
      },
      {
        "q": "¿Es para llevar?",
        "a": "Sí, los llevaré al parque a ver a quién me encuentro hoy.",
      },
    ],
  ),
  ShawarmaCustomer(
    imagePath: 'assets/images/shawarma/ppl/pp3.png',
    type: 'malo',
    successMessage:
        "Excelente. El autoritarismo extremo que ignora los límites personales es una alerta.",
    errorMessage:
        "Ignoraste señales de autoritarismo extremo que invalida las necesidades básicas.",
    questions: [
      {
        "q": "¿Quiere que lo corte a la mitad?",
        "a": "No, que se lo coman entero. Aquí se hace lo que yo digo y punto.",
      },
      {
        "q": "El niño parece cansado.",
        "a":
            "No importa si está cansado, tiene que aprender a obedecer sin quejarse.",
      },
      {
        "q": "¿Le pongo todos los vegetales?",
        "a":
            "Ponle de todo, si no le gusta no es mi problema, se lo traga igual.",
      },
    ],
  ),
  ShawarmaCustomer(
    imagePath: 'assets/images/shawarma/ppl/pp4.png',
    type: 'bueno',
    successMessage: "",
    errorMessage:
        "Te equivocaste. Esta persona demostró paciencia y respeto por las decisiones de los demás.",
    questions: [
      {
        "q": "Hay un poco de fila, disculpe.",
        "a": "No hay problema, aprovechamos para platicar de nuestro día.",
      },
      {
        "q": "¿Seguro que solo quiere uno?",
        "a":
            "Sí, mi sobrino me dijo que ya no tenía hambre, y hay que escuchar su cuerpo.",
      },
      {
        "q": "¿Quiere servilletas extra?",
        "a": "Por favor. Siempre es bueno prevenir accidentes.",
      },
    ],
  ),
  ShawarmaCustomer(
    imagePath: 'assets/images/shawarma/ppl/pp5.png',
    type: 'malo',
    successMessage:
        "Muy bien. Identificaste que pedir secretos a los niños es un comportamiento manipulador.",
    errorMessage:
        "Los secretos, especialmente cuando excluyen a los padres o cuidadores, son una gran señal de alerta.",
    questions: [
      {
        "q": "¿Lo empaco para regalo?",
        "a":
            "Sí, pero es un secreto. Será nuestro pequeño secreto, no le digas a sus papás.",
      },
      {
        "q": "¿Desea el ticket?",
        "a":
            "No, no quiero que quede registro. Es una sorpresa que solo nosotros compartimos.",
      },
      {
        "q": "Son 10 monedas.",
        "a":
            "Toma el cambio. Y recuerda, no viste a nadie, esto queda entre nosotros.",
      },
    ],
  ),
  ShawarmaCustomer(
    imagePath: 'assets/images/shawarma/ppl/pp6.png',
    type: 'malo',
    successMessage:
        "Correcto. Invalidar las emociones es una señal clara de falta de empatía y riesgo.",
    errorMessage:
        "Minimizar o invalidar constantemente las emociones es una forma de violencia psicológica.",
    questions: [
      {
        "q": "¿Por qué llora el pequeño?",
        "a": "Llora por tonterías, siempre exagera. No hay que hacerle caso.",
      },
      {
        "q": "¿Le doy un vaso de agua?",
        "a": "No, que se aguante. Tiene que hacerse fuerte desde pequeño.",
      },
      {
        "q": "Tal vez no le gusta la cebolla.",
        "a":
            "Sus sentimientos no importan, debe comer lo que se le da sin opinar.",
      },
    ],
  ),
  ShawarmaCustomer(
    imagePath: 'assets/images/shawarma/ppl/pp7.png',
    type: 'bueno',
    successMessage: "",
    errorMessage:
        "El respeto por el espacio y la opinión de los demás es una conducta sana, no debiste sospechar.",
    questions: [
      {
        "q": "Disculpe el ruido del local.",
        "a":
            "No te preocupes. Le pregunté a mi hijo si le molestaba y dijo que está bien.",
      },
      {
        "q": "¿Les sirvo en la mesa?",
        "a": "Sí, por favor. Así podemos tener nuestro espacio tranquilos.",
      },
      {
        "q": "¿Quiere que se lo entregue en la mano al niño?",
        "a": "Mejor ponlo en el plato, él decidirá cuándo comerlo.",
      },
    ],
  ),
  ShawarmaCustomer(
    imagePath: 'assets/images/shawarma/ppl/pp8.png',
    type: 'malo',
    successMessage:
        "Bien hecho. Forzar el contacto físico es una clara señal de alerta que detectaste a tiempo.",
    errorMessage:
        "El contacto físico forzado, incluso disfrazado de cariño, es una grave violación de los límites.",
    questions: [
      {
        "q": "¿Van a comer aquí?",
        "a":
            "Sí, me encanta sentarlos en mis piernas y abrazarlos aunque no quieran.",
      },
      {
        "q": "Parecen incómodos.",
        "a":
            "Solo se hacen los difíciles, en el fondo les encanta que los apriete.",
      },
      {
        "q": "¿Quiere espacio extra?",
        "a":
            "Para nada, me gusta estar lo más pegado posible a ellos todo el tiempo.",
      },
      {
        "q": "Aquí tiene su pedido.",
        "a": "Ven, dame un beso como agradecimiento, ándale, no seas tímido.",
      },
    ],
  ),
  ShawarmaCustomer(
    imagePath: 'assets/images/shawarma/ppl/pp9.png',
    type: 'malo',
    successMessage:
        "Excelente. Reconociste que las amenazas exageradas son una señal de abuso y control.",
    errorMessage:
        "Las amenazas desproporcionadas buscan infundir miedo, una alerta importante que dejaste pasar.",
    questions: [
      {
        "q": "¿Se les ofrece algo más?",
        "a": "No, si piden algo más los voy a dejar abandonados aquí.",
      },
      {
        "q": "Tenga cuidado, está caliente.",
        "a": "Si se queman es su culpa, y ya verán cómo les va en la casa.",
      },
      {
        "q": "Que disfruten su comida.",
        "a": "Más les vale comer rápido o no vuelven a ver la luz del sol.",
      },
    ],
  ),
  ShawarmaCustomer(
    imagePath: 'assets/images/shawarma/ppl/pp10.png',
    type: 'malo',
    successMessage:
        "Correcto. La manipulación emocional y el chantaje son conductas que deben encender las alarmas.",
    errorMessage:
        "La manipulación emocional constante busca generar culpa y control en la otra persona.",
    questions: [
      {
        "q": "¿Es todo su pedido?",
        "a":
            "Sí, a ver si así por fin me agradecen algo, después de todo lo que sufro.",
      },
      {
        "q": "¿Se sienten bien?",
        "a":
            "No sé ellos, pero si me quisieran de verdad se portarían mucho mejor.",
      },
      {
        "q": "Tardará unos minutos.",
        "a": "Está bien. Siempre tengo que esperar, total, a nadie le importo.",
      },
      {
        "q": "Aquí está su comida.",
        "a":
            "A ver si con esto me demuestras que me quieres, porque últimamente no lo parece.",
      },
    ],
  ),
];

// --- ESTADO DEL JUEGO ---
class ShawarmaGameState {
  final int lives;
  final int score;
  final List<ShawarmaCustomer> queue;
  final ShawarmaCustomer? currentCustomer;
  final String? currentDialogue;
  final int shawarmaStep;
  final bool isGateFalling; // <-- NUEVO: Controla la reja
  final bool showEvaluationModal; // <-- NUEVO: Muestra el modal exacto del HTML
  final String evalTitle;
  final String evalMessage;
  final bool isGameOver;
  final bool isVictory;

  ShawarmaGameState({
    this.lives = 3,
    this.score = 0,
    this.queue = const [],
    this.currentCustomer,
    this.currentDialogue,
    this.shawarmaStep = 0,
    this.isGateFalling = false,
    this.showEvaluationModal = false,
    this.evalTitle = "",
    this.evalMessage = "",
    this.isGameOver = false,
    this.isVictory = false,
  });

  ShawarmaGameState copyWith({
    int? lives,
    int? score,
    List<ShawarmaCustomer>? queue,
    ShawarmaCustomer? currentCustomer,
    String? currentDialogue,
    int? shawarmaStep,
    bool? isGateFalling,
    bool? showEvaluationModal,
    String? evalTitle,
    String? evalMessage,
    bool? isGameOver,
    bool? isVictory,
    bool clearDialogue = false,
  }) {
    return ShawarmaGameState(
      lives: lives ?? this.lives,
      score: score ?? this.score,
      queue: queue ?? this.queue,
      currentCustomer: currentCustomer ?? this.currentCustomer,
      currentDialogue: clearDialogue
          ? null
          : (currentDialogue ?? this.currentDialogue),
      shawarmaStep: shawarmaStep ?? this.shawarmaStep,
      isGateFalling: isGateFalling ?? this.isGateFalling,
      showEvaluationModal: showEvaluationModal ?? this.showEvaluationModal,
      evalTitle: evalTitle ?? this.evalTitle,
      evalMessage: evalMessage ?? this.evalMessage,
      isGameOver: isGameOver ?? this.isGameOver,
      isVictory: isVictory ?? this.isVictory,
    );
  }
}

// --- CONTROLADOR ---
final shawarmaProvider =
    StateNotifierProvider<ShawarmaNotifier, ShawarmaGameState>((ref) {
      return ShawarmaNotifier(ref);
    });

class ShawarmaNotifier extends StateNotifier<ShawarmaGameState> {
  final Ref ref;

  ShawarmaNotifier(this.ref) : super(ShawarmaGameState()) {
    _initGame();
  }

  void _initGame() {
    List<ShawarmaCustomer> shuffledQueue = List.from(_customersBank)..shuffle();
    state = ShawarmaGameState(
      queue: shuffledQueue,
      currentCustomer: shuffledQueue.isNotEmpty ? shuffledQueue.first : null,
    );
  }

  void askQuestion(String answer) {
    state = state.copyWith(currentDialogue: answer);
  }

  bool tryAddIngredient(int ingredientId) {
    if (state.shawarmaStep == ingredientId - 1) {
      state = state.copyWith(shawarmaStep: ingredientId);
      return true;
    }
    return false;
  }

  void finishShawarma() {
    if (state.shawarmaStep == 4) {
      state = state.copyWith(shawarmaStep: 5);
    }
  }

  void serveCustomer() {
    if (state.currentCustomer == null || state.shawarmaStep != 5) return;

    if (state.currentCustomer!.type == "bueno") {
      state = state.copyWith(
        currentDialogue: "¡Muchas gracias! Se ve delicioso.",
      );
      Future.delayed(const Duration(seconds: 2), () {
        _handleResult(
          true,
          "¡Bien Hecho!",
          "Atendiste correctamente al cliente.",
        );
      });
    } else {
      _handleResult(false, "¡Cuidado!", state.currentCustomer!.errorMessage);
    }
  }

  void pressRedButton() {
    if (state.currentCustomer == null || state.isGateFalling) return;

    // 1. Cae la reja
    state = state.copyWith(
      isGateFalling: true,
      currentDialogue: null,
      clearDialogue: true,
    );

    // 2. Esperamos a que la reja caiga y mostramos la evaluación modal
    Future.delayed(const Duration(milliseconds: 600), () {
      if (state.currentCustomer!.type == "malo") {
        _handleResult(
          true,
          "¡Bien Hecho!",
          state.currentCustomer!.successMessage,
        );
      } else {
        _handleResult(false, "¡Cuidado!", state.currentCustomer!.errorMessage);
      }
    });
  }

  void _handleResult(bool isSuccess, String title, String message) {
    int newLives = state.lives;
    int newScore = state.score;

    if (isSuccess) {
      newScore += 10;
    } else {
      newLives -= 1;
    }

    state = state.copyWith(
      lives: newLives,
      score: newScore,
      showEvaluationModal: true,
      evalTitle: title,
      evalMessage: message,
    );
  }

  // Se llama cuando el usuario presiona "Continuar" en el modal
  void continueToNextCustomer() {
    if (state.lives <= 0) {
      state = state.copyWith(
        isGameOver: true,
        isVictory: false,
        showEvaluationModal: false,
      );
      _saveScoreToDatabase();
      return;
    }
    if (state.queue.length <= 1) {
      state = state.copyWith(
        isGameOver: true,
        isVictory: true,
        showEvaluationModal: false,
      );
      _saveScoreToDatabase();
      return;
    }

    List<ShawarmaCustomer> newQueue = List.from(state.queue)..removeAt(0);
    state = state.copyWith(
      queue: newQueue,
      currentCustomer: newQueue.first,
      shawarmaStep: 0,
      clearDialogue: true,
      showEvaluationModal: false,
      isGateFalling: false, // Levantamos la reja
    );
  }

  void resetGame() {
    _initGame();
  }

  Future<void> _saveScoreToDatabase() async {
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      await ref
          .read(scoreRepositoryProvider)
          .saveGameScore(
            userId: user.uid,
            gameId: 'shawarma',
            gameName: 'Shawarma Seguro',
            score: state.score,
          );
    }
  }
}
