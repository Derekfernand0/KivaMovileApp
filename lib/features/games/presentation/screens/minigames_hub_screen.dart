import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/minigames_provider.dart';
import 'emotion_dial_screen.dart'; // Añade esta línea al inicio
import 'traffic_light_game_screen.dart';
import 'body_traffic_light_screen.dart';
import 'chat_game_screen.dart';
import 'safe_circle_game_screen.dart';
import 'my_body_rules_screen.dart';
import 'break_silence_story_screen.dart'; // Asegúrate de que apunte al archivo correcto

class MiniGamesHubScreen extends ConsumerWidget {
  const MiniGamesHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(miniGamesProvider);

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
        backgroundColor: AppTheme.paperLight,
        iconTheme: const IconThemeData(color: AppTheme.inkLight),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '¡Elige una actividad para comenzar!',
              style: GoogleFonts.fredoka(
                fontSize: 24,
                color: AppTheme.inkLight,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Completa todos los juegos para aprender a cuidarte.',
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 25),

            // --- LISTA DE LOS 7 MINIJUEGOS ---
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildGameCard(
                    context,
                    'Rompe el\nSilencio',
                    Icons.grid_view,
                    AppTheme.pink,
                    () {
                      // 👇 CAMBIAMOS ESTO HACIA LA NUEVA PANTALLA
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const BreakSilenceStoryScreen(),
                        ),
                      );
                    },
                    state.rompeSilencioScore > 0,
                  ),
                  _buildGameCard(
                    context,
                    'Emocionómetro',
                    Icons.speed,
                    AppTheme.blue,
                    () {
                      // 👇 Cambiamos el SnackBar por la navegación
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EmotionDialScreen(),
                        ),
                      );
                    },
                    state.emocionometroScore > 0,
                  ),

                  _buildGameCard(
                    context,
                    'Semáforo de\nSituaciones',
                    Icons.traffic,
                    AppTheme.yellow,
                    () {
                      // 👇 CAMBIA ESTO:
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TrafficLightGameScreen(),
                        ),
                      );
                    },
                    state.semaforoSituacionesScore > 0,
                  ),

                  _buildGameCard(
                    context,
                    'Semáforo del\nCuerpo',
                    Icons.accessibility_new,
                    AppTheme.peach,
                    () {
                      // 👇 CAMBIA ESTO:
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const BodyTrafficLightScreen(),
                        ),
                      );
                    },
                    state.semaforoCuerpoScore > 0,
                  ),

                  _buildGameCard(
                    context,
                    'Detecta el\nEngaño',
                    Icons.chat_bubble_outline,
                    AppTheme.lilac,
                    () {
                      // 👇 CAMBIA ESTO:
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ChatGameScreen(),
                        ),
                      );
                    },
                    state.detectaEnganoScore > 0,
                  ),

                  _buildGameCard(
                    context,
                    'Mi Círculo\nSeguro',
                    Icons.security,
                    const Color(0xFF2ed573),
                    () {
                      // 👇 CAMBIA ESTO:
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SafeCircleGameScreen(),
                        ),
                      );
                    },
                    state.circuloSeguroScore > 0,
                  ),

                  _buildGameCard(
                    context,
                    'Mi cuerpo,\nmis reglas',
                    Icons.pan_tool,
                    Colors.orangeAccent,
                    () {
                      // 👇 CAMBIA ESTO:
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MyBodyRulesScreen(),
                        ),
                      );
                    },
                    state.cuerpoReglasScore > 0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para crear las tarjetas del menú
  Widget _buildGameCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isCompleted,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 45, color: color),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.fredoka(
                      fontSize: 15,
                      color: AppTheme.inkLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (isCompleted)
              const Positioned(
                top: 10,
                right: 10,
                child: Icon(
                  Icons.check_circle,
                  color: Color(0xFF2ed573),
                  size: 28,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
