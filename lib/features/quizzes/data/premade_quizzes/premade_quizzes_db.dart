import '../../domain/models/quiz_model.dart';

// 📚 CATÁLOGO GLOBAL DE QUIZZES
final List<QuizModel> premadeQuizzesDatabase = [
  QuizModel(
    id: 'quiz_01_bullying',
    title: 'Conceptos Básicos de KIVA',
    description:
        'Un quiz rápido para evaluar qué tanto saben los alumnos sobre el respeto y KIVA.',
    isPremade: true,
    questions: [
      QuizQuestion(
        questionText:
            '¿Qué debes hacer si ves a alguien molestando a un compañero?',
        options: [
          'Unirme a la burla',
          'Ignorarlo',
          'Avisar a un maestro o adulto de confianza',
          'Reírme',
        ],
        correctOptionIndex: 2,
        points: 10, // 👈 Esta vale 10 puntos
      ),
      QuizQuestion(
        questionText:
            'Mi cuerpo es solo mío y nadie debe tocarlo si no quiero.',
        options: ['Verdadero', 'Falso'],
        correctOptionIndex: 0,
        points: 15, // 👈 Esta vale 15 puntos por ser más importante
      ),
    ],
  ),
];
