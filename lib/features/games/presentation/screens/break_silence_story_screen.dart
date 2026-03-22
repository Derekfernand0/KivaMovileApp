import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/minigames_provider.dart';

// --- MODELOS DE LA HISTORIA ---
class StoryOption {
  final String label;
  final String nextNode;
  final bool isCorrect;

  StoryOption({
    required this.label,
    required this.nextNode,
    this.isCorrect = true,
  });
}

class StoryNode {
  final String emoji;
  final String text;
  final List<StoryOption> options;
  final Color cardColor;

  StoryNode({
    required this.emoji,
    required this.text,
    required this.options,
    this.cardColor = Colors.white,
  });
}

class BreakSilenceStoryScreen extends ConsumerStatefulWidget {
  const BreakSilenceStoryScreen({super.key});

  @override
  ConsumerState<BreakSilenceStoryScreen> createState() =>
      _BreakSilenceStoryScreenState();
}

class _BreakSilenceStoryScreenState
    extends ConsumerState<BreakSilenceStoryScreen> {
  int _internalScore = 0;

  // Banco de Historias Aleatorias
  final List<Map<String, StoryNode>> _storyBank = [
    {
      "start": StoryNode(
        emoji: "😰",
        text:
            "Tu amiga Sofía llora y te dice que un vecino mayor quiso jugar un 'juego de cosquillas' con ella, pero le pidió que sea su secreto. ¿Qué le dices?",
        options: [
          StoryOption(
            label: "Le prometo no decir nada para que confíe en mí.",
            nextNode: "bad1",
            isCorrect: false,
          ),
          StoryOption(
            label:
                "Los secretos que te hacen llorar son malos. ¡Vamos con la maestra!",
            nextNode: "end1",
            isCorrect: true,
          ),
        ],
      ),
      "bad1": StoryNode(
        emoji: "🚫",
        cardColor: const Color(0xFFFFE5E5),
        text:
            "¡Peligro! Guardar el secreto protege al vecino malo y Sofía sigue en riesgo. Los amigos de verdad buscan ayuda adulta.",
        options: [
          StoryOption(
            label: "Entiendo. La llevaré con la directora para protegerla.",
            nextNode: "end1",
            isCorrect: true,
          ),
        ],
      ),
      "end1": StoryNode(
        emoji: "🫂",
        cardColor: const Color(0xFFE5FFEA),
        text:
            "¡Súper valiente! La directora las escuchó. Sofía ya está a salvo y agradece que hayas roto el silencio por ella. 🎉",
        options: [],
      ),
    },
    {
      "start": StoryNode(
        emoji: "📱",
        text:
            "Ves que en el grupo de WhatsApp del salón están enviando memes burlándose de Mateo. En clase lo ves muy triste y callado.",
        options: [
          StoryOption(
            label: "Me río de los memes para que no se burlen de mí también.",
            nextNode: "bad1",
            isCorrect: false,
          ),
          StoryOption(
            label:
                "No digo nada en el grupo, le tomo captura y le aviso a mi mamá.",
            nextNode: "end1",
            isCorrect: true,
          ),
        ],
      ),
      "bad1": StoryNode(
        emoji: "😔",
        cardColor: const Color(0xFFFFE5E5),
        text:
            "Mateo se siente peor al ver que todos, incluso tú, se ríen. El silencio y las risas ayudan a los que molestan.",
        options: [
          StoryOption(
            label: "Tienes razón. Borraré mi mensaje y le avisaré a mi profe.",
            nextNode: "end1",
            isCorrect: true,
          ),
        ],
      ),
      "end1": StoryNode(
        emoji: "🛡️",
        cardColor: const Color(0xFFE5FFEA),
        text:
            "¡Excelente! El profe detuvo las burlas a tiempo. Mateo sabe que no está solo gracias a que decidiste actuar. 🎉",
        options: [],
      ),
    },
    {
      "start": StoryNode(
        emoji: "🎮",
        text:
            "Tu amigo Leo te cuenta emocionado que un jugador 'Nivel 100' le pidió su dirección de casa para enviarle diamantes gratis.",
        options: [
          StoryOption(
            label: "¡Qué chido! Le digo que me pida diamantes para mí también.",
            nextNode: "bad1",
            isCorrect: false,
          ),
          StoryOption(
            label:
                "¡Es una trampa! Le digo que bloquee a ese jugador y le avise a sus papás.",
            nextNode: "end1",
            isCorrect: true,
          ),
        ],
      ),
      "bad1": StoryNode(
        emoji: "⚠️",
        cardColor: const Color(0xFFFFE5E5),
        text:
            "¡Mucho cuidado! Los adultos que buscan contactar niños y piden direcciones en los juegos son muy peligrosos.",
        options: [
          StoryOption(
            label: "¡Mejor voy rápido a avisarle a los papás de Leo!",
            nextNode: "end1",
            isCorrect: true,
          ),
        ],
      ),
      "end1": StoryNode(
        emoji: "🛑",
        cardColor: const Color(0xFFE5FFEA),
        text:
            "¡Lo salvaste! Los papás de Leo bloquearon al estafador. Nunca des información personal a desconocidos de internet. 🎉",
        options: [],
      ),
    },
    {
      "start": StoryNode(
        emoji: "🥪",
        text:
            "En el recreo ves a Ana sentada sola. Otros niños no la dejaron jugar con ellos porque es 'nueva y rara'.",
        options: [
          StoryOption(
            label: "Voy y me siento a comer con ella.",
            nextNode: "end1",
            isCorrect: true,
          ),
          StoryOption(
            label: "La ignoro y me voy a jugar con mis amigos.",
            nextNode: "bad1",
            isCorrect: false,
          ),
        ],
      ),
      "bad1": StoryNode(
        emoji: "💔",
        cardColor: const Color(0xFFFFE5E5),
        text:
            "Ana se sintió invisible. A veces, la indiferencia duele tanto como las burlas. Un pequeño gesto tuyo puede cambiar su día.",
        options: [
          StoryOption(
            label: "Me regreso y le invito de mis galletas.",
            nextNode: "end1",
            isCorrect: true,
          ),
        ],
      ),
      "end1": StoryNode(
        emoji: "😊",
        cardColor: const Color(0xFFE5FFEA),
        text:
            "¡Héroe! Ana sonrió y platicaron muchísimo. Con tu empatía demostraste que en la escuela hay lugar para todos. 🎉",
        options: [],
      ),
    },
  ];

  late List<int> _availableIndices;
  late Map<String, StoryNode> _currentStory;
  late StoryNode _currentNode;

  @override
  void initState() {
    super.initState();
    _refillStories();
    _loadRandomStory();
  }

  void _refillStories() {
    _availableIndices = List.generate(_storyBank.length, (index) => index);
  }

  void _loadRandomStory() {
    if (_availableIndices.isEmpty) {
      _refillStories();
    }

    final random = Random();
    int randomIndexPosition = random.nextInt(_availableIndices.length);
    int storyIndex = _availableIndices[randomIndexPosition];

    _availableIndices.removeAt(randomIndexPosition);

    setState(() {
      _currentStory = _storyBank[storyIndex];
      _currentNode = _currentStory["start"]!;
    });
  }

  void _handleOptionTap(StoryOption option) {
    int pointsToGive = 0;
    if (option.isCorrect) {
      pointsToGive += 10;
    }

    if (_currentStory[option.nextNode]!.options.isEmpty) {
      pointsToGive += 5;
    }

    if (pointsToGive > 0) {
      setState(() {
        _internalScore += pointsToGive;
      });
      ref.read(miniGamesProvider.notifier).addRompeSilencioScore(pointsToGive);
    }

    setState(() {
      _currentNode = _currentStory[option.nextNode]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle = GoogleFonts.fredoka(
      color: AppTheme.inkLight,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      backgroundColor: AppTheme.paperLight,
      appBar: AppBar(
        title: Text(
          'Centro de Exploración',
          style: GoogleFonts.nunito(color: AppTheme.inkLight),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.inkLight),
      ),
      body: Column(
        children: [
          // --- CABECERA Y MARCADOR (Siempre visible arriba) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🎤 Rompe el silencio',
                        style: titleStyle.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Ayuda al personaje a elegir la mejor opción.',
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
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
          ),
          const SizedBox(height: 10),

          // --- CONTENIDO SCROLLABLE (Solución al Overflow) ---
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- TARJETA DE LA HISTORIA ---
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: _currentNode.cardColor,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: AppTheme.lineLight, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (child, animation) =>
                                ScaleTransition(scale: animation, child: child),
                            child: Text(
                              _currentNode.emoji,
                              key: ValueKey(_currentNode.emoji),
                              style: const TextStyle(fontSize: 100),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            _currentNode.text,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 22,
                              color: AppTheme.inkLight,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- BOTONES DE OPCIÓN ---
                    if (_currentNode.options.isEmpty)
                      // FINAL DE LA HISTORIA
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.peach,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 4,
                        ),
                        onPressed: _loadRandomStory,
                        icon: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Siguiente Historia',
                          style: GoogleFonts.fredoka(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      // BOTONES DE DECISIÓN
                      ..._currentNode.options.map(
                        (opt) => Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.inkLight,
                              padding: const EdgeInsets.symmetric(
                                vertical: 18,
                                horizontal: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              side: BorderSide(color: AppTheme.lilac, width: 3),
                              elevation: 2,
                            ),
                            onPressed: () => _handleOptionTap(opt),
                            child: Text(
                              opt.label,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.fredoka(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 20), // Margen inferior extra
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
