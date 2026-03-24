import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/quiz_provider.dart';
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

  final _openAnswerController = TextEditingController();
  final Map<String, String> _openAnswers = {}; // 👈 Aquí guardaremos los textos

  void _answerMultipleChoice(int index, dynamic currentQuestion, dynamic quiz) {
    if (_hasAnswered) return;

    setState(() {
      _hasAnswered = true;
      _selectedOptionIndex = index;
    });

    if (index == currentQuestion.correctOptionIndex) {
      setState(() => _score += currentQuestion.points as int);
    }

    _advanceToNext(quiz);
  }

  void _answerOpenQuestion(dynamic currentQuestion, dynamic quiz) {
    if (_openAnswerController.text.trim().isEmpty || _hasAnswered) return;

    setState(() {
      _hasAnswered = true;
      _score += currentQuestion.points as int; // Puntos por participar
      // 👇 Guardamos lo que el alumno escribió
      _openAnswers[currentQuestion.questionText] = _openAnswerController.text
          .trim();
    });

    _advanceToNext(quiz);
  }

  void _advanceToNext(dynamic quiz) {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      if (_currentIndex < quiz.questions.length - 1) {
        setState(() {
          _currentIndex++;
          _hasAnswered = false;
          _selectedOptionIndex = null;
          _openAnswerController.clear();
        });
      } else {
        _finishQuiz(quiz);
      }
    });
  }

  Future<void> _finishQuiz(dynamic quiz) async {
    setState(() => _isGameOver = true);
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      await ref
          .read(scoreRepositoryProvider)
          .saveGameScore(
            userId: user.uid,
            gameId: quiz.id,
            gameName: quiz.title,
            score: _score,
            openAnswers: _openAnswers, // 👈 Enviamos los textos a Firebase
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizAsync = ref.watch(singleQuizProvider(widget.quizId));

    return quizAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (quiz) {
        if (quiz == null)
          return const Scaffold(
            body: Center(child: Text('Error: Este Quiz no existe.')),
          );
        if (_isGameOver) return _buildVictoryScreen(quiz);

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
                    const SizedBox(height: 20),

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

                    const SizedBox(height: 30),

                    if (currentQuestion.type == 'multiple_choice')
                      Expanded(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: currentQuestion.options.length,
                          itemBuilder: (context, index) {
                            final isSelected = _selectedOptionIndex == index;
                            final isCorrectOption =
                                index == currentQuestion.correctOptionIndex;

                            Color btnColor = Colors.white;
                            Color txtColor = AppTheme.inkLight;
                            Color brdColor = AppTheme.lineLight;

                            if (_hasAnswered) {
                              if (isCorrectOption) {
                                btnColor = Colors.green.shade100;
                                txtColor = Colors.green.shade800;
                                brdColor = Colors.green;
                              } else if (isSelected && !isCorrectOption) {
                                btnColor = Colors.red.shade100;
                                txtColor = Colors.red.shade800;
                                brdColor = Colors.red;
                              }
                            }

                            return Padding(
                                  padding: const EdgeInsets.only(bottom: 15),
                                  child: InkWell(
                                    onTap: () => _answerMultipleChoice(
                                      index,
                                      currentQuestion,
                                      quiz,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: btnColor,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: brdColor,
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
                                                color: txtColor,
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
                                .animate(
                                  delay: Duration(milliseconds: 100 * index),
                                )
                                .fadeIn()
                                .slideX();
                          },
                        ),
                      )
                    else
                      // 👇 SOLUCIÓN AL OVERFLOW: SingleChildScrollView
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              TextField(
                                controller: _openAnswerController,
                                maxLines: 6,
                                enabled: !_hasAnswered,
                                decoration: InputDecoration(
                                  hintText: 'Escribe tu respuesta aquí...',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                      color: AppTheme.lineLight,
                                    ),
                                  ),
                                ),
                              ).animate().fadeIn().slideY(),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _hasAnswered
                                      ? Colors.green
                                      : AppTheme.kivaPurple,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                    horizontal: 30,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                onPressed: _hasAnswered
                                    ? null
                                    : () => _answerOpenQuestion(
                                        currentQuestion,
                                        quiz,
                                      ),
                                icon: Icon(
                                  _hasAnswered ? Icons.check : Icons.send,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  _hasAnswered
                                      ? 'Respuesta Enviada'
                                      : 'Enviar Respuesta',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ).animate().fadeIn(delay: 300.ms),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVictoryScreen(dynamic quiz) {
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
                    .animate(onPlay: (c) => c.repeat())
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
