import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/task_provider.dart';
import 'create_task_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 👇 IMPORTAMOS LAS RUTAS A LOS JUEGOS Y QUIZZES
import '../../../games/presentation/screens/doors_game_screen.dart';
import '../../../games/presentation/screens/water_game_screen.dart';
import '../../../games/presentation/screens/shawarma_game_screen.dart';
import '../../../games/presentation/screens/minigames_hub_screen.dart';
import '../../../quizzes/presentation/screens/quiz_game_screen.dart'; // 👈 El nuevo
import '../../../quizzes/data/premade_quizzes/premade_quizzes_db.dart'; // 👈 Base de datos de quizzes

class TaskDetailScreen extends ConsumerWidget {
  final GameTask task;
  final bool isMaestro;
  final bool isOriginalGame;
  final bool isExpired;
  final bool isCompleted;
  final dynamic currentClass;

  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.isMaestro,
    required this.isOriginalGame,
    required this.isExpired,
    required this.isCompleted,
    required this.currentClass,
  });

  int _getStudentScore(Map<String, dynamic> data, String gameId) {
    int getSafeInt(String key) => (data[key] as num?)?.toInt() ?? 0;

    switch (gameId) {
      case 'rompe_silencio':
        return getSafeInt('rompeSilencioScore');
      case 'detecta_engano':
        return getSafeInt('detectaEnganoScore');
      case 'circulo_seguro':
        return getSafeInt('circuloSeguroScore');
      case 'cuerpo_reglas':
        return getSafeInt('cuerpoReglasScore');
      case 'semaforo_cuerpo':
        return getSafeInt('semaforoCuerpoScore');
      case 'semaforo_situaciones':
        return getSafeInt('semaforoSituacionesScore');
      case 'emocionometro':
        return getSafeInt('emocionometroScore');
      case 'puertas':
        return getSafeInt('puertasScore');
      case 'torre':
        return getSafeInt('torreScore');
      case 'shawarma':
        return getSafeInt('shawarmaScore');
      default:
        return getSafeInt('${gameId}Score');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleStyle = GoogleFonts.fredoka(
      color: AppTheme.inkLight,
      fontWeight: FontWeight.bold,
    );
    String dueDateText =
        '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year} a las ${task.dueDate.hour}:${task.dueDate.minute.toString().padLeft(2, '0')}';

    // 👇 NOMBRES DINÁMICOS (Soporta minijuegos y Quizzes infinitos)
    String gameName = 'Juego Desconocido';
    if (task.targetGameId.startsWith('quiz_')) {
      final quiz = premadeQuizzesDatabase
          .where((q) => q.id == task.targetGameId)
          .firstOrNull;
      gameName = quiz != null ? '📝 ${quiz.title}' : '📝 Cuestionario KIVA';
    } else {
      final Map<String, String> gameNames = {
        'puertas': '🚪 Las Puertas de la Confianza',
        'torre': '🏗️ La Gran Torre de Isla',
        'shawarma': '🥙 El Shawarma Seguro',
        'rompe_silencio': '🎤 Rompe el Silencio',
        'emocionometro': '🧭 Emocionómetro',
        'semaforo_situaciones': '🚦 Semáforo Situaciones',
        'semaforo_cuerpo': '🚦 Semáforo del Cuerpo',
        'detecta_engano': '📱 Detecta el Engaño',
        'circulo_seguro': '🛡️ Mi Círculo Seguro',
        'cuerpo_reglas': '🙅‍♀️ Mi cuerpo, mis reglas',
      };
      gameName = gameNames[task.targetGameId] ?? 'Juego Desconocido';
    }

    return Scaffold(
      backgroundColor: AppTheme.paperLight,
      appBar: AppBar(
        title: Text(
          'Detalle de la Tarea',
          style: GoogleFonts.nunito(
            color: AppTheme.inkLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.inkLight),
        actions: [
          if (isMaestro)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueAccent),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CreateTaskScreen(
                      taskToEdit: task,
                      classId: task.classId,
                    ),
                  ),
                );
              },
            ),
          if (isMaestro)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () {
                ref.read(taskProvider.notifier).removeTask(task.id);
                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isMaestro && isCompleted)
              _buildBanner(
                Colors.green,
                Icons.check_circle,
                '¡Felicidades! Ya completaste esta tarea.',
              )
            else if (!isMaestro && isExpired)
              _buildBanner(
                Colors.red,
                Icons.timer_off,
                'Esta tarea ha caducado y ya no puede ser jugada.',
              ),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
                border: Border.all(color: AppTheme.lineLight, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title, style: titleStyle.copyWith(fontSize: 28)),
                  const SizedBox(height: 15),
                  Wrap(
                    spacing: 15,
                    runSpacing: 10,
                    children: [
                      _buildChip(
                        AppTheme.yellow,
                        Icons.star,
                        'Objetivo: ${task.targetScore} pts',
                        AppTheme.inkLight,
                      ),
                      _buildChip(
                        isExpired ? Colors.red.shade100 : Colors.blue.shade50,
                        Icons.access_time,
                        'Límite: $dueDateText',
                        isExpired ? Colors.red : Colors.blue,
                      ),
                    ],
                  ),
                  const Divider(height: 40, thickness: 2),
                  Text(
                    'Instrucciones:',
                    style: titleStyle.copyWith(
                      fontSize: 18,
                      color: AppTheme.lilac,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    task.description,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Actividad Asignada:',
                    style: titleStyle.copyWith(
                      fontSize: 18,
                      color: AppTheme.lilac,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppTheme.paperLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      gameName,
                      style: GoogleFonts.fredoka(
                        fontSize: 18,
                        color: AppTheme.inkLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            if (isMaestro) ...[
              Text(
                '📊 Progreso de Alumnos',
                style: titleStyle.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 15),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'alumno')
                    .where('classId', isEqualTo: task.classId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final realStudents = snapshot.data?.docs ?? [];

                  if (realStudents.isEmpty) {
                    return _buildEmptyBox(
                      'Aún no hay alumnos registrados en tu clase.',
                    );
                  }

                  List<QueryDocumentSnapshot> completedStudents = [];
                  for (var student in realStudents) {
                    if (_getStudentScore(
                          student.data() as Map<String, dynamic>,
                          task.targetGameId,
                        ) >=
                        task.targetScore) {
                      completedStudents.add(student);
                    }
                  }

                  if (completedStudents.length == realStudents.length) {
                    return Column(
                      children: [
                        _buildBanner(
                          Colors.green,
                          Icons.workspace_premium,
                          '¡Excelente! Todos los alumnos han completado esta tarea.',
                        ),
                        _buildStudentsList(
                          realStudents,
                          completedStudents,
                          task.targetScore,
                        ),
                      ],
                    );
                  } else if (completedStudents.isEmpty) {
                    return Column(
                      children: [
                        _buildBanner(
                          Colors.orange,
                          Icons.info_outline,
                          'Nadie ha terminado esta tarea aún.',
                        ),
                        _buildStudentsList(
                          realStudents,
                          completedStudents,
                          task.targetScore,
                        ),
                      ],
                    );
                  }

                  return _buildStudentsList(
                    realStudents,
                    completedStudents,
                    task.targetScore,
                  );
                },
              ),
            ] else if (!isExpired || isCompleted)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompleted
                      ? Colors.grey.shade300
                      : const Color(0xFF2ed573),
                  foregroundColor: isCompleted
                      ? Colors.grey.shade700
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: isCompleted ? 0 : 5,
                ),
                onPressed: () {
                  // 👇 AHORA SÍ NAVEGAMOS AL JUEGO CORRESPONDIENTE O AL QUIZ
                  if (task.targetGameId.startsWith('quiz_')) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            QuizGameScreen(quizId: task.targetGameId),
                      ),
                    );
                  } else if (task.targetGameId == 'puertas') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DoorsGameScreen(),
                      ),
                    );
                  } else if (task.targetGameId == 'torre') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const WaterGameScreen(),
                      ),
                    );
                  } else if (task.targetGameId == 'shawarma') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ShawarmaGameScreen(),
                      ),
                    );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MiniGamesHubScreen(),
                      ),
                    );
                  }
                },
                icon: Icon(
                  isCompleted ? Icons.replay : Icons.play_arrow,
                  size: 28,
                ),
                label: Text(
                  isCompleted ? 'Reintentar Tarea' : 'Ir a la Actividad',
                  style: GoogleFonts.fredoka(fontSize: 22),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner(Color color, IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.nunito(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    Color bgColor,
    IconData icon,
    String text,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 5),
          Text(
            text,
            style: GoogleFonts.fredoka(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyBox(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Text(message, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }

  Widget _buildStudentsList(
    List<QueryDocumentSnapshot> allStudents,
    List<QueryDocumentSnapshot> completedStudents,
    int targetScore,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: allStudents.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final studentDoc = allStudents[index];
          final studentData = studentDoc.data() as Map<String, dynamic>;

          bool done = completedStudents.any((doc) => doc.id == studentDoc.id);
          String studentName =
              studentData['name'] ??
              studentData['nombre'] ??
              studentData['alias'] ??
              'Alumno Desconocido';
          int currentScore = _getStudentScore(studentData, task.targetGameId);

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: done
                  ? Colors.green.shade100
                  : Colors.orange.shade100,
              child: Icon(
                done ? Icons.check : Icons.hourglass_empty,
                color: done ? Colors.green : Colors.orange,
              ),
            ),
            title: Text(
              studentName,
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              'Progreso: $currentScore / $targetScore pts',
              style: GoogleFonts.nunito(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: done ? Colors.green.shade100 : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                done ? 'Completado' : 'Pendiente',
                style: GoogleFonts.nunito(
                  color: done ? Colors.green.shade800 : Colors.orange.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
