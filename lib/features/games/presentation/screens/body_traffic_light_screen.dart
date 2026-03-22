import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/minigames_provider.dart';

// Modelo para los puntos interactivos
class BodyDot {
  final double topPercent;
  final double leftPercent;
  final Color color;
  final String message;

  BodyDot({
    required this.topPercent,
    required this.leftPercent,
    required this.color,
    required this.message,
  });
}

class BodyTrafficLightScreen extends ConsumerStatefulWidget {
  const BodyTrafficLightScreen({super.key});

  @override
  ConsumerState<BodyTrafficLightScreen> createState() =>
      _BodyTrafficLightScreenState();
}

class _BodyTrafficLightScreenState
    extends ConsumerState<BodyTrafficLightScreen> {
  BodyDot? _selectedDot;

  // 👇 MARCADOR LOCAL Y REGISTRO DE DESCUBRIMIENTOS
  int _internalScore = 0;
  final Set<BodyDot> _touchedDots =
      {}; // Guarda los círculos que ya se tocaron para no repetir puntos

  // Colores exactos
  final Color _green = const Color(0xFF2ed573);
  final Color _yellow = const Color(0xFFf1c40f);
  final Color _red = const Color(0xFFe74c3c);

  // Lista exacta de puntos basados en tu HTML
  late final List<BodyDot> _dots;

  @override
  void initState() {
    super.initState();
    _dots = [
      // --- NIÑO (Izquierda) ---
      BodyDot(
        topPercent: 0.26,
        leftPercent: 0.32,
        color: _green,
        message:
            "🟢 CABEZA: ¡Está bien! Las caricias en la cabeza de tus papás son cariño seguro.",
      ),
      BodyDot(
        topPercent: 0.42,
        leftPercent: 0.32,
        color: _red,
        message:
            "🔴 BOCA: ¡ALTO! Nadie puede obligarte a dar besos. Tu boca es tuya.",
      ),
      BodyDot(
        topPercent: 0.54,
        leftPercent: 0.28,
        color: _red,
        message:
            "🔴 PECHO: ¡Nadie toca! Es tu zona privada. Si alguien te toca, cuéntalo.",
      ),
      BodyDot(
        topPercent: 0.66,
        leftPercent: 0.24,
        color: _yellow,
        message:
            "🟡 MANOS: ¡Atención! Solo da la mano si tú quieres y te sientes cómoda/o.",
      ),
      BodyDot(
        topPercent: 0.66,
        leftPercent: 0.32,
        color: _red,
        message:
            "🔴 ENTREPIERNA: ¡PROHIBIDO! Nadie debe tocar tus partes privadas. ¡Grita NO!",
      ),
      BodyDot(
        topPercent: 0.80,
        leftPercent: 0.32,
        color: _yellow,
        message:
            "🟡 PIES: ¡Cuidado! Fíjate por dónde caminas y aléjate si algo no te gusta.",
      ),

      // --- NIÑA (Derecha) ---
      BodyDot(
        topPercent: 0.26,
        leftPercent: 0.68,
        color: _green,
        message:
            "🟢 MENTE: ¡Pensamientos sanos! Nadie debe pedirte guardar secretos malos.",
      ),
      BodyDot(
        topPercent: 0.425,
        leftPercent: 0.685,
        color: _red,
        message: "🔴 BOCA: ¡ALTO! Nadie extraño debe pedirte besos.",
      ),
      BodyDot(
        topPercent: 0.54,
        leftPercent: 0.715,
        color: _red,
        message:
            "🔴 PECHO: Zona privada. Nadie puede tocarte aquí bajo la ropa.",
      ),
      BodyDot(
        topPercent: 0.66,
        leftPercent: 0.76,
        color: _yellow,
        message: "🟡 MANOS: ¡Ojo! Ten cuidado quién te toma de la mano.",
      ),
      BodyDot(
        topPercent: 0.68,
        leftPercent: 0.685,
        color: _red,
        message:
            "🔴 ENTREPIERNA: ¡ALTO TOTAL! Nadie puede tocar ni pedirte que toques.",
      ),
      BodyDot(
        topPercent: 0.80,
        leftPercent: 0.68,
        color: _yellow,
        message:
            "🟡 PIES: ¡Cuidado! Si alguien te sigue, corre hacia un adulto de confianza.",
      ),
    ];
  }

  void _onDotTapped(BodyDot dot) {
    setState(() {
      _selectedDot = dot;

      // 👇 LÓGICA DE PUNTOS DINÁMICA
      // Si el círculo no había sido tocado antes, damos puntos
      if (!_touchedDots.contains(dot)) {
        _touchedDots.add(dot);
        _internalScore += 5; // 5 puntos por cada descubrimiento
        ref.read(miniGamesProvider.notifier).addSemaforoCuerpoScore(5);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedDot = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Estilos de tipografía infantil
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 👇 CABECERA CON MARCADOR (Igual al chat)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🚦 Semáforo del Cuerpo',
                          style: titleStyle.copyWith(fontSize: 24),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Toca los círculos para descubrir.',
                          style: bodyStyle.copyWith(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Marcador de puntos
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
              const SizedBox(height: 30),

              // Contenedor principal del juego
              GestureDetector(
                onTap:
                    _clearSelection, // Si tocan fuera de los puntos, se reinicia
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.lineLight, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // LA IMAGEN CON LOS PUNTOS INTERACTIVOS
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // Obtenemos el ancho disponible para calcular posiciones exactas
                          final double maxWidth = constraints.maxWidth;

                          return Stack(
                            children: [
                              // 1. Imagen de fondo
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  'assets/images/ninos.jpg',
                                  width: maxWidth,
                                  fit: BoxFit.contain,
                                ),
                              ),

                              // 2. Los puntos interactivos superpuestos
                              if (maxWidth > 0)
                                Positioned.fill(
                                  child: Stack(
                                    children: _dots.map((dot) {
                                      // Saber si ya lo tocamos para hacerlo ligeramente transparente si queremos,
                                      // pero lo dejaremos normal para que siga siendo colorido.
                                      bool isTouched = _touchedDots.contains(
                                        dot,
                                      );

                                      return Align(
                                        alignment: FractionalOffset(
                                          dot.leftPercent,
                                          dot.topPercent,
                                        ),
                                        child: GestureDetector(
                                          onTap: () => _onDotTapped(dot),
                                          child: AnimatedScale(
                                            scale: _selectedDot == dot
                                                ? 1.3
                                                : 1.0, // El seleccionado se hace grande
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: dot.color,
                                                shape: BoxShape.circle,
                                                // Le ponemos una marca visual sutil si ya fue descubierto
                                                border: Border.all(
                                                  color: isTouched
                                                      ? Colors.white70
                                                      : Colors.white,
                                                  width: 3,
                                                ),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.black45,
                                                    blurRadius: 4,
                                                  ),
                                                ],
                                              ),
                                              // Le ponemos una palomita chiquita si ya dio puntos (opcional, ayuda al niño a saber qué le falta)
                                              child: isTouched
                                                  ? const Icon(
                                                      Icons.check,
                                                      size: 15,
                                                      color: Colors.white,
                                                    )
                                                  : null,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // LA CAJA DE FEEDBACK (El mensaje que aparece al tocar)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color:
                              _selectedDot?.color.withOpacity(0.1) ??
                              Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: _selectedDot?.color ?? Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          _selectedDot?.message ??
                              "👆 Toca los puntos de colores en el dibujo.",
                          textAlign: TextAlign.center,
                          style: bodyStyle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _selectedDot != null
                                ? AppTheme.inkLight
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
