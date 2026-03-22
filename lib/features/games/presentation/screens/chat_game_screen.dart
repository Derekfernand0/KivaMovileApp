import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/minigames_provider.dart';

// --- MODELOS ---
class ChatOption {
  final String text;
  final bool safe;
  final String reply;
  ChatOption({required this.text, required this.safe, required this.reply});
}

class ChatScenario {
  final String sender;
  final String text;
  final List<ChatOption> options;
  ChatScenario({
    required this.sender,
    required this.text,
    required this.options,
  });
}

class ChatMessage {
  final String text;
  final String type; // 'receive', 'sent', 'system'
  final String? sender;
  ChatMessage({required this.text, required this.type, this.sender});
}

// --- BANCO DE ESCENARIOS (Exactos a tu JS) ---
final List<ChatScenario> _scenariosData = [
  ChatScenario(
    sender: "Desconocido",
    text: "Hola, vi tu perfil y me caíste súper bien. ¿Tienes fotos? 😉",
    options: [
      ChatOption(
        text: "¡Claro! ¿Quién eres?",
        safe: false,
        reply:
            "⛔ ¡Alto! Nunca envíes fotos a desconocidos. Pueden usarlas para hacerte daño.",
      ),
      ChatOption(
        text: "No te conozco, bloquear.",
        safe: true,
        reply: "✅ ¡Excelente! Bloquear es lo más seguro.",
      ),
    ],
  ),
  ChatScenario(
    sender: "GamerPro_99",
    text:
        "Oye, te regalo 1000 monedas para el juego. Solo pásame tu contraseña para depositarlas. 🎮",
    options: [
      ChatOption(
        text: "¡Gracias! Aquí está...",
        safe: false,
        reply: "⛔ ¡Peligro! Nunca des tu contraseña. Te robarán la cuenta.",
      ),
      ChatOption(
        text: "Nadie pide contraseñas para regalar cosas. Reportar.",
        safe: true,
        reply: "✅ ¡Muy bien! Identificaste una estafa (Phishing).",
      ),
    ],
  ),
  ChatScenario(
    sender: "Amigo_Misterioso",
    text:
        "Vamos a vernos en el parque, pero es NUESTRO SECRETO 🤫. No le digas a tus papás.",
    options: [
      ChatOption(
        text: "Bueno, pero rápido.",
        safe: false,
        reply:
            "⛔ ¡Alerta Roja! Los secretos que te piden ocultar a tus padres son peligrosos.",
      ),
      ChatOption(
        text: "No guardo secretos malos. Le diré a mi mamá.",
        safe: true,
        reply:
            "✅ ¡Perfecto! Cuéntaselo a un adulto de confianza inmediatamente.",
      ),
    ],
  ),
  ChatScenario(
    sender: "Perfil_Sin_Foto",
    text: "¿A qué escuela vas? Creo que te he visto a la salida. 🏫",
    options: [
      ChatOption(
        text: "Voy a la escuela [Nombre].",
        safe: false,
        reply:
            "⛔ ¡Cuidado! Nunca des datos de tu ubicación o rutina a extraños.",
      ),
      ChatOption(
        text: "¿Quién eres? No doy esa información.",
        safe: true,
        reply: "✅ ¡Bien hecho! Protege tus datos personales siempre.",
      ),
    ],
  ),
  ChatScenario(
    sender: "Anónimo",
    text:
        "Si no haces lo que te digo, voy a subir tus fotos y todos se burlarán de ti. 😠",
    options: [
      ChatOption(
        text: "Por favor no lo hagas, haré lo que sea.",
        safe: false,
        reply:
            "⛔ No cedas al chantaje. Eso les da más poder. Pide ayuda adulta urgente.",
      ),
      ChatOption(
        text: "No tengo miedo. Voy a avisar a un adulto.",
        safe: true,
        reply: "✅ ¡Valiente! Ante amenazas, no respondas y busca ayuda.",
      ),
    ],
  ),
  ChatScenario(
    sender: "Agencia_Talentos",
    text:
        "¡Hola! Tienes cara de modelo. Mándanos una foto de cuerpo completo para contratarte. 📸",
    options: [
      ChatOption(
        text: "¡Wow! ¿En serio? Ahí va.",
        safe: false,
        reply:
            "⛔ ¡Es una trampa común! Los adultos no buscan niños modelos por chat privado.",
      ),
      ChatOption(
        text: "No creo en esto. Adiós.",
        safe: true,
        reply:
            "✅ ¡Inteligente! Si fuera real, hablarían con tus padres, no contigo en secreto.",
      ),
    ],
  ),
  ChatScenario(
    sender: "Usuario_X",
    text:
        "Mi cámara no funciona, pero prende la tuya para que nos conozcamos mejor. 📹",
    options: [
      ChatOption(
        text: "Está bien, la prendo un rato.",
        safe: false,
        reply:
            "⛔ ¡Riesgo! No enciendas tu cámara para desconocidos. Podrían grabarte.",
      ),
      ChatOption(
        text: "No. No hago videollamadas con extraños.",
        safe: true,
        reply: "✅ ¡Exacto! Tu privacidad en video es muy importante.",
      ),
    ],
  ),
  ChatScenario(
    sender: "Lobo_Solitario",
    text:
        "Tus papás no te entienden como yo. Yo soy el único que te escucha de verdad. 🐺",
    options: [
      ChatOption(
        text: "Sí, tienes razón. Ellos son malos.",
        safe: false,
        reply:
            "⛔ ¡Cuidado! Alguien que te pone en contra de tu familia te quiere aislar.",
      ),
      ChatOption(
        text: "Eso no es cierto. Me voy de este chat.",
        safe: true,
        reply:
            "✅ ¡Muy bien! Detectaste una manipulación. Aléjate de esa persona.",
      ),
    ],
  ),
];

