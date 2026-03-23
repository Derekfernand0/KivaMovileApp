import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/firebase_score_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MiniGamesState {
  final int emocionometroScore;
  final int semaforoSituacionesScore;
  final int semaforoCuerpoScore;
  final int detectaEnganoScore;
  final int circuloSeguroScore;
  final int cuerpoReglasScore;
  final int rompeSilencioScore;

  MiniGamesState({
    this.emocionometroScore = 0,
    this.semaforoSituacionesScore = 0,
    this.semaforoCuerpoScore = 0,
    this.detectaEnganoScore = 0,
    this.circuloSeguroScore = 0,
    this.cuerpoReglasScore = 0,
    this.rompeSilencioScore = 0,
  });

  factory MiniGamesState.initial() => MiniGamesState();

  int get totalScore =>
      emocionometroScore +
      semaforoSituacionesScore +
      semaforoCuerpoScore +
      detectaEnganoScore +
      circuloSeguroScore +
      cuerpoReglasScore +
      rompeSilencioScore;

  MiniGamesState copyWith({
    int? emocionometroScore,
    int? semaforoSituacionesScore,
    int? semaforoCuerpoScore,
    int? detectaEnganoScore,
    int? circuloSeguroScore,
    int? cuerpoReglasScore,
    int? rompeSilencioScore,
  }) {
    return MiniGamesState(
      emocionometroScore: emocionometroScore ?? this.emocionometroScore,
      semaforoSituacionesScore:
          semaforoSituacionesScore ?? this.semaforoSituacionesScore,
      semaforoCuerpoScore: semaforoCuerpoScore ?? this.semaforoCuerpoScore,
      detectaEnganoScore: detectaEnganoScore ?? this.detectaEnganoScore,
      circuloSeguroScore: circuloSeguroScore ?? this.circuloSeguroScore,
      cuerpoReglasScore: cuerpoReglasScore ?? this.cuerpoReglasScore,
      rompeSilencioScore: rompeSilencioScore ?? this.rompeSilencioScore,
    );
  }
}

final miniGamesProvider =
    StateNotifierProvider<MiniGamesNotifier, MiniGamesState>((ref) {
      return MiniGamesNotifier(ref);
    });

class MiniGamesNotifier extends StateNotifier<MiniGamesState> {
  final Ref ref;

  // 👇 1. Llama a la función de cargar datos apenas se inicie el provider
  MiniGamesNotifier(this.ref) : super(MiniGamesState.initial()) {
    _loadScoresFromFirebase();
  }

  // 👇 2. MÉTODO NUEVO: Descarga los puntos de Firebase al abrir la app
  Future<void> _loadScoresFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        state = state.copyWith(
          rompeSilencioScore: data['rompeSilencioScore'] ?? 0,
          emocionometroScore: data['emocionometroScore'] ?? 0,
          semaforoSituacionesScore: data['semaforoSituacionesScore'] ?? 0,
          semaforoCuerpoScore: data['semaforoCuerpoScore'] ?? 0,
          detectaEnganoScore: data['detectaEnganoScore'] ?? 0,
          circuloSeguroScore: data['circuloSeguroScore'] ?? 0,
          cuerpoReglasScore: data['cuerpoReglasScore'] ?? 0,
        );
      }
    }
  }

  // 👇 3. MÉTODO NUEVO: Sube los puntos a Firebase cada que el niño gana
  // 👇 MÉTODO ACTUALIZADO: Guarda la puntuación máxima y el historial real
  Future<void> _saveScoreToFirebase(String baseGameId, int newScore) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);

      // Usamos una Transacción para leer los datos actuales y actualizarlos de forma segura
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;

        final data = snapshot.data()!;

        // 1. Actualizamos la puntuación máxima (si la nueva es mayor)
        int currentMax = data['${baseGameId}Score'] ?? 0;
        int newMax = newScore > currentMax ? newScore : currentMax;

        // 2. Agregamos el nuevo intento al historial
        List<dynamic> history = data['${baseGameId}History'] ?? [];
        history.add(newScore);

        // 3. Guardamos ambos en Firebase
        transaction.update(docRef, {
          '${baseGameId}Score': newMax,
          '${baseGameId}History': history,
        });
      });
    }
  }

  // 1. Rompe el Silencio (Decisiones e Historias)
  void addRompeSilencioScore(int pointsEarned) {
    final newScore = state.rompeSilencioScore + pointsEarned;
    state = state.copyWith(rompeSilencioScore: newScore);
    _saveScoreToFirebase('rompeSilencioScore', newScore);
    _saveTotalScore();
  }

  void addEmocionometroScore(int pointsEarned) {
    final newScore = state.emocionometroScore + pointsEarned;
    state = state.copyWith(emocionometroScore: newScore);
    _saveScoreToFirebase('emocionometroScore', newScore);
    _saveTotalScore();
  }

  // Compatibilidad con pantallas existentes
  void completeEmocionometro() {
    if (state.emocionometroScore == 0) {
      addEmocionometroScore(5);
    }
  }

  // 3. Semáforo de Situaciones
  void addSemaforoSituacionesScore(int pointsEarned) {
    final newScore = state.semaforoSituacionesScore + pointsEarned;
    state = state.copyWith(semaforoSituacionesScore: newScore);
    _saveScoreToFirebase('semaforoSituacionesScore', newScore);
    _saveTotalScore();
  }

  // Compatibilidad con pantallas existentes
  void completeSemaforoSituaciones() {
    if (state.semaforoSituacionesScore == 0) {
      addSemaforoSituacionesScore(15);
    }
  }

  // 4. Semáforo del Cuerpo
  void addSemaforoCuerpoScore(int pointsEarned) {
    final newScore = state.semaforoCuerpoScore + pointsEarned;
    state = state.copyWith(semaforoCuerpoScore: newScore);
    _saveScoreToFirebase('semaforoCuerpoScore', newScore);
    _saveTotalScore();
  }

  // 5. Detecta el Engaño (Simulador de Chat)
  void addDetectaEnganoScore(int pointsEarned) {
    final newScore = state.detectaEnganoScore + pointsEarned;
    state = state.copyWith(detectaEnganoScore: newScore);
    _saveScoreToFirebase('detectaEnganoScore', newScore);
    _saveTotalScore();
  }

  // 6. Mi Círculo Seguro
  void addCirculoSeguroScore(int pointsEarned) {
    final newScore = state.circuloSeguroScore + pointsEarned;
    state = state.copyWith(circuloSeguroScore: newScore);
    _saveScoreToFirebase('circuloSeguroScore', newScore);
    _saveTotalScore();
  }

  // 7. Mi cuerpo, mis reglas
  void addCuerpoReglasScore(int pointsEarned) {
    final newScore = state.cuerpoReglasScore + pointsEarned;
    state = state.copyWith(cuerpoReglasScore: newScore);
    _saveScoreToFirebase('cuerpoReglasScore', newScore);
    _saveTotalScore();
  }

  Future<void> _saveTotalScore() async {
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      await ref
          .read(scoreRepositoryProvider)
          .saveGameScore(
            userId: user.uid,
            gameId: 'game_04_minigames',
            gameName: 'Centro de Exploración',
            score: state.totalScore,
          );
    }
  }
}
