import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/models/class_model.dart';

class FirebaseClassRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Genera un código de 5 caracteres al azar
  String _generateShortCode() {
    const chars =
        'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Quitamos O, 0, 1, I para evitar confusiones
    Random rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(5, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }

  // 1. Maestro crea una clase
  Future<AppClass> createClass(String name, String hostId) async {
    final String code = _generateShortCode();

    // Verificamos que el código no exista (poco probable, pero buena práctica)
    final existing = await _firestore
        .collection('classes')
        .where('code', isEqualTo: code)
        .get();
    if (existing.docs.isNotEmpty) {
      return createClass(name, hostId); // Reintenta si existe
    }

    final docRef = _firestore.collection('classes').doc();
    final newClass = AppClass(
      id: docRef.id,
      name: name,
      code: code,
      hostId: hostId,
      memberIds: [hostId], // El maestro también es miembro
    );

    await docRef.set(newClass.toMap());
    return newClass;
  }

  // 2. Alumno se une a una clase
  Future<void> joinClass(String code, String userId) async {
    final query = await _firestore
        .collection('classes')
        .where('code', isEqualTo: code.toUpperCase())
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Código de clase no válido.');
    }

    final classDoc = query.docs.first;
    List<String> currentMembers = List<String>.from(
      classDoc.data()['memberIds'] ?? [],
    );

    if (currentMembers.contains(userId)) {
      throw Exception('Ya estás en esta clase.');
    }

    currentMembers.add(userId);
    await classDoc.reference.update({'memberIds': currentMembers});
  }

  // 3. Obtener las clases a las que pertenece el usuario (en tiempo real)
  Stream<List<AppClass>> getUserClasses(String userId) {
    return _firestore
        .collection('classes')
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AppClass.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
