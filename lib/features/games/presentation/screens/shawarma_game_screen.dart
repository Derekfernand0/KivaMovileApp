import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/shawarma_game_provider.dart';

class ShawarmaGameScreen extends ConsumerWidget {
  const ShawarmaGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shawarmaProvider);
    final notifier = ref.read(shawarmaProvider.notifier);
    final screenSize = MediaQuery.of(context).size;

    // --- PANTALLA FINAL (VICTORIA O DERROTA) ---
    if (state.isGameOver) {
      return Scaffold(
        backgroundColor: Colors.black87,
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(30),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF1e272e),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.isVictory ? '¡Misión Cumplida!' : 'Fin del Juego',
                  style: GoogleFonts.fredoka(fontSize: 32, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  state.isVictory
                      ? 'Lograste atender correctamente y detectar señales. Puntuación: ${state.score}'
                      : 'Te quedaste sin vidas. Recuerda observar las señales. Puntuación: ${state.score}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    color: const Color(0xFF4b3ff5),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3498db),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => notifier.resetGame(),
                  child: const Text('Reiniciar'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Volver al Menú',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: Stack(
        children: [
          // CAPA 1: Fondo del local (Lejos)
          Positioned.fill(
            child: Image.asset(
              'assets/images/shawarma/obj/swbg.png',
              fit: BoxFit.cover,
            ),
          ),

          // CAPA 2: Zona del Cliente (Detrás del mostrador)
          if (state.currentCustomer != null)
            Positioned(
              bottom: screenSize.height * 0.25,
              left: 0,
              right: 0,
              child: DragTarget<String>(
                onAcceptWithDetails: (details) {
                  if (details.data == 'shawarma_listo')
                    notifier.serveCustomer();
                },
                builder: (context, candidateData, rejectedData) {
                  return Center(
                    child: SizedBox(
                      height: screenSize.height * 0.50,
                      child: Image.asset(
                        state.currentCustomer!.imagePath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
            ),

          // CAPA 3: Estructura del Local (El mostrador enfrente del cliente)
          Positioned.fill(
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/shawarma/obj/swst.png',
                fit: BoxFit.fill,
              ),
            ),
          ),

          // CAPA 4: Globo de Diálogo (Movido más arriba y a la izquierda para no estorbar)
          if (state.currentDialogue != null)
            Positioned(
              top: screenSize.height * 0.18,
              right: screenSize.width * 0.25,
              child: Container(
                width: 180,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, blurRadius: 10),
                  ],
                ),
                child: Text(
                  state.currentDialogue!,
                  style: GoogleFonts.nunito(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

          // CAPA 5: Panel de Preguntas (Movido más abajo para dejar libre el diálogo)
          if (state.currentCustomer != null &&
              !state.showEvaluationModal &&
              !state.isGateFalling)
            Positioned(
              top: screenSize.height * 0.38, // <--- Ajuste: Más abajo
              right: 15,
              child: Container(
                width: 200,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Preguntar:',
                      style: GoogleFonts.fredoka(
                        color: const Color(0xFFf1c40f),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Divider(color: Colors.white24),
                    ...state.currentCustomer!.questions.map(
                      (q) => Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white12,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onPressed: () => notifier.askQuestion(q['a']!),
                          child: Text(
                            q['q']!,
                            style: const TextStyle(fontSize: 12),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // CAPA 6: Botón Rojo de Denuncia
          Positioned(
            top: screenSize.height * 0.22,
            left: 10,
            child: GestureDetector(
              onTap: () => notifier.pressRedButton(),
              child: Image.asset(
                'assets/images/shawarma/obj/swbtn.png',
                width: 70,
              ),
            ),
          ),

          // CAPA 7: Zona de Preparación (Subida para apoyarse en el escritorio)
          Positioned(
            bottom: 90, // <--- Ajuste: Más arriba (antes era 20)
            left: 10,
            right: 10,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Mesa (Izquierda)
                DragTarget<int>(
                  onAcceptWithDetails: (details) {
                    notifier.tryAddIngredient(details.data);
                  },
                  builder: (context, candidateData, rejectedData) {
                    return GestureDetector(
                      onTap: () => notifier.finishShawarma(),
                      child: SizedBox(
                        width: screenSize.width * 0.35,
                        child: _buildTableImage(state.shawarmaStep),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10),

                // Ingredientes
                Expanded(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (state.shawarmaStep < 4) ...[
                        _buildDraggableIngredient(
                          1,
                          'assets/images/shawarma/ingredientes/swtll.png',
                        ),
                        _buildDraggableIngredient(
                          2,
                          'assets/images/shawarma/ingredientes/swsl.png',
                        ),
                        _buildDraggableIngredient(
                          3,
                          'assets/images/shawarma/ingredientes/swvr.png',
                        ),
                        _buildDraggableIngredient(
                          4,
                          'assets/images/shawarma/ingredientes/swcr.png',
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // CAPA 8: UI Superior (Botones y Vidas)
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Row(
                  children: List.generate(
                    3,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Image.asset(
                        'assets/images/shawarma/obj/swht.png',
                        width: 40,
                        color: index < state.lives ? null : Colors.black54,
                        colorBlendMode: index < state.lives
                            ? null
                            : BlendMode.saturation,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // CAPA 9: La Reja de Seguridad Animada (Cae desde arriba Y TAPA TODO LO ANTERIOR)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeIn,
            top: state.isGateFalling ? 0 : -screenSize.height,
            left: 0,
            right: 0,
            height: screenSize.height,
            child: Image.asset(
              'assets/images/shawarma/obj/swrj.png',
              fit: BoxFit.cover,
            ),
          ),

          // CAPA 10: Modal de Evaluación
          if (state.showEvaluationModal)
            Container(
              color: Colors.black87,
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(30),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1e272e),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                    boxShadow: const [
                      BoxShadow(color: Colors.black87, blurRadius: 20),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.evalTitle,
                        style: GoogleFonts.fredoka(
                          fontSize: 28,
                          color: const Color(0xFFf1c40f),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        state.evalMessage,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          color: const Color(0xFF4b3ff5),
                        ),
                      ),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3498db),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () => notifier.continueToNextCustomer(),
                        child: const Text(
                          'Continuar',
                          style: TextStyle(fontSize: 16),
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

  Widget _buildTableImage(int step) {
    if (step == 5) {
      return Draggable<String>(
        data: 'shawarma_listo',
        feedback: Image.asset(
          'assets/images/shawarma/ingredientes/shawarma.png',
          width: 120,
        ),
        childWhenDragging: const SizedBox(),
        child: Image.asset('assets/images/shawarma/ingredientes/shawarma.png'),
      );
    }
    String tblImage = step == 0 ? 'swtbl.png' : 'swtb$step.png';
    return Image.asset('assets/images/shawarma/ingredientes/$tblImage');
  }

  Widget _buildDraggableIngredient(int id, String assetPath) {
    return Draggable<int>(
      data: id,
      feedback: Image.asset(assetPath, width: 80),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: Image.asset(assetPath, width: 70),
      ),
      child: Image.asset(assetPath, width: 70),
    );
  }
}
