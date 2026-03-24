import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import 'student_stats_screen.dart';

class ClassMembersScreen extends StatefulWidget {
  final String classId;
  final String className;
  final String hostId;

  const ClassMembersScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.hostId,
  });

  @override
  State<ClassMembersScreen> createState() => _ClassMembersScreenState();
}

class _ClassMembersScreenState extends State<ClassMembersScreen> {
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  Future<void> _deleteClass() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 30,
            ),
            const SizedBox(width: 10),
            Text(
              '¿Borrar clase?',
              style: GoogleFonts.fredoka(color: AppTheme.inkLight),
            ),
          ],
        ),
        content: Text(
          'Esta acción es irreversible. Se eliminará la clase "${widget.className}" para todos los integrantes. ¿Estás absolutamente seguro?',
          style: GoogleFonts.nunito(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.nunito(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Sí, borrar clase',
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('classes')
            .doc(widget.classId)
            .delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Clase eliminada correctamente.'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al borrar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showAdminOptions(
    String memberId,
    String memberName,
    String currentRole,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        // Usamos un nombre diferente para el contexto
        bool isMaestro = currentRole == 'maestro' || currentRole == 'admin';

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Administrar a $memberName',
                  style: GoogleFonts.fredoka(
                    fontSize: 20,
                    color: AppTheme.inkLight,
                  ),
                ),
                const SizedBox(height: 20),

                ListTile(
                  leading: Icon(
                    isMaestro ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isMaestro ? Colors.orange : Colors.green,
                  ),
                  title: Text(
                    isMaestro ? 'Degradar a Alumno' : 'Promover a Maestro',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    isMaestro
                        ? 'Solo podrá ver y resolver tareas.'
                        : 'Podrá crear y editar tareas.',
                    style: GoogleFonts.nunito(fontSize: 14),
                  ),
                  onTap: () async {
                    // 👇 1. GUARDAMOS EL MENSAJERO ANTES DE CERRAR
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(bottomSheetContext); // Cerramos el menú

                    try {
                      String newRole = isMaestro ? 'alumno' : 'maestro';
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(memberId)
                          .update({'role': newRole});
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Rol actualizado a $newRole'),
                          backgroundColor: AppTheme.green,
                        ),
                      );
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
                const Divider(),

                ListTile(
                  leading: const Icon(Icons.person_remove, color: Colors.red),
                  title: Text(
                    'Expulsar de la clase',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  subtitle: Text(
                    'El usuario ya no verá esta clase.',
                    style: GoogleFonts.nunito(fontSize: 14),
                  ),
                  onTap: () async {
                    // 👇 1. GUARDAMOS EL MENSAJERO ANTES DE CERRAR
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(bottomSheetContext);

                    try {
                      // 👇 2. Le quitamos el classId al usuario
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(memberId)
                          .update({'classId': ''});

                      // 👇 3. LO BORRAMOS DEL CONTADOR DE LA CLASE (Esto arregla el problema de los números)
                      await FirebaseFirestore.instance
                          .collection('classes')
                          .doc(widget.classId)
                          .update({
                            'memberIds': FieldValue.arrayRemove([memberId]),
                          });

                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Usuario expulsado de la clase.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Error al expulsar: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isHost = currentUserId == widget.hostId;

    return Scaffold(
      backgroundColor: AppTheme.paperLight,
      appBar: AppBar(
        title: Text(
          'Integrantes',
          style: GoogleFonts.nunito(
            color: AppTheme.inkLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.inkLight),
        actions: [
          if (isHost)
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
              tooltip: 'Borrar Clase',
              onPressed: _deleteClass,
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('classId', isEqualTo: widget.classId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final members = snapshot.data?.docs ?? [];

          if (members.isEmpty) {
            return Center(
              child: Text(
                'Aún no hay alumnos en esta clase.',
                style: GoogleFonts.nunito(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: members.length,
            separatorBuilder: (_, __) => const SizedBox(height: 15),
            itemBuilder: (context, index) {
              final memberDoc = members[index];
              final memberData = memberDoc.data() as Map<String, dynamic>;

              final String memberName =
                  memberData['name'] ??
                  memberData['nombre'] ??
                  memberData['alias'] ??
                  'Sin nombre';
              final String memberRole = memberData['role'] ?? 'alumno';
              final bool isMemberAdmin =
                  memberRole == 'maestro' || memberRole == 'admin';

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: isMemberAdmin
                      ? BorderSide(
                          color: AppTheme.pink.withOpacity(0.5),
                          width: 2,
                        )
                      : BorderSide.none,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: isMemberAdmin
                        ? AppTheme.pink
                        : AppTheme.lilac,
                    radius: 25,
                    child: Text(
                      memberName[0].toUpperCase(),
                      style: GoogleFonts.fredoka(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        memberName,
                        style: GoogleFonts.fredoka(
                          fontSize: 18,
                          color: AppTheme.inkLight,
                        ),
                      ),
                      if (isMemberAdmin) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.verified_user,
                          color: AppTheme.pink,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(
                    isHost
                        ? 'Toca para estadísticas.\nMantén presionado para opciones.'
                        : 'Toca para ver estadísticas',
                    style: GoogleFonts.nunito(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.bar_chart,
                    color: AppTheme.pink,
                    size: 30,
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentStatsScreen(
                          studentId: memberDoc.id,
                          studentName: memberName,
                          studentData: memberData,
                        ),
                      ),
                    );
                  },

                  onLongPress: () {
                    if (isHost && currentUserId != memberDoc.id) {
                      _showAdminOptions(memberDoc.id, memberName, memberRole);
                    } else if (isHost && currentUserId == memberDoc.id) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'No puedes cambiar tu propio rol de creador.',
                          ),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
