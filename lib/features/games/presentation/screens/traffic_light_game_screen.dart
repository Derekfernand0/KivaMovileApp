import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/minigames_provider.dart';

// --- MODELO DE SITUACIÓN (Exacto al JS) ---
class SituationModel {
  final String text; // t
  final String emoji; // e
  final String color; // c (green, yellow, red)

  SituationModel({
    required this.text,
    required this.emoji,
    required this.color,
  });
}

// --- BANCO DE SITUACIONES (Copiado Verbatim de tu código) ---
final List<SituationModel> _allSituations = [
  // --- VERDE (Seguro / Confianza) ---
  SituationModel(
    text: "Abrazo de mamá o papá cuando tú quieres",
    emoji: "🤗",
    color: "green",
  ),
  SituationModel(
    text: "La doctora te revisa con tu mamá presente",
    emoji: "👩‍⚕️",
    color: "green",
  ),
  SituationModel(
    text: "Jugar y reír con tus amigos en el recreo",
    emoji: "⚽",
    color: "green",
  ),
  SituationModel(
    text: "Tu abuela te da la mano para cruzar la calle",
    emoji: "👵",
    color: "green",
  ),
  SituationModel(
    text: "Chocar las manos con tu mejor amigo",
    emoji: "🙏",
    color: "green",
  ),
  SituationModel(
    text: "Decir 'NO' a algo que no te gusta",
    emoji: "🛑",
    color: "green",
  ),
  SituationModel(
    text: "Tu tío te lee un cuento en la sala",
    emoji: "📖",
    color: "green",
  ),
  SituationModel(
    text: "Bañarte tú solito/a con la puerta cerrada",
    emoji: "🚿",
    color: "green",
  ),

  // --- AMARILLO (Alerta / Incomodidad / Límites) ---
  SituationModel(
    text: "Un familiar te pide beso y tú NO quieres",
    emoji: "💋",
    color: "yellow",
  ),
  SituationModel(
    text: "Alguien te hace cosquillas y no para",
    emoji: "😖",
    color: "yellow",
  ),
  SituationModel(
    text: "Un amigo te empuja jugando y te duele",
    emoji: "😣",
    color: "yellow",
  ),
  SituationModel(
    text: "Sientes 'mariposas malas' en la panza",
    emoji: "🦋",
    color: "yellow",
  ),
  SituationModel(
    text: "Alguien te dice 'qué bonito cuerpo tienes'",
    emoji: "👀",
    color: "yellow",
  ),
  SituationModel(
    text: "Te obligan a saludar de beso a una visita",
    emoji: "😒",
    color: "yellow",
  ),

  // --- ROJO (Peligro / Pedir Ayuda Urgente) ---
  SituationModel(
    text: "Un desconocido te ofrece dulces o regalos",
    emoji: "🍬",
    color: "red",
  ),
  SituationModel(
    text: "Alguien te pide guardar un secreto 'malo'",
    emoji: "🤫",
    color: "red",
  ),
  SituationModel(
    text: "Te piden que te quites la ropa para una foto",
    emoji: "📸",
    color: "red",
  ),
  SituationModel(
    text: "Un extraño te invita a subir a su coche",
    emoji: "🚗",
    color: "red",
  ),
  SituationModel(
    text: "Alguien toca tus partes privadas",
    emoji: "👙",
    color: "red",
  ),
  SituationModel(
    text: "Te amenazan si cuentas lo que pasó",
    emoji: "😠",
    color: "red",
  ),
  SituationModel(
    text: "Un desconocido te contacta por internet",
    emoji: "💻",
    color: "red",
  ),
];

class TrafficLightGameScreen extends ConsumerStatefulWidget {
  const TrafficLightGameScreen({super.key});

  @override
  ConsumerState<TrafficLightGameScreen> createState() =>
      _TrafficLightGameScreenState();
}

