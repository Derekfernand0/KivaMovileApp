import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameTask {
  final String id;
  final String classId;
  final String title;
  final String description;
  final String targetGameId;
  final int targetScore;
  final DateTime dueDate;
  final DateTime createdAt; // 🔥 Agregado para el ordenamiento

  GameTask({
    required this.id,
    required this.classId,
    required this.title,
    required this.description,
    required this.targetGameId,
    required this.targetScore,
    required this.dueDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'classId': classId,
      'title': title,
      'description': description,
      'targetGameId': targetGameId,
      'targetScore': targetScore,
      'dueDate': dueDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
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
      // Si es una tarea vieja sin este campo, asume la fecha actual para no fallar
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
}

class TaskNotifier extends StateNotifier<List<GameTask>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _subscription;

  TaskNotifier() : super([]);

  void listenToTasks(String classId) {
    _subscription?.cancel();

    print("📡 Escuchando tareas para la clase: $classId");

    _subscription = _firestore
        .collection('tasks')
        .where('classId', isEqualTo: classId)
        .snapshots()
        .listen(
          (snapshot) {
            final tasks = snapshot.docs
                .map((doc) => GameTask.fromMap(doc.data(), doc.id))
                .toList();

            // 🔥 ORDENAMOS LAS TAREAS: La más reciente creada irá hasta arriba
            tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            state = tasks;
          },
          onError: (error) {
            print("🔥 ERROR FATAL AL ESCUCHAR TAREAS: $error");
          },
        );
  }

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
      createdAt: DateTime.now(), // 🔥 Fecha exacta de creación
    );
    await _firestore.collection('tasks').add(newTask.toMap());
  }

  Future<void> updateTask(GameTask updatedTask) async {
    await _firestore
        .collection('tasks')
        .doc(updatedTask.id)
        .update(updatedTask.toMap());
  }

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
