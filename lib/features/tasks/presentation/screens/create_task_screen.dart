import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/task_provider.dart';
// 👇 Importamos la base de datos de Quizzes que creamos en el paso anterior
import '../../../quizzes/data/premade_quizzes/premade_quizzes_db.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  final String classId;
  final GameTask? taskToEdit;

  const CreateTaskScreen({super.key, this.classId = '', this.taskToEdit});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  // 👇 Control del nuevo interruptor (Minijuego vs Quiz)
  String _taskType = 'game'; // 'game' o 'quiz'

  String _selectedGameId = 'rompe_silencio';
  String? _selectedQuizId; // Para guardar el ID del quiz seleccionado

  double _targetScore = 15;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));

  final Map<String, String> _availableGames = {
    'puertas': '🚪 Las Puertas de la Confianza',
    'torre': '🏗️ La Gran Torre de Isla',
    'shawarma': '🥙 El Shawarma Seguro',
    'rompe_silencio': '🎤 Rompe el Silencio',
    'emocionometro': '🧭 Emocionómetro',
    'semaforo_situaciones': '🚦 Semáforo Situaciones',
    'semaforo_cuerpo': '🚦 Semáforo del Cuerpo',
    'detecta_engano': '📱 Detecta el Engaño',
    'circulo_seguro': '🛡️ Mi Círculo Seguro',
    'cuerpo_reglas': '🙅‍♀️ Mi cuerpo, mis reglas',
  };

  final Map<String, String> _gameImages = {
    'puertas': 'assets/images/PELRC.png',
    'torre': 'assets/images/islalogo.png',
    'shawarma': 'assets/images/SHWS.png',
  };

  @override
  void initState() {
    super.initState();

    // Seleccionamos el primer quiz por defecto si la base de datos no está vacía
    if (premadeQuizzesDatabase.isNotEmpty) {
      _selectedQuizId = premadeQuizzesDatabase.first.id;
    }

    if (widget.taskToEdit != null) {
      _titleController.text = widget.taskToEdit!.title;
      _descController.text = widget.taskToEdit!.description;
      _targetScore = widget.taskToEdit!.targetScore.toDouble();
      _selectedDate = widget.taskToEdit!.dueDate;

      // 👇 Detectamos si la tarea que estamos editando era un Quiz o un Juego
      if (widget.taskToEdit!.targetGameId.startsWith('quiz_')) {
        _taskType = 'quiz';
        _selectedQuizId = widget.taskToEdit!.targetGameId;
      } else {
        _taskType = 'game';
        _selectedGameId = widget.taskToEdit!.targetGameId;
      }
    }
  }

  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _submitTask() async {
    if (_formKey.currentState!.validate()) {
      // Validamos que si eligió Quiz, realmente haya un quiz seleccionado
      if (_taskType == 'quiz' && _selectedQuizId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona un Quiz'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 👇 Determinamos el ID final a guardar
      final String finalTargetId = _taskType == 'game'
          ? _selectedGameId
          : _selectedQuizId!;

      try {
        if (widget.taskToEdit != null) {
          final updatedTask = GameTask(
            id: widget.taskToEdit!.id,
            classId: widget.classId,
            title: _titleController.text,
            description: _descController.text,
            targetGameId: finalTargetId, // Guardamos el juego o el quiz
            targetScore: _targetScore.toInt(),
            dueDate: _selectedDate,
            createdAt: widget.taskToEdit!.createdAt,
          );

          await ref.read(taskProvider.notifier).updateTask(updatedTask);

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '✅ Tarea actualizada',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.blue,
            ),
          );
        } else {
          await ref
              .read(taskProvider.notifier)
              .addTask(
                classId: widget.classId,
                title: _titleController.text,
                description: _descController.text,
                targetGameId: finalTargetId, // Guardamos el juego o el quiz
                targetScore: _targetScore.toInt(),
                dueDate: _selectedDate,
              );

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '✅ Tarea asignada',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Color(0xFF2ed573),
            ),
          );
        }

        if (!mounted) return;
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al guardar: $e',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} a las ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.fredoka(
      color: AppTheme.inkLight,
      fontWeight: FontWeight.bold,
    );
    final isEditing = widget.taskToEdit != null;

    return Scaffold(
      backgroundColor: AppTheme.paperLight,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Editar Tarea' : 'Nueva Tarea',
          style: GoogleFonts.nunito(
            color: AppTheme.inkLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.inkLight),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? '✏️ Editar Tarea' : '📝 Nueva Tarea',
                style: titleStyle.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 30),

              Text(
                'Título de la Tarea',
                style: titleStyle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Ej: Aprende a cuidarte',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Por favor ingresa un título' : null,
              ),
              const SizedBox(height: 20),

              // 👇 NUEVO INTERRUPTOR DE TIPO DE TAREA
              Text(
                'Tipo de Actividad',
                style: titleStyle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppTheme.lineLight),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _taskType = 'game'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _taskType == 'game'
                                ? const Color(0xFF2ed573)
                                : Colors.transparent, // Verde si está activo
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              '🎮 Minijuegos',
                              style: GoogleFonts.nunito(
                                color: _taskType == 'game'
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _taskType = 'quiz'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _taskType == 'quiz'
                                ? AppTheme.kivaPurple
                                : Colors.transparent, // Morado si está activo
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              '📝 Quizzes',
                              style: GoogleFonts.nunito(
                                color: _taskType == 'quiz'
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 👇 SECCIÓN DINÁMICA (Depende del interruptor)
              if (_taskType == 'game') ...[
                Text(
                  'Elige un Minijuego:',
                  style: titleStyle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedGameId,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: _availableGames.entries
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(
                            e.value,
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedGameId = value!),
                ),
                if (_gameImages.containsKey(_selectedGameId))
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          _gameImages[_selectedGameId]!,
                          height: 120,
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) => const SizedBox(),
                        ),
                      ),
                    ),
                  ),
              ] else ...[
                Text(
                  'Elige un Quiz KIVA prehecho:',
                  style: titleStyle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 8),
                if (premadeQuizzesDatabase.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Text(
                      '⚠️ No hay quizzes creados en la base de datos todavía.',
                      style: TextStyle(color: Colors.orange),
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    value: _selectedQuizId,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: premadeQuizzesDatabase
                        .map(
                          (q) => DropdownMenuItem(
                            value: q.id,
                            child: Text(
                              q.title,
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedQuizId = value),
                  ),

                const SizedBox(height: 15),
                // Botón visual preparado para el futuro
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    side: const BorderSide(
                      color: AppTheme.kivaPurple,
                      width: 2,
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'La creación de Quizzes Personalizados estará disponible muy pronto.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: AppTheme.kivaPurple,
                  ),
                  label: Text(
                    'Crear Quiz Personalizado (Próximamente)',
                    style: GoogleFonts.nunito(
                      color: AppTheme.kivaPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Resto del formulario...
              Text(
                'Fecha y Hora Límite',
                style: titleStyle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDateTime,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDateTime(_selectedDate),
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.inkLight,
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: AppTheme.lilac),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Puntos a conseguir:',
                    style: titleStyle.copyWith(fontSize: 16),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.yellow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_targetScore.toInt()} pts',
                      style: titleStyle,
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppTheme.lilac,
                  thumbColor: AppTheme.lilac,
                ),
                child: Slider(
                  value: _targetScore,
                  min: 5,
                  max: 60,
                  divisions: 11,
                  onChanged: (value) => setState(() => _targetScore = value),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Mensaje para los alumnos',
                style: titleStyle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Ej: Repasen lo visto en clase...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2c3e50),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                onPressed: _submitTask,
                icon: Icon(
                  isEditing ? Icons.save : Icons.send,
                  color: Colors.white,
                ),
                label: Text(
                  isEditing ? 'Guardar Cambios' : 'Asignar Tarea',
                  style: GoogleFonts.fredoka(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
