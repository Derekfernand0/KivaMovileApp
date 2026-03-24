import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/premade_quizzes/premade_quizzes_db.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../games/data/firebase_score_repository.dart';

class QuizGameScreen extends ConsumerStatefulWidget {
  final String quizId;

  const QuizGameScreen({super.key, required this.quizId});

  @override
  ConsumerState<QuizGameScreen> createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends ConsumerState<QuizGameScreen> {
  int _currentIndex = 0;
  int _score = 0;
  bool _hasAnswered = false;
  int? _selectedOptionIndex;
  bool _isGameOver = false;

  late final quiz = premadeQuizzesDatabase.firstWhere(
    (q) => q.id == widget.quizId,
  );

  void _answerQuestion(int index) {
    if (_hasAnswered) return;

    setState(() {
      _hasAnswered = true;
      _selectedOptionIndex = index;
    });

    final currentQuestion = quiz.questions[_currentIndex];
    final isCorrect = index == currentQuestion.correctOptionIndex;

    if (isCorrect) {
      setState(() {
        _score += currentQuestion.points;
      });
    }

    // Esperamos un momento para que el alumno vea si acertó, luego avanzamos
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      if (_currentIndex < quiz.questions.length - 1) {
        setState(() {
          _currentIndex++;
          _hasAnswered = false;
          _selectedOptionIndex = null;
        });
      } else {
        _finishQuiz();
      }
    });
  }

  Future<void> _finishQuiz() async {
    setState(() {
      _isGameOver = true;
    });

    // Guardamos el puntaje en Firebase automáticamente
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      await ref
          .read(scoreRepositoryProvider)
          .saveGameScore(
            userId: user.uid,
            gameId:
                quiz.id, // Se guarda con el ID del quiz (ej: quiz_01_bullying)
            gameName: quiz.title,
            score: _score,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isGameOver) {
      return _buildVictoryScreen();
    }

    final currentQuestion = quiz.questions[_currentIndex];

    return AppTheme.buildWebBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            quiz.title,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.bold,
              color: AppTheme.inkLight,
            ),
          ),
          backgroundColor: Colors.white.withOpacity(0.9),
          elevation: 0,
          iconTheme: const IconThemeData(color: AppTheme.inkLight),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Indicador de Progreso y Puntos
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pregunta ${_currentIndex + 1} de ${quiz.questions.length}',
                      style: GoogleFonts.fredoka(
                        fontSize: 18,
                        color: AppTheme.kivaPurple,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.yellow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$_score Puntos',
                        style: GoogleFonts.fredoka(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.inkLight,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Tarjeta de la Pregunta
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.kivaBlue, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        currentQuestion.questionText,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(
                          fontSize: 22,
                          color: AppTheme.inkLight,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Vale ${currentQuestion.points} pts',
                        style: GoogleFonts.nunito(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ).animate(key: ValueKey(_currentIndex)).fadeIn().scale(),

                const SizedBox(height: 40),

                // Opciones
                Expanded(
                  child: ListView.builder(
                    itemCount: currentQuestion.options.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedOptionIndex == index;
                      final isCorrectOption =
                          index == currentQuestion.correctOptionIndex;

                      Color buttonColor = Colors.white;
                      Color textColor = AppTheme.inkLight;
                      Color borderColor = AppTheme.lineLight;

                      if (_hasAnswered) {
                        if (isCorrectOption) {
                          buttonColor = Colors.green.shade100;
                          textColor = Colors.green.shade800;
                          borderColor = Colors.green;
                        } else if (isSelected && !isCorrectOption) {
                          buttonColor = Colors.red.shade100;
                          textColor = Colors.red.shade800;
                          borderColor = Colors.red;
                        }
                      }

                      return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: InkWell(
                              onTap: () => _answerQuestion(index),
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: buttonColor,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: borderColor,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        currentQuestion.options[index],
                                        style: GoogleFonts.nunito(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                    if (_hasAnswered && isCorrectOption)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      )
                                    else if (_hasAnswered &&
                                        isSelected &&
                                        !isCorrectOption)
                                      const Icon(
                                        Icons.cancel,
                                        color: Colors.red,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .animate(delay: Duration(milliseconds: 100 * index))
                          .fadeIn()
                          .slideX();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVictoryScreen() {
    return AppTheme.buildWebBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                      Icons.workspace_premium,
                      size: 100,
                      color: AppTheme.yellow,
                    )
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 1200.ms, color: Colors.white)
                    .scale(duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: 20),
                Text(
                  '¡Quiz Terminado!',
                  style: GoogleFonts.fredoka(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.kivaBlue,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Conseguiste',
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  '$_score / ${quiz.totalPossibleScore} pts',
                  style: GoogleFonts.fredoka(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.pink,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.kivaPurple,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Regresar al Muro',
                    style: GoogleFonts.fredoka(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
