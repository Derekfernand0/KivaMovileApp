import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/class_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  void _showCreateClassDialog(
    BuildContext context,
    WidgetRef ref,
    String hostId,
  ) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Crear Nueva Clase',
          style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: 'Nombre de la clase (ej. 4to Grado)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.pink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                try {
                  await ref
                      .read(classRepositoryProvider)
                      .createClass(name, hostId);
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: Text(
              'Crear',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showJoinClassDialog(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Unirse a una Clase',
          style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: codeController,
          maxLength: 5,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: 'Código de 5 letras',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(
                0xFF9BC5FF,
              ), // Azul claro de AppTheme.blue
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              final code = codeController.text.trim().toUpperCase();
              if (code.length == 5) {
                try {
                  await ref
                      .read(classRepositoryProvider)
                      .joinClass(code, userId);
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll('Exception: ', '')),
                    ),
                  );
                }
              }
            },
            child: Text(
              'Unirme',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold,
                color: AppTheme.inkLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final classesAsync = ref.watch(userClassesProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isMaestro = user.role == 'maestro';

    // 👇 Usamos el fondo de círculos web para darle consistencia a la app
    return AppTheme.buildWebBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent, // Transparente para ver el fondo
        // 👇 HEADER IDÉNTICO AL DE LAS CLASES (KIVA Multicolor)
        appBar: AppBar(
          backgroundColor: Colors.white.withOpacity(0.95),
          elevation: 4,
          iconTheme: const IconThemeData(color: AppTheme.inkLight),
          titleSpacing: 0,
          title: Row(
            children: [
              const SizedBox(width: 15),
              Image.asset(
                'assets/images/kiva logo.png',
                height: 35,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.shield_rounded,
                  color: AppTheme.lilac,
                  size: 28,
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
              const SizedBox(width: 8),
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
                      ),
                      Text(
                        "- Kid's Integrity, voz y Apoyo",
                        style: GoogleFonts.nunito(
                          color: const Color(0xFF6C3A9B),
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
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              tooltip: 'Cerrar Sesión',
              onPressed: () {
                ref.read(authRepositoryProvider).signOut();
                ref.invalidate(authStateProvider);
              },
            ),
          ],
        ),

        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- TARJETA DE BIENVENIDA ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppTheme.ringLight),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Hola, ${user.name}!',
                      style: GoogleFonts.fredoka(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.inkLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isMaestro
                          ? 'Panel de control del maestro.'
                          : 'Listo para aprender y jugar.',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        color: AppTheme.inkLight.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isMaestro ? AppTheme.lilac : AppTheme.pink,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            user.role.toUpperCase(),
                            style: GoogleFonts.fredoka(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // BOTÓN ACCIÓN PRINCIPAL (Crear o Unirse)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isMaestro
                                ? AppTheme.peach
                                : const Color(0xFF9BC5FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          onPressed: () {
                            if (isMaestro) {
                              _showCreateClassDialog(context, ref, user.uid);
                            } else {
                              _showJoinClassDialog(context, ref, user.uid);
                            }
                          },
                          icon: Icon(
                            isMaestro ? Icons.add : Icons.group_add,
                            color: AppTheme.inkLight,
                          ),
                          label: Text(
                            isMaestro ? 'Crear Clase' : 'Unirme a Clase',
                            style: GoogleFonts.fredoka(
                              color: AppTheme.inkLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 30),
              Text(
                'Tus Clases',
                style: GoogleFonts.fredoka(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.inkLight,
                ),
              ),
              const SizedBox(height: 16),

              // --- LISTA DE CLASES EN TIEMPO REAL ---
              Expanded(
                child: classesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) =>
                      Center(child: Text('Error al cargar clases: $error')),
                  data: (classes) {
                    if (classes.isEmpty) {
                      return Center(
                        child: Text(
                          isMaestro
                              ? 'No tienes clases aún.\n¡Presiona "Crear Clase" para empezar!'
                              : 'Aún no estás en ninguna clase.\nPídele el código a tu maestro.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ).animate().fadeIn(delay: 300.ms);
                    }

                    return ListView.builder(
                      itemCount: classes.length,
                      itemBuilder: (context, index) {
                        final c = classes[index];
                        return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              margin: const EdgeInsets.only(bottom: 15),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.lilac.withOpacity(
                                    0.5,
                                  ),
                                  child: const Icon(
                                    Icons.school,
                                    color: AppTheme.inkLight,
                                  ),
                                ),
                                title: Text(
                                  c.name,
                                  style: GoogleFonts.fredoka(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.inkLight,
                                  ),
                                ),
                                subtitle: Text(
                                  '${c.memberIds.length} miembros',
                                  style: GoogleFonts.nunito(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                trailing: isMaestro
                                    ? Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppTheme.yellow,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          'CÓDIGO: ${c.code}',
                                          style: GoogleFonts.fredoka(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.inkLight,
                                          ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: AppTheme.pink,
                                      ),
                                onTap: () {
                                  context.push('/class/${c.id}');
                                },
                              ),
                            )
                            .animate()
                            .fadeIn(
                              delay: Duration(milliseconds: 100 * index),
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
      ),
    );
  }
}
