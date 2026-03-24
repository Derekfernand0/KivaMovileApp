import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/quiz_model.dart';
import '../providers/quiz_provider.dart';

// Objeto mutable local para construir la UI antes de enviarla
class _MutableQuestion {
  TextEditingController questionText = TextEditingController();
  String type = 'multiple_choice';
  List<TextEditingController> options = [
    TextEditingController(text: 'Opción 1'),
    TextEditingController(text: 'Opción 2'),
  ];
  int correctIndex = 0;
  double points = 10;
}

class CreateCustomQuizScreen extends ConsumerStatefulWidget {
  const CreateCustomQuizScreen({super.key});

  @override
  ConsumerState<CreateCustomQuizScreen> createState() =>
      _CreateCustomQuizScreenState();
}

class _CreateCustomQuizScreenState
    extends ConsumerState<CreateCustomQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  final List<_MutableQuestion> _questions = [
    _MutableQuestion(),
  ]; // Iniciamos con 1 pregunta
  bool _isLoading = false;

  void _addQuestion() {
    setState(() {
      _questions.add(_MutableQuestion());
    });
  }

  void _removeQuestion(int index) {
    if (_questions.length > 1) {
      setState(() {
        _questions.removeAt(index);
      });
    }
  }

  Future<void> _saveQuiz() async {
    if (!_formKey.currentState!.validate()) return;

    // Validación extra: Que las preguntas tengan texto
    for (var q in _questions) {
      if (q.questionText.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todas las preguntas deben tener texto.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authStateProvider).value;

      // Convertimos los objetos mutables al Modelo oficial
      final List<QuizQuestion> finalQuestions = _questions.map((q) {
        return QuizQuestion(
          questionText: q.questionText.text.trim(),
          type: q.type,
          points: q.points.toInt(),
          correctOptionIndex: q.correctIndex,
          options: q.type == 'multiple_choice'
              ? q.options.map((o) => o.text.trim()).toList()
              : [],
        );
      }).toList();

      final newQuiz = QuizModel(
        id: '', // Lo genera Firebase
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        questions: finalQuestions,
        hostId: user!.uid,
      );

      final newQuizId = await ref
          .read(quizRepositoryProvider)
          .createCustomQuiz(newQuiz);

      if (!mounted) return;
      Navigator.pop(
        context,
        newQuizId,
      ); // Regresamos el ID a la pantalla de Tareas
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.fredoka(
      color: AppTheme.inkLight,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      backgroundColor: AppTheme.paperLight,
      appBar: AppBar(
        title: Text(
          'Crear Quiz Personalizado',
          style: GoogleFonts.nunito(
            color: AppTheme.inkLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppTheme.inkLight),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // DATOS GENERALES
            Text('Datos del Quiz', style: titleStyle.copyWith(fontSize: 22)),
            const SizedBox(height: 10),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Título (Ej. Examen de KIVA)',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              validator: (v) => v!.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _descController,
              decoration: InputDecoration(
                hintText: 'Descripción breve',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              validator: (v) => v!.isEmpty ? 'Requerido' : null,
            ),
            const Divider(height: 40, thickness: 2),

            // LISTA DE PREGUNTAS
            Text('Preguntas', style: titleStyle.copyWith(fontSize: 22)),
            const SizedBox(height: 15),

            ..._questions.asMap().entries.map((entry) {
              int idx = entry.key;
              _MutableQuestion q = entry.value;

              return Card(
                margin: const EdgeInsets.only(bottom: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pregunta ${idx + 1}',
                            style: titleStyle.copyWith(
                              fontSize: 18,
                              color: AppTheme.kivaBlue,
                            ),
                          ),
                          if (_questions.length > 1)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeQuestion(idx),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: q.questionText,
                        decoration: InputDecoration(
                          hintText: 'Escribe la pregunta...',
                          filled: true,
                          fillColor: AppTheme.paperLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // TIPO Y PUNTOS
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: q.type,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppTheme.paperLight,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'multiple_choice',
                                  child: Text('Opciones Cerradas'),
                                ),
                                DropdownMenuItem(
                                  value: 'open',
                                  child: Text('Respuesta Abierta'),
                                ),
                              ],
                              onChanged: (val) => setState(() => q.type = val!),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 15,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.yellow,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${q.points.toInt()} pts',
                              style: titleStyle,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: q.points,
                        min: 5,
                        max: 50,
                        divisions: 9,
                        activeColor: AppTheme.lilac,
                        onChanged: (val) => setState(() => q.points = val),
                      ),

                      // OPCIONES (Solo si es cerrada)
                      if (q.type == 'multiple_choice') ...[
                        const SizedBox(height: 10),
                        Text(
                          'Opciones (Selecciona la correcta):',
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...q.options.asMap().entries.map((optEntry) {
                          int oIdx = optEntry.key;
                          return Row(
                            children: [
                              Radio<int>(
                                value: oIdx,
                                groupValue: q.correctIndex,
                                activeColor: Colors.green,
                                onChanged: (val) =>
                                    setState(() => q.correctIndex = val!),
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller: q.options[oIdx],
                                  decoration: InputDecoration(
                                    hintText: 'Opción ${oIdx + 1}',
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                              if (q.options.length > 2)
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () => setState(() {
                                    q.options.removeAt(oIdx);
                                    if (q.correctIndex >= q.options.length)
                                      q.correctIndex = 0;
                                  }),
                                ),
                            ],
                          );
                        }),
                        if (q.options.length < 5)
                          TextButton.icon(
                            onPressed: () => setState(
                              () => q.options.add(
                                TextEditingController(text: 'Nueva Opción'),
                              ),
                            ),
                            icon: const Icon(Icons.add),
                            label: const Text('Agregar Opción'),
                          ),
                      ] else ...[
                        // Mensaje informativo para respuesta abierta
                        Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info, color: Colors.blue),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'El alumno escribirá libremente. Los puntos se le asignarán automáticamente por participar.',
                                  style: GoogleFonts.nunito(
                                    color: Colors.blue.shade800,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),

            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                side: const BorderSide(color: AppTheme.kivaBlue, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: _addQuestion,
              icon: const Icon(Icons.add_circle, color: AppTheme.kivaBlue),
              label: Text(
                'Agregar otra pregunta',
                style: titleStyle.copyWith(color: AppTheme.kivaBlue),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.kivaPurple,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onPressed: _isLoading ? null : _saveQuiz,
          icon: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Icon(Icons.save, color: Colors.white),
          label: Text(
            'Guardar y Usar Quiz',
            style: GoogleFonts.fredoka(fontSize: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