class ChatGameScreen extends ConsumerStatefulWidget {
  const ChatGameScreen({super.key});

  @override
  ConsumerState<ChatGameScreen> createState() => _ChatGameScreenState();
}

class _ChatGameScreenState extends ConsumerState<ChatGameScreen> {
  List<int> _availableIndices = [];
  ChatScenario? _currentScenario;
  final List<ChatMessage> _messages = [];
  List<ChatOption> _currentOptions = [];

  String _feedbackText = "";
  Color _feedbackColor = Colors.transparent;

  // 👇 MARCADOR LOCAL
  int _internalScore = 0;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _refillBag() {
    _availableIndices = List.generate(_scenariosData.length, (index) => index);
  }

  void _resetGame() {
    setState(() {
      _messages.clear();
      _feedbackText = "";
      _currentOptions = [];
    });

    if (_availableIndices.isEmpty) {
      _refillBag();
    }

    final random = Random();
    int randomIndexPosition = random.nextInt(_availableIndices.length);
    int scenarioIndex = _availableIndices[randomIndexPosition];

    _availableIndices.removeAt(randomIndexPosition);
    _currentScenario = _scenariosData[scenarioIndex];

    _playScenario();
  }

  void _playScenario() {
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      _addMessage(
        _currentScenario!.text,
        "receive",
        sender: _currentScenario!.sender,
      );

      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        setState(() {
          _currentOptions = List.from(_currentScenario!.options)..shuffle();
        });
        _scrollToBottom();
      });
    });
  }

  void _addMessage(String text, String type, {String? sender}) {
    setState(() {
      _messages.add(ChatMessage(text: text, type: type, sender: sender));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _checkAnswer(ChatOption opt) {
    // 👇 CÁLCULO DE PUNTOS DINÁMICO
    int pointsEarned = 5; // Puntos base por interacción
    if (opt.safe) {
      pointsEarned += 10; // +10 por decisión correcta y segura
    }

    setState(() {
      _internalScore += pointsEarned; // Actualiza el UI
      _currentOptions = [];
      _feedbackText = opt.reply;
      _feedbackColor = opt.safe
          ? const Color(0xFF2ed573)
          : const Color(0xFFe74c3c);
    });

    _addMessage(opt.text, "sent");

    // 👇 Enviar puntos al controlador global
    ref.read(miniGamesProvider.notifier).addDetectaEnganoScore(pointsEarned);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      if (opt.safe) {
        _addMessage(
          "🛡️ Has tomado la decisión segura. (+$pointsEarned pts)",
          "system",
        );
      } else {
        _addMessage(
          "⚠️ Situación de riesgo. Bloqueando usuario... (+$pointsEarned pts por explorar)",
          "system",
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.paperLight,
      appBar: AppBar(
        title: Text(
          'Centro de Exploración',
          style: GoogleFonts.fredoka(color: AppTheme.inkLight),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.inkLight),
      ),
      body: Column(
        children: [
          // 👇 CABECERA CON MARCADOR INCORPORADO
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
                        '📱 Detecta el Engaño',
                        style: GoogleFonts.fredoka(
                          fontSize: 24,
                          color: AppTheme.inkLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Elige la respuesta segura.',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // El marcador estilo Semáforo
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

          // Pantalla del Chat (El Teléfono)
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2F5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  children: [
                    // Barra superior del "Chat"
                    Container(
                      padding: const EdgeInsets.all(15),
                      color: const Color(0xFF2c3e50),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, color: Colors.grey),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _currentScenario?.sender ?? "Conectando...",
                              style: GoogleFonts.fredoka(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Lista de Mensajes
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(15),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          return _buildChatBubble(_messages[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Feedback de la respuesta
          if (_feedbackText.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: _feedbackColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: _feedbackColor, width: 2),
              ),
              child: Text(
                _feedbackText,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.inkLight,
                ),
              ),
            ),

          // Opciones (Botones de respuesta)
          if (_currentOptions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _currentOptions
                    .map(
                      (opt) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.inkLight,
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            side: BorderSide(color: AppTheme.lilac, width: 2),
                            elevation: 2,
                          ),
                          onPressed: () => _checkAnswer(opt),
                          child: Text(
                            opt.text,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.fredoka(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

          // Botón de Siguiente Chat
          if (_feedbackText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                bottom: 20.0,
                left: 20,
                right: 20,
                top: 10,
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.peach,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                ),
                onPressed: _resetGame,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: Text(
                  "Siguiente Mensaje",
                  style: GoogleFonts.fredoka(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage msg) {
    if (msg.type == 'system') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              msg.text,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: Colors.black54,
              ),
            ),
          ),
        ),
      );
    }

    bool isMe = msg.type == 'sent';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ), // Un poco más ancho para los mensajes largos
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFDCF8C6) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 20),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          msg.text,
          style: GoogleFonts.nunito(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
