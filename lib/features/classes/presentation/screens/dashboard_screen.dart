import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/class_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  // --- MÉTODOS PARA MOSTRAR DIÁLOGOS ---

  // Diálogo para que el MAESTRO cree una clase
  void _showCreateClassDialog(
    BuildContext context,
    WidgetRef ref,
    String hostId,
  ) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardLight,
        title: Text(
          'Crear Nueva Clase',
          style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Nombre de la clase (ej. 4to Grado)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.pink),
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
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  // Diálogo para que el ALUMNO se una a una clase
  void _showJoinClassDialog(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardLight,
        title: Text(
          'Unirse a una Clase',
          style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: codeController,
          maxLength: 5,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            hintText: 'Código de 5 letras',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.blue),
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
            child: const Text('Unirme'),
          ),
        ],
      ),
    );
  }

  // --- INTERFAZ GRÁFICA ---

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    // Escuchamos las clases en tiempo real
    final classesAsync = ref.watch(userClassesProvider);

    if (user == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final isMaestro = user.role == 'maestro';

    return Scaffold(
      backgroundColor: AppTheme.paperLight,
      appBar: AppBar(
        title: Text(
          'KIVA Kids',
          style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.paperLight,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.inkLight),
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
                color: AppTheme.cardLight,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppTheme.lineLight),
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
                          ),
                        ),
                      ),
                      // BOTÓN ACCIÓN PRINCIPAL (Crear o Unirse)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isMaestro
                              ? AppTheme.peach
                              : AppTheme.blue,
                        ),
                        onPressed: () {
                          if (isMaestro) {
                            _showCreateClassDialog(context, ref, user.uid);
                          } else {
                            _showJoinClassDialog(context, ref, user.uid);
                          }
                        },
                        icon: Icon(isMaestro ? Icons.add : Icons.group_add),
                        label: Text(
                          isMaestro ? 'Crear Clase' : 'Unirme a Clase',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            Text(
              'Tus Clases',
              style: GoogleFonts.fredoka(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // --- LISTA DE CLASES EN TIEMPO REAL ---
            Expanded(
              child: classesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
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
                    );
                  }

                  return ListView.builder(
                    itemCount: classes.length,
                    itemBuilder: (context, index) {
                      final c = classes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          title: Text(
                            c.name,
                            style: GoogleFonts.fredoka(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text('${c.memberIds.length} miembros'),
                          trailing: isMaestro
                              ? Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.yellow,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'CÓDIGO: ${c.code}',
                                    style: GoogleFonts.fredoka(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            context.push('/class/${c.id}');
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
