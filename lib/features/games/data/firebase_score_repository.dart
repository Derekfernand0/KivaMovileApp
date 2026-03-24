import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final scoreRepositoryProvider = Provider((ref) => FirebaseScoreRepository());

class FirebaseScoreRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveGameScore({
    required String userId,
    required String gameId,
    required String gameName,
    required int score,
    Map<String, String>? openAnswers, // 👈 NUEVO: Recibe respuestas de texto
  }) async {
    try {
      final userDocRef = _firestore.collection('users').doc(userId);

      // 1. Guardamos el historial en la subcolección
      Map<String, dynamic> historyData = {
        'gameId': gameId,
        'gameName': gameName,
        'score': score,
        'playedAt': FieldValue.serverTimestamp(),
      };
      if (openAnswers != null && openAnswers.isNotEmpty) {
        historyData['openAnswers'] = openAnswers;
      }

      await userDocRef.collection('scores').add(historyData);

      // 2. Actualizamos el puntaje máximo en el documento PRINCIPAL
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDocRef);
        if (!snapshot.exists) return;

        final data = snapshot.data() ?? {};
        final String scoreField = '${gameId}Score';

        int currentMax = (data[scoreField] as num?)?.toInt() ?? 0;
        int newMax = score > currentMax ? score : currentMax;

        Map<String, dynamic> updateData = {scoreField: newMax};

        // 👇 Si hay respuestas abiertas, las guardamos en el perfil del alumno
        if (openAnswers != null && openAnswers.isNotEmpty) {
          updateData['${gameId}Answers'] = openAnswers;
        }

        transaction.set(userDocRef, updateData, SetOptions(merge: true));
      });
    } catch (e) {
      throw Exception('Error al guardar el puntaje: $e');
    }
  }
}