class _TrafficLightGameScreenState
    extends ConsumerState<TrafficLightGameScreen> {
  List<SituationModel> _deck = []; // La baraja actual
  int _internalScore = 0; // Puntos: 0 (JS score)
  bool _isPlaying = false; // Presiona Iniciar
  SituationModel? _currentSituation; // currentItem
  String _feedbackMessage = ""; // feedback.textContent
  Color _feedbackColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    // No barajamos hasta que pulsen "Iniciar"
  }

  // Lógica exacta de JS: Barajar deck y sacar última carta
  SituationModel _getNextCard() {
    if (_deck.isEmpty) {
      _deck = List.from(_allSituations); // allLevels
      _deck.shuffle(); // shuffle()
    }
    return _deck.removeLast(); // deck.pop()
  }

  // Lógica exacta de JS: Reiniciar score y deck
  void _startGame() {
    setState(() {
      _internalScore = 0;
      _isPlaying = true;
      _deck = []; // Limpiar para forzar la recarga
      _feedbackMessage = "";
      _loadNextCard();
    });
  }

  void _loadNextCard() {
    setState(() {
      _currentSituation = _getNextCard();
    });
  }

  // Lógica exacta de JS: +10 si es bien, 0 si oops, delay de 900ms
  void _checkAnswer(String userColor) {
    if (!_isPlaying || _feedbackMessage.isNotEmpty)
      return; // Evita toques múltiples

    bool isCorrect = (userColor == _currentSituation!.color);

    setState(() {
      if (isCorrect) {
        _feedbackMessage = "¡BIEN! 👍";
        _feedbackColor = const Color(0xFF2ed573); // Color de .correct
        _internalScore += 10;
      } else {
        _feedbackMessage = "OOPS ✋";
        _feedbackColor = const Color(0xFFe74c3c); // Color de .wrong
        // No bajamos puntos
      }
    });

    // Avisar al provider global (solo la primera vez)
    ref.read(miniGamesProvider.notifier).completeSemaforoSituaciones();

    // Siguiente carta después de 900ms
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() {
          _feedbackMessage = ""; // reset feedback className
          _loadNextCard();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Estilos para niños (Redondeados y claros)
    final TextStyle titleStyle = GoogleFonts.fredoka(
      color: AppTheme.inkLight,
      fontWeight: FontWeight.bold,
    );
    final TextStyle bodyStyle = GoogleFonts.nunito(color: AppTheme.inkLight);

    return Scaffold(
      backgroundColor: AppTheme.paperLight,
      appBar: AppBar(
        title: Text('Centro de Exploración', style: bodyStyle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.inkLight),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- CABECERA (semaforo-header) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👇 Envolvemos el título en un Expanded para que no empuje al marcador
                Expanded(
                  child: Text(
                    '🚦 Semáforo de Situaciones',
                    style: titleStyle.copyWith(fontSize: 22),
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: 10),
                // Marcador (score-board)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2c3e50),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    'Puntos: $_internalScore',
                    style: GoogleFonts.fredoka(
                      color: AppTheme.yellow,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Subtítulo (.small)
            Text(
              '¿Seguro, Incómodo o Peligro?\n¡Toca el color correcto!',
              textAlign: TextAlign.center,
              style: bodyStyle.copyWith(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 30),

            // --- ÁREA DE JUEGO (sem-game-area) ---
            Stack(
              alignment: Alignment.center,
              children: [
                // LA CARTA (sem-card)
                Container(
                  padding: const EdgeInsets.all(30),
                  height: 350,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.lineLight, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: _currentSituation == null
                      // Pantalla de inicio "Presiona Iniciar"
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '🎮',
                              style: TextStyle(fontSize: 80),
                            ), // .sem-emoji
                            const SizedBox(height: 15),
                            Text(
                              'Presiona Iniciar',
                              textAlign: TextAlign.center,
                              style: titleStyle.copyWith(
                                fontSize: 24,
                                color: AppTheme.lineLight,
                              ),
                            ), // .sem-text
                          ],
                        )
                      // Pantalla de juego (Mecánica de 'cards' con emoji y texto)
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentSituation!.emoji,
                              style: const TextStyle(fontSize: 100),
                            ), // .sem-emoji
                            const SizedBox(height: 15),
                            Text(
                              _currentSituation!.text,
                              textAlign: TextAlign.center,
                              style: titleStyle.copyWith(fontSize: 22),
                            ), // .sem-text
                          ],
                        ),
                ),

                // FEEDBACK OVERLAY (.sem-feedback)
                if (_feedbackMessage.isNotEmpty)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: _feedbackColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            _feedbackMessage,
                            style: titleStyle.copyWith(
                              fontSize: 32,
                              color: _feedbackColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 30),

            // --- CONTROLES (sem-controls) ---
            Row(
              children: [
                Expanded(
                  child: _buildTrafficButton(
                    context,
                    "🟢\nSeguro",
                    const Color(0xFF2ed573),
                    "green",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTrafficButton(
                    context,
                    "🟡\nAlerta",
                    AppTheme.yellow,
                    "yellow",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTrafficButton(
                    context,
                    "🔴\nPeligro",
                    const Color(0xFFe74c3c),
                    "red",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // BOTÓN COMENZAR/REINICIAR (#startSemBtn)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lilac,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: _startGame,
              child: Text(
                _isPlaying ? "Reiniciar Juego" : "¡Comenzar Juego!",
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Constructor para los botones del semáforo
  Widget _buildTrafficButton(
    BuildContext context,
    String title,
    Color color,
    String colorKey,
  ) {
    bool isFeedbackActive = _feedbackMessage.isNotEmpty;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        disabledBackgroundColor: color.withOpacity(0.3),
        // 👇 Redujimos el padding horizontal para que quepan mejor
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: Color(0xFF2c3e50), width: 3),
        elevation: 4,
        shadowColor: Colors.black26,
      ),
      onPressed: (_currentSituation == null || isFeedbackActive)
          ? null
          : () => _checkAnswer(colorKey),
      child: Text(
        title,
        textAlign: TextAlign.center,
        // 👇 Centramos el texto porque ahora tiene un salto de línea (\n)
        style: GoogleFonts.fredoka(
          fontSize: 15,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
