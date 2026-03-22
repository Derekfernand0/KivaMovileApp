import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- MODELO DE LA TAREA (Preparado para Firestore) ---
class GameTask {
  final String id;
  final String classId;
  final String title;
  final String description;
  final String targetGameId;
  final int targetScore;
  final DateTime dueDate;

  GameTask({
    required this.id,
    required this.classId,
    required this.title,
    required this.description,
    required this.targetGameId,
    required this.targetScore,
    required this.dueDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'classId': classId,
      'title': title,
      'description': description,
      'targetGameId': targetGameId,
      'targetScore': targetScore,
      'dueDate': dueDate.toIso8601String(), // Guardamos la fecha como texto
    };
  }

  factory GameTask.fromMap(Map<String, dynamic> map, String docId) {
    return GameTask(
      id: docId,
      classId: map['classId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      targetGameId: map['targetGameId'] ?? '',
      targetScore: map['targetScore']?.toInt() ?? 0,
      dueDate: DateTime.parse(map['dueDate']),
    );
  }
}

// --- CONTROLADOR CONECTADO A FIREBASE ---
class TaskNotifier extends StateNotifier<List<GameTask>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _subscription;

  TaskNotifier() : super([]);

  // 👇 Escucha las tareas de una clase específica en TIEMPO REAL
  // 👇 Escucha las tareas de una clase específica en TIEMPO REAL
  void listenToTasks(String classId) {
    _subscription?.cancel(); // Cancelamos suscripciones anteriores

    print("📡 Intentando escuchar tareas para la clase: $classId");

    _subscription = _firestore
        .collection('tasks')
        .where('classId', isEqualTo: classId)
        .snapshots()
        .listen(
          (snapshot) {
            print(
              "✅ ÉXITO: Se encontraron ${snapshot.docs.length} tareas en Firebase.",
            );
            state = snapshot.docs
                .map((doc) => GameTask.fromMap(doc.data(), doc.id))
                .toList();
          },
          onError: (error) {
            // 🚨 AQUÍ ESTÁ LA MAGIA: Si Firebase nos bloquea, nos lo dirá aquí.
            print("🔥 ERROR FATAL AL ESCUCHAR TAREAS: $error");
          },
        );
  }

  // 👇 Escribir en Firebase
  Future<void> addTask({
    required String classId,
    required String title,
    required String description,
    required String targetGameId,
    required int targetScore,
    required DateTime dueDate,
  }) async {
    final newTask = GameTask(
      id: '',
      classId: classId,
      title: title,
      description: description,
      targetGameId: targetGameId,
      targetScore: targetScore,
      dueDate: dueDate,
    );
    await _firestore.collection('tasks').add(newTask.toMap());
  }

  // 👇 Actualizar en Firebase
  Future<void> updateTask(GameTask updatedTask) async {
    await _firestore
        .collection('tasks')
        .doc(updatedTask.id)
        .update(updatedTask.toMap());
  }

  // 👇 Borrar en Firebase
  Future<void> removeTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, List<GameTask>>((ref) {
  return TaskNotifier();
});
