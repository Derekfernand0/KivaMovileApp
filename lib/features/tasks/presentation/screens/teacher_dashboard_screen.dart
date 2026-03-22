import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/task_provider.dart';
import 'create_task_screen.dart';

class TeacherDashboardScreen extends ConsumerWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos la lista de tareas creadas
    final tasks = ref.watch(taskProvider);
    final titleStyle = GoogleFonts.fredoka(
      color: AppTheme.inkLight,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      backgroundColor: AppTheme.paperLight,
      appBar: AppBar(
        title: Text(
          'Panel de Maestro',
          style: GoogleFonts.nunito(
            color: AppTheme.inkLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.inkLight),
      ),
      body: tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.assignment_add,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Aún no has creado tareas.',
                    style: titleStyle.copyWith(
                      fontSize: 24,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Presiona el botón de abajo para empezar.',
                    style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.lilac,
                      child: const Icon(Icons.gamepad, color: Colors.white),
                    ),
                    title: Text(
                      task.title,
                      style: titleStyle.copyWith(fontSize: 18),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          task.description,
                          style: GoogleFonts.nunito(
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.yellow,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Objetivo: ${task.targetScore} pts',
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        // El maestro puede borrar la tarea si se equivoca
                        ref.read(taskProvider.notifier).removeTask(task.id);
                      },
                    ),
                  ),
                );
              },
            ),

      // 👇 ESTE ES EL BOTÓN QUE NAVEGA CORRECTAMENTE A CREAR TAREA
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2c3e50),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Nueva Tarea',
          style: GoogleFonts.fredoka(color: Colors.white, fontSize: 16),
        ),
        onPressed: () {
          // Navegación estricta hacia la pantalla de creación
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CreateTaskScreen()),
          );
        },
      ),
    );
  }
}
