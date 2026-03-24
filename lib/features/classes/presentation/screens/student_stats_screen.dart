import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 👈 Agregado para usar ConsumerWidget
import '../../../../core/theme/app_theme.dart';
import '../../../quizzes/presentation/providers/quiz_provider.dart'; // 👈 Importamos proveedor

// 👇 Cambiamos a ConsumerWidget
class StudentStatsScreen extends ConsumerWidget {
  final String studentId;
  final String studentName;
  final Map<String, dynamic> studentData;

  const StudentStatsScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.studentData,
  });

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

  int _getSafeInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int globalTotalScore = 0;
    int globalGamesPlayed = 0;
    int globalMax = 0;

    for (var baseKey in _gamesConfig.keys) {
      List<dynamic> history = studentData['${baseKey}History'] ?? [];
      if (history.isNotEmpty) {
        for (var score in history) {
          int s = _getSafeInt(score);
          globalTotalScore += s;
          globalGamesPlayed++;
          if (s > globalMax) globalMax = s;
        }
      } else {
        int oldScore = _getSafeInt(studentData['${baseKey}Score']);
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

    // 👇 Leemos todos los quizzes (Prehechos + Los creados por este maestro)
    final quizzesAsync = ref.watch(availableQuizzesProvider);

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
              '🎮 Rendimiento en Juegos',
              style: GoogleFonts.fredoka(
                fontSize: 22,
                color: AppTheme.inkLight,
              ),
            ),
            const SizedBox(height: 15),

            ..._gamesConfig.entries.map((entry) {
              String baseKey = entry.key;
              String gameName = entry.value['name'];
              Color gameColor = entry.value['color'];

              List<dynamic> history = studentData['${baseKey}History'] ?? [];
              int maxScore = _getSafeInt(studentData['${baseKey}Score']);
              double avgScore = 0.0;

              if (history.isNotEmpty) {
                int sum = history.fold(
                  0,
                  (prev, curr) => prev + _getSafeInt(curr),
                );
                avgScore = sum / history.length;
                maxScore = history
                    .map((e) => _getSafeInt(e))
                    .reduce((a, b) => a > b ? a : b);
              } else if (maxScore > 0) {
                avgScore = maxScore.toDouble();
              }

              if (maxScore == 0 && history.isEmpty)
                return _buildEmptyCard(gameName, Icons.videogame_asset_off);
              return _buildChartCard(
                gameName,
                gameColor,
                Icons.videogame_asset,
                history.length,
                avgScore,
                maxScore,
                maxScore + 10,
              );
            }),

            const SizedBox(height: 30),

            Text(
              '📝 Rendimiento en Quizzes',
              style: GoogleFonts.fredoka(
                fontSize: 22,
                color: AppTheme.inkLight,
              ),
            ),
            const SizedBox(height: 15),

            // 👇 GENERAMOS LAS GRÁFICAS DE TODOS LOS QUIZZES (Incluso los personalizados)
            quizzesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text('Error al cargar quizzes: $e'),
              data: (quizzes) {
                if (quizzes.isEmpty)
                  return const Text('No hay quizzes disponibles.');

                return Column(
                  children: quizzes.map((quiz) {
                    String baseKey = quiz.id;
                    String quizName = quiz.title;
                    Color quizColor = AppTheme.kivaPurple;
                    int totalPossible = quiz.totalPossibleScore;

                    List<dynamic> history =
                        studentData['${baseKey}History'] ?? [];
                    int maxScore = _getSafeInt(studentData['${baseKey}Score']);
                    double avgScore = 0.0;

                    if (history.isNotEmpty) {
                      int sum = history.fold(
                        0,
                        (prev, curr) => prev + _getSafeInt(curr),
                      );
                      avgScore = sum / history.length;
                      maxScore = history
                          .map((e) => _getSafeInt(e))
                          .reduce((a, b) => a > b ? a : b);
                    } else if (maxScore > 0) {
                      avgScore = maxScore.toDouble();
                    }

                    if (maxScore == 0 && history.isEmpty)
                      return _buildEmptyCard(quizName, Icons.quiz_outlined);
                    return _buildChartCard(
                      quizName,
                      quizColor,
                      Icons.quiz,
                      history.length,
                      avgScore,
                      maxScore,
                      totalPossible,
                    );
                  }).toList(),
                );
              },
            ),
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

  Widget _buildEmptyCard(String title, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      color: Colors.grey.shade100,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey.shade400),
        title: Text(
          title,
          style: GoogleFonts.fredoka(fontSize: 16, color: Colors.grey.shade500),
        ),
        trailing: Text(
          'Sin datos',
          style: GoogleFonts.nunito(color: Colors.grey.shade500),
        ),
      ),
    );
  }

  Widget _buildChartCard(
    String title,
    Color color,
    IconData icon,
    int attempts,
    double avgScore,
    int maxScore,
    int graphCeiling,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: ExpansionTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: GoogleFonts.fredoka(fontSize: 16, color: AppTheme.inkLight),
        ),
        subtitle: Text(
          'Intentos: $attempts',
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
                          'Calificación Máxima',
                          style: GoogleFonts.nunito(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          maxScore.toString(),
                          style: GoogleFonts.fredoka(
                            fontSize: 22,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: graphCeiling < 20 ? 20.0 : graphCeiling.toDouble(),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                value == 0 ? 'Promedio' : 'Máxima',
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(
                              toY: maxScore.toDouble(),
                              color: color,
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
  }
}
