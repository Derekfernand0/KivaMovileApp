import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 👈 IMPORTANTE
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../games/presentation/screens/doors_game_screen.dart';
import '../../../games/presentation/screens/minigames_hub_screen.dart';
import '../../../games/presentation/screens/shawarma_game_screen.dart';
import '../../../games/presentation/screens/water_game_screen.dart';
import '../providers/class_provider.dart';
import 'class_members_screen.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../../../tasks/presentation/screens/create_task_screen.dart';
import '../../../tasks/presentation/screens/task_detail_screen.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taskProvider.notifier).listenToTasks(widget.classId);
    });
  }

  void _openAssignedGame(BuildContext context, String gameId) {
    switch (gameId) {
      case 'puertas':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const DoorsGameScreen()));
        return;
      case 'shawarma':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ShawarmaGameScreen()));
        return;
      case 'torre':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const WaterGameScreen()));
        return;
      default:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const MiniGamesHubScreen()));
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final classId = widget.classId;
    final user = ref.watch(authStateProvider).value;
    final classesAsync = ref.watch(userClassesProvider);
    final tasks = ref.watch(taskProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return classesAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (classes) {
        final classExists = classes.any((c) => c.id == classId);
        if (!classExists) {
          return const Scaffold(
            backgroundColor: Colors.transparent,
            body: SizedBox.shrink(),
          );
        }

        final currentClass = classes.firstWhere((c) => c.id == classId);
        final isMaestro =
            user.role == 'maestro' ||
            user.role == 'admin' ||
            currentClass.hostId == user.uid;

        return AppTheme.buildWebBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,

            // 👇 NUEVO HEADER CON LOGO E IMAGEN MULTICOLOR
            appBar: AppBar(
              backgroundColor: Colors.white.withOpacity(0.95),
              elevation: 4,
              iconTheme: const IconThemeData(color: AppTheme.inkLight),
              titleSpacing: 0,
              title: Row(
                children: [
                  const SizedBox(width: 10),
                  // Logo de KIVA
                  Image.asset(
                    'assets/images/kiva logo.png',
                    height: 35,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.shield_rounded,
                      color: AppTheme.lilac,
                      size: 28,
                    ),
                  ).animate().scale(
                    duration: 500.ms,
                    curve: Curves.easeOutBack,
                  ),

                  const SizedBox(width: 8),

                  // Textos (KIVA en colores web CSS)
                  Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.fredoka(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              children: const [
                                TextSpan(
                                  text: 'K',
                                  style: TextStyle(color: Color(0xFFFFD88A)),
                                ), // Amarillo CSS
                                TextSpan(
                                  text: 'I',
                                  style: TextStyle(color: Color(0xFFFFA8A8)),
                                ), // Rosa CSS
                                TextSpan(
                                  text: 'V',
                                  style: TextStyle(color: Color(0xFFB8A0FF)),
                                ), // Morado CSS
                                TextSpan(
                                  text: 'A',
                                  style: TextStyle(color: Color(0xFF9BC5FF)),
                                ), // Azul CSS
                              ],
                            ),
                          ),
                          Text(
                            "- Kid's Integrity, voz y Apoyo",
                            style: GoogleFonts.nunito(
                              color: const Color(
                                0xFF6C3A9B,
                              ), // Morado oscuro de la marca
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 400.ms)
                      .slideX(begin: 0.1, end: 0),
                ],
              ),
              actions: [
                if (isMaestro)
                  IconButton(
                    icon: const Icon(Icons.people, color: AppTheme.inkLight),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClassMembersScreen(
                            classId: currentClass.id,
                            className: currentClass.name,
                            hostId: currentClass.hostId,
                          ),
                        ),
                      );
                    },
                  ),
                IconButton(
                  icon: const Icon(
                    Icons.info_outline,
                    color: AppTheme.inkLight,
                  ),
                  onPressed: () {},
                ),
              ],
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
                            const Icon(
                              Icons.school,
                              size: 48,
                              color: AppTheme.ringLight,
                            ),
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
                      )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.2, end: 0),

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
                        : StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .snapshots(),
                            builder: (context, userSnapshot) {
                              final userData =
                                  userSnapshot.data?.data()
                                      as Map<String, dynamic>? ??
                                  {};

                              return ListView.builder(
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

                                  int currentScore =
                                      (userData['${task.targetGameId}Score']
                                              as num?)
                                          ?.toInt() ??
                                      0;
                                  bool isCompleted =
                                      !isMaestro &&
                                      (currentScore >= task.targetScore);
                                  String dueDateText =
                                      '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}';

                                  return Card(
                                        margin: const EdgeInsets.only(
                                          bottom: 15,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        elevation: isCompleted ? 0 : 2,
                                        color: isCompleted
                                            ? Colors.grey.shade100
                                            : Colors.white,
                                        child: ListTile(
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    TaskDetailScreen(
                                                      task: task,
                                                      isMaestro: isMaestro,
                                                      isOriginalGame:
                                                          isOriginalGame,
                                                      isExpired: isExpired,
                                                      isCompleted: isCompleted,
                                                      currentClass:
                                                          currentClass,
                                                    ),
                                              ),
                                            );
                                          },
                                          contentPadding: const EdgeInsets.all(
                                            15,
                                          ),
                                          leading: CircleAvatar(
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: isCompleted
                                                          ? Colors
                                                                .green
                                                                .shade100
                                                          : (isExpired
                                                                ? Colors
                                                                      .grey
                                                                      .shade300
                                                                : AppTheme
                                                                      .yellow),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      'Progreso: $currentScore/${task.targetScore}',
                                                      style: GoogleFonts.nunito(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: isCompleted
                                                            ? Colors
                                                                  .green
                                                                  .shade800
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
                                                            : Colors
                                                                  .grey
                                                                  .shade600,
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
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    '🔒',
                                                    style: GoogleFonts.fredoka(
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                  ),
                                                )
                                              : ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: isCompleted
                                                        ? Colors.grey.shade300
                                                        : const Color(
                                                            0xFF2ed573,
                                                          ),
                                                    foregroundColor: isCompleted
                                                        ? Colors.grey.shade700
                                                        : Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                    elevation: isCompleted
                                                        ? 0
                                                        : 2,
                                                  ),
                                                  onPressed: () {
                                                    if (isOriginalGame) {
                                                      _openAssignedGame(
                                                        context,
                                                        task.targetGameId,
                                                      );
                                                    } else {
                                                      Navigator.of(
                                                        context,
                                                      ).push(
                                                        MaterialPageRoute(
                                                          builder: (_) =>
                                                              const MiniGamesHubScreen(),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  child: Text(
                                                    isCompleted
                                                        ? 'Reintentar'
                                                        : 'Jugar',
                                                    style: GoogleFonts.fredoka(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                        ),
                                      )
                                      .animate()
                                      .fadeIn(
                                        delay: Duration(
                                          milliseconds: 100 * index,
                                        ),
                                        duration: 400.ms,
                                      )
                                      .slideX(begin: 0.1, end: 0);
                                },
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
                          builder: (context) =>
                              CreateTaskScreen(classId: widget.classId),
                        ),
                      );
                    },
                    backgroundColor: const Color(
                      0xFF6C3A9B,
                    ), // AppTheme.kivaPurple
                    icon: const Icon(Icons.add_task, color: Colors.white),
                    label: Text(
                      'Nueva Tarea',
                      style: GoogleFonts.fredoka(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ).animate().scale(
                    delay: 800.ms,
                    duration: 500.ms,
                    curve: Curves.easeOutBack,
                  )
                : null,
          ),
        );
      },
    );
  }
}
