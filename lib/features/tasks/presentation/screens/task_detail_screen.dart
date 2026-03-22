import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/task_provider.dart';
import 'create_task_screen.dart';
import '../../../games/presentation/screens/minigames_hub_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskDetailScreen extends ConsumerWidget {
  final GameTask task;
  final bool isMaestro;
  final bool isOriginalGame;
  final bool isExpired;
  final bool isCompleted;
  final dynamic currentClass; // 👈 1. Recibimos la clase real aquí

  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.isMaestro,
    required this.isOriginalGame,
    required this.isExpired,
    required this.isCompleted,
    required this.currentClass, // 👈 2. Lo pedimos en el constructor
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleStyle = GoogleFonts.fredoka(
      color: AppTheme.inkLight,
      fontWeight: FontWeight.bold,
    );
    String dueDateText =
        '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year} a las ${task.dueDate.hour}:${task.dueDate.minute.toString().padLeft(2, '0')}';

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
    String gameName = gameNames[task.targetGameId] ?? 'Juego Desconocido';

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
            // Estado Completado o Caducado (Para Alumnos)
            if (!isMaestro && isCompleted)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFF2ed573)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF2ed573)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '¡Felicidades! Ya completaste esta tarea.',
                        style: GoogleFonts.nunito(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (!isMaestro && isExpired)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_off, color: Colors.red),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Esta tarea ha caducado y ya no puede ser jugada.',
                        style: GoogleFonts.nunito(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Tarjeta Principal
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.yellow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, size: 18),
                            const SizedBox(width: 5),
                            Text(
                              'Objetivo: ${task.targetScore} pts',
                              style: GoogleFonts.fredoka(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isExpired
                              ? Colors.red.shade100
                              : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 18,
                              color: isExpired ? Colors.red : Colors.blue,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Límite: $dueDateText',
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isExpired ? Colors.red : Colors.blue,
                              ),
                            ),
                          ],
                        ),
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
                    'Juego Asignado:',
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

            // 👇 SECCIÓN EXCLUSIVA PARA EL MAESTRO (CONECTADO A FIREBASE)
            if (isMaestro) ...[
              Text(
                '📊 Progreso de Alumnos',
                style: titleStyle.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 15),

              StreamBuilder<QuerySnapshot>(
                // ⚠️ AJUSTA ESTA CONSULTA A TU BASE DE DATOS:
                // Buscamos en la colección 'users' a los que sean 'alumno' y pertenezcan a esta clase
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'alumno')
                    // .where('classId', isEqualTo: currentClass.id) // Descomenta y ajusta si los alumnos tienen el ID de la clase guardado
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final realStudents = snapshot.data?.docs ?? [];

                  if (realStudents.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Center(
                        child: Text(
                          'No hay alumnos registrados en la base de datos.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  // 3. SEPARAMOS QUIÉNES TERMINARON Y QUIÉNES NO
                  List<QueryDocumentSnapshot> completedStudents = [];
                  List<QueryDocumentSnapshot> pendingStudents = [];

                  for (var student in realStudents) {
                    final data = student.data() as Map<String, dynamic>;

                    // 👇 Leemos el puntaje del alumno desde Firebase según el juego
                    int studentScore = 0;
                    switch (task.targetGameId) {
                      case 'rompe_silencio':
                        studentScore = data['rompeSilencioScore'] ?? 0;
                        break;
                      case 'detecta_engano':
                        studentScore = data['detectaEnganoScore'] ?? 0;
                        break;
                      case 'circulo_seguro':
                        studentScore = data['circuloSeguroScore'] ?? 0;
                        break;
                      case 'cuerpo_reglas':
                        studentScore = data['cuerpoReglasScore'] ?? 0;
                        break;
                      case 'semaforo_cuerpo':
                        studentScore = data['semaforoCuerpoScore'] ?? 0;
                        break;
                      case 'semaforo_situaciones':
                        studentScore = data['semaforoSituacionesScore'] ?? 0;
                        break;
                      case 'emocionometro':
                        studentScore = data['emocionometroScore'] ?? 0;
                        break;
                      // case 'puertas': studentScore = data['puertasScore'] ?? 0; break;
                    }

                    if (studentScore >= task.targetScore) {
                      completedStudents.add(student);
                    } else {
                      pendingStudents.add(student);
                    }
                  }

                  // 4. EL MENSAJE SI NADIE HA TERMINADO
                  if (completedStudents.isEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.orange.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Nadie ha terminado esta tarea aún.',
                                  style: GoogleFonts.nunito(
                                    color: Colors.orange.shade800,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Mostramos la lista de alumnos reales pendientes
                        _buildStudentsList(realStudents, completedStudents),
                      ],
                    );
                  }

                  // Si hay alumnos que terminaron
                  return _buildStudentsList(realStudents, completedStudents);
                },
              ),
            ]
            // Botón de Acción para Alumnos
            else if (!isExpired || isCompleted)
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
                  if (isOriginalGame) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Abriendo el juego original...'),
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
                  isCompleted ? 'Reintentar Juego' : 'Ir a Jugar',
                  style: GoogleFonts.fredoka(fontSize: 22),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 👇 Widget extraído para mantener limpio el código de arriba
  // 👇 Adaptado para leer documentos de Firestore
  Widget _buildStudentsList(
    List<QueryDocumentSnapshot> allStudents,
    List<QueryDocumentSnapshot> completedStudents,
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
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final studentDoc = allStudents[index];
          final studentData = studentDoc.data() as Map<String, dynamic>;

          bool done = completedStudents.any((doc) => doc.id == studentDoc.id);

          // ⚠️ AJUSTA 'name' o 'nombre' según cómo lo guardes en Firebase
          String studentName =
              studentData['name'] ??
              studentData['nombre'] ??
              'Alumno Desconocido';

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
