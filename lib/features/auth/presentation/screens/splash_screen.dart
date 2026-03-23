import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final Duration totalDuration = 5500.ms; // 5.5 segundos

  @override
  void initState() {
    super.initState();
    Future.delayed(totalDuration + 800.ms, () {
      if (mounted) {
        context.go('/dashboard');
      }
    });
  }

  Widget _buildColoredKivaText() {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.fredoka(fontSize: 56, fontWeight: FontWeight.bold),
        children: const [
          TextSpan(
            text: 'K',
            style: TextStyle(color: Color(0xFFFFD88A)),
          ),
          TextSpan(
            text: 'I',
            style: TextStyle(color: Color(0xFFFFA8A8)),
          ),
          TextSpan(
            text: 'V',
            style: TextStyle(color: Color(0xFFB8A0FF)),
          ),
          TextSpan(
            text: 'A',
            style: TextStyle(color: Color(0xFF9BC5FF)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double centerY = MediaQuery.of(context).size.height * 0.5;

    return AppTheme.buildWebBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // --- CAPA FINAL: TEXTO SECUNDARIO "Kid's Integrity..." ---
            // 👇 Lo bajamos más (centerY + 120) para que no choque con KIVA
            Positioned(
              top: centerY + 120,
              child:
                  Container(
                        color: Colors.transparent,
                        child: Text(
                          "Kid's Integrity, voz y Apoyo",
                          style: GoogleFonts.nunito(
                            color: const Color(0xFF6C3A9B),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                      .animate(delay: 4300.ms)
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.5, end: 0, duration: 600.ms)
                      .shimmer(
                        duration: 2000.ms,
                        color: Colors.white70,
                        blendMode: BlendMode.srcOver,
                      ),
            ),

            // --- CAPA 3: TEXTO PRINCIPAL "KIVA" (Detrás del escudo) ---
            // 👇 Nace más abajo (centerY + 25) para evitar el escudo
            Positioned(top: centerY + 25, child: _buildColoredKivaText())
                .animate(delay: 2700.ms)
                .fadeIn(duration: 400.ms)
                .scale(
                  begin: const Offset(0.3, 0.3),
                  end: const Offset(1, 1),
                  duration: 400.ms,
                  curve: Curves.easeOutBack,
                )
                // 👇 Se desplaza más hacia abajo (end: 0.5) para separarse bien
                .slideY(
                  begin: 0,
                  end: 0.5,
                  delay: 3600.ms,
                  duration: 800.ms,
                  curve: Curves.fastOutSlowIn,
                ),

            // --- CAPA 2: EL ESCUDO (Formado y moviéndose) ---
            // 👇 Nace más arriba (centerY - 110)
            Positioned(
              top: centerY - 110,
              child:
                  Container(
                        width: 150,
                        height: 150,
                        color: Colors.transparent,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            // --- CAPA 1: LAS 22 PIEZAS ---
                            ...List.generate(22, (index) {
                              final double angle = index * (math.pi * 2) / 22;
                              final double scatterChaos =
                                  2.0 + (math.Random().nextDouble() * 1.5);
                              final double startX =
                                  math.cos(angle) * scatterChaos;
                              final double startY =
                                  math.sin(angle) * scatterChaos;

                              // 👇 MÁS CAOS: Ahora dan entre 6 y 8 vueltas completas a toda velocidad
                              final double exactTurns =
                                  (index % 2 == 0 ? 6.0 : -6.0) + (index % 3);

                              final int delayMs = 200 + (15 * index);
                              final int flightMs = 2200;

                              return SizedBox(
                                    width: 150,
                                    height: 150,
                                    child: SvgPicture.asset(
                                      'assets/images/splash/layer_$index.svg',
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(duration: 400.ms)
                                  .scale(
                                    begin: const Offset(0.1, 0.1),
                                    end: const Offset(1, 1),
                                    delay: delayMs.ms,
                                    duration: 600.ms,
                                    curve: Curves.easeOutBack,
                                  )
                                  .slide(
                                    begin: Offset(startX, startY),
                                    end: Offset.zero,
                                    delay: delayMs.ms,
                                    duration: flightMs.ms,
                                    curve: Curves.fastOutSlowIn,
                                  )
                                  // Vuelan girando a máxima velocidad
                                  .rotate(
                                    begin: exactTurns,
                                    end: 0,
                                    delay: delayMs.ms,
                                    duration: flightMs.ms,
                                    curve: Curves.fastOutSlowIn,
                                  )
                                  .shakeX(
                                    delay: (delayMs + 500).ms,
                                    duration: 1500.ms,
                                    amount: 3, // Vibran un poco más fuerte
                                    hz: 5,
                                  )
                                  .then()
                                  .scale(
                                    begin: const Offset(1, 1),
                                    end: const Offset(1.15, 1.15),
                                    duration: 300.ms,
                                    curve: Curves.elasticOut,
                                  )
                                  .then()
                                  .scale(
                                    begin: const Offset(1.15, 1.15),
                                    end: const Offset(1, 1),
                                    duration: 200.ms,
                                  );
                            }),

                            // --- EL DESTELLO MÁGICO ---
                            Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.yellow,
                                        blurRadius: 40,
                                        spreadRadius: 30,
                                      ),
                                      BoxShadow(
                                        color: Colors.white70,
                                        blurRadius: 20,
                                        spreadRadius: 10,
                                      ),
                                    ],
                                  ),
                                )
                                .animate(delay: 2700.ms)
                                .scale(
                                  begin: const Offset(0, 0),
                                  end: const Offset(18, 18),
                                  duration: 300.ms,
                                  curve: Curves.easeOut,
                                )
                                .fadeOut(duration: 250.ms),
                          ],
                        ),
                      )
                      // 🎬 Revelación de Escudo
                      // 👇 Sube más (end: -0.4) para alejarse de KIVA
                      .animate(delay: 3600.ms)
                      .slideY(
                        begin: 0,
                        end: -0.4,
                        duration: 800.ms,
                        curve: Curves.fastOutSlowIn,
                      )
                      .then()
                      .slideY(end: 0.05, duration: 200.ms)
                      .then()
                      .slideY(end: 0, duration: 150.ms),
            ),
          ],
        ),
      ),
    );
  }
}
