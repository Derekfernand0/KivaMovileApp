import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/doors_game_provider.dart';

class DoorsGameScreen extends ConsumerWidget {
  const DoorsGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(doorsGameProvider);
    final notifier = ref.read(doorsGameProvider.notifier);

    // --- PANTALLA DE FIN DE JUEGO ---
    if (gameState.isGameOver) {
      return Scaffold(
        backgroundColor: AppTheme.inkLight,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  gameState.isVictory
                      ? Icons.emoji_events
                      : Icons.sentiment_dissatisfied,
                  size: 100,
                  color: gameState.isVictory ? AppTheme.yellow : AppTheme.pink,
                ),
                const SizedBox(height: 20),
                Text(
                  gameState.isVictory ? '¡Felicidades!' : '¡Oh no!',
                  style: GoogleFonts.fredoka(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  gameState.isVictory
                      ? 'Has completado el juego.\nPuntuación Final: ${gameState.score}'
                      : 'Te quedaste sin vidas.\nPuntuación Final: ${gameState.score}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => notifier.resetGame(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.peach,
                  ),
                  child: const Text('Volver a Intentar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Salir al Muro',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // --- PANTALLA PRINCIPAL DEL JUEGO ---
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Fondo (Imagen FELRC.png difuminada)
          // *Si aún no tienes la imagen, puedes comentar esto y usar un color sólido
          Image.asset(
            'assets/images/FELRC.png',
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(
              0.4,
            ), // Oscurece un poco para que el texto se lea
            colorBlendMode: BlendMode.darken,
          ),

          // 2. Efecto de Destello (Verde/Rojo) al responder
          if (gameState.isAnimating && gameState.selectedDoorIndex != null)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              color:
                  gameState.selectedDoorIndex ==
                      gameState.currentQuestion.correctIndex
                  ? Colors.green.withOpacity(0.4)
                  : Colors.red.withOpacity(0.4),
            ),

          // 3. Contenido del Juego
          SafeArea(
            child: Column(
              children: [
                // BARRA SUPERIOR (Vidas, Tiempo, Salir)
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
                          Icons.close,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      // Corazones
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < gameState.lives
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.redAccent,
                            size: 28,
                          );
                        }),
                      ),
                      // Puntos y Tiempo
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '⏱️ ${gameState.timeLeft}s',
                              style: GoogleFonts.fredoka(
                                color: AppTheme.yellow,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // TEXTO DE LA PREGUNTA
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        gameState.currentQuestion.text,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                // LAS DOS PUERTAS
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildDoor(context, ref, 0, gameState),
                        _buildDoor(context, ref, 1, gameState),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget Constructor de cada Puerta
  Widget _buildDoor(
    BuildContext context,
    WidgetRef ref,
    int doorIndex,
    DoorsGameState state,
  ) {
    final notifier = ref.read(doorsGameProvider.notifier);
    final isSelected = state.selectedDoorIndex == doorIndex;

    return GestureDetector(
      onTap: () => notifier.selectDoor(doorIndex),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Caja de texto de la opción
          // Caja de texto de la opción
          Container(
            width: 140,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            // 👇 AQUÍ ESTÁ LA CORRECCIÓN
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              state.currentQuestion.options[doorIndex],
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.inkLight,
              ),
            ),
          ),
          // Imagen de la puerta (Aplica animación si fue seleccionada)
          AnimatedScale(
            scale: isSelected ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Image.asset(
              isSelected
                  ? 'assets/images/Pabierta.png'
                  : 'assets/images/puerta.png',
              width: 130,
              height: 200,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
