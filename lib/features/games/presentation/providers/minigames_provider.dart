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

  MiniGamesNotifier(this.ref) : super(MiniGamesState.initial()) {
    _loadScoresFromFirebase();
  }

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
          // 👇 Usamos num? y toInt() para evitar errores de lectura si Firebase lo guardó como double
          rompeSilencioScore:
              (data['rompeSilencioScore'] as num?)?.toInt() ?? 0,
          emocionometroScore:
              (data['emocionometroScore'] as num?)?.toInt() ?? 0,
          semaforoSituacionesScore:
              (data['semaforoSituacionesScore'] as num?)?.toInt() ?? 0,
          semaforoCuerpoScore:
              (data['semaforoCuerpoScore'] as num?)?.toInt() ?? 0,
          detectaEnganoScore:
              (data['detectaEnganoScore'] as num?)?.toInt() ?? 0,
          circuloSeguroScore:
              (data['circuloSeguroScore'] as num?)?.toInt() ?? 0,
          cuerpoReglasScore: (data['cuerpoReglasScore'] as num?)?.toInt() ?? 0,
        );
      }
    }
  }

  // 👇 FUNCIÓN CORREGIDA Y A PRUEBA DE BALAS
  Future<void> _saveScoreToFirebase(
    String exactScoreField,
    int newScore,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);

      try {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final snapshot = await transaction.get(docRef);
          if (!snapshot.exists) return;

          final data = snapshot.data() ?? {};

          // 1. Obtenemos la puntuación máxima actual
          int currentMax = (data[exactScoreField] as num?)?.toInt() ?? 0;
          int newMax = newScore > currentMax ? newScore : currentMax;

          // 2. Creamos el campo para el historial reemplazando la palabra "Score" por "History"
          String exactHistoryField = exactScoreField.replaceAll(
            'Score',
            'History',
          );
          List<dynamic> history = data[exactHistoryField] ?? [];
          history.add(newScore);

          // 3. Guardamos en Firebase usando merge:true para no afectar otros datos del alumno
          transaction.set(docRef, {
            exactScoreField: newMax,
            exactHistoryField: history,
          }, SetOptions(merge: true));
        });
      } catch (e) {
        print("🚨 Error al subir puntaje a Firebase: $e");
      }
    }
  }

  void addRompeSilencioScore(int pointsEarned) {
    final newScore = state.rompeSilencioScore + pointsEarned;
    state = state.copyWith(rompeSilencioScore: newScore);
    _saveScoreToFirebase(
      'rompeSilencioScore',
      newScore,
    ); // 👈 Ahora usa el nombre exacto
    _saveTotalScore();
  }

  void addEmocionometroScore(int pointsEarned) {
    final newScore = state.emocionometroScore + pointsEarned;
    state = state.copyWith(emocionometroScore: newScore);
    _saveScoreToFirebase('emocionometroScore', newScore);
    _saveTotalScore();
  }

  void completeEmocionometro() {
    if (state.emocionometroScore == 0) {
      addEmocionometroScore(5);
    }
  }

  void addSemaforoSituacionesScore(int pointsEarned) {
    final newScore = state.semaforoSituacionesScore + pointsEarned;
    state = state.copyWith(semaforoSituacionesScore: newScore);
    _saveScoreToFirebase('semaforoSituacionesScore', newScore);
    _saveTotalScore();
  }

  void completeSemaforoSituaciones() {
    if (state.semaforoSituacionesScore == 0) {
      addSemaforoSituacionesScore(15);
    }
  }

  void addSemaforoCuerpoScore(int pointsEarned) {
    final newScore = state.semaforoCuerpoScore + pointsEarned;
    state = state.copyWith(semaforoCuerpoScore: newScore);
    _saveScoreToFirebase('semaforoCuerpoScore', newScore);
    _saveTotalScore();
  }

  void addDetectaEnganoScore(int pointsEarned) {
    final newScore = state.detectaEnganoScore + pointsEarned;
    state = state.copyWith(detectaEnganoScore: newScore);
    _saveScoreToFirebase('detectaEnganoScore', newScore);
    _saveTotalScore();
  }

  void addCirculoSeguroScore(int pointsEarned) {
    final newScore = state.circuloSeguroScore + pointsEarned;
    state = state.copyWith(circuloSeguroScore: newScore);
    _saveScoreToFirebase('circuloSeguroScore', newScore);
    _saveTotalScore();
  }

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
