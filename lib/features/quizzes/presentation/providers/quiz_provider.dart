import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/quiz_model.dart';
import '../../data/premade_quizzes/premade_quizzes_db.dart';

final quizRepositoryProvider = Provider((ref) => FirebaseQuizRepository());

class FirebaseQuizRepository {
  final _firestore = FirebaseFirestore.instance;

  // Guarda el quiz en Firebase y retorna su ID generado
  Future<String> createCustomQuiz(QuizModel quiz) async {
    final docRef = await _firestore.collection('quizzes').add(quiz.toMap());
    return docRef.id;
  }

  // Escucha los quizzes creados SOLO por el maestro actual
  Stream<List<QuizModel>> getMaestroQuizzes(String maestroId) {
    return _firestore
        .collection('quizzes')
        .where('hostId', isEqualTo: maestroId)
        .snapshots()
        .map((snapshot) {
          final customQuizzes = snapshot.docs
              .map((doc) => QuizModel.fromMap(doc.data(), doc.id))
              .toList();

          return [...premadeQuizzesDatabase, ...customQuizzes];
        });
  }
}

// Proveedor para listar quizzes en la pantalla de "Crear Tarea" (Solo para maestros)
final availableQuizzesProvider = StreamProvider<List<QuizModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  // Si es alumno, no necesita cargar la lista de maestros
  if (user == null || user.role == 'alumno')
    return Stream.value(premadeQuizzesDatabase);

  return ref.read(quizRepositoryProvider).getMaestroQuizzes(user.uid);
});

// 👇 NUEVO: Proveedor para cargar UN SOLO QUIZ (Ideal para que el Alumno pueda jugarlo)
final singleQuizProvider = FutureProvider.family<QuizModel?, String>((
  ref,
  quizId,
) async {
  // 1. Primero buscamos si es un quiz prehecho
  try {
    return premadeQuizzesDatabase.firstWhere((q) => q.id == quizId);
  } catch (_) {}

  // 2. Si no es prehecho, lo descargamos directo de Firebase usando su ID
  final doc = await FirebaseFirestore.instance
      .collection('quizzes')
      .doc(quizId)
      .get();
  if (doc.exists) {
    return QuizModel.fromMap(doc.data()!, doc.id);
  }
  return null; // Si de plano no existe
});
