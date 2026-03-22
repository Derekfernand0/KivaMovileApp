import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/minigames_provider.dart';

class EmotionDialScreen extends ConsumerStatefulWidget {
  const EmotionDialScreen({super.key});

  @override
  ConsumerState<EmotionDialScreen> createState() => _EmotionDialScreenState();
}

class _EmotionDialScreenState extends ConsumerState<EmotionDialScreen> {
  // Ángulo visual inicial (0 = Arriba)
  double _rotationAngleDeg = 0.0;
  int _currentEmotionIndex = 4; // Índice de "Calmado" (Centro)
  final GlobalKey _dialKey = GlobalKey();

  // --- DATOS EXACTOS DE APP.JS (8 Emociones con sus Frases) ---
  final List<Map<String, dynamic>> _emotionsData = [
    {
      'name': 'Asustado',
      'icon': '😲',
      'color': const Color(0xFF9b59b6),
      'quote':
          '¡Oh! Algo inesperado pasó. El miedo nos ayuda a estar alerta y buscar seguridad cuando la necesitamos.',
    },
    {
      'name': 'Triste',
      'icon': '😢',
      'color': const Color(0xFF3498db),
      'quote':
          'Está bien estar triste. La tristeza nos dice que algo nos importa y nos invita a buscar consuelo y apoyo.',
    },
    {
      'name': 'Enojado',
      'icon': '😠',
      'color': const Color(0xFFe74c3c),
      'quote':
          'El enojo nos dice cuando algo no es justo o cuando necesitamos defender nuestros límites con respeto.',
    },
    {
      'name': 'Preocupado',
      'icon': '😟',
      'color': const Color(0xFFe67e22),
      'quote':
          'La preocupación nos invita a pensar en soluciones y a prepararnos para los retos con cuidado.',
    },
    {
      'name': 'Calmado',
      'icon': '😌',
      'color': const Color(0xFF2ecc71),
      'quote':
          'La calma nos ayuda a pensar con claridad y a disfrutar el momento presente con tranquilidad.',
    },
    {
      'name': 'Feliz',
      'icon': '😄',
      'color': const Color(0xFFf1c40f),
      'quote':
          '¡Qué alegría! Comparte tu felicidad y deja que esa energía positiva ilumine tu día y el de los demás.',
    },
    {
      'name': 'Nervioso',
      'icon': '😰',
      'color': const Color(0xFF1abc9c),
      'quote':
          'Los nervios son normales ante algo nuevo. Respira profundo, ¡tú puedes manejar esta situación!',
    },
    {
      'name': 'Confundido',
      'icon': '😕',
      'color': const Color(0xFF34495e),
      'quote':
          'La confusión es el inicio del aprendizaje. Está bien hacer preguntas hasta entender mejor.',
    },
  ];

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_dialKey.currentContext == null) return;
    final RenderBox renderBox =
        _dialKey.currentContext!.findRenderObject() as RenderBox;

    // Obtenemos el centro del widget
    final center = Offset(renderBox.size.width / 2, renderBox.size.height / 2);
    // Posición del toque relativa al widget
    final touchPoint = renderBox.globalToLocal(details.globalPosition);

    // Matemática exacta de tu app.js: atan2(dy, dx) y ajuste para que 0 sea arriba
    double dy = center.dy - touchPoint.dy;
    double dx = touchPoint.dx - center.dx;
    double angleRad = atan2(dy, dx);
    double angleDeg = angleRad * (180 / pi);

    // Ajustamos para que 0 grados sea "Arriba"
    angleDeg = -(angleDeg - 90);

    // Limitar entre 180 y -180 para el control lógico
    if (angleDeg > 180) angleDeg -= 360;
    if (angleDeg < -180) angleDeg += 360;

    // === LÍMITE EXACTO DE TU JS (Media Vuelta, tope en 150 y -150) ===
    if (angleDeg > 150 || angleDeg < -150) return;

    // Mapeamos los grados (-150 a 150) a un índice de 0 a 7
    // Rango total = 300 grados
    double normalized = (angleDeg + 150) / 300;
    int index = (normalized * _emotionsData.length).floor().clamp(
      0,
      _emotionsData.length - 1,
    );

    setState(() {
      _rotationAngleDeg = angleDeg;
      _currentEmotionIndex = index;
    });

    // Otorgar puntos al interactuar
    ref.read(miniGamesProvider.notifier).completeEmocionometro();
  }

  @override
  Widget build(BuildContext context) {
    final currentEmotion = _emotionsData[_currentEmotionIndex];
    final currentColor = currentEmotion['color'] as Color;

    return Scaffold(
      backgroundColor: AppTheme.paperLight,
      appBar: AppBar(
        title: Text(
          'Centro de Exploración',
          style: GoogleFonts.fredoka(
            color: AppTheme.inkLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.inkLight),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
        child: Column(
          children: [
            Text(
              '🧭 Emocionómetro',
              textAlign: TextAlign.center,
              style: GoogleFonts.fredoka(
                fontSize: 32,
                color: AppTheme.inkLight,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '¿Cómo te sientes hoy?\nGira la bolita con tu dedo.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 18,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 40),

            // === EL DIAL VISUAL ===
            GestureDetector(
              onPanUpdate: _handlePanUpdate,
              child: Stack(
                alignment: Alignment.center,
                key: _dialKey,
                children: [
                  // 1. Fondo del Dial (Círculo estático con gradiente)
                  Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFFf1c40f), Color(0xFFe67e22)],
                        stops: [0.6, 1.0],
                      ),
                      border: Border.all(color: AppTheme.inkLight, width: 4),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                  ),

                  // 2. El Indicador (Bolita blanca giratoria / Knob)
                  Transform.rotate(
                    angle:
                        _rotationAngleDeg *
                        (pi / 180), // Convertimos grados a radianes
                    child: SizedBox(
                      width: 260,
                      height: 260,
                      child: Align(
                        alignment: Alignment.topCenter, // Inicia arriba
                        child: Container(
                          width: 28,
                          height: 28,
                          margin: const EdgeInsets.only(
                            top: 2,
                          ), // Pegado al borde superior
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.inkLight,
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(color: Colors.black45, blurRadius: 4),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 3. Círculo Central con el Emoji (Estático)
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF2c3e50),
                      border: Border.all(color: Colors.white, width: 5),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 8),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        currentEmotion['icon'] as String,
                        style: const TextStyle(fontSize: 80),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Nombre de la Emoción
            Text(
              currentEmotion['name'] as String,
              style: GoogleFonts.fredoka(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: currentColor,
              ),
            ),

            const SizedBox(height: 20),

            // === LA FRASE EDUCATIVA ===
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300, width: 2),
                // Borde lateral de color
                boxShadow: [
                  BoxShadow(color: currentColor, offset: const Offset(-8, 0)),
                ],
              ),
              child: Text(
                currentEmotion['quote'] as String,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.inkLight,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
