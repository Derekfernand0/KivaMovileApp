import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class StudentStatsScreen extends StatelessWidget {
  final String studentId;
  final String studentName;
  final Map<String, dynamic> studentData;

  const StudentStatsScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.studentData,
  });

  // 👇 DICCIONARIO COMPLETO: LOS 10 JUEGOS
  // Usamos el "ID base" que coincida con cómo lo guardas en Firebase
  final Map<String, Map<String, dynamic>> _gamesConfig = const {
    'puertas': {'name': '🚪 Las Puertas', 'color': Colors.redAccent},
    'torre': {'name': '🏗️ La Gran Torre', 'color': Colors.amber},
    'shawarma': {'name': '🥙 El Shawarma Seguro', 'color': Colors.brown},
    'rompeSilencio': {'name': '🎤 Rompe el Silencio', 'color': Colors.blue},
    'detectaEngano': {'name': '📱 Detecta el Engaño', 'color': Colors.purple},
    'circuloSeguro': {'name': '🛡️ Mi Círculo Seguro', 'color': Colors.green},
    'cuerpoReglas': {
      'name': '🙅‍♀️ Mi cuerpo, mis reglas',
      'color': Colors.orange,
    },
    'emocionometro': {'name': '🧭 Emocionómetro', 'color': Colors.teal},
    'semaforoSituaciones': {
      'name': '🚦 Sem. Situaciones',
      'color': Colors.lightGreen,
    },
    'semaforoCuerpo': {
      'name': '🚦 Sem. del Cuerpo',
      'color': Colors.pinkAccent,
    },
  };

  @override
  Widget build(BuildContext context) {
    int globalTotalScore = 0;
    int globalGamesPlayed = 0;
    int globalMax = 0;

    // 1. CALCULAR MÉTRICAS GLOBALES REALES
    for (var baseKey in _gamesConfig.keys) {
      // Leemos el historial real del juego (Ej: puertasHistory: [5, 10, 5])
      List<dynamic> history = studentData['${baseKey}History'] ?? [];

      if (history.isNotEmpty) {
        for (var score in history) {
          int s = score as int;
          globalTotalScore += s;
          globalGamesPlayed++;
          if (s > globalMax) globalMax = s;
        }
      } else {
        // Compatibilidad con datos viejos por si no tienen historial aún
        int oldScore = studentData['${baseKey}Score'] ?? 0;
        if (oldScore > 0) {
          globalTotalScore += oldScore;
          globalGamesPlayed++;
          if (oldScore > globalMax) globalMax = oldScore;
        }
      }
    }

    double globalAvg = globalGamesPlayed > 0
        ? globalTotalScore / globalGamesPlayed
        : 0.0;

    return Scaffold(
      backgroundColor: AppTheme.paperLight,
      appBar: AppBar(
        title: Text(
          'Perfil de $studentName',
          style: GoogleFonts.nunito(
            color: AppTheme.inkLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.inkLight),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- TARJETAS GLOBALES ---
            Row(
              children: [
                Expanded(
                  child: _buildGlobalCard(
                    'Promedio Global',
                    globalAvg.toStringAsFixed(1),
                    AppTheme.yellow,
                    Icons.functions,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildGlobalCard(
                    'Máxima Global',
                    globalMax.toString(),
                    AppTheme.pink,
                    Icons.emoji_events,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            Text(
              '📊 Rendimiento por Juego',
              style: GoogleFonts.fredoka(
                fontSize: 22,
                color: AppTheme.inkLight,
              ),
            ),
            const SizedBox(height: 15),

            // --- LISTA DE GRÁFICAS POR JUEGO ---
            ..._gamesConfig.entries.map((entry) {
              String baseKey = entry.key;
              String gameName = entry.value['name'];
              Color gameColor = entry.value['color'];

              // 2. MATEMÁTICA REAL POR JUEGO
              List<dynamic> history = studentData['${baseKey}History'] ?? [];
              int maxScore = studentData['${baseKey}Score'] ?? 0;
              double avgScore = 0.0;

              if (history.isNotEmpty) {
                int sum = history.fold(0, (prev, curr) => prev + (curr as int));
                avgScore = sum / history.length;
                // Nos aseguramos que el maxScore sea correcto basándonos en el historial
                maxScore = history.cast<int>().reduce((a, b) => a > b ? a : b);
              } else if (maxScore > 0) {
                // Si no hay historial pero sí hay un score viejo, el promedio es igual a ese score
                avgScore = maxScore.toDouble();
              }

              // Si el alumno no ha jugado este juego, mostramos una tarjeta atenuada
              if (maxScore == 0 && history.isEmpty) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  color: Colors.grey.shade100,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.videogame_asset_off,
                      color: Colors.grey.shade400,
                    ),
                    title: Text(
                      gameName,
                      style: GoogleFonts.fredoka(
                        fontSize: 16,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    trailing: Text(
                      'Sin datos',
                      style: GoogleFonts.nunito(color: Colors.grey.shade500),
                    ),
                  ),
                );
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 2,
                child: ExpansionTile(
                  leading: Icon(Icons.videogame_asset, color: gameColor),
                  title: Text(
                    gameName,
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      color: AppTheme.inkLight,
                    ),
                  ),
                  subtitle: Text(
                    'Intentos jugados: ${history.length}',
                    style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'Promedio',
                                    style: GoogleFonts.nunito(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    avgScore.toStringAsFixed(1),
                                    style: GoogleFonts.fredoka(
                                      fontSize: 22,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    'Puntuación Máxima',
                                    style: GoogleFonts.nunito(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    maxScore.toString(),
                                    style: GoogleFonts.fredoka(
                                      fontSize: 22,
                                      color: gameColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),

                          // 👇 GRÁFICA REAL DE BARRAS (fl_chart)
                          SizedBox(
                            height: 200,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: maxScore < 20
                                    ? 20
                                    : (maxScore + 10)
                                          .toDouble(), // Escala dinámica
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8.0,
                                          ),
                                          child: Text(
                                            value == 0 ? 'Promedio' : 'Máxima',
                                            style: GoogleFonts.nunito(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                gridData: const FlGridData(show: false),
                                barGroups: [
                                  // Barra de Promedio
                                  BarChartGroupData(
                                    x: 0,
                                    barRods: [
                                      BarChartRodData(
                                        toY: avgScore,
                                        color: Colors.grey.shade400,
                                        width: 35,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ],
                                  ),
                                  // Barra de Puntuación Máxima
                                  BarChartGroupData(
                                    x: 1,
                                    barRods: [
                                      BarChartRodData(
                                        toY: maxScore.toDouble(),
                                        color: gameColor,
                                        width: 35,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.fredoka(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
