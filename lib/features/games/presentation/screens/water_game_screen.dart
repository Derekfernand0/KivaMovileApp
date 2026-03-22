import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/water_game_provider.dart';

class WaterGameScreen extends ConsumerWidget {
  const WaterGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(waterGameProvider);
    final notifier = ref.read(waterGameProvider.notifier);

    // Constante visual: altura de cada bloque
    const double blockHeight = 40.0;

    // Cálculo para el efecto de cámara:
    // Si el jugador sube de la mitad de la pantalla, bajamos el mundo para seguirlo
    final double screenHeight = MediaQuery.of(context).size.height;
    final double playerAltitude = gameState.playerBlocks * blockHeight;
    final double cameraOffset = playerAltitude > (screenHeight * 0.4)
        ? (playerAltitude - (screenHeight * 0.4))
        : 0;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Fondo (isla.png difuminada)
          Image.asset(
            'assets/images/isla.png',
            fit: BoxFit.cover,
            color: Colors.white.withOpacity(0.4),
            colorBlendMode: BlendMode.lighten,
          ),

          // 2. EL MUNDO (Bloques y Jugador) - Se mueve con el efecto cámara
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            bottom: -cameraOffset, // Desplaza hacia abajo
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // El Jugador (niño.png)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 80,
                  width: 60,
                  child: Image.asset(
                    'assets/images/niño.png',
                    fit: BoxFit.contain,
                  ),
                ),
                // Los Bloques apilados
                ...List.generate(gameState.playerBlocks, (index) {
                  return Container(
                    width: 220,
                    height: blockHeight,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                      // Alternamos colores para que se vea como en tu CSS
                      color: index % 2 == 0 ? AppTheme.peach : AppTheme.pink,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black12),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, offset: Offset(0, -2)),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // 3. EL AGUA (mar.png repetido)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            bottom: -cameraOffset, // El agua también sigue la cámara
            left: 0,
            right: 0,
            height: gameState.waterBlocks * blockHeight,
            child: Container(
              color: Colors.blue.withOpacity(0.7),
              child: Image.asset(
                'assets/images/mar.png',
                repeat: ImageRepeat.repeatX,
                alignment: Alignment.topCenter,
              ),
            ),
          ),

          // 4. INTERFAZ DE USUARIO (Preguntas y tiempo) - Queda fija arriba del todo
          SafeArea(
            child: Column(
              children: [
                // Barra Superior (Botón salir y Marcador de agua)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppTheme.inkLight,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade800,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Nivel Agua: ${gameState.waterBlocks}',
                          style: GoogleFonts.fredoka(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Tarjeta de Preguntas (Se oculta si el juego terminó)
                if (!gameState.isGameOver)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Barra de progreso del temporizador
                        LinearProgressIndicator(
                          value: gameState.timeLeft / 10,
                          backgroundColor: Colors.grey.shade300,
                          color: gameState.timeLeft > 3
                              ? AppTheme.ringLight
                              : Colors.red,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        const SizedBox(height: 16),

                        // Texto de la Pregunta
                        Text(
                          gameState.currentQuestion.text,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.fredoka(
                            fontSize: 20,
                            color: AppTheme.inkLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Opciones
                        ...List.generate(
                          gameState.currentQuestion.options.length,
                          (index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.all(16),
                                    side: const BorderSide(
                                      color: AppTheme.blue,
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    foregroundColor: AppTheme.inkLight,
                                  ),
                                  onPressed: () =>
                                      notifier.answerQuestion(index),
                                  child: Text(
                                    gameState.currentQuestion.options[index],
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // 5. PANTALLA DE GAME OVER
          if (gameState.isGameOver)
            Container(
              color: Colors.black87,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        gameState.isVictory
                            ? '¡TE SALVASTE!'
                            : '¡TE HAS AHOGADO!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: gameState.isVictory
                              ? Colors.greenAccent
                              : Colors.redAccent,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Alcanzaste una altura de: ${gameState.playerBlocks} bloques',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () => notifier.resetGame(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.peach,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                        ),
                        child: Text(
                          'Reintentar',
                          style: GoogleFonts.fredoka(fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Salir',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
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
