import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../games/presentation/screens/minigames_hub_screen.dart';
// 👇 Importamos el provider de los minijuegos para leer los puntos
import '../../../games/presentation/providers/minigames_provider.dart';
import '../providers/class_provider.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../../../tasks/presentation/screens/create_task_screen.dart';
import '../../../tasks/presentation/screens/task_detail_screen.dart';

// ... tus importaciones actuales ...

class ClassDetailScreen extends ConsumerStatefulWidget {
  final String classId;
  const ClassDetailScreen({super.key, required this.classId});

  @override
  ConsumerState<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends ConsumerState<ClassDetailScreen> {
  @override
  void initState() {
    super.initState();
    // 👇 Le decimos a Firebase que cargue las tareas de esta clase al entrar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taskProvider.notifier).listenToTasks(widget.classId);
    });
  }

  // Función auxiliar para leer los puntos
  int _getCurrentScoreForGame(String gameId, dynamic gameState) {
    switch (gameId) {
      case 'rompe_silencio':
        return gameState.rompeSilencioScore;
      case 'emocionometro':
        return gameState.emocionometroScore;
      case 'semaforo_situaciones':
        return gameState.semaforoSituacionesScore;
      case 'semaforo_cuerpo':
        return gameState.semaforoCuerpoScore;
      case 'detecta_engano':
        return gameState.detectaEnganoScore;
      case 'circulo_seguro':
        return gameState.circuloSeguroScore;
      case 'cuerpo_reglas':
        return gameState.cuerpoReglasScore;
      // Añade aquí los de tus juegos originales si los tienes en el estado
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 👇 NOTA: Ahora usamos widget.classId porque es un StatefulWidget
    final classId = widget.classId;

    // ... TODO EL RESTO DE TU CÓDIGO BUILD SE QUEDA EXACTAMENTE IGUAL ...
    final user = ref.watch(authStateProvider).value;
    final classesAsync = ref.watch(userClassesProvider);
    final tasks = ref.watch(taskProvider);

    // 👇 Leemos los puntos actuales del usuario
    final miniGamesState = ref.watch(miniGamesProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return classesAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (classes) {
        final currentClass = classes.firstWhere(
          (c) => c.id == classId,
          orElse: () => throw Exception('Clase no encontrada'),
        );
        final isMaestro = user.role == 'maestro';

        return Scaffold(
          backgroundColor: AppTheme.paperLight,
          appBar: AppBar(
            backgroundColor: AppTheme.paperLight,
            title: Text(
              currentClass.name,
              style: GoogleFonts.fredoka(
                fontWeight: FontWeight.bold,
                color: AppTheme.inkLight,
              ),
            ),
            iconTheme: const IconThemeData(color: AppTheme.inkLight),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.lilac.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.ringLight.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.school, size: 48, color: AppTheme.ringLight),
                      const SizedBox(height: 8),
                      Text(
                        'Bienvenido a ${currentClass.name}',
                        style: GoogleFonts.fredoka(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.inkLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'Muro de la Clase',
                  style: GoogleFonts.fredoka(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.inkLight,
                  ),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: tasks.isEmpty
                      ? Center(
                          child: Text(
                            'El muro está vacío por ahora.',
                            style: GoogleFonts.nunito(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            bool isOriginalGame =
                                (task.targetGameId == 'puertas' ||
                                task.targetGameId == 'torre' ||
                                task.targetGameId == 'shawarma');
                            bool isExpired = DateTime.now().isAfter(
                              task.dueDate,
                            );

                            // 👇 LOGICA DE COMPLETADO
                            int currentScore = _getCurrentScoreForGame(
                              task.targetGameId,
                              miniGamesState,
                            );
                            bool isCompleted = currentScore >= task.targetScore;

                            String dueDateText =
                                '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}';

                            return Card(
                              margin: const EdgeInsets.only(bottom: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: isCompleted
                                  ? 0
                                  : 2, // Si está completada, se ve plana
                              // 👇 Si está completada, fondo gris clarito
                              color: isCompleted
                                  ? Colors.grey.shade100
                                  : Colors.white,
                              child: ListTile(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => TaskDetailScreen(
                                        task: task,
                                        isMaestro: isMaestro,
                                        isOriginalGame: isOriginalGame,
                                        isExpired: isExpired,
                                        isCompleted: isCompleted,
                                        currentClass:
                                            currentClass, // 👈 AGREGAR ESTA LÍNEA
                                      ),
                                    ),
                                  );
                                },
                                contentPadding: const EdgeInsets.all(15),
                                leading: CircleAvatar(
                                  // Cambia el ícono si está completada ✅
                                  backgroundColor: isCompleted
                                      ? const Color(0xFF2ed573)
                                      : (isExpired
                                            ? Colors.grey
                                            : AppTheme.peach),
                                  child: Icon(
                                    isCompleted
                                        ? Icons.check
                                        : (isExpired
                                              ? Icons.timer_off
                                              : Icons.star),
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  task.title,
                                  style: GoogleFonts.fredoka(
                                    fontSize: 18,
                                    color: isCompleted || isExpired
                                        ? Colors.grey
                                        : AppTheme.inkLight,
                                    decoration: isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 5),
                                    Text(
                                      task.description,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.nunito(
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 5,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        // Puntos (Muestra progreso real ej: 15/15)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isCompleted
                                                ? Colors.green.shade100
                                                : (isExpired
                                                      ? Colors.grey.shade300
                                                      : AppTheme.yellow),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            'Progreso: $currentScore/${task.targetScore}',
                                            style: GoogleFonts.nunito(
                                              fontWeight: FontWeight.bold,
                                              color: isCompleted
                                                  ? Colors.green.shade800
                                                  : AppTheme.inkLight,
                                            ),
                                          ),
                                        ),
                                        if (!isCompleted)
                                          Text(
                                            '🕒 Límite: $dueDateText',
                                            style: GoogleFonts.nunito(
                                              fontSize: 12,
                                              color: isExpired
                                                  ? Colors.red
                                                  : Colors.grey.shade600,
                                              fontWeight: isExpired
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: isMaestro
                                    ? const Icon(
                                        Icons.chevron_right,
                                        color: Colors.grey,
                                      )
                                    : isExpired && !isCompleted
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          '🔒',
                                          style: GoogleFonts.fredoka(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      )
                                    // 👇 BOTÓN REINTENTAR EN GRIS SI ESTÁ COMPLETADA
                                    : ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isCompleted
                                              ? Colors.grey.shade300
                                              : const Color(0xFF2ed573),
                                          foregroundColor: isCompleted
                                              ? Colors.grey.shade700
                                              : Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          elevation: isCompleted ? 0 : 2,
                                        ),
                                        onPressed: () {
                                          if (isOriginalGame) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Abriendo el juego original...',
                                                ),
                                              ),
                                            );
                                          } else {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const MiniGamesHubScreen(),
                                              ),
                                            );
                                          }
                                        },
                                        child: Text(
                                          isCompleted ? 'Reintentar' : 'Jugar',
                                          style: GoogleFonts.fredoka(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: isMaestro
              ? FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CreateTaskScreen(
                          classId: widget
                              .classId, // 👈 ¡AQUÍ ESTÁ LA SOLUCIÓN! Le pasamos el ID real
                        ),
                      ),
                    );
                  },
                  backgroundColor: AppTheme.pink,
                  icon: const Icon(Icons.add, color: AppTheme.inkLight),
                  label: Text(
                    'Nueva Tarea',
                    style: GoogleFonts.fredoka(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.inkLight,
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}
