import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Proveedor global para usarlo en cualquier juego
final scoreRepositoryProvider = Provider((ref) => FirebaseScoreRepository());

class FirebaseScoreRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Función genérica para guardar el puntaje de CUALQUIER juego
  Future<void> saveGameScore({
    required String userId,
    required String gameId,
    required String gameName,
    required int score,
  }) async {
    try {
      // Guardamos el historial de partidas dentro del documento del usuario
      await _firestore.collection('users').doc(userId).collection('scores').add(
        {
          'gameId': gameId,
          'gameName': gameName,
          'score': score,
          'playedAt':
              FieldValue.serverTimestamp(), // Guarda la fecha y hora exacta
        },
      );
    } catch (e) {
      throw Exception('Error al guardar el puntaje: $e');
    }
  }
}
