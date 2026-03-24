import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Proveedor global para usarlo en cualquier juego
final scoreRepositoryProvider = Provider((ref) => FirebaseScoreRepository());

class FirebaseScoreRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Función genérica para guardar el puntaje de CUALQUIER juego original
  Future<void> saveGameScore({
    required String userId,
    required String
    gameId, // Debe ser exactamente 'puertas', 'shawarma' o 'torre'
    required String gameName,
    required int score,
  }) async {
    try {
      final userDocRef = _firestore.collection('users').doc(userId);

      // 1. Guardamos el historial en la subcolección (para tener el registro exacto de cada jugada)
      await userDocRef.collection('scores').add({
        'gameId': gameId,
        'gameName': gameName,
        'score': score,
        'playedAt': FieldValue.serverTimestamp(),
      });

      // 👇 2. MAGIA: Actualizamos el puntaje máximo en el documento PRINCIPAL del usuario
      // Esto es lo que lee el Maestro en la pantalla de "Muro de Tareas"
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDocRef);
        if (!snapshot.exists) return;

        final data = snapshot.data() ?? {};

        // Creamos el nombre del campo exacto (ej. 'puertasScore')
        final String scoreField = '${gameId}Score';

        // Comparamos si el puntaje nuevo es mayor al que ya tenía guardado
        int currentMax = (data[scoreField] as num?)?.toInt() ?? 0;
        int newMax = score > currentMax ? score : currentMax;

        // Lo guardamos sin borrar los demás datos (merge: true)
        transaction.set(userDocRef, {
          scoreField: newMax,
        }, SetOptions(merge: true));
      });
    } catch (e) {
      throw Exception('Error al guardar el puntaje: $e');
    }
  }
}
